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

-- Constants
local SPEC_PRIEST_DISCIPLINE = 1
local ATONEMENT_COLOR = oUF:CreateColor(0.81, 0.71, 0.23)

local ATONEMENT_SPELLS = {
	[194384] = true,	-- Atonement
	[214206] = true		-- Atonement PvP Talent
}

local function UpdateColor(element)
	local color = element.color
	if (color) then
		element:SetStatusBarColor(color.r, color.g, color.b, color.a or 1)

		local bg = element.bg
		if bg then
			local mu = bg.multiplier or 1
			bg:SetVertexColor(color.r * mu, color.g * mu, color.b * mu, (color.a * mu) or 1)
		end
	end
end

local function UpdateAura(element, unit, data)
	if (data) then
		local duration = C_UnitAuras.GetAuraDuration(unit, data.auraInstanceID)
		element.duration = duration

		if (duration) then
			element:SetTimerDuration(duration, element.interpolation, element.direction)
			element:Show()
		else
			element.duration = nil
			element:SetValue(0)
			element:Hide()
		end
	else
		element.duration = nil
		element:SetValue(0)
		element:Hide()
	end
end

local function FilterAuras(unit, data)
	return data and ATONEMENT_SPELLS[data.spellId]
end

local function Update(self, event, unit, updateInfo)
	if self.unit ~= unit then return end
	
	local element = self.Atonement
	if not element then return end

	local isFullUpdate = not updateInfo or updateInfo.isFullUpdate

	local changed = false

	if (isFullUpdate) then
		element.data = nil

		local slots = { C_UnitAuras.GetAuraSlots(unit, element.filter) }
		for i = 2, #slots do
			local data = C_UnitAuras.GetAuraDataBySlot(unit, slots[i])
			if FilterAuras(unit, data) then
				element.data = data
				break
			end
		end

		changed = true
	else
		if (updateInfo.addedAuras) then
			for _, data in next, updateInfo.addedAuras do
				if FilterAuras(unit, data) then
					element.data = data
					changed = true
					break
				end
			end
		end

		if updateInfo.updatedAuraInstancesIDs then
			for _, auraInstanceID in next, updateInfo.updatedAuraInstancesIDs do
				local data = C_UnitAuras.GetAuraDataByInstanceID(unit, auraInstanceID)
				if FilterAuras(unit, data) then
					element.data = data
					changed = true
					break
				end
			end
		end

		if updateInfo.removedAuraInstancesIDs then
			for _, auraInstanceID in next, updateInfo.removedAuraInstancesIDs do
				if (element.data and element.data.auraInstanceID == auraInstanceID) then
					element.data = nil
					changed = true
					break
				end
			end
		end
	end

	if changed then
		UpdateAura(element, unit, element.data)
	elseif (element.data) then
		local data = C_UnitAuras.GetPlayerAuraBySpellID(element.data.spellId)
		if (not data or data.auraInstanceID ~= element.data.auraInstanceID) then
			element.data = data
			UpdateAura(element, unit, data)
		end
	end
end

local function Visibility(self, event)
	local element = self.Atonement

	local _, class = UnitClass("player")
	local specialization = C_SpecializationInfo.GetSpecialization()

	element:Hide()

	if (class == "PRIEST") and (specialization == SPEC_PRIEST_DISCIPLINE) then
		UpdateColor(element)
		self:RegisterEvent("UNIT_AURA", Update)
	else
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

local function ForceUpdate(element)
	Visibility(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.Atonement
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.color = element.color or ATONEMENT_COLOR
		element.filter = "HELPFUL|PLAYER"
		element.interpolation = Enum.StatusBarInterpolation.Immediate
		element.direction = Enum.StatusBarTimerDirection.RemainingTime

		self:RegisterEvent("PLAYER_TALENT_UPDATE", Visibility, true)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Visibility, true)

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
