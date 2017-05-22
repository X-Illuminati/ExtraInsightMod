//=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
//
// ExtraInsight\ei_other_armor_bars.lua
//
//    Created by:   Chris Baker (chris.l.baker@gmail.com)
//    License:      Public Domain
//
// Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
// Worlds Entertainment, Inc.  Natural Selection 2, its Assets, Source Code, Documentation, and
// Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
// ========= For more information, visit http://www.unknownworlds.com ============================

//********************
// Local Variables
//********************
local original_otherList
local original_kOtherHealthBarTexture
local original_kOtherHealthBarTextureSize
local original_kOtherHealthBarSize

//********************
// Local Functions
//********************
// Extend GUIInsight_OtherHealthbars:Update to update the armor/health bar size
local originalGI_OH_Update = nil
local function extendGI_OtherHealthbars_Update(self, deltaTime)

	originalGI_OH_Update(self, deltaTime)

	if original_otherList then
		for index, otherGUI in pairs(original_otherList) do
			if otherGUI.HealthBar and EI_otherArmorBars then
				local armorBar = otherGUI.EI_ArmorBar
				if not armorBar then
					armorBar = GUIManager:CreateGraphicItem()
					armorBar:SetAnchor(GUIItem.Left, GUIItem.Top)
					armorBar:SetTexture(original_kOtherHealthBarTexture or "ui/healthbarsmall.dds")
					otherGUI.Background:AddChild(armorBar)
					otherGUI.EI_ArmorBar = armorBar
				end

				local other = Shared.GetEntity(index)
				local backgroundSize = otherGUI.Background:GetSize().x
				local armorColor = ConditionalValue(EI_armorBarHighContrast, kEIHighContrastArmorColors, EI_original_kArmorColors)[ConditionalValue(other:GetTeamType() == kAlienTeamType, 2, 1)]

				local health = other:GetHealth()
				local armor = other:GetArmor() * kHealthPointsPerArmor
				local maxHealth = other:GetMaxHealth()
				local maxArmor = other:GetMaxArmor() * kHealthPointsPerArmor            
				local healthFraction = health/(maxHealth+maxArmor)
				local armorFraction = armor/(maxHealth+maxArmor)

				// re-position health bar
				local healthBar = otherGUI.HealthBar
				local healthBarSize =  healthFraction * backgroundSize - GUIScale(1)
				local healthBarTextureSize = healthFraction * original_kOtherHealthBarTextureSize.x
				//healthBar:SetTexturePixelCoordinates(unpack({0, 0, healthBarTextureSize, original_kOtherHealthBarTextureSize.y}))
				healthBar:SetSize(Vector(healthBarSize, original_kOtherHealthBarSize.y, 0))
				//healthBar:SetColor(color)

				// position armor bar
				local armorBarSize =  armorFraction * backgroundSize
				local armorBarTextureSize = armorFraction * original_kOtherHealthBarTextureSize.x
				armorBar:SetTexturePixelCoordinates(unpack({healthBarTextureSize, 0, healthBarTextureSize+armorBarTextureSize, original_kOtherHealthBarTextureSize.y}))
				armorBar:SetSize(Vector(armorBarSize, original_kOtherHealthBarSize.y, 0))
				armorBar:SetPosition(Vector(healthBarSize, 0, 0))
				armorBar:SetColor(armorColor)
				armorBar:SetIsVisible(true)
			elseif otherGUI.EI_ArmorBar and not EI_otherArmorBars then
				otherGUI.EI_ArmorBar:SetIsVisible(false)
			end
		end
	end
end

// Extend GUIInsight_OtherHealthbars:Initialize to extract the new otherList
local originalGI_OH_Initialize = nil
local function extendGI_OH_Initialize(self)
	Print("extendGI_OH_Initialize")
	originalGI_OH_Initialize(self)
	original_otherList = GetLocal(originalGI_OH_Initialize, "otherList")
	original_kOtherHealthBarSize = GetLocal(originalGI_OH_Initialize, "kOtherHealthBarSize") or GUIScale(Vector(64, 6, 0))
end

//********************
// Global Functions
//********************
function EI_OABTest(testparam1)
	if nil == testparam1 then
		Print("Other Armor Bars: %s %s", EI_otherArmorBars, original_otherList)
	elseif 0 == tonumber(testparam1) then
		EI_otherArmorBars = false
	elseif nil ~= tonumber(testparam1) then
		EI_otherArmorBars = true
	elseif testparam1 == "x" or testparam1 == "toggle" then
		EI_otherArmorBars = not EI_otherArmorBars
	elseif testparam1 == "true" then
		EI_otherArmorBars = true
	elseif testparam1 == "false" then
		EI_otherArmorBars = false
	else
		Print("Unrecognized option")
	end
end

//********************
// Hook Routines
//********************

// Callback from common hook for GUIInsight_Overhead:Update
function EI_OAB_Overhead_hooks()
	if not originalGI_OH_Update then
		if GUIInsight_OtherHealthbars and GUIInsight_OtherHealthbars.Update then
			Print("--Patching GUIInsight_OtherHealthbars")
			//extract the otherList, kOtherHealthBarTexture,
			//kOtherHealthBarTextureSize, kOtherHealthBarSize
			original_otherList = GetLocal(GUIInsight_OtherHealthbars.Update, "otherList")
			original_kOtherHealthBarTexture = GetLocal(GUIInsight_OtherHealthbars.CreateOtherGUIItem, "kOtherHealthBarTexture")
			original_kOtherHealthBarTextureSize = GetLocal(GUIInsight_OtherHealthbars.Update, "kOtherHealthBarTextureSize") or Vector(64, 6, 0)
			original_kOtherHealthBarSize = GetLocal(GUIInsight_OtherHealthbars.Update, "kOtherHealthBarSize") or GUIScale(Vector(64, 6, 0))

			//extend GUIInsight_OtherHealthbars:Update
			originalGI_OH_Update = GUIInsight_OtherHealthbars.Update
			GUIInsight_OtherHealthbars.Update = extendGI_OtherHealthbars_Update

			//extend GUIInsight_OtherHealthbars:Initialize
			originalGI_OH_Initialize = GUIInsight_OtherHealthbars.Initialize
			GUIInsight_OtherHealthbars.Initialize = extendGI_OH_Initialize
		end
	end

	return (originalGI_OH_Update ~= nil)
end


//=== Change Log =================================================================================
//
// 0.80
// - Initial Revision
// - Implements Non-Player Armor Bars
//
//================================================================================================