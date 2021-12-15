﻿  ; #singleinstance, force
  ; HotkeyNavigation.Activate()
  ; HotkeyNavigation.Deactivate()
; return

class HotkeyNavigation
{
  #maxthreadsperhotkey, 1

  #if !HotkeyNavigation.hotkeys.isAltGrDown && !winactive("ahk_exe VirtualBoxVM.exe")
  #if
  #if HotkeyNavigation.hotkeys.isAltGrDown && !winactive("ahk_exe VirtualBoxVM.exe")
  #if

  static hotkeys := {
  (Join
    activation: {
      on: "lctrl & ralt",
      off: "lctrl & ralt up"
    },
    disable: [
      "lalt"
    ],
    navigation: {
      unraw: {
        j: "delete",
        u: "insert",
        i: "home",
        k: "end",
        o: "pgup",
        l: "pgdn",

        å: "backspace",
        ö: "enter",

        s: "down",
        w: "up",
        a: "left",
        d: "right",

        c: "c",
        v: "v",
        x: "x",
        z: "z",
        y: "y",
        t: "t",
        f: "f",

        "'": "'",
        tab: "tab",
        space: "space"
      },
      raw: {
        7: "{",
        0: "}",
        8: "[",
        9: "]",
        "+": "\",
        2: "@",
        3: "£",
        4: "$",
        e: "€",
        "<": "|",
        "¨": "~"
      }
    },
    timing: {
      repeatDelayMs: 350,
      repeatRateMs: 0
    },
    isAltGrDown: false
  )}
  
  static isNavigationActive := false


  Activate(repeatRateMs := 20, repeatDelayMs := 350) {
    this.hotkeys.timing.repeatDelayMs := repeatDelayMs
    this.hotkeys.timing.repeatRateMs := repeatRateMs

    if (!HotkeyNavigation.isNavigationActive)
    {
      ; Setup AltGr detection hotkeys
      altGrFunc := HotkeyNavigation.AltGrSwitch.bind(this)
      

      ; Setup replacement navigation hotkeys
      hotkey, if, !HotkeyNavigation.hotkeys.isAltGrDown && !winactive("ahk_exe VirtualBoxVM.exe")
      hotkey, % HotkeyNavigation.hotkeys.activation.on, % altGrFunc
      hotkey, if
      hotkey, if, HotkeyNavigation.hotkeys.isAltGrDown && !winactive("ahk_exe VirtualBoxVM.exe")
      hotkey, % HotkeyNavigation.hotkeys.activation.off, % altGrFunc

      for hotkeyType, hotkeys in HotkeyNavigation.hotkeys.navigation
      {
        isRawVirtualKey := hotkeyType == "raw"

        for sourceHotkey, targetHotkey in hotkeys
        {
          hotkeyExecuteFunc := HotkeyNavigation
                                .ExecuteNavigationHotkey
                                .bind(this, sourceHotkey, targetHotkey, isRawVirtualKey)
          hotkey, % (isRawVirtualKey ? "" : "*") sourceHotkey, % hotkeyExecuteFunc
        }
      }

      for index, keyname in HotkeyNavigation.hotkeys.disable
      {
        hotkeyExecuteFunc := HotkeyNavigation.IgnoreKey.bind(this)
        hotkey, % keyname, % hotkeyExecuteFunc
      } 

      hotkey, if

      HotkeyNavigation.isNavigationActive := true
    }
  }

  IgnoreKey(realKey) {
    return
  }

  ExecuteNavigationHotkey(keyPressed, virtualKeyToSend, isRawVirtualKey) {
    this.hotkey.previouslyExecuted := keyPressed

    sendCompatibleHotkey := strlen(virtualKeyToSend) > 1 && !isRawVirtualKey
                              ? "{" virtualKeyToSend "}" : virtualKeyToSend


    loop
    {
      prefixPressDownCombination := ""
        . HotkeyNavigation.PrefixKeys.GetCtrlDownIfReplacementDown()
        . HotkeyNavigation.PrefixKeys.GetAltDownIfReplacementDown()
        . HotkeyNavigation.PrefixKeys.GetShiftDownIfReplacementDown()

      prefixReleaseUpCombination := ""
        . HotkeyNavigation.PrefixKeys.GetCtrlUpIfReplacementDown()
        . HotkeyNavigation.PrefixKeys.GetAltUpIfReplacementDown()
        . HotkeyNavigation.PrefixKeys.GetShiftUpIfReplacementDown()

      if (!getkeystate(keyPressed, "p"))
      {
        break
      }

      if (strlen(prefixPressDownCombination) > 0)
      {
        if (isRawVirtualKey)
        {
          sendinput % "{Raw}" sendCompatibleHotkey
        }
        else
        {
          sendplay % prefixPressDownCombination sendCompatibleHotkey
        }
      }
      else
      {
        if (isRawVirtualKey)
        {
          sendinput % "{Raw}" sendCompatibleHotkey
        }
        else
        {
          sendplay % sendCompatibleHotkey
        }
      }


      if (a_index == 1)
      {
        iterationStartTime := a_tickcount

        loop
        {
          elapsedIterationTime := a_tickcount - iterationStartTime

          if (  !getkeystate(keyPressed, "p")
              || elapsedIterationTime >= HotkeyNavigation.hotkeys.timing.repeatDelayMs)
          {
            break
          }
        }

      }
      else
      {
        iterationStartTime := a_tickcount

        loop
        {
          elapsedIterationTime := a_tickcount - iterationStartTime

          if (  !getkeystate(keyPressed, "p")
              || elapsedIterationTime >= HotkeyNavigation.hotkeys.timing.repeatRateMs)
          {
            break
          }
        }
      }
    }

    if (strlen(prefixReleaseUpCombination) > 0)
    {
      sendplay % "{blind}" prefixReleaseUpCombination
    }
  }

  AltGrSwitch() {
    HotkeyNavigation.hotkeys.isAltGrDown := !HotkeyNavigation.hotkeys.isAltGrDown

    if (a_thishotkey == HotkeyNavigation.hotkeys.activation.on)
    {
    }
    else if (a_thishotkey == HotkeyNavigation.hotkeys.activation.off)
    {
      releaseKeys := ""
        . (getkeystate("ctrl", "p") ? "" : "{ctrl up}")
        . (getkeystate("alt", "p") ? "" : "{alt up}")
        . (getkeystate("shift", "p") ? "" : "{shift up}")

      if (strlen(releaseKeys))
      {
        send % "{blind}" releaseKeys

        ; NOTE: This code MUST be here to make AHK running in VirtualBox
        ; successfully release the ctrl key.
        if (getkeystate("ctrl"))
        {
          send % "{blind}{ctrl up}"
        }
      }
    }
    else
    {
      throw Exception("Unrecognized AltGr switch hotkey: " a_thishotkey)
    }
  }

  Deactivate() {
    if (HotkeyNavigation.isNavigationActive)
    {
      Hotkey, % HotkeyNavigation.hotkeys.activation.on, Off
      Hotkey, % HotkeyNavigation.hotkeys.activation.off, Off
      HotkeyNavigation.isNavigationActive := false
    }
  }

  class PrefixKeys
  {
    GetShiftDownIfReplacementDown() {
      return getkeystate("shift") ? "{shift down}" : ""
    }

    GetCtrlDownIfReplacementDown() {
      return getkeystate("lalt", "p") ? "{ctrl down}" : ""
    }

    GetAltDownIfReplacementDown() {
      return getkeystate("lwin") ? "{alt down}" : ""
    }

    GetShiftUpIfReplacementDown() {
      return getkeystate("shift") ? "{shift up}" : ""
    }

    GetCtrlUpIfReplacementDown() {
      return getkeystate("lalt") ? "{ctrl up}" : ""
    }

    GetAltUpIfReplacementDown() {
      return getkeystate("lwin") ? "{alt up}" : ""
    }
  }
}
