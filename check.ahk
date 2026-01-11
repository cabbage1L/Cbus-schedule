#Requires AutoHotkey v2.0
CoordMode "Mouse", "Screen"
CoordMode "Pixel", "Screen"

SetTimer(Show, 100)
Show() {
  MouseGetPos &x, &y
  c := PixelGetColor(x, y, "RGB")
  r := (c >> 16) & 0xFF
  g := (c >> 8) & 0xFF
  b := c & 0xFF
  ToolTip "x=" x " y=" y "`nRGB=" r "," g "," b
}
