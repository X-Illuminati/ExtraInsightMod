//=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
//
// ExtraInsight\ei_common.lua
//
//    Created by:   Chris Baker (chris.l.baker@gmail.com)
//    License:      Public Domain
//
// Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
// Worlds Entertainment, Inc.  Natural Selection 2, its Assets, Source Code, Documentation, and
// Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
// ========= For more information, visit http://www.unknownworlds.com ============================

//********************
// Constants
//********************
kEIUIScaleDefault = 1
kEIHighContrastArmorColors = {Color(0.59, 0.79, 0.9, 1), Color(0.9, 0.72, 0.59, 1)}
kEIHighContrastCommanderColor = Color(1, 0.96, 0.1, 1)

//********************
// Global Variables
//********************

// menu settings
EI_UIScale = 1
EI_armorBarHighContrast = true
EI_otherArmorBars = true
EI_commBGHighContrast = true
EI_minimapFriendColors = false
EI_playerFrameParasites = true
EI_chevronsHighContrast = true

// player armor bars
local EI_original_kArmorColors = nil

//********************
// Global Functions
//********************

//Retrieves the current value of the desired local from the targetFunction
//The default value is the value to return if the desired local is not found
//Example: maxheight = GetLocals(Player.GetJumpHeight, "kMaxHeight", nil)
function GetLocal(targetFunction, desiredLocal, defaultValue)
	//Print("--GetLocal(%s, %s)", targetFunction, desiredLocal)
	local index = 1
	while true do
		local n, v = debug.getupvalue(targetFunction, index)
		if not n then
			break
		end
		-- Find the highest index matching the name.
		if n == desiredLocal then
			//Print("  %s = %s", n, v)
			return v
		end
		index = index + 1
	end

	return defaultValue
end

//=== Change Log =================================================================================
//
// 0.80
// - Initial Revision
// - Added GetLocal helper function to get a named upvalue
//
//================================================================================================