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

*':: sendHotkey("comment")
lalt::return
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
¨::~

#if

sendHotkey(hotkeyVar) {
  local sendCompatibleHotkey, fullHotkeyCombination

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
  
  send % fullHotkeyCombination
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
