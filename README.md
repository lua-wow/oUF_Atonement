# oUF_Atonement

Atonement tracker support for oUF layouts

```lua
local class = select(2, UnitClass("player"))

if (class ~= "PRIEST") then return end

-- create atonement oUF
local Atonement = CreateFrame("StatusBar", self:GetName().."Atonement", self.Health)
Atonement:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT")
Atonement:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT")
Atonement:SetHeight(6)
Atonement:SetStatusBarTexture(HealthTexture)
Atonement:SetFrameLevel(self.Health:GetFrameLevel() + 1)

-- add a background
Atonement.Background = Atonement:CreateTexture(nil, "BORDER")
Atonement.Background:SetTexture(HealthTexture)
Atonement.Background:SetAllPoints()
Atonement.Background:SetColorTexture(207/255 * .2, 181/255 * .2, 59/255 * .2)

-- register it with oUF
self.Atonement = Atonement
```
