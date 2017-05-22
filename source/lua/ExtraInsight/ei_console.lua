//=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
//
// ExtraInsight\ei_console.lua
//
//    Created by:   Chris Baker (chris.l.baker@gmail.com)
//    License:      Public Domain
//
// Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
// Worlds Entertainment, Inc.  Natural Selection 2, its Assets, Source Code, Documentation, and
// Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
// ========= For more information, visit http://www.unknownworlds.com ============================

local function OnCommandEIVer()
	DebugPrint(kEIModName .. " version " .. kEIVersion)
end

Event.Hook("Console_eiver", OnCommandEIVer)

// Unit Test Commands
local function OnCommandEITest(testcommand, ...)
	Print("OnCommandEITest - %s", testcommand)
	if not testcommand then
		Print("Available Test Commands:")
		Print("  pab   - high contrast player armor bars")
		Print("  oab   - non-player armor bars")
		Print("  cbc   - commander background contrast")
		Print("  mmf   - minimap friend colors")
		Print("  pfp   - player frame parasites")
		Print("  ucc   - upgrade chevron contrast")
		Print("  scale - insight UI scale")
		return
	end

	if testcommand == "pab" then
		EI_PABTest(...)
	elseif testcommand == "oab" then
		EI_OABTest(...)
	elseif testcommand == "cbc" then
		EI_CBCTest(...)
	elseif testcommand == "mmf" then
		EI_MMFTest(...)
	elseif testcommand == "pfp" then
		EI_PFPTest(...)
	elseif testcommand == "ucc" then
		EI_UCCTest(...)
	elseif testcommand == "scale" then
		EI_UIScaleTest(...)
	end
end

Event.Hook("Console_eitest", OnCommandEITest)

//=== Change Log =================================================================================
//
// 0.80
// - Initial Revision
//
//================================================================================================