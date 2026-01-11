#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"

WinTitle := "Schedule Plus"
EnsureWindow() {
    global WinTitle
    if !WinExist(WinTitle)
        throw Error("Schedule Plus window not found")
    WinActivate WinTitle
    WinWaitActive WinTitle, , 2
}
SafeClick(x, y){
  DllCall("SetCursorPos","int",x,"int",y)
  Sleep 25
  Click "Down"
  Sleep 40
  Click "Up"
}

 SafeClick(720, 500)
