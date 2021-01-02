local t = Def.ActorFrame {
    Name = "PlayerInfoFrame",
    LoginMessageCommand = function(self)
        self:playcommand("Set")
        ms.ok("Login Successful")
    end,
    LogOutMessageCommand = function(self)
        self:playcommand("Set")
    end,
    LoginFailedMessageCommand = function(self)
        self:playcommand("Set")
    end,
    OnlineUpdateMessageCommand = function(self)
        self:playcommand("Set")
    end
}

local visEnabled = Var("visualizer")
local loadingScreenName = Var("screen")

local ratios = {
    Height = 109 / 1080, -- frame height
    Width = 1, -- full screen width
    AvatarWidth = 109 / 1080, -- this should end up square
    ConnectionLogoRightGap = 0 / 1080, -- logo position relative to the right edge of avatar (height based for square)
    ConnectionLogoBottomGap = 0 / 1080, -- same as above
    ConnectionLogoSize = 36 / 1080, -- this is 36x36
    LeftTextLeftGap = 8 / 1920, -- this is after the avatar
    LeftTextTopGap1 = 24 / 1080, -- from top to center of line 1
    LeftTextTopGap2 = 49 / 1080, -- from top to center of line 2
    LeftTextTopGap3 = 72 / 1080, -- from top to center of line 3
    LeftTextTopGap4 = 95 / 1080, -- from top to center of line 4
    RightTextLeftGap = 412 / 1920, -- this is from avatar to right text
    RightTextTopGap1 = 21 / 1080, -- why did this have to be different from Left line 1
    RightTextTopGap2 = 54 / 1080, -- from top to center of line 2
    RightTextTopGap3 = 89 / 1080, -- from top to center of line 3
    VisualizerLeftGap = 707 / 1920, -- from left side of screen to leftmost bin
    VisualizerWidth = 693 / 1920,

    RatingEdgeToVisualizerBuffer = 32 / 1920,
    RatingSideBuffer = 25 / 1920, -- an area of buffer to the left and right of the player rating text

    IconUpperGap = 36 / 1080,
    IconExitWidth = 47 / 1920,
    IconExitHeight = 36 / 1080,
    IconExitRightGap = 38 / 1920, -- from right side of screen to right end of icon
    IconSettingsWidth = 44 / 1920,
    IconSettingsHeight = 35 / 1080,
    IconSettingsRightGap = 123 / 1920,
    IconHelpWidth = 36 / 1920,
    IconHelpHeight = 36 / 1080,
    IconHelpRightGap = 205 / 1920,
    IconDownloadsWidth = 51 / 1920,
    IconDownloadsHeight = 36 / 1080,
    IconDownloadsRightGap = 278 / 1920,
    IconRandomWidth = 41 / 1920,
    IconRandomHeight = 36 / 1080,
    IconRandomRightGap = 367 / 1920,
    IconSearchWidth = 36 / 1920,
    IconSearchHeight = 36 / 1080,
    IconSearchRightGap = 446 / 1920,
}

local actuals = {
    Height = ratios.Height * SCREEN_HEIGHT,
    Width = ratios.Width * SCREEN_WIDTH,
    AvatarWidth = ratios.AvatarWidth * SCREEN_HEIGHT,
    ConnectionLogoRightGap = ratios.ConnectionLogoRightGap * SCREEN_HEIGHT,
    ConnectionLogoBottomGap = ratios.ConnectionLogoBottomGap * SCREEN_HEIGHT,
    ConnectionLogoSize = ratios.ConnectionLogoSize * SCREEN_HEIGHT,
    LeftTextLeftGap = ratios.LeftTextLeftGap * SCREEN_WIDTH,
    LeftTextTopGap1 = ratios.LeftTextTopGap1 * SCREEN_HEIGHT,
    LeftTextTopGap2 = ratios.LeftTextTopGap2 * SCREEN_HEIGHT,
    LeftTextTopGap3 = ratios.LeftTextTopGap3 * SCREEN_HEIGHT,
    LeftTextTopGap4 = ratios.LeftTextTopGap4 * SCREEN_HEIGHT,
    RightTextLeftGap = ratios.RightTextLeftGap * SCREEN_WIDTH,
    RightTextTopGap1 = ratios.RightTextTopGap1 * SCREEN_HEIGHT,
    RightTextTopGap2 = ratios.RightTextTopGap2 * SCREEN_HEIGHT,
    RightTextTopGap3 = ratios.RightTextTopGap3 * SCREEN_HEIGHT,
    VisualizerLeftGap = ratios.VisualizerLeftGap * SCREEN_WIDTH,
    VisualizerWidth = ratios.VisualizerWidth * SCREEN_WIDTH,

    RatingEdgeToVisualizerBuffer = ratios.RatingEdgeToVisualizerBuffer * SCREEN_WIDTH,
    RatingSideBuffer = ratios.RatingSideBuffer * SCREEN_WIDTH,

    IconUpperGap = ratios.IconUpperGap * SCREEN_HEIGHT,
    IconExitWidth = ratios.IconExitWidth * SCREEN_WIDTH,
    IconExitHeight = ratios.IconExitHeight * SCREEN_HEIGHT,
    IconExitRightGap = ratios.IconExitRightGap * SCREEN_WIDTH,
    IconSettingsWidth = ratios.IconSettingsWidth * SCREEN_WIDTH,
    IconSettingsHeight = ratios.IconSettingsHeight * SCREEN_HEIGHT,
    IconSettingsRightGap = ratios.IconSettingsRightGap * SCREEN_WIDTH,
    IconHelpWidth = ratios.IconHelpWidth * SCREEN_WIDTH,
    IconHelpHeight = ratios.IconHelpHeight * SCREEN_HEIGHT,
    IconHelpRightGap = ratios.IconHelpRightGap * SCREEN_WIDTH,
    IconDownloadsWidth = ratios.IconDownloadsWidth * SCREEN_WIDTH,
    IconDownloadsHeight = ratios.IconDownloadsHeight * SCREEN_HEIGHT,
    IconDownloadsRightGap = ratios.IconDownloadsRightGap * SCREEN_WIDTH,
    IconRandomWidth = ratios.IconRandomWidth * SCREEN_WIDTH,
    IconRandomHeight = ratios.IconRandomHeight * SCREEN_HEIGHT,
    IconRandomRightGap = ratios.IconRandomRightGap * SCREEN_WIDTH,
    IconSearchWidth = ratios.IconSearchWidth * SCREEN_WIDTH,
    IconSearchHeight = ratios.IconSearchHeight * SCREEN_HEIGHT,
    IconSearchRightGap = ratios.IconSearchRightGap * SCREEN_WIDTH,
}

-- the list of buttons and the lists of screens those buttons are allowed on
-- if "All" is listed, the button is always active
local screensAllowedForButtons = {
    Exit = {
        All = true,
    },
    Settings = {

    },
    Help = {

    },
    Downloads = {
        ScreenSelectMusic = true,
    },
    Random = {
        ScreenSelectMusic = true,
    },
    Search = {
        ScreenSelectMusic = true,
    },
}

-- find out if a button from the above list is selectable based on the current screen
-- wont work on Init, only when the screen exists (at or after BeginCommand)
local function selectable(name)
    local screen = loadingScreenName
    return screensAllowedForButtons[name]["All"] ~= nil or screensAllowedForButtons[name][screen]
end

local disabledButtonAlpha = 0.4
local hoverAlpha = 0.6
local visualizerBins = 126
local leftTextBigSize = 0.7
local leftTextSmallSize = 0.65
local rightTextSize = 0.7
local textzoomFudge = 5 -- for gaps in maxwidth
-- a controllable hack to give more girth to the rating text (RightText) on smaller aspect ratios
-- should push the visualizer further right and make less problems
local textzoomBudge = 25

local profile = GetPlayerOrMachineProfile(PLAYER_1)
local pname = profile:GetDisplayName()
local pcount = SCOREMAN:GetTotalNumberOfScores()
local parrows = profile:GetTotalTapsAndHolds()
local strparrows = shortenIfOver1Mil(parrows)
local ptime = profile:GetTotalSessionSeconds()
local username = ""
local redir = false -- tell whether or not redirected input is on for the login prompt stuff

-- this does not include the exit button
-- from left to right starting at 1, the user may press a number while holding to control to activate them
-- assuming context is set and the button is allowed
local iconCountForKeyboardInput = 5

-- handle logging in
local function beginLoginProcess(self)
    redir = SCREENMAN:get_input_redirected(PLAYER_1)
    local function off()
        if redir then
            SCREENMAN:set_input_redirected(PLAYER_1, false)
        end
    end
    local function on()
        if redir then
            SCREENMAN:set_input_redirected(PLAYER_1, true)
        end
    end
    off()

    username = ""
    
    -- this sets up 2 text entry windows to pull your username and pass
    -- if you press escape or just enter nothing, you are forced out
    -- input redirects are controlled here because we want to be careful not to break any prior redirects
    askForInputStringWithFunction(
        "Enter Username",
        64,
        false,
        function(answer)
            username = answer
            -- moving on to step 2 if the answer isnt blank
            if answer:gsub("^%s*(.-)%s*$", "%1") ~= "" then
                self:sleep(0.01):queuecommand("LoginStep2")
            else
                ms.ok("Login cancelled")
                on()
            end
        end,
        function() return true, "" end,
        function()
            on()
            ms.ok("Login cancelled")
        end
    )
end

-- do not use this function outside of first calling beginLoginProcess
local function loginStep2()
    local function off()
        if redir then
            SCREENMAN:set_input_redirected(PLAYER_1, false)
        end
    end
    local function on()
        if redir then
            SCREENMAN:set_input_redirected(PLAYER_1, true)
        end
    end
    -- try to keep the scope of password here
    -- if we open up the scope, if a lua error happens on this screen
    -- the password may show up in the error message
    local password = ""
    askForInputStringWithFunction(
        "Enter Password",
        128,
        true,
        function(answer)
            password = answer
            -- log in if not blank
            if answer:gsub("^%s*(.-)%s*$", "%1") ~= "" then
                DLMAN:Login(username, password)
            else
                ms.ok("Login cancelled")
            end
            on()
        end,
        function() return true, "" end,
        function()
            on()
            ms.ok("Login cancelled")
        end
    )
end



t[#t+1] = Def.Quad {
    Name = "BG",
    InitCommand = function(self)
        self:halign(0):valign(0)
        self:zoomto(actuals.Width, actuals.Height)
        self:diffuse(color("#111111"))
        self:diffusealpha(0.8)
    end
}

t[#t+1] = Def.Sprite {
    Name = "Avatar",
    InitCommand = function(self)
        self:halign(0):valign(0)
    end,
    BeginCommand = function(self)
        self:Load(getAvatarPath(PLAYER_1))
        self:zoomto(actuals.AvatarWidth, actuals.AvatarWidth)
    end
}

t[#t+1] = UIElements.SpriteButton(1, 1, nil) .. {
    Name = "ConnectionSprite",
    InitCommand = function(self)
        self:halign(1):valign(1)
        -- position relative to the bottom right corner of the avatar
        self:xy(actuals.AvatarWidth - actuals.ConnectionLogoRightGap, actuals.AvatarWidth - actuals.ConnectionLogoBottomGap)
        self:playcommand("Set")
    end,
    SetCommand = function(self)
        if DLMAN:IsLoggedIn() then
            self:Load(THEME:GetPathG("", "loggedin"))
        else
            self:Load(THEME:GetPathG("", "loggedout"))
        end
        self:zoomto(actuals.ConnectionLogoSize, actuals.ConnectionLogoSize)
    end,
    MouseDownCommand = function(self, params)
        if params.event == "DeviceButton_left mouse button" then
            if DLMAN:IsLoggedIn() then
                DLMAN:Logout()
            else
                beginLoginProcess(self)
            end
        end
    end,
    LoginStep2Command = function(self)
        loginStep2()
    end
}

t[#t+1] = Def.ActorFrame {
    Name = "LeftText",
    InitCommand = function(self)
        self:x(actuals.AvatarWidth + actuals.LeftTextLeftGap)
    end,

    LoadFont("Common Normal") .. {
        Name = "NameRank",
        InitCommand = function(self)
            self:y(actuals.LeftTextTopGap1)
            self:halign(0)
            self:zoom(leftTextBigSize)
            self:maxwidth((actuals.RightTextLeftGap - actuals.LeftTextLeftGap) / leftTextBigSize - textzoomFudge)
            self:playcommand("Set")
        end,
        SetCommand = function(self)
            if DLMAN:IsLoggedIn() then
                local pn = DLMAN:GetUsername()
                self:settextf("%s (#%d)", pn, DLMAN:GetSkillsetRank("Overall"))
            else
                self:settext(pname)
            end
        end
    },
    LoadFont("Common Normal") .. {
        Name = "Playcount",
        InitCommand = function(self)
            self:y(actuals.LeftTextTopGap2)
            self:halign(0)
            self:zoom(leftTextSmallSize)
            self:maxwidth((actuals.RightTextLeftGap - actuals.LeftTextLeftGap) / leftTextSmallSize - textzoomFudge)
            self:settextf("%d plays", pcount)
        end
    },
    UIElements.TextToolTip(1, 1, "Common Normal") .. {
        Name = "Arrows",
        InitCommand = function(self)
            self:y(actuals.LeftTextTopGap3)
            self:halign(0)
            self:zoom(leftTextSmallSize)
            self:maxwidth((actuals.RightTextLeftGap - actuals.LeftTextLeftGap) / leftTextSmallSize - textzoomFudge)
            self:settextf("%s arrows smashed", strparrows)
        end,
        MouseOverCommand = function(self)
            if self:IsInvisible() then return end
            TOOLTIP:SetText(parrows)
            TOOLTIP:Show()
        end,
        MouseOutCommand = function(self)
            if self:IsInvisible() then return end
            TOOLTIP:Hide()
        end,
    },
    LoadFont("Common Normal") .. {
        Name = "Playtime",
        InitCommand = function(self)
            self:y(actuals.LeftTextTopGap4)
            self:halign(0)
            self:zoom(leftTextSmallSize)
            self:maxwidth((actuals.RightTextLeftGap - actuals.LeftTextLeftGap) / leftTextSmallSize - textzoomFudge)
            self:settextf("%s playtime", SecondsToHHMMSS(ptime))
        end
    }
}

t[#t+1] = Def.ActorFrame {
    Name = "RightText",
    InitCommand = function(self)
        self:x(actuals.AvatarWidth + actuals.RightTextLeftGap)
    end,
    BeginCommand = function(self)
        local lt = self:GetParent():GetChild("LeftText")
        local longestWidth = getLargestChildWidth(lt)
        self:x(actuals.AvatarWidth + longestWidth + actuals.RatingSideBuffer)
    end,

    LoadFont("Common Normal") .. {
        Name = "Header",
        InitCommand = function(self)
            self:y(actuals.RightTextTopGap1)
            self:halign(0)
            self:zoom(rightTextSize)
            self:maxwidth((actuals.VisualizerLeftGap - actuals.RightTextLeftGap - actuals.AvatarWidth) / rightTextSize + textzoomBudge)
            self:playcommand("Set")
        end,
        SetCommand = function(self)
            if DLMAN:IsLoggedIn() then
                self:settext("Player Ratings:")
            else
                self:settext("Player Rating:")
            end
        end
    },
    LoadFont("Common Normal") .. {
        Name = "OfflineRating",
        InitCommand = function(self)
            self:y(actuals.RightTextTopGap2)
            self:halign(0)
            self:zoom(rightTextSize)
            self:maxwidth((actuals.VisualizerLeftGap - actuals.RightTextLeftGap - actuals.AvatarWidth) / rightTextSize + textzoomBudge)
            self:playcommand("Set")
        end,
        SetCommand = function(self)
            local offlinerating = profile:GetPlayerRating()
            if DLMAN:IsLoggedIn() then
                self:settextf("Offline - %5.2f", offlinerating)
            else
                self:settextf("%5.2f", offlinerating)
            end
        end
    },
    LoadFont("Common Normal") .. {
        Name = "OnlineRating",
        InitCommand = function(self)
            self:y(actuals.RightTextTopGap3)
            self:halign(0)
            self:zoom(rightTextSize)
            self:maxwidth((actuals.VisualizerLeftGap - actuals.RightTextLeftGap - actuals.AvatarWidth) / rightTextSize + textzoomBudge)
            self:playcommand("Set")
        end,
        SetCommand = function(self)
            if DLMAN:IsLoggedIn() then
                self:settextf("Online - %5.2f", DLMAN:GetSkillsetRating("Overall"))
            else
                self:settext("")
            end
        end
    },
}

t[#t+1] = Def.ActorFrame {
    Name = "Icons",
    InitCommand = function(self)
        self:xy(SCREEN_WIDTH, actuals.IconUpperGap)
    end,
    BeginCommand = function(self)
        local snm = SCREENMAN:GetTopScreen():GetName()
        local anm = self:GetName()
        -- this keeps track of whether or not the user is allowed to use the keyboard to change tabs
        CONTEXTMAN:RegisterToContextSet(snm, "Main1", anm)

        -- enable the possibility to press the keyboard to switch tabs
        SCREENMAN:GetTopScreen():AddInputCallback(function(event)
            -- if locked out, dont allow
            if not CONTEXTMAN:CheckContextSet(snm, "Main1") then return end
            if event.type == "InputEventType_FirstPress" then
                -- must be a number with control held down
                if event.char and tonumber(event.char) and INPUTFILTER:IsControlPressed() then
                    local n = tonumber(event.char)
                    if n == 0 then n = 10 end
                    if n >= 1 and n <= iconCountForKeyboardInput then
                        local childToInvoke = nil
                        if n == 1 then
                            childToInvoke = self:GetChild("Search")
                        elseif n == 2 then
                            childToInvoke = self:GetChild("Random")
                        elseif n == 3 then
                            childToInvoke = self:GetChild("Downloads")
                        elseif n == 4 then
                            childToInvoke = self:GetChild("Help")
                        elseif n == 5 then
                            childToInvoke = self:GetChild("Settings")
                        end
                        if childToInvoke ~= nil then
                            childToInvoke:playcommand("Invoke")
                        end
                    end
                elseif event.DeviceInput.button == "DeviceButton_F1" then
                    -- im making a single exception that F1 alone invokes Search
                    -- for convenience purposes
                    self:GetChild("Search"):playcommand("Invoke")
                end
            end
        end)
    end,

    UIElements.SpriteButton(1, 1, THEME:GetPathG("", "exit")) .. {
        Name = "Exit",
        InitCommand = function(self)
            self:halign(1):valign(0)
            self:x(-actuals.IconExitRightGap)
            self:zoomto(actuals.IconExitWidth, actuals.IconExitHeight)
            self:diffusealpha(disabledButtonAlpha)
        end,
        OnCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(1)
            end
        end,
        MouseOverCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(hoverAlpha)
            end
        end,
        MouseOutCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(1)
            end
        end,
        MouseDownCommand = function(self, params)
            if params.event == "DeviceButton_left mouse button" then
                SCREENMAN:set_input_redirected(PLAEYR_1, false)
                SCREENMAN:GetTopScreen():Cancel()
            end
        end
    },
    UIElements.SpriteButton(1, 1, THEME:GetPathG("", "settings")) .. {
        Name = "Settings",
        InitCommand = function(self)
            self:halign(1):valign(0)
            self:x(-actuals.IconSettingsRightGap)
            self:zoomto(actuals.IconSettingsWidth, actuals.IconSettingsHeight)
            self:diffusealpha(disabledButtonAlpha)
        end,
        OnCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(1)
            end
        end,
        MouseOverCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(hoverAlpha)
            end
        end,
        MouseOutCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(1)
            end
        end,
        InvokeCommand = function(self)
            if selectable(self:GetName()) then
            end
        end,
        MouseDownCommand = function(self, params)
            self:playcommand("Invoke")
        end
    },
    UIElements.SpriteButton(1, 1, THEME:GetPathG("", "gameinfoandhelp")) .. {
        Name = "Help",
        InitCommand = function(self)
            self:halign(1):valign(0)
            self:x(-actuals.IconHelpRightGap)
            self:zoomto(actuals.IconHelpWidth, actuals.IconHelpHeight)
            self:diffusealpha(disabledButtonAlpha)
        end,
        OnCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(1)
            end
        end,
        MouseOverCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(hoverAlpha)
            end
        end,
        MouseOutCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(1)
            end
        end,
        InvokeCommand = function(self)
            if selectable(self:GetName()) then
            end
        end,
        MouseDownCommand = function(self, params)
            self:playcommand("Invoke")
        end
    },
    UIElements.SpriteButton(1, 1, THEME:GetPathG("", "packdownloads")) .. {
        Name = "Downloads",
        InitCommand = function(self)
            self:halign(1):valign(0)
            self:x(-actuals.IconDownloadsRightGap)
            self:zoomto(actuals.IconDownloadsWidth, actuals.IconDownloadsHeight)
            self:diffusealpha(disabledButtonAlpha)
        end,
        OnCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(1)
            end
        end,
        MouseOverCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(hoverAlpha)
            end
        end,
        MouseOutCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(1)
            end
        end,
        InvokeCommand = function(self)
            if selectable(self:GetName()) then
                MESSAGEMAN:Broadcast("PlayerInfoFrameTabSet", {tab = "Downloads"})
            end
        end,
        MouseDownCommand = function(self, params)
            self:playcommand("Invoke")
        end
    },
    UIElements.SpriteButton(1, 1, THEME:GetPathG("", "random")) .. {
        Name = "Random",
        InitCommand = function(self)
            self:halign(1):valign(0)
            self:x(-actuals.IconRandomRightGap)
            self:zoomto(actuals.IconRandomWidth, actuals.IconRandomHeight)
            self:diffusealpha(disabledButtonAlpha)
        end,
        OnCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(1)
            end
        end,
        MouseOverCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(hoverAlpha)
            end
        end,
        MouseOutCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(1)
            end
        end,
        InvokeCommand = function(self)
            if selectable(self:GetName()) then
                local scr = SCREENMAN:GetTopScreen()
                local group = WHEELDATA:GetRandomFolder()
                local song = WHEELDATA:GetRandomSongInFolder(group)
                scr:GetChild("WheelFile"):playcommand("FindSong", {song = song})
            end
        end,
        MouseDownCommand = function(self, params)
            self:playcommand("Invoke")
        end
    },
    UIElements.SpriteButton(1, 1, THEME:GetPathG("", "searchIcon")) .. {
        Name = "Search",
        InitCommand = function(self)
            self:halign(1):valign(0)
            self:x(-actuals.IconSearchRightGap)
            self:zoomto(actuals.IconSearchWidth, actuals.IconSearchHeight)
            self:diffusealpha(disabledButtonAlpha)
        end,
        OnCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(1)
            end
        end,
        MouseOverCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(hoverAlpha)
            end
        end,
        MouseOutCommand = function(self)
            if selectable(self:GetName()) then
                self:diffusealpha(1)
            end
        end,
        InvokeCommand = function(self)
            if selectable(self:GetName()) then
                MESSAGEMAN:Broadcast("PlayerInfoFrameTabSet", {tab = "Search"})
                --[[ -- legacy title only search
                local scr = SCREENMAN:GetTopScreen()
                local w = scr:GetChild("WheelFile")
                if w ~= nil then
                    redir = SCREENMAN:get_input_redirected(PLAYER_1)
                    local function off()
                        if redir then
                            SCREENMAN:set_input_redirected(PLAYER_1, false)
                        end
                    end
                    local function on()
                        if redir then
                            SCREENMAN:set_input_redirected(PLAYER_1, true)
                        end
                    end
                    off()
                    askForInputStringWithFunction(
                        "Enter Search",
                        1024,
                        false,
                        function(answer)
                            -- moving on to step 2 if the answer isnt blank
                            WHEELDATA:SetSearch({Title = answer})
                            w:sleep(0.01):queuecommand("UpdateFilters")
                            on()
                        end,
                        function() return true, "" end,
                        function()
                            on()
                        end
                    )
                end
                ]]
            end
        end,
        MouseDownCommand = function(self, params)
            self:playcommand("Invoke")
        end
    }
}


if visEnabled then
    local intervals = {0, 10, 26, 48, 60, 92, 120, 140, 240, 400, 800, 1600, 2600, 3500, 4000}
    t[#t+1] = audioVisualizer:new {
        x = actuals.VisualizerLeftGap,
        y = actuals.Height,
        width = actuals.VisualizerWidth,
        maxHeight = actuals.Height / 1.8,
        freqIntervals = audioVisualizer.multiplyIntervals(intervals, 9),
        color = color("1,1,1,1"),
        onBarUpdate = function(self)
            -- hmm
        end
    } .. {
        BeginCommand = function(self)
            local rt = self:GetParent():GetChild("RightText")
            local x = rt:GetX()
            local longestWidth = getLargestChildWidth(rt)
            x = x + longestWidth + actuals.RatingEdgeToVisualizerBuffer
            local newVisualizerWidth = actuals.VisualizerWidth + (actuals.VisualizerLeftGap - x)
            self:x(x)
            self:playcommand("ResetWidth", {width = newVisualizerWidth})
        end
    }
end

-- below this point we load things that only work on specific screens
-- buttons that arent meant to function on some screens dont need their intended targets loaded
-- this saves on load time and fps
if selectable("Exit") then
    -- nothing, it's just a button
end

if selectable("Settings") then
    -- nothing yet
end

if selectable("Help") then
    -- nothing yet
end

if selectable("Downloads") then
    t[#t+1] = LoadActor("downloads.lua")
end

if selectable("Random") then
    -- nothing, it's just a button
end

if selectable("Search") then
    t[#t+1] = LoadActor("searchfilter.lua")
end

return t