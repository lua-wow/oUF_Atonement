--[[
	# Element: Atonement

	Handles the update of a status bar that displays player's Atonement buff duration.

	## Widgets

	Atonement 	- A `StatusBar` used to represent player's 'Atonement' buff duration.

	## Sub-Widgets

	.bg 		- A `Texture` used as a background. It will inherit the color of the main StatusBar.

	## Options

	.color		- use to color the status bar. Default is #cfb53b (207, 181, 59)

	## Examples

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

		-- Register it with oUF
		Atonement.bg = Background
		self.Atonement = Atonement
--]]
local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "oUF_Atonement was unable to locate oUF install.")

-- Blizzard
local GetSpecialization = _G.GetSpecialization
local UnitClass = _G.UnitClass
local UnitBuff = _G.UnitBuff

-- Constants
local SPEC_PRIEST_DISCIPLINE = 1
local MAX_AURAS = 40
local ATONEMENT_COLOR = oUF:CreateColor(0.81, 0.71, 0.23)

local auras = {
	[194384] = true,	-- Atonement
	[214206] = true		-- Atonement PvP Talent
}

local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if (self.elapsed >= 0.1) then
		local value = (self.expirationTime or 0) - GetTime()
		if (value > 0) then
			self:SetValue(value)
		else
			self:SetScript("OnUpdate", nil)
			self:SetValue(0)
		end
	end
end

local GetUnitAura
if C_UnitAuras then
	GetUnitAura = function(unit, index, filter)
		return C_UnitAuras.GetBuffDataByIndex(unit, index, filter)
	end
else
	GetUnitAura = function(unit, index, filter)
		local name, icon, count, dispelType, duration, expirationTime, source, isStealable, nameplateShowPersonal,
		spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = UnitBuff(unit, index, filter)
		if name then
			return {
				auraInstanceID = index,
				name = name,
				icon = icon,
				spellId = spellId,
				sourceUnit = source,
				dispelName = dispelType,
				applications = count,
				canApplyAura = canApplyAura,
				duration = duration,
				expirationTime = expirationTime,
				isStealable = isStealable,
				isBossAura = isBossDebuff,
				isFromPlayerOrPlayerPet = castByPlayer,
				isHarmful = (filter == "HARMFUL"),
				isHelpful = (filter == "HELPFUL"),
				isRaid = (filter == "RAID"),
				isNameplateOnly = false,
				nameplateShowAll = nameplateShowAll,
				nameplateShowPersonal = false,
				charges = nil,
				maxCharges = nil,
				points = nil,
				timeMod = timeMod
			}
		end
	end
end

local function Update(self, event, unit)
	if self.unit ~= unit then return end
	local element = self.Atonement

	if element then
		for index = 1, MAX_AURAS do
			local aura = GetUnitAura(unit, index, "HELPFUL")
			if aura then
				if auras[aura.spellId] then
					element.duration = aura.duration or 0
					element.expirationTime = aura.expirationTime or (GetTime() + element.duration)
					
					element:SetMinMaxValues(0, element.duration)
					element:SetScript("OnUpdate", OnUpdate)
					element:Show()

					return
				end
			end
		end

		element:SetScript("OnUpdate", nil)
		element:SetValue(0)
		element:Hide()
	end
end

local function Visibility(self, event)
	local _, class = UnitClass("player")
	local specialization = GetSpecialization()

	if (class == "PRIEST") and (specialization == SPEC_PRIEST_DISCIPLINE) then
		self:RegisterEvent("UNIT_AURA", Update)
	else
		self.Atonement:SetScript("OnUpdate", nil)
		self.Atonement:SetValue(0)
		self.Atonement:Hide()

		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

local function Enable(self)
	local element = self.Atonement
	if element then
		element.color = element.color or ATONEMENT_COLOR

		self:RegisterEvent("UNIT_AURA", Update)
		self:RegisterEvent("PLAYER_TALENT_UPDATE", Visibility, true)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Visibility, true)

		local color = element.color
		element:SetValue(0)
		element:SetStatusBarColor(color.r, color.g, color.b)

		local bg = element.bg
		if bg then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(color.r * mu, color.g * mu, color.b * mu)
		end

		element:Hide()

		return true
	end
end

local function Disable(self)
	local element = self.Atonement
	if element then
		element:Hide()

		self:UnregisterEvent("UNIT_AURA", Update)
		self:UnregisterEvent("PLAYER_TALENT_UPDATE", Visibility)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Visibility)
	end
end

oUF:AddElement("Atonement", Update, Enable, Disable)
