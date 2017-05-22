//=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
//
// ExtraInsight\ei_player_armor_bars.lua
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
local GI_PlayerHealthbars_patched = false

//********************
// Global Functions
//********************
function EI_UpdatePlayerArmorBarContrast()
	Print("EI_UpdatePlayerArmorBarContrast")
	if GI_PlayerHealthbars_patched then
		if GUIInsight_PlayerHealthbars and GUIInsight_PlayerHealthbars.UpdatePlayers then
			if (EI_armorBarHighContrast) then
				Print("--Replacing kArmorColors")
				ReplaceLocals(GUIInsight_PlayerHealthbars.UpdatePlayers, {kArmorColors = kEIHighContrastArmorColors})
			elseif EI_original_kArmorColors then
				Print("--Restoring kArmorColors")
				ReplaceLocals(GUIInsight_PlayerHealthbars.UpdatePlayers, {kArmorColors = EI_original_kArmorColors})
			end
		end
	end
end

function EI_PABTest(testparam1)
	local setting = EI_armorBarHighContrast
	if nil == testparam1 then
		Print("Player Armor Bars: %s", EI_armorBarHighContrast)
	elseif 0 == tonumber(testparam1) then
		setting = false
	elseif nil ~= tonumber(testparam1) then
		setting = true
	elseif testparam1 == "x" or testparam1 == "toggle" then
		setting = not EI_armorBarHighContrast
	elseif testparam1 == "true" then
		setting = true
	elseif testparam1 == "false" then
		setting = false
	else
		Print("Unrecognized option")
	end

	if  setting ~= EI_armorBarHighContrast then
		EI_armorBarHighContrast = setting
		EI_UpdatePlayerArmorBarContrast()
	end
end

//********************
// Hook Routines
//********************

// Callback from common hook for GUIInsight_Overhead:Update
function EI_PAB_Overhead_hooks()
	if not GI_PlayerHealthbars_patched then
		if GUIInsight_PlayerHealthbars and GUIInsight_PlayerHealthbars.UpdatePlayers then
			Print("--Patching GUIInsight_PlayerHealthbars")
			//extract the default armor color
			EI_original_kArmorColors = GetLocal(GUIInsight_PlayerHealthbars.UpdatePlayers, "kArmorColors")
			GI_PlayerHealthbars_patched = true
			EI_UpdatePlayerArmorBarContrast()
		end
	end

	return GI_PlayerHealthbars_patched
end

//=== Change Log =================================================================================
//
// 0.80
// - Initial Revision
// - Implements High Contrast Player Armor Bars
//
//================================================================================================