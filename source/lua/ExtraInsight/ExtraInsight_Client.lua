//=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
//
// ExtraInsight\ExtraInsight_Client.lua
//
//    Created by:   Chris Baker (chris.l.baker@gmail.com)
//    License:      Public Domain
//
// Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
// Worlds Entertainment, Inc.  Natural Selection 2, its Assets, Source Code, Documentation, and
// Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
// ========= For more information, visit http://www.unknownworlds.com ============================

kEIVersion = "0.80"
kEIModName = "Extra Insight Mod"
DebugPrint(kEIModName .. " version " .. kEIVersion)

// Source the common mod code
Script.Load("lua/ExtraInsight/ei_common.lua")

// Source the sub-modules
Script.Load("lua/ExtraInsight/ei_player_armor_bars.lua")
Script.Load("lua/ExtraInsight/ei_other_armor_bars.lua")
Script.Load("lua/ExtraInsight/ei_comm_player_frame.lua")
Script.Load("lua/ExtraInsight/ei_friend_colors.lua")
Script.Load("lua/ExtraInsight/ei_player_frames.lua")
Script.Load("lua/ExtraInsight/ei_chevrons.lua")
Script.Load("lua/ExtraInsight/ei_ui_scale.lua")
//TODO:
// - UI Scale
// - Ammo Bar weapon color distinction
// - Hive growth ETA timer
// - Alien Upgrade icons on Player Frame
//TODO Maybe:
// - Lifeform Kill Counter and Player Frame tooltips
// - Lerk/Gorge/JP Down
// - Co-Caster View Assist

// Source the settings menu and console bindings
Script.Load("lua/ExtraInsight/ei_console.lua")
Script.Load("lua/ExtraInsight/ei_menu.lua")
Script.Load("lua/ExtraInsight/ModMenu_Core.lua")

// Some functions need to be hooked by several modules so just hook into them
// once at the very end
Script.Load("lua/ExtraInsight/ei_common_hook.lua")

//=== Change Log =================================================================================
//
// 0.80
// - Initial Revision
// - Includes high-contrast armor bars module
// - Includes non-player armor bars module
// - Includes high-contrast command player frame module
// - Includes disabled minimap friends module
// - Includes parasite on player frames module
// - Includes high-contrast upgrade chevrons module
// - Includes stub UI Scale module
//
//================================================================================================