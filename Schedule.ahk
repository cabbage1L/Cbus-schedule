#Requires AutoHotkey v2.0
#SingleInstance Force
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"

WinTitle := "Schedule Plus"

CFG := Map(
    "modes", Map(
        "LIGHT", Map(
            "select", [601, 114],
            "activeCheck", [29, 157]
        ),
        "AIR", Map(
            "select", [601, 114],
            "activeCheck", [29, 157]
        )
    ),
    "floors", Map(
        "F1", Map(
            "select", [100, 860],
            "activeCheck", [30, 860]
        )
    ),
    "zones", Map(
        "Z2", Map(
            "select", [440, 110],
            "activeCheck", [440, 106]
        ),
        "Z1", Map(
            "select", [285, 104],
            "activeCheck", [285, 104]
        )
    ),
    "lights", Map(
        "L001", [720, 454],
        "L002", [720, 500]
    )
)

GetRGB(x, y) {
    c := PixelGetColor(x, y, "RGB")
    r := (c >> 16) & 0xFF
    g := (c >> 8) & 0xFF
    b := c & 0xFF
    return [r, g, b]
}

IsGreen(rgb) {
    r := rgb[1], g := rgb[2], b := rgb[3]
    return (g > 140) && (g - r > 60) && (g - b > 60)
}

IsRed(rgb) {
    r := rgb[1], g := rgb[2], b := rgb[3]
    return (r > 140) && (r - g > 60) && (r - b > 60)
}

IsWhite(rgb) {
    r := rgb[1], g := rgb[2], b := rgb[3]
    return (r >= 230) && (g >= 230) && (b >= 230)
}

EnsureWindow() {
    global WinTitle
    if !WinExist(WinTitle)
        throw Error("Schedule Plus window not found")
    WinActivate WinTitle
    WinWaitActive WinTitle, , 2
}

EnsureFloor(floorKey) {
    global CFG
    f := CFG["floors"][floorKey]

    Click f["select"][1], f["select"][2]
    Sleep 250

    rgb := GetRGB(f["activeCheck"][1], f["activeCheck"][2])
    if !IsRed(rgb) {
        MsgBox "Floor not active: " floorKey "`nRGB=" rgb[1] "," rgb[2] "," rgb[3]
        throw Error("Floor not active: " floorKey " (check point/color)")
    }
}

EnsureZone(zoneKey) {
    global CFG
    z := CFG["zones"][zoneKey]
    Click z["select"][1], z["select"][2]
    Sleep 150

    rgb := GetRGB(z["activeCheck"][1], z["activeCheck"][2])
    if !IsGreen(rgb)
        throw Error("Zone not active: " zoneKey " (check point/color)")
}

; EnsureMode(modeKey) {
;     global CFG
;     m := CFG["modes"][modeKey]
;     SafeClick(m["select"][1], m["select"][2])
;     Sleep 250

;     rgb := GetRGB(m["activeCheck"][1], m["activeCheck"][2])
;     if !IsWhite(rgb)
;         throw Error("Mode not active: " modeKey " (check point/color)")
; }

EnsureMode(modeKey) {
    global CFG
    m := CFG["modes"][modeKey]
    rgb := GetRGB(m["activeCheck"][1], m["activeCheck"][2])
    if IsWhite(rgb)
        return
    SafeClick(m["select"][1], m["select"][2])
    Sleep 250
    rgb2 := GetRGB(m["activeCheck"][1], m["activeCheck"][2])
    if !IsWhite(rgb2)
        throw Error("Mode not switched: " modeKey " (still not white)")
}

Sleep 250
GetLightState(lightKey) {
    global CFG
    p := CFG["lights"][lightKey]
    rgb := GetRGB(p[1], p[2])
    if IsGreen(rgb)
        return "ON"
    if IsRed(rgb)
        return "OFF"
    return "UNKNOWN" ; เผื่อสีไม่ชัด/ตำแหน่งพลาด
}
SafeClick(x, y) {
    DllCall("SetCursorPos", "int", x, "int", y)
    Sleep 30
    Click "Down"
    Sleep 30
    Click "Up"
}

WaitState(lightKey, desired, timeoutMs := 2000) {
    start := A_TickCount
    while (A_TickCount - start < timeoutMs) {
        if (GetLightState(lightKey) = desired)
            return true
        Sleep 100
    }
    return false
}

SetLight(lightKey, desired) {
    global CFG
    p := CFG["lights"][lightKey]

    state := GetLightState(lightKey)
    if (state = "UNKNOWN")
        throw Error("Light state UNKNOWN for " lightKey " (wrong point?)")

    if (desired = state) {
        return state
    }

    SafeClick(p[1], p[2])
    Sleep 800
    if !WaitState(lightKey, desired, 2500)
    ; throw Error("p: " p[1] p[2])
    throw Error("Clicked but state didn't change: " lightKey)

}

; -------------------------
;  INPUT: จาก Node "F1|Z2|L001|ON"
arg := A_Args.Length ? A_Args[1] : "F1|Z2|L002|LIGHT|On"
parts := StrSplit(arg, "|")
if (parts.Length != 5) {
    MsgBox "Bad args. Use: F#|Z#|Device|LIGHT/AIR|ON/OFF"
    ExitApp 2
}

floorKey := parts[1]
zoneKey := parts[2]
devKey := parts[3]
modeKey := StrUpper(parts[4])     ; LIGHT หรือ AIR
desired := StrUpper(parts[5])     ; ON/OFF

try {
    EnsureWindow()
    EnsureFloor(floorKey)
    EnsureZone(zoneKey)
    EnsureMode(modeKey)

    before := GetLightState(devKey)
    after := SetLight(devKey, desired)

    TrayTip "Schedule Plus", "SUCCESS " floorKey " | " zoneKey " | " modeKey "`n" devKey ": " before " → " after, 3
    ExitApp 0
} catch as e {
    MsgBox e.Message
    ExitApp 1
}
