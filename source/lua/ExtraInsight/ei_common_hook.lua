//=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
//
// ExtraInsight\ei_common_hook.lua
//
//    Created by:   Chris Baker (chris.l.baker@gmail.com)
//    License:      Public Domain
//
// Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
// Worlds Entertainment, Inc.  Natural Selection 2, its Assets, Source Code, Documentation, and
// Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
// ========= For more information, visit http://www.unknownworlds.com ============================

//**********************
// Local Variables
//**********************
applied_EI_PAB_Overhead_hooks = false
applied_EI_OAB_Overhead_hooks = false
applied_EI_CBC_Overhead_hooks = false
applied_EI_PFP_Overhead_hooks = false
applied_EI_UCC_Overhead_hooks = false

//**********************
// Common Hook Routines
//**********************

// Hook GUIInsight_Overhead:Update to run various module hook functions
local originalGI_Overhead_Update = nil
local function hookGI_Overhead_Update(self, deltaTime)
	if not applied_EI_PAB_Overhead_hooks then
		applied_EI_PAB_Overhead_hooks = EI_PAB_Overhead_hooks()
	end
	if not applied_EI_OAB_Overhead_hooks then
		applied_EI_OAB_Overhead_hooks = EI_OAB_Overhead_hooks()
	end
	if not applied_EI_CBC_Overhead_hooks then
		applied_EI_CBC_Overhead_hooks = EI_CBC_Overhead_hooks()
	end
	if not applied_EI_PFP_Overhead_hooks then
		applied_EI_PFP_Overhead_hooks = EI_PFP_Overhead_hooks()
	end
	if not applied_EI_UCC_Overhead_hooks then
		applied_EI_UCC_Overhead_hooks = EI_UCC_Overhead_hooks()
	end

	return originalGI_Overhead_Update(self, deltaTime)
end

// Hook SetLocalPlayerIsOverhead to hook into GUIInsight_Overhead:Update
local originalSetLocalPlayerIsOverhead = SetLocalPlayerIsOverhead
function SetLocalPlayerIsOverhead(isOverhead)
	Print("SetLocalPlayerIsOverhead(%s)", isOverhead)

	if not originalGI_Overhead_Update then
		if GUIInsight_Overhead and GUIInsight_Overhead.Update then
			//hook into GUIInsight_Overhead:Update
			originalGI_Overhead_Update = GUIInsight_Overhead.Update
			GUIInsight_Overhead.Update = hookGI_Overhead_Update
		end
	end

	return originalSetLocalPlayerIsOverhead(isOverhead)
end

//=== Change Log =================================================================================
//
// 0.80
// - Initial Revision
// - Hooks GUIInsight_Overhead:Update to run various module hook functions
//
//================================================================================================