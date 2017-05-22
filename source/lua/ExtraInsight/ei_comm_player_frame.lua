//=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
//
// ExtraInsight\ei_comm_player_frame.lua
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
local GI_PlayerFrames_patched = false
local original_kCommanderColor

//********************
// Global Functions
//********************
function EI_UpdateCommBGColor()
	Print("EI_UpdateCommBGColor %s", EI_commBGHighContrast)
	if GI_PlayerFrames_patched then
		if GUIInsight_PlayerFrames and GUIInsight_PlayerFrames.UpdatePlayers then
			if EI_commBGHighContrast then
				Print("--Replacing kCommanderColor")
				ReplaceLocals(GUIInsight_PlayerFrames.UpdatePlayer, {kCommanderColor = kEIHighContrastCommanderColor})
			elseif original_kCommanderColor then
				Print("--Restoring kCommanderColor")
				ReplaceLocals(GUIInsight_PlayerFrames.UpdatePlayer, {kCommanderColor = original_kCommanderColor})
			end
		end
	end
end

function EI_CBCTest(testparam1)
	local setting = EI_commBGHighContrast
	if nil == testparam1 then
		Print("Commander BG Contrast: %s", EI_commBGHighContrast)
	elseif 0 == tonumber(testparam1) then
		setting = false
	elseif nil ~= tonumber(testparam1) then
		setting = true
	elseif testparam1 == "x" or testparam1 == "toggle" then
		setting = not EI_commBGHighContrast
	elseif testparam1 == "true" then
		setting = true
	elseif testparam1 == "false" then
		setting = false
	else
		Print("Unrecognized option")
	end

	if  setting ~= EI_commBGHighContrast then
		EI_commBGHighContrast = setting
		EI_UpdateCommBGColor()
	end
end

//********************
// Hook Routines
//********************

// Callback from common hook for GUIInsight_Overhead:Update
function EI_CBC_Overhead_hooks()
	if not GI_PlayerFrames_patched then
		if GUIInsight_PlayerFrames and GUIInsight_PlayerFrames.UpdatePlayer then
			Print("--Patching GUIInsight_PlayerFrames")
			//extract the default armor color
			original_kCommanderColor = GetLocal(GUIInsight_PlayerFrames.UpdatePlayer, "kCommanderColor")
			GI_PlayerFrames_patched = true
			EI_UpdateCommBGColor()
		end
	end

	return GI_PlayerFrames_patched
end

//=== Change Log =================================================================================
//
// 0.80
// - Initial Revision
// - Implements Commander Player-Frame Background Contrast
//
//================================================================================================