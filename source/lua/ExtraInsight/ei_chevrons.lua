//=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
//
// ExtraInsight\ei_friend_colors.lua
//
//    Created by:   Chris Baker (chris.l.baker@gmail.com)
//    License:      Public Domain
//
// Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
// Worlds Entertainment, Inc.  Natural Selection 2, its Assets, Source Code, Documentation, and
// Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
// ========= For more information, visit http://www.unknownworlds.com ============================

Script.Load("lua/TechTreeConstants.lua")

//********************
// Local Variables
//********************
local original_kIconSize
local EI_chevron_info = {
	[kTechId.Armor1] = {Color = Color(0,0,0,0), TextureCoords={0,0,80,80}},
	[kTechId.Armor2] = {Color = Color(1,1,0,1), TextureCoords={80,0,160,80}},
	[kTechId.Armor3] = {Color = Color(1,0,0,1), TextureCoords={160,0,240,80}},
	[kTechId.Weapons1] = {Color = Color(0,0,0,0), TextureCoords={240,0,320,80}},
	[kTechId.Weapons2] = {Color = Color(1,1,0,1), TextureCoords={320,0,400,80}},
	[kTechId.Weapons3] = {Color = Color(1,0,0,1), TextureCoords={400,0,480,80}},
}

local original_GP_Complete = nil
local original_GP_InProgress = nil

//********************
// Local Functions
//********************

// Extend GUIProduction/createTech to add additional contrast icons
local originalGP_createTech = nil
local function extendGP_createTech(self, list, techId, teamIndex)
	Print("extendGP_createTech(%s, %s)", EnumToString(kTechId, techId), teamIndex)

	original_GP_Complete = self.Complete
	original_GP_InProgress = self.InProgress
	local techinfo = EI_chevron_info[techId]
	if techinfo then
		local tech = originalGP_createTech(self, list, techId, teamIndex)
		local background = tech.Background

		local iconItem = GUIManager:CreateGraphicItem()
		iconItem:SetTexture("ui/chevrons.dds")
		iconItem:SetSize(original_kIconSize)
		iconItem:SetTexturePixelCoordinates(unpack(techinfo.TextureCoords))
		iconItem:SetColor(techinfo.Color)
		iconItem:SetIsVisible(EI_chevronsHighContrast)
		background:AddChild(iconItem)
		tech.EI_Icon = iconItem
		
		return tech
	end

	return originalGP_createTech(self, list, techId, teamIndex)
end

local function foreach_callback(item, i)
	if (item.EI_Icon) then
		item.EI_Icon:SetIsVisible(EI_chevronsHighContrast)
	end
end

//********************
// Global Functions
//********************
function EI_UpdateChevronColor()
	Print("EI_UpdateChevronColor")
	if (EI_chevronsHighContrast) then
		Print("--Displaying High Contrast Chevrons")
	else
		Print("--Hiding High Contrast Chevrons")
	end

	if (original_GP_Complete) then
		original_GP_Complete:ForEach(foreach_callback)
	end
	if (original_GP_InProgress) then
		original_GP_InProgress:ForEach(foreach_callback)
	end
end

function EI_UCCTest(testparam1)
	local setting = EI_chevronsHighContrast
	if nil == testparam1 then
		Print("High Contrast Upgrade Chevrons: %s", EI_chevronsHighContrast)
	elseif 0 == tonumber(testparam1) then
		setting = false
	elseif nil ~= tonumber(testparam1) then
		setting = true
	elseif testparam1 == "x" or testparam1 == "toggle" then
		setting = not EI_chevronsHighContrast
	elseif testparam1 == "true" then
		setting = true
	elseif testparam1 == "false" then
		setting = false
	else
		Print("Unrecognized option")
	end

	if  setting ~= EI_chevronsHighContrast then
		EI_chevronsHighContrast = setting
		EI_UpdateChevronColor()
	end
end

//********************
// Hook Routines
//********************

// Callback from common hook for GUIInsight_Overhead:Update
function EI_UCC_Overhead_hooks()
	if not originalGP_createTech then
		if GUIProduction and GUIProduction.UpdateTech then
			Print("--Patching GUIProduction")
			local updateStateFunc = GetLocal(GUIProduction.UpdateTech, "updateState")
			if updateStateFunc then
				originalGP_createTech = GetLocal(updateStateFunc, "createTech")
				if not originalGP_createTech then
					Print("----Patching GUIProduction/createTech failed")
					return true //failure but don't try again
				else
					original_kIconSize = GetLocal(originalGP_createTech, "kIconSize", GUIScale(Vector(42, 42, 0)))
					ReplaceLocals(updateStateFunc, {createTech = extendGP_createTech})
					return true //success
				end
			else
				Print("----Patching GUIProduction/updateState failed")
				return true //failure but don't try again
			end
		end
	end

	return false
end

//=== Change Log =================================================================================
//
// 0.80
// - Initial Revision
// - Implement disabled high contrast upgrade chevrons
//
//================================================================================================