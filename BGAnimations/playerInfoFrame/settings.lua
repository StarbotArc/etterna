local ratios = {
    RightWidth = 782 / 1920,
    LeftWidth = 783 / 1920,
    Height = 971 / 1080,
    TopLipHeight = 44 / 1080,
    BottomLipHeight = 99 / 1080,

    EdgePadding = 12 / 1920, -- distance from edges for text and items
    
    --
    -- right options
    OptionTextWidth = 275 / 1920, -- left edge of text to edge of area for text
    OptionTextListTopGap = 21 / 1080, -- bottom of right top lip to top of text
    OptionTextBuffer = 7 / 1920, -- distance from end of width to beginning of selection frame
    OptionSelectionFrameWidth = 250 / 1920, -- allowed area for option selection

    -- for this area, this is the allowed height for all options including sub options
    -- when an option opens, it may only show as many sub options as there are lines after subtracting the amount of option categories
    -- so 1 category with 24 sub options has 25 lines
    -- 2 categories can then only have up to 23 sub options each to make 25 lines
    -- etc
    OptionAllottedHeight = 672 / 1080, -- from top of top option to bottom of bottom option
    NoteskinDisplayWidth = 240 / 1920, -- width of the text but lets fit the arrows within this
    NoteskinDisplayRightGap = 17 / 1920, -- distance from right edge of frame to right edge of display
    NoteskinDisplayReceptorTopGap = 29 / 1080, -- bottom of text to top of receptors
    NoteskinDisplayTopGap = 21 / 1080, -- bottom of right top lip to top of text
}

local actuals = {
    LeftWidth = ratios.LeftWidth * SCREEN_WIDTH,
    RightWidth = ratios.RightWidth * SCREEN_WIDTH,
    Height = ratios.Height * SCREEN_HEIGHT,
    TopLipHeight = ratios.TopLipHeight * SCREEN_HEIGHT,
    BottomLipHeight = ratios.BottomLipHeight * SCREEN_HEIGHT,
    EdgePadding = ratios.EdgePadding * SCREEN_WIDTH,
    OptionTextWidth = ratios.OptionTextWidth * SCREEN_WIDTH,
    OptionTextListTopGap = ratios.OptionTextListTopGap * SCREEN_HEIGHT,
    OptionTextBuffer = ratios.OptionTextBuffer * SCREEN_WIDTH,
    OptionSelectionFrameWidth = ratios.OptionSelectionFrameWidth * SCREEN_WIDTH,
    OptionAllottedHeight = ratios.OptionAllottedHeight * SCREEN_HEIGHT,
    NoteskinDisplayWidth = ratios.NoteskinDisplayWidth * SCREEN_WIDTH,
    NoteskinDisplayRightGap = ratios.NoteskinDisplayRightGap * SCREEN_WIDTH,
    NoteskinDisplayReceptorTopGap = ratios.NoteskinDisplayReceptorTopGap * SCREEN_HEIGHT,
    NoteskinDisplayTopGap = ratios.NoteskinDisplayTopGap * SCREEN_HEIGHT,
}

local visibleframeY = SCREEN_HEIGHT - actuals.Height
local animationSeconds = 0.1
local focused = false

local titleTextSize = 0.8
local explanationTextSize = 0.8
local textZoomFudge = 5

local choiceTextSize = 0.8
local buttonHoverAlpha = 0.6
local buttonActiveStrokeColor = color("0.85,0.85,0.85,0.8")

local maxExplanationTextLines = 2

local t = Def.ActorFrame {
    Name = "SettingsFile",
    InitCommand = function(self)
        -- lets just say uh ... despite the fact that this file might want to be portable ...
        -- lets ... just .... assume it always goes in the same place ... and the playerInfoFrame is the same size always
        self:y(visibleframeY)
        self:diffusealpha(0)
    end,
    GeneralTabSetMessageCommand = function(self, params)
        -- if we ever get this message we need to hide the frame and just exit.
        focused = false
    end,
    PlayerInfoFrameTabSetMessageCommand = function(self, params)
        if params.tab and params.tab == "Settings" then
            --
            -- movement is delegated to the left and right halves
            -- right half immediately comes out
            -- left half comes out when selecting "Customize Playfield" or "Customize Keybinds"
            --
            self:diffusealpha(1)
            self:finishtweening()
            self:sleep(0.01)
            self:queuecommand("FinishFocusing")
        else
            self:finishtweening()
            self:smooth(animationSeconds)
            self:diffusealpha(0)
            focused = false
        end
    end,
    FinishFocusingCommand = function(self)
        focused = true
        CONTEXTMAN:SetFocusedContextSet(SCREENMAN:GetTopScreen():GetName(), "Settings")
    end,
}


local function leftFrame()

    local t = Def.ActorFrame {
        Name = "LeftFrame",
        InitCommand = function(self)
            self:x(0) -- yea
        end,

        Def.Quad {
            Name = "BG",
            InitCommand = function(self)
                self:valign(0):halign(0)
                self:zoomto(actuals.LeftWidth, actuals.Height)
                self:diffuse(color("#111111"))
                self:diffusealpha(0.6)
            end
        },
        Def.Quad {
            Name = "TopLip",
            InitCommand = function(self)
                self:valign(0):halign(0)
                self:zoomto(actuals.LeftWidth, actuals.TopLipHeight)
                self:diffuse(color("#111111"))
                self:diffusealpha(0.6)
            end
        },
        LoadFont("Common Normal") .. {
            Name = "HeaderText",
            InitCommand = function(self)
                self:halign(0)
                self:xy(actuals.EdgePadding, actuals.TopLipHeight / 2)
                self:zoom(titleTextSize)
                self:maxwidth((actuals.LeftWidth - actuals.EdgePadding*2) / titleTextSize - textZoomFudge)
                self:settext("Customize {x}")
            end
        }
    }


    return t
end

local function rightFrame()

    local t = Def.ActorFrame {
        Name = "RightFrame",
        InitCommand = function(self)
            self:x(SCREEN_WIDTH - actuals.RightWidth)
        end,

        Def.Quad {
            Name = "BG",
            InitCommand = function(self)
                self:valign(0):halign(0)
                self:zoomto(actuals.RightWidth, actuals.Height)
                self:diffuse(color("#111111"))
                self:diffusealpha(0.6)
            end,
        },
        Def.Quad {
            Name = "TopLip",
            InitCommand = function(self)
                -- height is double normal top lip
                self:valign(0):halign(0)
                self:zoomto(actuals.RightWidth, actuals.TopLipHeight * 2)
                self:diffuse(color("#111111"))
                self:diffusealpha(0.6)
            end,
        },
        Def.Quad {
            Name = "BottomLip",
            InitCommand = function(self)
                -- height is double normal top lip
                self:valign(1):halign(0)
                self:y(actuals.Height)
                self:zoomto(actuals.RightWidth, actuals.BottomLipHeight)
                self:diffuse(color("#111111"))
                self:diffusealpha(0.6)
            end,
        },
        LoadFont("Common Normal") .. {
            Name = "HeaderText",
            InitCommand = function(self)
                self:halign(0)
                self:xy(actuals.EdgePadding, actuals.TopLipHeight / 2)
                self:zoom(titleTextSize)
                self:maxwidth((actuals.RightWidth - actuals.EdgePadding*2) / titleTextSize - textZoomFudge)
                self:settext("Options")
            end
        },
        LoadFont("Common Normal") .. {
            Name = "ExplanationText",
            InitCommand = function(self)
                self:halign(0):valign(0)
                self:xy(actuals.EdgePadding, actuals.Height - actuals.BottomLipHeight + actuals.EdgePadding)
                self:zoom(explanationTextSize)
                --self:maxwidth((actuals.RightWidth - actuals.EdgePadding*2) / explanationTextSize - textZoomFudge)
                self:wrapwidthpixels((actuals.RightWidth - actuals.EdgePadding * 2) / explanationTextSize)
                self:maxheight((actuals.BottomLipHeight - actuals.EdgePadding * 2) / explanationTextSize)
                self:settext("Explanations about optoins go here and im writing a long sentence so that the demonstration of automatic line breaks is completed.")
            end
        }
    }

    -- -----
    -- Utility functions for options not necessarily needed for global use in /Scripts (could easily be put there instead though)
    
    -- set any mod as part of PlayerOptions at all levels in one easy function
    local function setPlayerOptionsModValueAllLevels(funcname, ...)
        -- you give a funcname like MMod, XMod, CMod and it just works
        local poptions = GAMESTATE:GetPlayerState():GetPlayerOptions("ModsLevel_Preferred")
        local stoptions = GAMESTATE:GetPlayerState():GetPlayerOptions("ModsLevel_Stage")
        local soptions = GAMESTATE:GetPlayerState():GetPlayerOptions("ModsLevel_Song")
        local coptions = GAMESTATE:GetPlayerState():GetPlayerOptions("ModsLevel_Current")
        poptions[funcname](poptions, ...)
        stoptions[funcname](stoptions, ...)
        soptions[funcname](soptions, ...)
        coptions[funcname](coptions, ...)
    end
    -- set any mod as part of SongOptions at all levels in one easy function
    local function setSongOptionsModValueAllLevels(funcname, ...)
        -- you give a funcname like MusicRate and it just works
        local poptions = GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred")
        local stoptions = GAMESTATE:GetSongOptionsObject("ModsLevel_Stage")
        local soptions = GAMESTATE:GetSongOptionsObject("ModsLevel_Song")
        local coptions = GAMESTATE:GetSongOptionsObject("ModsLevel_Current")
        poptions[funcname](poptions, ...)
        stoptions[funcname](stoptions, ...)
        soptions[funcname](soptions, ...)
        coptions[funcname](coptions, ...)
    end
    -- alias for getting "current" PlayerOptions
    local function getPlayerOptions()
        return GAMESTATE:GetPlayerState():GetPlayerOptions("ModsLevel_Preferred")
    end
    -- alias for getting "current" SongOptions
    local function getSongOptions()
        return GAMESTATE:GetSongOptionsObject("ModsLevel_Preferred")
    end

    --- for Speed Mods -- this has been adapted from the fallback script which does speed and mode at once
    local function getSpeedModeFromPlayerOptions()
        local poptions = GAMESTATE:GetPlayerState():GetPlayerOptions("ModsLevel_Preferred")
        if poptions:MaxScrollBPM() > 0 then
            return "M"
        elseif poptions:TimeSpacing() > 0 then
            return "C"
        else
            return "X"
        end
    end
    local function getSpeedValueFromPlayerOptions()
        local poptions = GAMESTATE:GetPlayerState():GetPlayerOptions("ModsLevel_Preferred")
        if poptions:MaxScrollBPM() > 0 then
            return math.round(poptions:MaxScrollBPM())
        elseif poptions:TimeSpacing() > 0 then
            return math.round(poptions:ScrollBPM())
        else
            return math.round(poptions:ScrollSpeed() * 100)
        end
    end

    -- for convenience to generate a choice table for a float interface setting
    local function floatSettingChoice(visibleName, funcName, enabledValue, offValue)
        return {
            Name = visibleName,
            CheckFunction = function()
                return getPlayerOptions()[funcName] ~= offValue
            end,
            OnFunction = function()
                setPlayerOptionsModValueAllLevels(funcName, enabledValue)
            end,
            OffFunction = function()
                setPlayerOptionsModValueAllLevels(funcName, offValue)
            end,
        }
    end

    -- for convenience to generate a choice table for a boolean interface setting
    local function booleanSettingChoice(visibleName, funcName)
        return {
            Name = visibleName,
            CheckFunction = function()
                return getPlayerOptions()[funcName] == true
            end,
            OnFunction = function()
                setPlayerOptionsModValueAllLevels(funcName, true)
            end,
            OffFunction = function()
                setPlayerOptionsModValueAllLevels(funcName, false)
            end,
        }
    end

    -- for convenience to generate a direction table for a setting which goes in either direction and wraps via PREFSMAN
    -- if the max value is reached, the min value is the next one
    local function preferenceIncrementDecrementDirections(preferenceName, minValue, maxValue, increment)
        return {
            Left = function()
                local x = clamp(PREFSMAN:GetPreference(preferenceName), minValue, maxValue)
                x = x - increment
                if x < minValue then x = maxValue end
                PREFSMAN:SetPreference(preferenceName, notShit.round(x, 3))
            end,
            Right = function()
                local x = clamp(PREFSMAN:GetPreference(preferenceName), minValue, maxValue)
                x = x + increment
                if x > maxValue then x = minValue end
                PREFSMAN:SetPreference(preferenceName, notShit.round(x, 3))
            end,
        }
    end

    local function basicNamedPreferenceChoice(preferenceName, displayName, chosenValue)
        return {
            Name = displayName,
            ChosenFunction = function()
                PREFSMAN:SetPreference(preferenceName, chosenValue)
            end,
        }
    end

    --
    -- -----

    -- -----
    -- Extra data for option temporary storage or cross option interaction
    --
    local playerConfigData = playerConfig:get_data()
    local themeConfigData = themeConfig:get_data()
    local displaySpecs = GetDisplaySpecs()
    local optionData = {
        speedMod = {
            speed = getSpeedValueFromPlayerOptions(),
            mode = getSpeedModeFromPlayerOptions(),
        },
        noteSkins = {
            names = NOTESKIN:GetNoteSkinNames(),
        },
        receptorSize = playerConfigData.ReceptorSize,
        gameMode = {
            modes = GAMEMAN:GetEnabledGames(),
            current = GAMESTATE:GetCurrentGame():GetName(),
        },
        screenFilter = playerConfigData.ScreenFilter,
        language = {
            list = THEME:GetLanguages(),
            current = THEME:GetCurLanguage(),
        },
        instantSearch = themeConfigData.global.InstantSearch,
        display = {
            dRatios = GetDisplayAspectRatios(displaySpecs),
            wRatios = GetWindowAspectRatios(),
            loadedAspectRatio = PREFSMAN:GetPreference("DisplayAspectRatio")
        },
    }
    --
    -- -----

    -- -----
    -- Extra utility functions that require optionData to be initialized first
    local function setSpeedValueFromOptionData()
        local mode = optionData.speedMod.mode
        local speed = optionData.speedMod.speed
        if mode == "X" then
            -- the way we store stuff, xmod must divide by 100
            -- theres no quirk to it, thats just because we store the number as an int (not necessarily an int but yeah)
            -- so 0.01x XMod would be a CMod of 1 -- this makes even more sense if you just think about it
            setPlayerOptionsModValueAllLevels("XMod", speed/100)
        elseif mode == "C" then
            setPlayerOptionsModValueAllLevels("CMod", speed)
        elseif mode == "M" then
            setPlayerOptionsModValueAllLevels("MMod", speed)
        end
    end
    --
    -- -----

    -- the names and order of the option pages
    -- these values must correspond to the keys of optionPageCategoryLists
    local pageNames = {
        "Player",
        "Graphics",
        "Sound",
        "Input",
        "Profiles",
    }

    -- mappings of option page names to lists of categories
    -- the keys in this table are option pages
    -- the values are tables -- the categories of each page in that order
    -- each category corresponds to a key in optionDefs
    -- the options of each category are in the order of the value tables in optionDefs
    local optionPageCategoryLists = {
        Player = {
            "Essential Options",
            "Appearance Options",
            "Invalidating Options",
        },
        Graphics = {
            "Global Options",
            "Appearance Options",
        },
        Sound = {
            "Sound Options",
        },
        Input = {
            "Input Options",
        },
        Profiles = {
            "Profile Options",
        },
    }

    -- the mother of all tables.
    -- this is each option definition for every single option present in the right frame
    -- mapping option categories to lists of options
    -- LIMITATIONS: A category cannot have more sub options than the max number of lines minus the number of categories.
    --  example: 25 lines? 2 categories? up to 23 options per category.
    -- OPTION DEFINITION EXAMPLE: 
    --[[
        {
            Name = "option name" -- display name for the option
            Type = "" -- determines how to generate the actor to display the choices
            AssociatedOptions = {"other option name"} -- runs the index getter for these options when a choice is selected
            Choices = { -- option choice definitions -- each entry is another table -- if no choices are defined, visible choice comes from ChoiceIndexGetter
                {
                    Name = "choice1" -- display name for the choice
                    ChosenFunction = function() end -- what happens when choice is PICKED (not hovered)
                },
                {
                    Name = "choice2"
                    ...
                },
                ...
            },
            Directions = {
                -- table of direction functions -- these define what happens for each pressed direction button
                -- most options have only Left and Right
                -- if these functions are undefined and required by the option type, a default function moves the index of the choice rotationally
                -- some option types may allow for more directions or direction multipliers
                -- if Toggle is defined, this function is used for all direction presses
                Left = function() end,
                Right = function() end,
                Toggle = function() end, --- OPTIONAL -- WILL REPLACE ALL DIRECTION FUNCTIONALITY IF PRESENT
                ...
            },
            ChoiceIndexGetter = function() end -- a function to run to get the choice index or text, or return a table for multi selection options
            ChoiceGenerator = function() end -- an OPTIONAL function for generating the choices table if too long to write out (return a table)
            Explanation = "" -- an explanation that appears at the bottom of the screen
        }
    ]]
    local optionDefs = {
        -----
        -- PLAYER OPTIONS
        ["Essential Options"] = {
            {
                Name = "Scroll Type",
                Type = "",
                AssociatedOptions = {
                    "Scroll Speed",
                },
                Choices = {
                    {
                        Name = "XMod",
                    },
                    {
                        Name = "CMod",
                    },
                    {
                        Name = "MMod",
                    },
                },
                Directions = {
                    Left = function()
                        -- traverse list left, set the speed mod again
                        -- order:
                        -- XMOD - CMOD - MMOD
                        local mode = optionData.speedMod.mode
                        if mode == "C" then
                            mode = "X"
                        elseif mode == "M" then
                            mode = "C"
                        elseif mode == "X" then
                            mode = "M"
                        end
                        optionData.speedMod.mode = mode
                        setSpeedValueFromOptionData()
                    end,
                    Right = function()
                        -- traverse list right, set the speed mod again
                        -- order:
                        -- XMOD - CMOD - MMOD
                        local mode = optionData.speedMod.mode
                        if mode == "C" then
                            mode = "M"
                        elseif mode == "M" then
                            mode = "X"
                        elseif mode == "X" then
                            mode = "C"
                        end
                        optionData.speedMod.mode = mode
                        setSpeedValueFromOptionData()
                    end,
                },
                ChoiceIndexGetter = function()
                    local mode = optionData.speedMod.mode
                    if mode == "X" then return 1
                    elseif mode == "C" then return 2
                    elseif mode == "M" then return 3 end
                end,
            },
            {
                Name = "Scroll Speed",
                Type = "",
                Directions = {
                    Left = function(multiplier)
                        local increment = -1
                        if multiplier then increment = -50 end
                        optionData.speedMod.speed = optionData.speedMod.speed + increment
                        setSpeedValueFromOptionData()
                    end,
                    Right = function(multiplier)
                        local increment = 1
                        if multiplier then increment = 50 end
                        optionData.speedMod.speed = optionData.speedMod.speed + increment
                        setSpeedValueFromOptionData()
                    end,
                },
                ChoiceIndexGetter = function()
                    local mode = optionData.speedMod.mode
                    local speed = optionData.speedMod.speed
                    if mode == "X" then
                        return mode .. notShit.round((speed/100), 2)
                    else
                        return mode .. speed
                    end
                end,
            },
            {
                Name = "Scroll Direction",
                Type = "",
                Choices = {
                    {
                        Name = "Upscroll",
                    },
                    {
                        Name = "Downscroll",
                    },
                },
                Directions = {
                    Toggle = function()
                        if getPlayerOptions():UsingReverse() then
                            -- 1 is 100% reverse which means on
                            setPlayerOptionsModValueAllLevels("Reverse", 1)
                        else
                            -- 0 is 0% reverse which means off
                            setPlayerOptionsModValueAllLevels("Reverse", 0)
                        end
                    end,
                },
                ChoiceIndexGetter = function()
                    if getPlayerOptions:UsingReverse() then
                        return 2
                    else
                        return 1
                    end
                end,
            },
            {
                Name = "Noteskin",
                Type = "",
                ChoiceIndexGetter = function()
                    local currentSkinName = getPlayerOptions():NoteSkin()
                    for i, name in ipairs(optionData.noteSkins.names) do
                        if name == currentSkinName then
                            return i
                        end
                    end
                    -- if function gets this far, look for the default skin
                    currentSkinName = THEME:GetMetric("Common", "DefaultNoteSkinName")
                    for i, name in ipairs(optionData.noteSkins.names) do
                        if name == currentSkinName then
                            return i
                        end
                    end
                    -- if function gets this far, cant find anything so just return the first skin
                    return 1
                end,
                ChoiceGenerator = function()
                    local o = {}
                    local skinNames = NOTESKIN:GetNoteSkinNames()
                    for i, name in ipairs(skinNames) do
                        o[#o+1] = {
                            Name = name,
                            ChosenFunction = function()
                                setPlayerOptionsModValueAllLevels("NoteSkin", name)
                            end,
                        }
                    end
                    table.sort(
                        o,
                        function(a, b)
                            return a.Name:lower() < b.Name:lower()
                        end)

                    return o
                end,
            },
            {
                Name = "Receptor Size",
                Type = "",
                Directions = {
                    Left = function()
                        local sz = optionData.receptorSize
                        sz = sz - 1
                        if sz < -200 then sz = 200 end
                        optionData.receptorSize = sz
                    end,
                    Right = function()
                        local sz = optionData.receptorSize
                        sz = sz + 1
                        if sz > 200 then sz = -200 end
                        optionData.receptorSize = sz
                    end,
                },
                ChoiceIndexGetter = function()
                    return optionData.receptorSize
                end,
            },
            {
                Name = "Judge Difficulty",
                Type = "",
                ChoiceIndexGetter = function()
                    return GetTimingDifficulty()
                end,
                ChoiceGenerator = function()
                    local o = {}
                    for i = 4, 8 do
                        o[#o+1] = {
                            Name = tostring(i),
                            ChosenFunction = function()
                                -- set judge
                                SetTimingDifficulty(i)
                            end,
                        }
                    end
                    o[#o+1] = {
                        Name = "Justice",
                        ChosenFunction = function()
                            -- sets j9
                            SetTimingDifficulty(9)
                        end,
                    }
                    return o
                end,
            },
            {
                Name = "Global Offset",
                Type = "",
                Directions = preferenceIncrementDecrementDirections("GlobalOffsetSeconds", -2, 2, 0.001),
                ChoiceIndexGetter = function()
                    return PREFSMAN:GetPreference("GlobalOffsetSeconds")
                end,
            },
            {
                Name = "Visual Delay",
                Type = "",
                Directions = preferenceIncrementDecrementDirections("VisualDelaySeconds", -2, 2, 0.001),
                ChoiceIndexGetter = function()
                    return PREFSMAN:GetPreference("VisualDelaySeconds")
                end,
            },
            {
                Name = "Game Mode",
                Type = "",
                ChoiceIndexGetter = function()
                    return strCapitalize(optionData.gameMode.current)
                end,
                ChoiceGenerator = function()
                    local o = {}
                    for i, name in ipairs(optionData.gameMode.modes) do
                        o[#o+1] = {
                            Name = strCapitalize(name),
                            ChosenFunction = function()
                                --GAMEMAN:SetGame(name)
                                optionData.gameMode.current = name
                            end,
                        }
                    end
                    return o
                end,
            },
            {
                Name = "Fail Type",
                Type = "",
                ChoiceIndexGetter = function()
                    local failtypes = FailType
                    local failtype = getPlayerOptions():FailSetting()
                    for i, name in ipairs(failtypes) do
                        if name == failtype then return i end
                    end
                    return 1
                end,
                ChoiceGenerator = function()
                    -- get the list of fail types
                    local failtypes = FailType
                    local o = {}
                    for i, name in ipairs(failtypes) do
                        o[#o+1] = {
                            Name = THEME:GetString("OptionNames", name:gsub("FailType_", "")),
                            ChosenFunction = function()
                                setPlayerOptionsModValueAllLevels("FailSetting", name)
                            end,
                        }
                    end
                    return o
                end,
            },
            {
                Name = "Customize Playfield",
                Type = "",
                Choices = {
                    {
                        Name = "Customize Playfield",
                        ChosenFunction = function()
                            -- activate customize gameplay screen
                        end,
                    }
                }
            },
            {
                Name = "Customize Keybinds",
                Type = "",
                Choices = {
                    {
                        Name = "Customize Keybinds",
                        ChosenFunction = function()
                            -- activate keybind screen
                        end,
                    }
                }
            },
        },
        ["Appearance Options"] = {
            {
                Name = "Appearance",
                Type = "",
                Choices = {
                    -- multiple choices allowed
                    floatSettingChoice("Hidden", "Hidden", 1, 0),
                    floatSettingChoice("HiddenOffset", "HiddenOffset", 1, 0),
                    floatSettingChoice("Sudden", "Sudden", 1, 0),
                    floatSettingChoice("SuddenOffset", "SuddenOffset", 1, 0),
                    floatSettingChoice("Stealth", "Stealth", 1, 0),
                    floatSettingChoice("Blink", "Blink", 1, 0)
                },
            },
            {
                Name = "Perspective",
                Type = "",
                Choices = {
                    -- the numbers in these defs are like the percentages you would put in metrics instead
                    -- 1 is 100%
                    -- Overhead does not use percentages.
                    -- adding an additional parameter to these functions does do something (approach rate) but is functionally useless
                    -- you are free to try these untested options for possible weird results:
                    -- setPlayerOptionsModValueAllLevels("Skew", x)
                    -- setPlayerOptionsModValueAllLevels("Tilt", x)
                    {
                        Name = "Overhead",
                        ChosenFunction = function()
                            setPlayerOptionsModValueAllLevels("Overhead", true)
                        end,
                    },
                    {
                        Name = "Incoming",
                        ChosenFunction = function()
                            setPlayerOptionsModValueAllLevels("Incoming", 1)
                        end,
                    },
                    {
                        Name = "Space",
                        ChosenFunction = function()
                            setPlayerOptionsModValueAllLevels("Space", 1)
                        end,
                    },
                    {
                        Name = "Hallway",
                        ChosenFunction = function()
                            setPlayerOptionsModValueAllLevels("Hallway", 1)
                        end,
                    },
                    {
                        Name = "Distant",
                        ChosenFunction = function()
                            setPlayerOptionsModValueAllLevels("Distant", 1)
                        end,
                    },
                },
                ChoiceIndexGetter = function()
                    local po = getPlayerOptions()
                    -- we unfortunately choose to hardcode these options and not allow an additional custom one
                    -- but the above choice definitions allow customizing the specific Perspective to whatever extent you want
                    if po:Overhead() then return 1
                    elseif po:Incoming() ~= nil then return 2
                    elseif po:Space() ~= nil then return 3
                    elseif po:Hallway() ~= nil then return 4
                    elseif po:Distant() ~= nil then return 5
                    end
                    return 1 -- 1 should be Overhead ....
                end,
            },
            {
                Name = "Mirror",
                Type = "",
                Choices = {
                    {
                        Name = "On",
                    },
                    {
                        Name = "Off",
                    }
                },
                Directions = {
                    Toggle = function()
                        local po = getPlayerOptions()
                        if po:Mirror() then
                            setPlayerOptionsModValueAllLevels("Mirror", false)
                        else
                            setPlayerOptionsModValueAllLevels("Mirror", true)
                        end
                    end,
                },
                ChoiceIndexGetter = function()
                    if getPlayerOptions():Mirror() then
                        return 1
                    else
                        return 2
                    end
                end,
            },
            {
                Name = "Hide Player UI",
                Type = "",
                Choices = {
                    floatSettingChoice("Hide Receptors", "Dark", 1, 0),
                    floatSettingChoice("Hide Judgment & Combo", "Blind", 1, 0),
                },
            },
            {
                Name = "Hidenote Judgment",
                Type = "",
                Choices = {
                    {
                        Name = "Miss",
                        ChosenFunction = function()
                            PREFSMAN:SetPreference("MinTNSToHideNotes", "TNS_Miss")
                        end,
                    },
                    {
                        Name = "Bad",
                        ChosenFunction = function()
                            PREFSMAN:SetPreference("MinTNSToHideNotes", "TNS_W5")
                        end,
                    },
                    {
                        Name = "Good",
                        ChosenFunction = function()
                            PREFSMAN:SetPreference("MinTNSToHideNotes", "TNS_W4")
                        end,
                    },
                    {
                        Name = "Great",
                        ChosenFunction = function()
                            PREFSMAN:SetPreference("MinTNSToHideNotes", "TNS_W3")
                        end,
                    },
                    {
                        Name = "Perfect",
                        ChosenFunction = function()
                            PREFSMAN:SetPreference("MinTNSToHideNotes", "TNS_W2")
                        end,
                    },
                    {
                        Name = "Marvelous",
                        ChosenFunction = function()
                            PREFSMAN:SetPreference("MinTNSToHideNotes", "TNS_W1")
                        end,
                    },
                },
                ChoiceIndexGetter = function()
                    local opt = PREFSMAN:GetPreference("MinTNSToHideNotes")
                    if opt == "TNS_Miss" then return 1
                    elseif opt == "TNS_W5" then return 2
                    elseif opt == "TNS_W4" then return 3
                    elseif opt == "TNS_W3" then return 4
                    elseif opt == "TNS_W2" then return 5
                    elseif opt == "TNS_W1" then return 6
                    else
                        return 4 -- this is the default option so default to this
                    end
                end,
            },
            {
                Name = "Default Centered NoteField",
                Type = "",
                Choices = {
                    {
                        Name = "Yes",
                    },
                    {
                        Name = "No",
                    }
                },
                Directions = {
                    Toggle = function()
                        if PREFSMAN:GetPreference("Center1Player") then
                            PREFSMAN:SetPreference("Center1Player", false)
                        else
                            PREFSMAN:SetPreference("Center1Player", true)
                        end
                    end,
                },
                ChoiceIndexGetter = function()
                    if PREFSMAN:GetPreference("Center1Player") then
                        return 1
                    else
                        return 2
                    end
                end,
            },
            {
                Name = "NoteField BG Opacity",
                Type = "",
                ChoiceGenerator = function()
                    local o = {}
                    for i = 0, 10 do
                        o[#o+1] = {
                            Name = i.."%",
                            ChosenFunction = function()
                                optionData.screenFilter = notShit.round(i / 10, 1)
                            end,
                        }
                    end
                    return o
                end,
                ChoiceIndexGetter = function()
                    local v = notShit.round(optionData.screenFilter, 1)
                    local ind = notShit.round(v * 10, 0) + 1
                    if ind > 0 and ind < 11 then -- this 11 should match the number of choices above
                        return ind
                    else
                        if ind <= 0 then
                            return 1
                        else
                            return 11
                        end
                    end
                end,
            },
            {
                Name = "Background Brightness",
                Type = "",
                ChoiceGenerator = function()
                    local o = {}
                    for i = 0, 10 do
                        o[#o+1] = {
                            Name = i.."%",
                            ChosenFunction = function()
                                PREFSMAN:SetPreference("BGBrightness", notShit.round(i / 10, 1))
                            end,
                        }
                    end
                    return o
                end,
                ChoiceIndexGetter = function()
                    local v = notShit.round(PREFSMAN:GetPreference("BGBrightness"))
                    local ind = notShit.round(v * 10, 0) + 1
                    if ind > 0 and ind < 11 then -- this 11 should match the nubmer of choices above
                        return ind
                    else
                        if ind <= 0 then
                            return 1
                        else
                            return 11
                        end
                    end
                end,
            },
            {
                Name = "Replay Mod Emulation",
                Type = "",
                Choices = {
                    {
                        Name = "On",
                    },
                    {
                        Name = "Off",
                    }
                },
                Directions = {
                    Toggle = function()
                        if PREFSMAN:GetPreference("ReplaysUseScoreMods") then
                            PREFSMAN:SetPreference("ReplaysUseScoreMods", false)
                        else
                            PREFSMAN:SetPreference("ReplaysUseScoreMods", true)
                        end
                    end,
                },
                ChoiceIndexGetter = function()
                    if PREFSMAN:GetPreference("ReplaysUseScoreMods") then
                        return 1
                    else
                        return 2
                    end
                end,
            },
            {
                Name = "Extra Scroll Mods",
                Type = "",
                Choices = {
                    floatSettingChoice("Split", "Split", 1, 0),
                    floatSettingChoice("Alternate", "Alternate", 1, 0),
                    floatSettingChoice("Cross", "Cross", 1, 0),
                    floatSettingChoice("Centered", "Centered", 1, 0),
                },
            },
            {
                Name = "Fun Effects",
                Type = "",
                Choices = {
                    floatSettingChoice("Drunk", "Drunk", 1, 0),
                    floatSettingChoice("Confusion", "Confusion", 1, 0),
                    floatSettingChoice("Tiny", "Tiny", 1, 0),
                    floatSettingChoice("Flip", "Flip", 1, 0),
                    floatSettingChoice("Invert", "Invert", 1, 0),
                    floatSettingChoice("Tornado", "Tornado", 1, 0),
                    floatSettingChoice("Tipsy", "Tipsy", 1, 0),
                    floatSettingChoice("Bumpy", "Bumpy", 1, 0),
                    floatSettingChoice("Beat", "Beat", 1, 0),
                    -- X-Mode is dead because it relies on player 2!! -- floatSettingChoice("X-Mode"),
                    floatSettingChoice("Twirl", "Twirl", 1, 0),
                    floatSettingChoice("Roll", "Roll", 1, 0),
                },
            },
            {
                Name = "Acceleration",
                Type = "",
                Choices = {
                    floatSettingChoice("Boost", "Boost", 1, 0),
                    floatSettingChoice("Brake", "Brake", 1, 0),
                    floatSettingChoice("Wave", "Wave", 1, 0),
                    floatSettingChoice("Expand", "Expand", 1, 0),
                    floatSettingChoice("Boomerang", "Boomerang", 1, 0),
                },
            }
        },
        ["Invalidating Options"] = {
            {
                Name = "Mines",
                Type = "",
                Choices = {
                    {
                        Name = "On",
                        ChosenFunction = function()
                            setPlayerOptionsModValueAllLevels("NoMines", false)
                            setPlayerOptionsModValueAllLevels("Mines", false)
                        end,
                    },
                    {
                        Name = "Off",
                        ChosenFunction = function()
                            setPlayerOptionsModValueAllLevels("NoMines", true)
                            setPlayerOptionsModValueAllLevels("Mines", false)
                        end,
                    },
                    {
                        Name = "Additive",
                        ChosenFunction = function()
                            setPlayerOptionsModValueAllLevels("NoMines", false)
                            setPlayerOptionsModValueAllLevels("Mines", true)
                        end,
                    }
                },
                ChoiceIndexGetter = function()
                    local po = getPlayerOptions()
                    if po:Mines() then
                        -- additive mines, invalidating
                        return 3
                    elseif po:NoMines() then
                        -- nomines, invalidating
                        return 2
                    else
                        -- regular mines, not invalidating
                        return 1
                    end
                end,
            },
            {
                Name = "Turn",
                Type = "",
                Choices = {
                    booleanSettingChoice("Backwards", "Backwards"),
                    booleanSettingChoice("Left", "Left"),
                    booleanSettingChoice("Right", "Right"),
                    booleanSettingChoice("Shuffle", "Shuffle"),
                    booleanSettingChoice("Soft Shuffle", "SoftShuffle"),
                    booleanSettingChoice("Super Shuffle", "SuperShuffle"),
                }
            },
            {
                Name = "Pattern Transform",
                Type = "",
                Choices = {
                    booleanSettingChoice("Echo", "Echo"),
                    booleanSettingChoice("Stomp", "Stomp"),
                    booleanSettingChoice("Jack JS", "JackJS"),
                    booleanSettingChoice("Anchor JS", "AnchorJS"),
                    booleanSettingChoice("IcyWorld", "IcyWorld"),
                },
            },
            {
                Name = "Hold Transform",
                Type = "",
                Choices = {
                    booleanSettingChoice("Planted", "Planted"),
                    booleanSettingChoice("Floored", "Floored"),
                    booleanSettingChoice("Twister", "Twister"),
                    booleanSettingChoice("Holds To Rolls", "HoldRolls"),
                },
            },
            {
                Name = "Remove",
                Type = "",
                Choices = {
                    booleanSettingChoice("No Holds", "NoHolds"),
                    booleanSettingChoice("No Rolls", "NoRolls"),
                    booleanSettingChoice("No Jumps", "NoJumps"),
                    booleanSettingChoice("No Hands", "NoHands"),
                    booleanSettingChoice("No Lifts", "NoLifts"),
                    booleanSettingChoice("No Fakes", "NoFakes"),
                    booleanSettingChoice("No Quads", "NoQuads"),
                    booleanSettingChoice("No Stretch", "NoStretch"),
                    booleanSettingChoice("Little", "Little"),
                },
            },
            {
                Name = "Insert",
                Type = "",
                Choices = {
                    booleanSettingChoice("Wide", "Wide"),
                    booleanSettingChoice("Big", "Big"),
                    booleanSettingChoice("Quick", "Quick"),
                    booleanSettingChoice("BMR-ize", "BMRize"),
                    booleanSettingChoice("Skippy", "Skippy"),
                },
            }
        },
        --
        -----
        -- GRAPHICS OPTIONS
        ["Global Options"] = {
            {
                Name = "Language",
                Type = "",
                ChoiceGenerator = function()
                    local o = {}
                    for i, l in ipairs(optionData.language.list) do
                        o[#o+1] = {
                            Name = l,
                            ChosenFunction = function()
                                optionData.language.current = l
                            end,
                        }
                    end
                    return o
                end,
                ChoiceIndexGetter = function()
                    for i, l in ipairs(optionData.language.list) do
                        if l == optionData.language.current then return i end
                    end
                    return 1
                end,
            },
            {
                Name = "Display Mode",
                Type = "",
                AssociatedOptions = {
                    "Aspect Ratio",
                    "Display Resolution",
                    "Refresh Rate",
                },
                -- the idea behind Display Mode is to also allow selecting a Display to show the game
                -- it is written into the lua side of the c++ options conf but unused everywhere as far as i know except maybe in linux
                -- so here lets just hardcode windowed/fullscreen until that feature becomes a certain reality
                -- and lets just all borderless here so that the options are simplified just a bit
                Choices = {
                    {
                        Name = "Windowed",
                        ChosenFunction = function()
                            PREFSMAN:SetPreference("Windowed", true)
                            PREFSMAN:SetPreference("FullscreenIsBorderlessWindow", false)
                        end,
                    },
                    {
                        Name = "Fullscreen",
                        ChosenFunction = function()
                            PREFSMAN:SetPreference("Windowed", false)
                            PREFSMAN:SetPreference("FullscreenIsBorderlessWindow", false)
                        end,
                    },
                    {
                        -- funny thing about this preference is that it doesnt force fullscreen
                        -- so you have to pick the right resolution for it to work
                        Name = "Borderless",
                        ChosenFunction = function()
                            PREFSMAN:SetPreference("Windowed", false)
                            PREFSMAN:SetPreference("FullscreenIsBorderlessWindow", true)
                        end,
                    }

                },
                ChoiceIndexGetter = function()
                    if PREFSMAN:GetPreference("FullscreenIsBorderlessWindow") then
                        return 3
                    elseif PREFSMAN:GetPreference("Windowed") then
                        return 1
                    else
                        -- fullscreen exclusive
                        return 2
                    end
                end,
            },
            {
                Name = "Aspect Ratio",
                Type = "",
                AssociatedOptions = {
                    "Display Resolution"
                },
                ChoiceGenerator = function()
                    local o = {}
                    local isWindowed = PREFSMAN:GetPreference("Windowed")
                    local curDisplayId = PREFSMAN:GetPreference("DisplayId")
                    local ratios = isWindowed and optionData.display.wRatios or (optionData.display.dRatios[curDisplayId] or optionData.display.dRatios[displaySpecs[1]:GetId()])
                    -- this is some super obscure function we have that sorts table keys and then runs a function over its pairs
                    -- im basically copying the code here from fallback scripts DisplaySpecs
                    foreach_ordered(ratios, function(_, ratio)
                        -- ratio is a fraction, d is denominator and n is numerator
                        local v = ratio.n / ratio.d
                        o[#o+1] = {
                            Name = ratio.n .. ":" .. ratio.d,
                            ChosenFunction = function()
                                PREFSMAN:SetPreference("DisplayAspectRatio", v)
                                optionData.display.loadedAspectRatio = v
                            end,
                        }
                    end)
                    return o
                end,
                ChoiceIndexGetter = function()
                    local closestdiff = 100
                    local closestindex = 1
                    local isWindowed = PREFSMAN:GetPreference("Windowed")
                    local curDisplayId = PREFSMAN:GetPreference("DisplayId")
                    local ratios = isWindowed and optionData.display.wRatios or (optionData.display.dRatios[curDisplayId] or optionData.display.dRatios[displaySpecs[1]:GetId()])
                    foreach_ordered(ratios, function(i, ratio)
                        local v = ratio.n / ratio.d
                        local diff = math.abs(v - optionData.display.loadedAspectRatio)
                        if diff < closestdiff then
                            closestdiff = diff
                            closestindex = i
                        end
                    end)
                    return closestindex
                end,
            },
            {
                Name = "Display Resolution",
                Type = "",
                AssociatedOptions = {
                    "Refresh Rate",
                },
                ChoiceGenerator = function()
                    local isWindowed = PREFSMAN:GetPreference("Windowed")
                    local curDisplay = displaySpecs:ById(PREFSMAN:GetPreference("DisplayId"))
                    local curRatio = optionData.display.loadedAspectRatio ~= 0 and optionData.display.loadedAspectRatio or PREFSMAN:GetPreference("DisplayAspectRatio")
                    local resolutions = isWindowed and GetFeasibleWindowSizesForRatio(displaySpecs, curRatio) or GetDisplayResolutionsForRatio(curDisplay, curRatio)
                    local w = PREFSMAN:GetPreference("DisplayWidth")
            		local h = PREFSMAN:GetPreference("DisplayHeight")
                    local o = {}
                    for _, resRect in ipairs(resolutions) do
                        -- resRect is a rectangle and contains a width w and a height h
                        local dist = math.sqrt((resRect.w - w)^2 + (resRect.h - h)^2)
                        o[#o+1] = {
                            Name = resRect.w .. "x" .. resRect.h,
                            ChosenFunction = function()
                                PREFSMAN:SetPreference("DisplayWidth", resRect.w)
                                PREFSMAN:SetPreference("DisplayHeight", resRect.h)
                            end,
                        }
                    end
                    return o
                end,
                ChoiceIndexGetter = function()
                    local isWindowed = PREFSMAN:GetPreference("Windowed")
                    local curDisplay = displaySpecs:ById(PREFSMAN:GetPreference("DisplayId"))
                    local curRatio = optionData.display.loadedAspectRatio ~= 0 and optionData.display.loadedAspectRatio or PREFSMAN:GetPreference("DisplayAspectRatio")
                    local resolutions = isWindowed and GetFeasibleWindowSizesForRatio(displaySpecs, curRatio) or GetDisplayResolutionsForRatio(curDisplay, curRatio)
                    local closestindex = 1
                    local mindist = -1
                    local w = PREFSMAN:GetPreference("DisplayWidth")
            		local h = PREFSMAN:GetPreference("DisplayHeight")
                    for i, resRect in ipairs(resolutions) do
                        -- resRect is a rectangle and contains a width w and a height h
                        local dist = math.sqrt((resRect.w - w)^2 + (resRect.h - h)^2)
                        if mindist == -1 or dist < mindist then
                            mindist = dist
                            closestindex = i
                        end
                    end
                    return closestindex
                end,
            },
            {
                Name = "Refresh Rate",
                Type = "",
                ChoiceGenerator = function()
                    local isWindowed = PREFSMAN:GetPreference("Windowed")
                    local d = displaySpecs:ById(PREFSMAN:GetPreference("DisplayId"))
                    local w = PREFSMAN:GetPreference("DisplayWidth")
                    local h = PREFSMAN:GetPreference("DisplayHeight")
                    local rates = isWindowed and {} or GetDisplayRatesForResolution(d, w, h)
                    local o = {
                        {
                            Name = "Default",
                            ChosenFunction = function()
                                PREFSMAN:SetPreference("RefreshRate", REFRESH_DEFAULT)
                            end,
                        },
                    }
                    for _, rate in ipairs(rates) do
                        o[#o+1] = {
                            Name = math.round(rate),
                            ChosenFunction = function()
                                PREFSMAN:SetPreference("RefreshRate", math.round(rate))
                            end,
                        }
                    end
                    return o
                end,
                ChoiceIndexGetter = function()
                    local isWindowed = PREFSMAN:GetPreference("Windowed")
                    local d = displaySpecs:ById(PREFSMAN:GetPreference("DisplayId"))
                    local w = PREFSMAN:GetPreference("DisplayWidth")
                    local h = PREFSMAN:GetPreference("DisplayHeight")
                    local rates = isWindowed and {} or GetDisplayRatesForResolution(d, w, h)
                    local o = {
                        {
                            Name = "Default",
                            ChosenFunction = function()
                                PREFSMAN:SetPreference("RefreshRate", REFRESH_DEFAULT)
                            end,
                        },
                    }
                    for _, rate in ipairs(rates) do
                        o[#o+1] = {
                            Name = math.round(rate),
                            ChosenFunction = function()
                                PREFSMAN:SetPreference("RefreshRate", math.round(rate))
                            end,
                        }
                    end
                end,
            },
            {
                Name = "Display Color Depth",
                Type = "",
                Choices = {
                    basicNamedPreferenceChoice("DisplayColorDepth", "16bit", 16),
                    basicNamedPreferenceChoice("DisplayColorDepth", "32bit", 32),
                },
                ChoiceIndexGetter = function()
                    local v = PREFSMAN:GetPreference("DisplayColorDepth")
                    if v == 16 then return 1
                    elseif v == 32 then return 2
                    end
                    return 1
                end,
            },
            {
                Name = "Force High Resolution Textures",
                Type = "",
                Choices = {
                    {
                        Name = "Yes",
                    },
                    {
                        Name = "No",
                    },
                },
                Directions = {
                    Toggle = function()
                        if PREFSMAN:GetPreference("HighResolutionTextures") then
                            PREFSMAN:SetPreference("HighResolutionTextures", false)
                        else
                            PREFSMAN:SetPreference("HighResolutionTextures", true)
                        end
                    end,
                },
                ChoiceIndexGetter = function()
                    if PREFSMAN:GetPreference("HighResolutionTextures") then
                        return 1
                    else
                        return 2
                    end
                end,
            },
            {
                Name = "Texture Resolution",
                Type = "",
                Choices = {
                    basicNamedPreferenceChoice("MaxTextureResolution", "256", 256),
                    basicNamedPreferenceChoice("MaxTextureResolution", "512", 512),
                    basicNamedPreferenceChoice("MaxTextureResolution", "1024", 1024),
                    basicNamedPreferenceChoice("MaxTextureResolution", "2048", 2048),
                },
                ChoiceIndexGetter = function()
                    local v = PREFSMAN:GetPreference("MaxTextureResolution")
                    if v == 256 then return 1
                    elseif v == 512 then return 2
                    elseif v == 1024 then return 3
                    elseif v == 2048 then return 4
                    end
                    return 1
                end,
            },
            {
                Name = "Texture Color Depth",
                Type = "",
                Choices = {
                    basicNamedPreferenceChoice("TextureColorDepth", "16bit", 16),
                    basicNamedPreferenceChoice("TextureColorDepth", "32bit", 32),
                },
                ChoiceIndexGetter = function()
                    local v = PREFSMAN:GetPreference("TextureColorDepth")
                    if v == 16 then return 1
                    elseif v == 32 then return 2
                    end
                    return 1
                end,
            },
            {
                Name = "Movie Color Depth",
                Type = "",
                Choices = {
                    basicNamedPreferenceChoice("MovieColorDepth", "16bit", 16),
                    basicNamedPreferenceChoice("MovieColorDepth", "32bit", 32),
                },
                ChoiceIndexGetter = function()
                    local v = PREFSMAN:GetPreference("MovieColorDepth")
                    if v == 16 then return 1
                    elseif v == 32 then return 2
                    end
                    return 1
                end,
            },
            {
                Name = "VSync",
                Type = "",
                Choices = {
                    {
                        Name = "On",
                    },
                    {
                        Name = "Off",
                    },
                },
                Directions = {
                    Toggle = function()
                        if PREFSMAN:GetPreference("Vsync") then
                            PREFSMAN:SetPreference("Vsync", false)
                        else
                            PREFSMAN:SetPreference("Vsync", true)
                        end
                    end,
                },
                ChoiceIndexGetter = function()
                    if PREFSMAN:GetPreference("Vsync") then
                        return 1
                    else
                        return 2
                    end
                end,
            },
            {
                Name = "Instant Search",
                Type = "",
                Choices = {
                    {
                        Name = "On",
                    },
                    {
                        Name = "Off",
                    },
                },
                Directions = {
                    Toggle = function()
                        if optionData.instantSearch then
                            optionData.instantSearch = false
                        else
                            optionData.instantSearch = true
                        end
                    end,
                },
                ChoiceIndexGetter = function()
                    if optionData.instantSearch then
                        return 1
                    else
                        return 2
                    end
                end,
            },
            {
                Name = "Fast Note Rendering",
                Type = "",
                Choices = {
                    {
                        Name = "On",
                    },
                    {
                        Name = "Off",
                    },
                },
                Directions = {
                    Toggle = function()
                        if PREFSMAN:GetPreference("FastNoteRendering") then
                            PREFSMAN:SetPreference("FastNoteRendering", false)
                        else
                            PREFSMAN:SetPreference("FastNoteRendering", true)
                        end
                    end,
                },
                ChoiceIndexGetter = function()
                    if PREFSMAN:GetPreference("FastNoteRendering") then
                        return 1
                    else
                        return 2
                    end
                end,
            },
            {
                Name = "Show Stats",
                Type = "",
                Choices = {
                    {
                        Name = "On",
                    },
                    {
                        Name = "Off",
                    },
                },
                Directions = {
                    Toggle = function()
                        if PREFSMAN:GetPreference("ShowStats") then
                            PREFSMAN:SetPreference("ShowStats", false)
                        else
                            PREFSMAN:SetPreference("ShowStats", true)
                        end
                    end,
                }
            },
        },
        ["Appearance Options"] = {
            {
                Name = "Theme",
                Type = "",
            },
            {
                Name = "Music Wheel Position",
                Type = "",
            },
            {
                Name = "Show Backgrounds",
                Type = "",
            },
            {
                Name = "Toasties",
                Type = "",
            },
            {
                Name = "Music Visualizer",
                Type = "",
            },
            {
                Name = "Mid Grades",
                Type = "",
            },
            {
                Name = "SSRNorm Sort",
                Type = "",
            },
            {
                Name = "Show Lyrics",
                Type = "",
            },
            {
                Name = "Transliteration",
                Type = "",
            },
            {
                Name = "Tip Type",
                Type = "",
            },
            {
                Name = "Set BG Fit Mode",
                Type = "",
            },
            {
                Name = "Color Config",
                Type = "",
            },
            {
                Name = "Overscan Correction",
                Type = "",
            },
        },
        --
        -----
        -- SOUND OPTIONS
        ["Sound Options"] = {
            {
                Name = "Volume",
                Type = "",
            },
            {
                Name = "Menu Sounds",
                Type = "",
            },
            {
                Name = "Mine Sounds",
                Type = "",
            },
            {
                Name = "Pitch on Rates",
                Type = "",
            },
            {
                Name = "Calibrate Audio Sync",
                Type = "",
            },
        },
        --
        -----
        -- INPUT OPTIONS
        ["Input Options"] = {
            {
                Name = "everthin in advance input optns",
                Type = "",
            },
            {
                Name = "Test Input",
                Type = "",
            },
        },
        --
        -----
        -- PROFILE OPTIONS
        ["Profile Options"] = {
            {
                Name = "Create Profile",
                Type = "",
            },
            {
                Name = "Rename Profile",
                Type = "",
            },
        },
    }
    -- check for choice generators on any option definitions and execute them
    for categoryName, categoryDefinition in pairs(optionDefs) do
        for i, optionDef in ipairs(categoryDefinition) do
            if optionDef.Choices == nil and optionDef.ChoiceGenerator ~= nil then
                optionDefs[categoryName][i].Choices = optionDef.ChoiceGenerator()
            end
        end
    end

    local function createOptionPageChoices()
        local selectedIndex = 1
    
        local function createChoice(i)
            return UIElements.TextButton(1, 1, "Common Normal") .. {
                Name = "ButtonTab_"..pageNames[i],
                InitCommand = function(self)
                    local txt = self:GetChild("Text")
                    local bg = self:GetChild("BG")
    
                    -- this position is the center of the text
                    -- divides the space into slots for the choices then places them half way into them
                    -- should work for any count of choices
                    -- and the maxwidth will make sure they stay nonoverlapping
                    self:x((actuals.RightWidth / #pageNames) * (i-1) + (actuals.RightWidth / #pageNames / 2))
                    txt:zoom(choiceTextSize)
                    txt:maxwidth(actuals.RightWidth / #pageNames / choiceTextSize - textZoomFudge)
                    txt:settext(pageNames[i])
                    bg:zoomto(actuals.RightWidth / #pageNames, actuals.TopLipHeight)
                end,
                UpdateSelectedIndexCommand = function(self)
                    local txt = self:GetChild("Text")
                    if selectedIndex == i then
                        txt:strokecolor(buttonActiveStrokeColor)
                    else
                        txt:strokecolor(color("0,0,0,0"))
                    end
                end,
                ClickCommand = function(self, params)
                    if self:IsInvisible() then return end
                    if params.update == "OnMouseDown" then
                        selectedIndex = i
                        MESSAGEMAN:Broadcast("GeneralTabSet", {tab = i})
                        self:GetParent():playcommand("UpdateSelectedIndex")
                    end
                end,
                RolloverUpdateCommand = function(self, params)
                    if self:IsInvisible() then return end
                    if params.update == "in" then
                        self:diffusealpha(buttonHoverAlpha)
                    else
                        self:diffusealpha(1)
                    end
                end
            }
        end
        local t = Def.ActorFrame {
            Name = "Choices",
            InitCommand = function(self)
                self:y(actuals.TopLipHeight * 1.5)
                self:playcommand("UpdateSelectedIndex")
            end,
            BeginCommand = function(self)
                local snm = SCREENMAN:GetTopScreen():GetName()
                local anm = self:GetName()

                CONTEXTMAN:RegisterToContextSet(snm, "Settings", anm)
                CONTEXTMAN:ToggleContextSet(snm, "Settings", false)
    
                -- enable the possibility to press the keyboard to switch tabs
                SCREENMAN:GetTopScreen():AddInputCallback(function(event)
                    -- if locked out, dont allow
                    if not CONTEXTMAN:CheckContextSet(snm, "Settings") then return end
                    if event.type == "InputEventType_FirstPress" then
                        -- nothing
                        -- will use arrows to place cursor
                        -- dummy complex probably not going to be in this spot
                    end
                end)
            end
        }
        for i = 1, #pageNames do
            t[#t+1] = createChoice(i)
        end
        return t
    end

    t[#t+1] = createOptionPageChoices()

    return t
end

t[#t+1] = leftFrame()
t[#t+1] = rightFrame()

return t