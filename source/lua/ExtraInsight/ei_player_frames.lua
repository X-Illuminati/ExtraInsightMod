//=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============
//
// ExtraInsight\ei_player_frames.lua
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
local original_playerList

//********************
// Local Functions
//********************

// Handles the logic of actually modifying the player nametag color
local function EI_PFP_Update_Parasites(player, deltaTime)
	local parasite_setting = false
	if EI_playerFrameParasites then
		local player_ent = Shared.GetEntity(player.EntityId)
		if player_ent then
			if GetIsParasited(player_ent) then
				parasite_setting = true
			end
		else
			// this doesn't completely work; if the player is
			// offscreen we just have to guess whether he is still
			// parasited or not
			parasite_setting = player.EI_parasited
			if kParasiteDuration ~= -1 and player.EI_parasite_time ~= nil then
				if player.EI_parasite_time > kParasiteDuration then
					parasite_setting = false
				end
			end
		end
	end

	local name = player.Name
	if name then
		if (name.EI_original_color and not parasite_setting) then
			Print("--%s-%s Unparasited", name:GetText(), player.EntityId)
			name:SetColor(name.EI_original_color)
			name.EI_original_color = nil
			player.EI_parasited = false
		elseif (parasite_setting and not name.EI_original_color) then
			Print("--%s-%s Parasited", name:GetText(), player.EntityId)
			name.EI_original_color = name:GetColor()
			name:SetColor(kParasiteColor)
			player.EI_parasited = true
			player.EI_parasite_time = 0
		elseif parasite_setting then
			// safeguard against some other mod resetting color on
			// every tick
			name:SetColor(kParasiteColor)
		end
	end

	// also update the overhead view
	if original_playerList then
		name = nil
		local playerGUI = original_playerList[player.EntityId]
		if playerGUI then
			name = playerGUI.Name
		end
		if name then
			if (name.EI_original_color and not parasite_setting) then
				name:SetColor(name.EI_original_color)
				name.EI_original_color = nil
			elseif (parasite_setting and not name.EI_original_color) then
				name.EI_original_color = name:GetColor()
				name:SetColor(kParasiteColor)
			elseif parasite_setting then
				// re-apply as this gets reset on every tick
				name:SetColor(kParasiteColor)
			end
		end
	end
end

// Extend GUIInsight_PlayerFrames:Update to add parasite colorations
local originalGI_PF_Update = nil
local function extendGI_PF_Update(self, deltaTime)
	originalGI_PF_Update(self, deltaTime)

	// technically we only need to do this for the marine team
	// but the overhead is fairly low and it might work without
	// modifications for some future alien v alien mod...
	for i, team in ipairs(self.teams) do
		if (team.Background:GetIsVisible()) then
			for j, player in pairs(team.PlayerList) do
				EI_PFP_Update_Parasites(player, deltaTime)
			end
		end
	end
end

// Extend GUIInsight_PkayerHealthbars:Initialize to extract the new playerList
local originalGI_PH_Initialize = nil
local function extendGI_PH_Initialize(self)
	Print("extendGI_PH_Initialize")
	originalGI_PH_Initialize(self)
	original_playerList = GetLocal(originalGI_PH_Initialize, "playerList")
end

// Extend GUIInsight_PkayerHealthbars:Uninitialize to destroy the playerList
local originalGI_PH_Uninitialize = nil
local function extendGI_PH_Uninitialize(self)
	Print("extendGI_PH_Uninitialize")
	originalGI_PH_Uninitialize(self)
	original_playerList = nil
end

//********************
// Global Functions
//********************
function EI_PFPTest(testparam1)
	local setting = EI_playerFrameParasites
	if nil == testparam1 then
		Print("Player Frame Parasites: %s", EI_playerFrameParasites)
	elseif 0 == tonumber(testparam1) then
		setting = false
	elseif nil ~= tonumber(testparam1) then
		setting = true
	elseif testparam1 == "x" or testparam1 == "toggle" then
		setting = not EI_playerFrameParasites
	elseif testparam1 == "true" then
		setting = true
	elseif testparam1 == "false" then
		setting = false
	else
		Print("Unrecognized option")
	end

	if  setting ~= EI_playerFrameParasites then
		EI_playerFrameParasites = setting
	end
end

//********************
// Hook Routines
//********************

// Callback from common hook for GUIInsight_Overhead:Update
function EI_PFP_Overhead_hooks()
	if not originalGI_PF_Update then
		if GUIInsight_PlayerFrames and GUIInsight_PlayerFrames.Update then
			Print("--Patching GUIInsight_PlayerFrames")
			//extend GUIInsight_PlayerFrames:Update
			originalGI_PF_Update = GUIInsight_PlayerFrames.Update
			GUIInsight_PlayerFrames.Update = extendGI_PF_Update
		end
	end

	if not originalGI_PH_Initialize then
		if GUIInsight_PlayerHealthbars and GUIInsight_PlayerHealthbars.Initialize then
			Print("--Patching GUIInsight_PlayerHealthbars")
			//extend GUIInsight_PlayerHealthbars:Initialize
			originalGI_PH_Initialize = GUIInsight_PlayerHealthbars.Initialize
			GUIInsight_PlayerHealthbars.Initialize = extendGI_PH_Initialize
			//extend GUIInsight_PlayerHealthbars:Uninitialize
			originalGI_PH_Uninitialize = GUIInsight_PlayerHealthbars.Uninitialize
			GUIInsight_PlayerHealthbars.Uninitialize = extendGI_PH_Uninitialize
			// extract the playerList array
			original_playerList = GetLocal(originalGI_PH_Initialize, "playerList")
		end
	end

	return (originalGI_PF_Update ~= nil and originalGI_PH_Initialize ~= nil)
end

//=== Change Log =================================================================================
//
// 0.80
// - Initial Revision
// - Implements Player-Frame Parasite indicator
//
//================================================================================================