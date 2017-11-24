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

return

lctrl & ralt:: isAltGrDown := true
lctrl & ralt up:: isAltGrDown := false

#if isAltGrDown

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
  sendCompatibleHotkey := strlen(%hotkeyVar%) > 1 
    ? "{" %hotkeyVar% "}"
    : %hotkeyVar%

  fullHotkeyCombination := ""
    . putCtrlIfReplacementDown()
    . putAltIfReplacementDown()
    . putShiftIfDown()
    . sendCompatibleHotkey
  ; tooltip % fullHotkeyCombination
  send % fullHotkeyCombination  
}

putShiftIfDown() {
  return getkeystate("shift") ? "+" : ""
}

putCtrlIfReplacementDown() {
  return getkeystate("lalt") ? "^" : ""
}

putAltIfReplacementDown() {
  return getkeystate("lwin") ? "!" : ""
}