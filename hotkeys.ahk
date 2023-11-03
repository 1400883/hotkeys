  ; #singleinstance, force
  ; HotkeyNavigation.Activate()
  ; HotkeyNavigation.Deactivate()
; return

class HotkeyNavigation
{
  #maxthreadsperhotkey, 1

  #if !HotkeyNavigation.hotkeys.isAltGrDown && !winactive("ahk_exe VirtualBoxVM.exe")
  #if HotkeyNavigation.hotkeys.isAltGrDown && !winactive("ahk_exe VirtualBoxVM.exe")
  #if

  static hotkeys := {
  (Join
    activation: {
      on: "~lctrl & ralt",
      off: "~lctrl & ralt up"
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

        q: "esc",

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

    sendinput % "{blind}{lalt up}"
    
    if (!HotkeyNavigation.isNavigationActive)
    {
      ; Setup AltGr detection hotkeys
      altGrFunc := HotkeyNavigation.AltGrSwitch.Bind(this)
      
      ; Setup replacement navigation hotkeys
      hotkey, if, !HotkeyNavigation.hotkeys.isAltGrDown && !winactive("ahk_exe VirtualBoxVM.exe")
      ; ---------------------------------------------------------------------------------
        hotkey, % HotkeyNavigation.hotkeys.activation.on, % altGrFunc
      ; ---------------------------------------------------------------------------------
      hotkey, if


      hotkey, if, HotkeyNavigation.hotkeys.isAltGrDown && !winactive("ahk_exe VirtualBoxVM.exe")
      ; ---------------------------------------------------------------------------------
        hotkey, % HotkeyNavigation.hotkeys.activation.off, % altGrFunc, P101
        
        for hotkeyType, hotkeys in HotkeyNavigation.hotkeys.navigation
        {
          isRawVirtualKey := hotkeyType == "raw"

          for sourceHotkey, targetHotkey in hotkeys
          {
            hotkeyExecuteFunc := HotkeyNavigation.ExecuteNavigationHotkey
                .Bind(this, sourceHotkey, targetHotkey, isRawVirtualKey)

            hotkeyTestFunc := HotkeyNavigation.ShouldNavigate.Bind(this)
            hotkey, if, % hotkeyTestFunc
            hotkey, % (isRawVirtualKey ? "" : "*") sourceHotkey, % hotkeyExecuteFunc, P100
          }
        }

        hotkey, if, HotkeyNavigation.hotkeys.isAltGrDown && !winactive("ahk_exe VirtualBoxVM.exe")

        for index, keyname in HotkeyNavigation.hotkeys.disable
        {
          hotkeyExecuteFunc := HotkeyNavigation.IgnoreKey.Bind(this, keyname)
          hotkey, % keyname, % hotkeyExecuteFunc
        }
      hotkey, if
      ; ---------------------------------------------------------------------------------
      HotkeyNavigation.isNavigationActive := true
    }
  }

  Deactivate() {
    if (HotkeyNavigation.isNavigationActive)
    {
      hotkey, if, !HotkeyNavigation.hotkeys.isAltGrDown && !winactive("ahk_exe VirtualBoxVM.exe")
      Hotkey, % HotkeyNavigation.hotkeys.activation.on, Off
      hotkey, if, HotkeyNavigation.hotkeys.isAltGrDown && !winactive("ahk_exe VirtualBoxVM.exe")
      Hotkey, % HotkeyNavigation.hotkeys.activation.off, Off
      hotkey, if

      HotkeyNavigation.isNavigationActive := false
    }
  }

  ShouldNavigate(fullHotkey) {
    return HotkeyNavigation.hotkeys.isAltGrDown && !winactive("ahk_exe VirtualBoxVM.exe") 
  }

  IgnoreKey(realKey) {
    return
  }

  ExecuteNavigationHotkey(keyPressed, virtualKeyToSend, isRawVirtualKey) {
    if (!getkeystate(keyPressed, "p") || !HotkeyNavigation.hotkeys.isAltGrDown)
    {
      return
    }

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

      if (!getkeystate(keyPressed, "p") || !HotkeyNavigation.hotkeys.isAltGrDown)
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
          sendinput % prefixPressDownCombination sendCompatibleHotkey prefixReleaseUpCombination
          ; sendinput % prefixPressDownCombination sendCompatibleHotkey prefixReleaseUpCombination
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
          sendinput % sendCompatibleHotkey
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

    ; tooltip % "Hotkey released", 20, 20, 2
    if (strlen(prefixReleaseUpCombination) > 0)
    {
      if ( !HotkeyNavigation.PrefixKeys.GetShiftUpIfReplacementDown() 
        && !HotkeyNavigation.PrefixKeys.GetAltUpIfReplacementDown())
      {
        ; Only release keys if Shift and LWin are not pressed.
        ; Otherwise, Shift and/or LWin will be released even 
        ; though being held down, typically causing an active 
        ; text (Shift) or multi-cursor (LWin) selection 
        ; operation to end prematurely.
        sendinput % "{blind}" prefixReleaseUpCombination
      }
    }
  }

  AltGrSwitch() {
    critical, on
    HotkeyNavigation.hotkeys.isAltGrDown := !HotkeyNavigation.hotkeys.isAltGrDown

    if (a_thishotkey == HotkeyNavigation.hotkeys.activation.on)
    {
    }
    else if (a_thishotkey == HotkeyNavigation.hotkeys.activation.off)
    {
      releaseKeys := ""
        . (getkeystate("lctrl", "p") ? "" : "{lctrl up}")
        . (getkeystate("alt", "p") ? "" : "{alt up}")
        . (getkeystate("shift", "p") ? "" : "{shift up}")
      ; msgbox % releaseKeys
      if (strlen(releaseKeys))
      {
        sendinput % "{blind}" releaseKeys 

        ; NOTE: This code MUST be here to make AHK running in VirtualBox
        ; successfully release the ctrl key.
        if (getkeystate("ctrl"))
        {
          ; send % "{blind}{ctrl up}"
        }
      }
    }
    else
    {
      throw Exception("Unrecognized AltGr switch hotkey: " a_thishotkey)
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
      return getkeystate("lwin", "p") ? "{alt down}" : ""
    }

    GetShiftUpIfReplacementDown() {
      return getkeystate("shift") ? "{shift up}" : ""
    }

    GetCtrlUpIfReplacementDown() {
      return getkeystate("lalt", "p") ? "{ctrl up}" : ""
    }

    GetAltUpIfReplacementDown() {
      return getkeystate("lwin", "p") ? "{alt up}" : ""
    }
  }
}