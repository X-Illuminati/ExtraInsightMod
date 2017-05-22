//=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
//
// ExtraInsight\ei_menu.lua
//
//    Created by:   Chris Baker (chris.l.baker@gmail.com)
//    License:      Public Domain
//
// Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
// Worlds Entertainment, Inc.  Natural Selection 2, its Assets, Source Code, Documentation, and
// Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
// ========= For more information, visit http://www.unknownworlds.com ============================

//********************
// Callback Functions
//********************
local function updateEIUIScale(mainMenu)
	local value = ModMenuOptionsElements.EI_UIScale:GetValue() * 4

	if value and (value >= 0) then
		EI_UIScale = value
		ModMenuOptionsElements.EI_UIScale.scrollValue = value //kind of a hack...
		Client.SetOptionFloat("EI_UIScale", EI_UIScale)
		EI_UpdateUIScale()
	end
end

local function updatePABSetting(formElement)
	Print("updatePABSetting(%s)", formElement:GetActiveOptionIndex())
	local setting = (formElement:GetActiveOptionIndex() > 1)
	if  setting ~= EI_armorBarHighContrast then
		EI_armorBarHighContrast = setting
		Client.SetOptionBoolean("EI_armorBarHighContrast", EI_armorBarHighContrast)
		EI_UpdatePlayerArmorBarContrast()
	end
end

local function updateOABSetting(formElement)
	Print("updateOABSetting(%s)", formElement:GetActiveOptionIndex())
	local setting = (formElement:GetActiveOptionIndex() > 1)
	if  setting ~= EI_otherArmorBars then
		EI_otherArmorBars = setting
		Client.SetOptionBoolean("EI_otherArmorBars", EI_otherArmorBars)
	end
end

local function updateUCCSetting(formElement)
	Print("updateUCCSetting(%s)", formElement:GetActiveOptionIndex())
	local setting = (formElement:GetActiveOptionIndex() > 1)
	if  setting ~= EI_chevronsHighContrast then
		EI_chevronsHighContrast = setting
		Client.SetOptionBoolean("EI_chevronsHighContrast", EI_chevronsHighContrast)
		EI_UpdateChevronColor()
	end
end

local function updateCBCSetting(formElement)
	Print("updateCBCSetting(%s)", formElement:GetActiveOptionIndex())
	local setting = (formElement:GetActiveOptionIndex() > 1)
	if  setting ~= EI_commBGHighContrast then
		EI_commBGHighContrast = setting
		Client.SetOptionBoolean("EI_commBGHighContrast", EI_commBGHighContrast)
		EI_UpdateCommBGColor()
	end
end

local function updateMMFSetting(formElement)
	Print("updateMMFSetting(%s)", formElement:GetActiveOptionIndex())
	local setting = (formElement:GetActiveOptionIndex() == 1) // the logic on this one is kind of backwards
	if  setting ~= EI_minimapFriendColors then
		EI_minimapFriendColors = setting
		Client.SetOptionBoolean("EI_minimapFriendColors", EI_minimapFriendColors)
	end
end

local function updatePFPSetting(formElement)
	Print("updatePFPSetting(%s)", formElement:GetActiveOptionIndex())
	local setting = (formElement:GetActiveOptionIndex() > 1)
	if  setting ~= EI_playerFrameParasites then
		EI_playerFrameParasites = setting
		Client.SetOptionBoolean("EI_playerFrameParasites", EI_playerFrameParasites)
	end
end

//********************
// Menu Uptions
//********************
local EI_modMenuOptions =
{
	{
		name    = "EI_UIScale",
		label   = "Insight UI Scale",
		type    = "slider",
		sliderCallback = updateEIUIScale
	},
	{
		name    = "EI_armorBarHighContrast",
		label   = "High Contrast Armor Bars",
		type    = "select",
		values  = { "DISABLED", "The Better to See You With" },
		callback = updatePABSetting
	},
	{
		name    = "EI_otherArmorBars",
		label   = "Non-Player Armor Bars",
		type    = "select",
		values  = { "DISABLED", "Show Me the Armor" },
		callback = updateOABSetting
	},
	{
		name    = "EI_chevronsHighContrast",
		label   = "High Contrast Upgrade Icons",
		type    = "select",
		values  = { "DISABLED", "The Chevrons are Locking" },
		callback = updateUCCSetting
	},
	{
		name    = "EI_commBGHighContrast",
		label   = "High Contrast Comm BG",
		type    = "select",
		values  = { "DISABLED", "Queen Bee" }, -- this one needs some work
		callback = updateCBCSetting
	},
	{
		name    = "EI_minimapFriendColors",
		label   = "Minimap Friend Colors",
		type    = "select",
		values  = { "ENABLED", "Forever Alone" },
		callback = updateMMFSetting
	},
	{
		name    = "EI_playerFrameParasites",
		label   = "Parasites on Side Frames",
		type    = "select",
		values  = { "DISABLED", "Parasites Lost" },
		callback = updatePFPSetting
	},
}

//********************
// Global Functions
//********************

-- ModMenu API -
-- Before creating the Mod Options form element, the ModMenu patch routine
-- will call the ModMenu_PrepareOptions function.
if ModMenu_PrepareOptions then
	local original_MM_PrepareOptions = ModMenu_PrepareOptions
end
function ModMenu_PrepareOptions()
	//Print("ModMenu_PrepareOptions - %d", #EI_modMenuOptions)
	if original_MM_PrepareOptions then
		local modMenuOptions = original_MM_PrepareOptions()
		for i = 1, #EI_modMenuOptions do
			table.insert(modMenuOptions, EI_modMenuOptions[i])
		end
		return modMenuOptions
	else
		return EI_modMenuOptions
	end
end


-- ModMenu API -
-- After creating the Mod Options form element, the ModMenu patch routine
-- will call the ModMenu_MenuCreatedCallback.
if ModMenu_MenuCreatedCallback then
	local original_MM_MenuCreatedCallback = ModMenu_MenuCreatedCallback
end
function ModMenu_MenuCreatedCallback(optionElements)
	//Print("ModMenu_MenuCreatedCallback")
	
	local function BoolToIndex(value)
		if value then
			return 2
		end
		return 1
	end

	// Set Initial menu element values
	EI_UIScale = Client.GetOptionFloat("EI_UIScale", 1.00)
	optionElements.EI_UIScale:SetValue(EI_UIScale/4)
	EI_armorBarHighContrast = Client.GetOptionBoolean("EI_armorBarHighContrast", true)
	optionElements.EI_armorBarHighContrast:SetOptionActive(BoolToIndex(EI_armorBarHighContrast))
	EI_otherArmorBars = Client.GetOptionBoolean("EI_otherArmorBars", true)
	optionElements.EI_otherArmorBars:SetOptionActive(BoolToIndex(EI_otherArmorBars))
	EI_commBGHighContrast = Client.GetOptionBoolean("EI_commBGHighContrast", true)
	optionElements.EI_commBGHighContrast:SetOptionActive(BoolToIndex(EI_commBGHighContrast))
	EI_minimapFriendColors = Client.GetOptionBoolean("EI_minimapFriendColors", false)
	optionElements.EI_minimapFriendColors:SetOptionActive(BoolToIndex(not EI_minimapFriendColors))
	EI_playerFrameParasites = Client.GetOptionBoolean("EI_playerFrameParasites", true)
	optionElements.EI_playerFrameParasites:SetOptionActive(BoolToIndex(EI_playerFrameParasites))
	EI_chevronsHighContrast = Client.GetOptionBoolean("EI_chevronsHighContrast", true)
	optionElements.EI_chevronsHighContrast:SetOptionActive(BoolToIndex(EI_chevronsHighContrast))

	if original_MM_MenuCreatedCallback then
		original_MM_MenuCreatedCallback(optionElements)
	end
end


//=== Change Log =================================================================================
//
// 0.80
// - Initial Revision
// - Added menu elements for use with ModMenu API
//
//================================================================================================