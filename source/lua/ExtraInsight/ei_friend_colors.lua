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

//********************
// Local Variables
//********************

//********************
// Global Functions
//********************
function EI_MMFTest(testparam1)
	local setting = EI_minimapFriendColors
	if nil == testparam1 then
		Print("Minimap Friend Highlights: %s", EI_minimapFriendColors)
	elseif 0 == tonumber(testparam1) then
		setting = false
	elseif nil ~= tonumber(testparam1) then
		setting = true
	elseif testparam1 == "x" or testparam1 == "toggle" then
		setting = not EI_minimapFriendColors
	elseif testparam1 == "true" then
		setting = true
	elseif testparam1 == "false" then
		setting = false
	else
		Print("Unrecognized option")
	end

	if  setting ~= EI_minimapFriendColors then
		EI_minimapFriendColors = setting
	end
end

//********************
// Hook Routines
//********************

// it turns out that the minimap code was way too complicated
// so it is easier just to patch the check here
// also, this function sure gets called a lot; how often do they think
// my friends list gets updated?
local original_GetSteamIdForClientIndex = GetSteamIdForClientIndex
function GetSteamIdForClientIndex(clientIndex)
	if Client.GetLocalClientTeamNumber() == kSpectatorIndex and not EI_minimapFriendColors then
		return nil
	end
	return original_GetSteamIdForClientIndex(clientIndex)
end

//=== Change Log =================================================================================
//
// 0.80
// - Initial Revision
// - Implement disabled Minimap Friend Colors
//
//================================================================================================