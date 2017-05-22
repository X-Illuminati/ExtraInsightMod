//=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
//
// ExtraInsight\ei_ui_scale.lua
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
function EI_UpdateUIScale()
	Print("EI_UpdateUIScale %s", EI_UIScale)
end

function EI_UIScaleTest(testparam1)
	if nil == testparam1 then
		Print("Insight UI Scale: %s", EI_UIScale)
		return
	end

	local setting = tonumber(testparam1)
	if nil ~= setting then
		if setting >= 0 and setting <= 4 then
			EI_UIScale = tonumber(testparam1)
			EI_UpdateUIScale()
		else
			Print("Parameter must be in range [0, 4]")
		end
	else
		Print("Unrecognized option")
	end
end

//********************
// Hook Routines
//********************


//=== Change Log =================================================================================
//
// 0.80
// - Initial Revision
// - Stubs Insight UI Scale
//
//================================================================================================