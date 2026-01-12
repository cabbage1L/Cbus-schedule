#Requires AutoHotkey v2.0

global CFG := Map(
    "modes", Map(
        "LIGHT", Map("select", [601, 114], "activeCheck", [29, 157]),
        "AIR",   Map("select", [601, 114], "activeCheck", [29, 157])
    ),
    "floors", Map(
        "F1", Map("select", [100, 860], "activeCheck", [30, 860])
    ),
    "zones", Map(
        "Z2", Map("select", [440, 110], "activeCheck", [440, 106]),
        "Z1", Map("select", [285, 104], "activeCheck", [285, 104])
    ),
    "lights", Map(
        "L001", [720, 454],
        "L002", [720, 500],
        "R001", [793, 397]
    )
)
