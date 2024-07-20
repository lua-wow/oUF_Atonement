# oUF_Atonement

Atonement tracker support for oUF layouts

## Element: `Atonement`

Handles the update of a status bar that displays player's Atonement buff duration.

### Widgets

-   `Atonement`: A `StatusBar` used to represent player's 'Atonement' buff duration.

### Sub-Widgets

-   `.bg`:  A `Texture` used as a background. It will inherit the color of the main StatusBar.

### Options

-   `.color`: use to color the status bar. Default is #cfb53b (207, 181, 59)

### Examples

```lua
local _, class = UnitClass("player")
if (class ~= "PRIEST") then return end

-- Position and size
local Atonement = CreateFrame("StatusBar", nil, self)
Atonement:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT")
Atonement:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")
Atonement:SetHeight(5)
Atonement:SetStatusBarTexture(Texture)

-- Add a background
local Background = Atonement:CreateTexture(nil, "BORDER")
Background:SetAllPoints()
Background:SetTexture(Texture)
Background.multiplier = 0.30

-- Register it with oUF
Atonement.bg = Background
self.Atonement = Atonement
```
