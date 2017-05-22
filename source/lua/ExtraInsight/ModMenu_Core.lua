--[[
=== This file modifies Natural Selection 2, Copyright Unknown Worlds Entertainment. ============

ModMenu_Core.lua

   Created by:   Chris Baker (chris.l.baker@gmail.com)
   License:      Public Domain

Public Domain license of this file does not supercede any Copyrights or Trademarks of Unknown
Worlds Entertainment, Inc.  Natural Selection 2, its Assets, Source Code, Documentation, and
Utilities are Copyright Unknown Worlds Entertainment, Inc. All rights reserved.
========= For more information, visit http://www.unknownworlds.com ============================
]]--


----------------------
-- ModMenu API
----------------------

--[[
Step 1:
  Before creating the Mod Options form element, the ModMenu patch routine will
  call the ModMenu_PrepareOptions function to get the table of options to be
  displayed. This table will be processed by GUIMainMenu.CreateOptionsForm, so
  it should be formatted suitably.

  The function can be appended by each mod as they load and will eventually
  return the full list of menu options.
  For example, add the following code to your mod to add a simple element to
  the menu:
--[=[
local mymod_modMenuOptions =
{
	{
		name    = "mymod_option_1",
		label   = "Option 1",
		type    = "select",
		values  = { "OFF", "ON" },
		callback = mymod_option_1_callback
	},
}

if ModMenu_PrepareOptions then
	local original_MM_PrepareOptions = ModMenu_PrepareOptions
end
function ModMenu_PrepareOptions()
	if original_MM_PrepareOptions then
		local modMenuOptions = original_MM_PrepareOptions()
		for i = 1, #mymod_modMenuOptions do
			table.insert(modMenuOptions, mymod_modMenuOptions[i])
		end
		return modMenuOptions
	else
		return mymod_modMenuOptions
	end
end
]=]--

Step 2:
  Afer creating the Mod Options form and the desired child elements, the
  ModMenu patch routine will call the ModMenu_MenuCreatedCallback function.

  This callback can be used to set initial values for each form element.

  The function can be appended by each mod as they load and will eventually
  callback to each mod in turn.
  For example, add the following code to your mod to set the initial value for
  the element created in the previous example:
--[=[
local mymod_modMenuOptions =
{
	{
		name    = "mymod_option_1",
		label   = "Option 1",
		type    = "select",
		values  = { "OFF", "ON" },
		callback = mymod_option_1_callback
	},
}

if ModMenu_MenuCreatedCallback then
	local original_MM_MenuCreatedCallback = ModMenu_MenuCreatedCallback
end
function ModMenu_MenuCreatedCallback(optionElements)
	mymod_option_1 = Client.GetOptionBool("mymod/option1", true)
	optionElements.mymod_option_1:SetOptionActive( BoolToIndex(mymod_option_1) )

	if original_MM_MenuCreatedCallback then
		original_MM_MenuCreatedCallback(optionElements)
	end
end
]=]--

Step 3:
  Include this file after defining your ModMenu_PrepareOptions
  This file will automatically tap into several function:
    - MainMenu_IsInGame
    - GUIMainMenu:CreateOptionWindow
    - GUIMainMenu:OnResolutionChanged
    - ContentBox:OnSlide

Step 4:
  After creation of the Options Window in GUIMainMenu:CreateOptionWindow(),
  this script will call ModMenu_CreateGUIWidgets to perform the bulk of the
  menu item creation.

  In the process it will call the ModMenu_PrepareOptions() function mentioned
  in Step 1. The resulting table will be processed by
  GUIMainMenu.CreateOptionsForm to create all of the menu elements. 
  This script will handle creation of a new tab button to make the new menu
  screen visible.

  This script is also responsible for populating the 3 ModMenu Globals:
  - ModMenuOptions - the final options menu list
  - ModMenuOptionsElements - table populated with the created form elements
  - ModMenuOptionsForm - the form that was created

  After all option elements are created, this script will call
  ModMenu_MenuCreatedCallback with ModMenuOptionsElements as a parameter.
]]--

----------------------
-- Helper Functions
----------------------

--Retrieves the current value of the desired local from the targetFunction
--The default value is the value to return if the desired local is not found
--Example: maxheight = ModMenu_GetLocal(Player.GetJumpHeight, "kMaxHeight", nil)
local function ModMenu_GetLocal(targetFunction, desiredLocal, defaultValue)
	local index = 1
	while true do
		local n, v = debug.getupvalue(targetFunction, index)
		if not n then
			break
		end
		-- Find the highest index matching the name.
		if n == desiredLocal then
			return v
		end
		index = index + 1
	end

	return defaultValue
end

-- This helper function finds the tab_background and other tab widgets.
local function ModMenu_FindOptionsTabs(guimainmenu)
	-- Find the tab background
	local tabs = nil
	local tabBackground = nil

	for _, child in ipairs(guimainmenu.optionWindow.children) do
		if (child:GetCSSClassNames() == "tab_background ") then
			tabBackground = child
		elseif (child:GetCSSClassNames() == "tab ") then
			if not tabs then
				for x, clickfunc in ipairs(child.clickCallbacks) do
					tabs = ModMenu_GetLocal(clickfunc, "tabs")
				end
			end
		end
		if tabBackground and tabs then
			break
		end
	end

	return tabs,tabBackground
end

-- This helper function creates an additional tab widget for the Mod options.
local function ModMenu_CreateModOptionsTab(guimainmenu, tabs, tabBackground)
	local tabAnimateTime = 0.1
	local tabButton = CreateMenuElement(guimainmenu.optionWindow, "MenuButton")
	table.insert(tabs, {label = "MOD SETTINGS", form = ModMenuOptionsForm})
	local i = #tabs

	local function ShowTab()
		for j = 1, #tabs do
			tabs[j].form:SetIsVisible(i == j)
		end
		guimainmenu.optionWindow:ResetSlideBar()
		guimainmenu.optionWindow:SetSlideBarVisible(tabs[i].scroll == true)
		local tabPosition = tabButton.background:GetPosition()
		tabBackground:SetBackgroundPosition(tabPosition, false, tabAnimateTime) 
	end

	tabButton:SetCSSClass("tab")
	tabButton:SetText(tabs[i].label)
	tabButton:AddEventCallbacks({ OnClick = ShowTab })

	local tabWidth = tabButton:GetWidth()
	tabButton:SetBackgroundPosition( Vector(tabWidth * (i-1), 0, 0) )
	guimainmenu.tabWidth=tabWidth
	
	--make room for the extra tab...
	guimainmenu.optionWindow:SetWidth(guimainmenu.optionWindow:GetWidth()+tabWidth)
	guimainmenu.optionWindow.background:SetPosition(guimainmenu.optionWindow.background:GetPosition()+Vector(tabWidth/-2, 0, 0))

end

----------------------
-- Global Functions
----------------------

-- This function creates the Mod Options Tab and registers it with the
-- GUIMainMenu class. It must be called after the optionWindow is created.
function ModMenu_CreateGUIWidgets(guimainmenu)
	if ModMenuOptionsForm then
		return
	end

	if not guimainmenu or not guimainmenu.optionWindow then
		return
	end

	-- Prepare ModMenuOptions
	if ModMenu_PrepareOptions then
		_G["ModMenuOptions"] = ModMenu_PrepareOptions()
	else
		_G["ModMenuOptions"] = {}
	end

	-- Create a blank form
	_G["ModMenuOptionsElements"] = {}
	_G["ModMenuOptionsForm"] = GUIMainMenu.CreateOptionsForm(guimainmenu, guimainmenu.optionWindow:GetContentBox(), ModMenuOptions, ModMenuOptionsElements)
	ModMenuOptionsForm:SetIsVisible(false)

	-- Create the tab to activate the form
	local tabs,tabBackground = ModMenu_FindOptionsTabs(guimainmenu)
	ModMenu_CreateModOptionsTab(guimainmenu, tabs, tabBackground)

	-- Call ModMenu_MenuCreatedCallback function to let mods set initial
	-- values for each element
	ModMenu_MenuCreatedCallback(ModMenuOptionsElements)
end

----------------------
-- Hook Routines
----------------------

-- We will extend GUIMainMenu:CreateOptionWindow to add our menu options
local original_GMM_CreateOptionWindow = nil
local function extend_GMM_CreateOptionWindow(self)
	--Print("extendGMM_CreateOptionWindow")
	original_GMM_CreateOptionWindow(self)

	ModMenu_CreateGUIWidgets(self)
end

-- We will extend GUIMainMenu:OnResolutionChanged because some settings must
-- be re-applied
local original_GMM_OnResolutionChanged = nil
local function extend_GMM_OnResolutionChanged(self, oldX, oldY, newX, newY)
	--Print("extend_GMM_OnResolutionChanged(%s, %s, %s, %s)", oldX, oldY, newX, newY)
	original_GMM_OnResolutionChanged(self, oldX, oldY, newX, newY)

	--make room for the extra tab...
	if (self.tabWidth) then
		self.optionWindow:SetWidth(self.optionWindow:GetWidth()+self.tabWidth)
		self.optionWindow.background:SetPosition(self.optionWindow.background:GetPosition()+Vector(self.tabWidth/-2, 0, 0))
	end
end

-- We will hook MainMenu_IsInGame to extend GUIMainMenu:CreateOptionWindow
-- and GUIMainMenu:OnResolutionChanged
local original_MM_IsInGame = MainMenu_IsInGame
function MainMenu_IsInGame()
	if not original_GMM_CreateOptionWindow then
		--Print("MainMenu_IsInGame")
		if GUIMainMenu and GUIMainMenu.CreateOptionWindow then
			--Print("--Patching GUIMainMenu:CreateOptionWindow")
			original_GMM_CreateOptionWindow = GUIMainMenu.CreateOptionWindow
			GUIMainMenu.CreateOptionWindow = extend_GMM_CreateOptionWindow
			original_GMM_OnResolutionChanged = GUIMainMenu.OnResolutionChanged
			GUIMainMenu.OnResolutionChanged = extend_GMM_OnResolutionChanged
		end
	end

	return original_MM_IsInGame()
end

-- There is a bug that affects scrolling very long forms due to having a fixed
-- CSS Height attribute. This routine will patch the form height to be
-- ContentSize + 20.
-- It will also export a global variable to prevent the fix from being applied
-- multiple times.
if not kLongFormScrollFix then
    -- Patch ContentBox:OnSlide to correct form height
    local originalCBOnSlide = ContentBox.OnSlide
    function ContentBox:OnSlide(slideFraction, align)
        --Print("ContentBox:OnSlide (%f)", slideFraction)
        for _, child in ipairs(self.children) do
            local desiredconheight = child:GetContentSize().y+20
            if child:isa("Form") and (child:GetHeight() ~= desiredconheight) then
                child:SetHeight(desiredconheight)
            end
        end
        originalCBOnSlide(self, slideFraction, align)
    end
    kLongFormScrollFix = 1
end

--[[
=== Change Log =================================================================================

20140418 - Revision 0.50
  - Initial Revision
  - Added basic mod menu system (new tab under options)
  - Added patch for ContentBox max height
  - Updated license and documentation info

20140518 - Revision 0.60
  - Added callback on completion of menu creation to set initial values

================================================================================================
]]--