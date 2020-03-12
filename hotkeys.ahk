#maxthreadsperhotkey, 2

lctrl & ralt:: 
  isAltGrDown := true
  if (!j) {

      j := "delete"
    , u := "insert"
    , i := "home"
    , k := "end"
    , o := "pgup"
    , l := "pgdn"

    , å := "backspace"
    , ö := "enter"

    , s := "down"
    , w := "up"
    , a := "left"
    , d := "right"

    , c := "c"
    , v := "v"
    , x := "x"
    , z := "z"
    , y := "y"

    , comment := "'"
    , tab := "tab"
    , space := "space"
  }
return

lctrl & ralt up:: isAltGrDown := false

#if isAltGrDown

lalt::return
*':: sendHotkey("comment")
*j::
*u::
*i::
*k::
*o::
*l::
*ö::
*å::
*s::
*w::
*a::
*d::
*c::
*x::
*v::
*z::
*y::
*tab::
*space::
  uniqueHotkeyId := substr(a_thishotkey, 2) a_now
  sendHotkey(substr(a_thishotkey, 2))
return

7::{
0::}
8::[
9::]
+::\
2::@
3::£
4::$
e::€
<::|
*¨:: send, {lctrl down}{ralt down}¨{ralt up}{lctrl up}

#maxthreadsperhotkey, 1
#if

sendHotkey(hotkeyVar) {
  local sendCompatibleHotkey, fullHotkeyCombination

  static isFunctionRunning = false, isHotkeySendInitiated = false

  isHotkeySendInitiated := true
  if (strlen(%hotkeyVar%) > 1) {
    sendCompatibleHotkey := "{" %hotkeyVar% "}"
  } else {
    sendCompatibleHotkey := %hotkeyVar%
  }

  fullHotkeyCombination := ""
    . putCtrlIfReplacementDown()
    . putAltIfReplacementDown()
    . putShiftIfDown()
    . sendCompatibleHotkey
  
  isHotkeySendInitiated := false
  send % fullHotkeyCombination
  
  if (!isFunctionRunning)
  {
    isFunctionRunning := true
    
    loop 3
    {
      sleep, 100
      if (isHotkeySendInitiated)
      {
        return
      }
    }
    
    loop
    {
      sleep, 30
      if (!getkeystate(hotkeyVar, "P"))
      {
        break
      }
      send % fullHotkeyCombination
    }

    isFunctionRunning := true
  }


}

putShiftIfDown() {
  return getkeystate("shift") ? "+" : ""
}

putCtrlIfReplacementDown() {
  return getkeystate("lalt", "P") ? "^" : ""
}

putAltIfReplacementDown() {
  return getkeystate("lwin") ? "!" : ""
}
