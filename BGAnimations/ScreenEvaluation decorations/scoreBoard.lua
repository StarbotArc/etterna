local t = Def.ActorFrame {
    Name = "ScoreBoardFrame",
}

local ratios = {
    VerticalDividerLeftGap = 131 / 1920, -- from beginning of frame to left edge of divider
    VerticalDividerUpperGap = 29 / 1080, -- from top of frame to top of divider
    VerticalDividerLength = 250 / 1080,
    LeftButtonLeftGap = 4 / 1920, -- left edge of frame to left edge of text

    LocalUpperGap = 28 / 1080, -- edge of frame to top of text
    OnlineUpperGap = 77 / 1080, -- edge of frame to top of text
    AllScoresUpperGap = 166 / 1080, -- again
    TopScoresUpperGap = 198 / 1080, -- ...
    CurrentRateUpperGap = 230 / 1080,
    AllRatesUpperGap = 263 / 1080,

    ScoreListUpperGap = 26 / 1080, -- inner edge of divider to inner edge of glow of top item
    ScoreListLeftGap = 158 / 1920, -- left edge of frame to inner edge of glow

    ScoreItemWidth = 467 / 1920, -- inner edge of glow to inner edge
    ScoreItemHeight = 43 / 1080,
    ScoreItemSpacing = 28 / 1080, -- distance between items
    ScoreClearInfoSpace = 67 / 1920, -- basically a portion of the width of the item, eyeballed
    ScoreMetaInfoSpace = 340 / 1920,
    ScorePlayerRateSpace = 60 / 1920,

    CursorVerticalSpan = 12 / 1080, -- visible cursor glow measured, doubled
    CursorHorizontalSpan = 12 / 1920, -- same

    LeftButtonWidth = 128 / 1920, -- guesstimation of max text width
    -- didnt measure height because it can be weird
}

local actuals = {
    VerticalDividerLeftGap = ratios.VerticalDividerLeftGap * SCREEN_WIDTH,
    VerticalDividerUpperGap = ratios.VerticalDividerUpperGap * SCREEN_HEIGHT,
    VerticalDividerLength = ratios.VerticalDividerLength * SCREEN_HEIGHT,
    LeftButtonLeftGap = ratios.LeftButtonLeftGap * SCREEN_WIDTH,
    LocalUpperGap = ratios.LocalUpperGap * SCREEN_HEIGHT,
    OnlineUpperGap = ratios.OnlineUpperGap * SCREEN_HEIGHT,
    AllScoresUpperGap = ratios.AllScoresUpperGap * SCREEN_HEIGHT,
    TopScoresUpperGap = ratios.TopScoresUpperGap * SCREEN_HEIGHT,
    CurrentRateUpperGap = ratios.CurrentRateUpperGap * SCREEN_HEIGHT,
    AllRatesUpperGap = ratios.AllRatesUpperGap * SCREEN_HEIGHT,
    ScoreListUpperGap = ratios.ScoreListUpperGap * SCREEN_HEIGHT,
    ScoreListLeftGap = ratios.ScoreListLeftGap * SCREEN_WIDTH,
    ScoreItemWidth = ratios.ScoreItemWidth * SCREEN_WIDTH,
    ScoreItemHeight = ratios.ScoreItemHeight * SCREEN_HEIGHT,
    ScoreItemSpacing = ratios.ScoreItemSpacing * SCREEN_HEIGHT,
    ScoreClearInfoSpace = ratios.ScoreClearInfoSpace * SCREEN_WIDTH,
    ScoreMetaInfoSpace = ratios.ScoreMetaInfoSpace * SCREEN_WIDTH,
    ScorePlayerRateSpace = ratios.ScorePlayerRateSpace * SCREEN_WIDTH,
    CursorVerticalSpan = ratios.CursorVerticalSpan * SCREEN_HEIGHT,
    CursorHorizontalSpan = ratios.CursorHorizontalSpan * SCREEN_WIDTH,
    LeftButtonWidth = ratios.LeftButtonWidth * SCREEN_WIDTH,
}

-- we are expecting this file to be loaded with these params precalculated
-- in reference, Height is measured divider edge to divider edge
-- in reference, Width is the length of the horizontal divider
actuals.FrameWidth = Var("Width")
actuals.FrameHeight = Var("Height")
actuals.DividerThickness = Var("DividerThickness")
local itemCount = Var("ItemCount")
if itemCount == nil or itemCount < 0 then itemCount = 1 end

local topButtonSize = 1
local bottomButtonSize = 0.7
local gradeSize = 0.8
local clearTypeSize = 0.65
local wifeJudgmentsSize = 0.6
local dateSSRSize = 0.6
local playerNameSize = 0.6
local rateSize = 0.6
local textZoomFudge = 5

-- increase the highlight area height of the buttons
local buttonSizingFudge = 8
local buttonBGYOffset = -1

t[#t+1] = Def.Quad {
    Name = "VerticalDivider",
    InitCommand = function(self)
        self:valign(0):halign(0)
        self:zoomto(actuals.DividerThickness, actuals.VerticalDividerLength)
        self:xy(actuals.VerticalDividerLeftGap, actuals.VerticalDividerUpperGap)
    end
}

-- online and offline (default is offline)
local isLocal = true
-- current rate or not (default is current rate)
-- this is NOT the variable that controls the online scores
-- if isLocal is false, defer to allRates = not DLMAN:GetCurrentRateFilter()
-- but do not replace the variable
local allRates = false
-- all scores or top scores (online only)
local allScores = not DLMAN:GetTopScoresOnlyFilter()

-- this will distribute a given highscore to the offsetplot and the other eval elements
-- it will only work properly with a replay, so restrict it to replay-only scores
local function distributeScore(callerActor, highscore)
    if highscore == nil or not highscore:HasReplayData() then return end
    -- this highscore is an online score so must request ReplayData
    if highscore:GetScoreKey():find("^Online_") ~= nil then
        -- this gets replay data and calls the given function upon completion
        DLMAN:RequestOnlineScoreReplayData(highscore,
        function()
            callerActor:GetParent():GetParent():playcommand("UpdateScore", {score = highscore})
        end)
    else
        -- otherwise we can immediately do the thing
        callerActor:GetParent():GetParent():playcommand("UpdateScore", {score = highscore})
    end
end

local function scoreList()
    local page = 1
    local maxPage = 1

    local function movePage(n)
        if maxPage <= 1 then
            return
        end
        -- the tooltip gets stuck on if it is visible and page changes
        TOOLTIP:Hide()

        -- math to make pages loop both directions
        local nn = (page + n) % (maxPage + 1)
        if nn == 0 then
            nn = n > 0 and 1 or maxPage
        end
        page = nn

        MESSAGEMAN:Broadcast("MovedPage")
    end

    -- yes, we do have a country filter
    -- we don't tell anyone
    -- the Global country just shows everyone
    local dlmanScoreboardCountryFilter = "Global"
    
    local mostRecentScore = SCOREMAN:GetMostRecentScore()
    local selectedScorekey = mostRecentScore:GetScoreKey()
    local scores = {}

    -- to prevent bombing the server repeatedly with leaderboard requests
    local alreadyRequestedLeaderboard = false

    local t = Def.ActorFrame {
        Name = "ScoreListFrame",
        InitCommand = function(self)
            self:xy(actuals.ScoreListLeftGap, actuals.ScoreListUpperGap)
        end,
        OnCommand = function(self)
            self:playcommand("UpdateScores")
            self:playcommand("UpdateList")
        end,
        UpdateScoresCommand = function(self)
            page = 1
            if isLocal then
                local scoresByRate = getRateTable(getScoresByKey(PLAYER_1))

                if allRates then
                    -- place every single score for the file into a table
                    scores = {}
                    for _, scoresAtRate in pairs(scoresByRate) do
                        for __, s in pairs(scoresAtRate) do
                            scores[#scores + 1] = s
                        end
                    end
                    -- sort it by Overall SSR
                    table.sort(scores, 
                    function(a,b)
                        return a:GetSkillsetSSR("Overall") > b:GetSkillsetSSR("Overall")
                    end)
                else
                    -- place only the scores for this rate into a table
                    -- it is already sorted by percent
                    -- the first half of this returns nil sometimes
                    -- particularly for scores that dont actually exist in your profile, like online replays
                    -- in those cases, we put the mostRecentScore into its own fallback table
                    -- mostRecentScore will never be nil. if it is, the game actually crashes before it gets here.
                    scores = scoresByRate[getRate(mostRecentScore)] or {mostRecentScore}
                end
            else
                local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
                -- operate with dlman scores
                -- ... everything here is determined by internal bools set by the toggle buttons
                scores = DLMAN:GetChartLeaderBoard(steps:GetChartKey(), dlmanScoreboardCountryFilter)

                -- this is the initial request for the leaderboard which should only end up running once
                -- and when it finishes, it loops back through this command
                -- on the second passthrough, the leaderboard is hopefully filled out
                if #scores == 0 then
                    if steps then
                        if not alreadyRequestedLeaderboard then
                            alreadyRequestedLeaderboard = true
                            DLMAN:RequestChartLeaderBoardFromOnline(
                                steps:GetChartKey(),
                                function(leaderboard)
                                    self:queuecommand("UpdateScores")
                                    self:queuecommand("UpdateList")
                                end
                            )
                        end
                    end
                end
            end
        end,
        UpdateListCommand = function(self)
            maxPage = math.ceil(#scores / itemCount)
            self:GetChild("Cursor"):diffusealpha(0)

            for i = 1, itemCount do
                local index = (page - 1) * itemCount + i
                self:GetChild("ScoreItem_"..i):playcommand("SetScore", {scoreIndex = index})
            end
        end,
        MovedPageMessageCommand = function(self)
            self:playcommand("UpdateList")
        end,
        ToggleCurrentRateMessageCommand = function(self, params)
            self:playcommand("UpdateScores")
            self:playcommand("UpdateList")
        end,
        ToggleAllScoresMessageCommand = function(self, params)
            self:playcommand("UpdateScores")
            self:playcommand("UpdateList")
        end,
        ToggleLocalMessageCommand = function(self, params)
            self:playcommand("UpdateScores")
            self:playcommand("UpdateList")
        end,
    }
    local function scoreItem(i)
        local score = nil
        local scoreIndex = i

        return Def.ActorFrame {
            Name = "ScoreItem_"..i,
            InitCommand = function(self)
                self:y((i-1) * actuals.ScoreItemSpacing + (i-1) * actuals.ScoreItemHeight)
            end,
            SetScoreCommand = function(self, params)
                scoreIndex = params.scoreIndex
                score = scores[scoreIndex]
                if score == nil then
                    self:diffusealpha(0)
                else
                    self:diffusealpha(1)
                    if score:GetScoreKey() == selectedScorekey then
                        self:GetParent():GetChild("Cursor"):playcommand("SetIndex", {index = i})
                    end
                end
            end,

            UIElements.QuadButton(1, 1) .. {
                Name = "Button",
                InitCommand = function(self)
                    self:halign(0):valign(0)
                    self:zoomto(actuals.ScoreItemWidth, actuals.ScoreItemHeight)
                    self:diffusealpha(0.2)
                end,
                MouseDownCommand = function(self)
                    if score ~= nil and score:HasReplayData() then
                        selectedScorekey = score:GetScoreKey()
                        self:GetParent():GetParent():GetChild("Cursor"):playcommand("SetIndex", {index = i})
                        -- this actor great grandparent is the ScoreBoardFrame (the file level t)
                        distributeScore(self:GetParent():GetParent():GetParent(), score)
                    end
                end,
                MouseOverCommand = function(self) self:playcommand("RolloverUpdate",{update = "over"}) end,
        		MouseOutCommand = function(self) self:playcommand("RolloverUpdate",{update = "out"}) end,
                RolloverUpdateCommand = function(self, params)
                    if score ~= nil and not score:HasReplayData() then
                        if params.update == "over" then
                            TOOLTIP:Show()
                            TOOLTIP:SetText("No Replay Data")
                        elseif params.update == "out" then
                            TOOLTIP:Hide()
                        end
                    end
                end,
                MovedPageMessageCommand = function(self)
                    if score ~= nil and isOver(self) and not score:HasReplayData() then
                        TOOLTIP:Show()
                        TOOLTIP:SetText("No Replay Data")
                    end
                end
            },
            LoadFont("Common Normal") .. {
                Name = "Grade",
                InitCommand = function(self)
                    self:xy(actuals.ScoreClearInfoSpace / 2, actuals.ScoreItemHeight / 4)
                    self:zoom(gradeSize)
                    self:maxwidth(actuals.ScoreClearInfoSpace / gradeSize - textZoomFudge)
                end,
                SetScoreCommand = function(self)
                    if score ~= nil then
                        local gra = THEME:GetString("Grade", ToEnumShortString(score:GetWifeGrade()))
                        self:settext(gra)
                        self:diffuse(getGradeColor(score:GetWifeGrade()))
                    end
                end
            },
            LoadFont("Common Normal") .. {
                Name = "ClearType",
                InitCommand = function(self)
                    self:xy(actuals.ScoreClearInfoSpace / 2, actuals.ScoreItemHeight / 4 * 3)
                    self:zoom(clearTypeSize)
                    self:maxwidth(actuals.ScoreClearInfoSpace / clearTypeSize - textZoomFudge)
                end,
                SetScoreCommand = function(self)
                    if score ~= nil then
                        local txt = getClearTypeFromScore(score, 0)
                        local color = getClearTypeFromScore(score, 2)
                        self:settext(txt)
                        self:diffuse(color)
                    end
                end
            },
            LoadFont("Common Normal") .. {
                Name = "PercentAndJudgments",
                InitCommand = function(self)
                    self:halign(0)
                    self:xy(actuals.ScoreClearInfoSpace, actuals.ScoreItemHeight / 4)
                    self:zoom(wifeJudgmentsSize)
                    self:maxwidth(actuals.ScoreMetaInfoSpace / wifeJudgmentsSize - textZoomFudge)
                end,
                SetScoreCommand = function(self)
                    if score ~= nil then
                        -- when you want individual colors for every single judgment in a continuous string.......
                        local wifeStr = string.format("%05.2f%%", notShit.floor(score:GetWifeScore() * 10000) / 100)
                        local jgMaStr = tostring(score:GetTapNoteScore("TapNoteScore_W1"))
                        local jgPStr = tostring(score:GetTapNoteScore("TapNoteScore_W2"))
                        local jgGrStr = tostring(score:GetTapNoteScore("TapNoteScore_W3"))
                        local jgGoStr = tostring(score:GetTapNoteScore("TapNoteScore_W4"))
                        local jgBStr = tostring(score:GetTapNoteScore("TapNoteScore_W5"))
                        local jgMiStr = tostring(score:GetTapNoteScore("TapNoteScore_Miss"))
                        self:ClearAttributes()
                        self:settextf("%s | %s - %s - %s - %s - %s - %s", wifeStr, jgMaStr, jgPStr, jgGrStr, jgGoStr, jgBStr, jgMiStr)
                        -- could have probably used a loop to do this
                        self:AddAttribute(#string.format("%s | ", wifeStr), {Length = #jgMaStr, Zoom = wifeJudgmentsSize, Diffuse = byJudgment("TapNoteScore_W1")})
                        self:AddAttribute(#string.format("%s | %s - ", wifeStr, jgMaStr), {Length = #jgPStr, Zoom = wifeJudgmentsSize, Diffuse = byJudgment("TapNoteScore_W2")})
                        self:AddAttribute(#string.format("%s | %s - %s - ", wifeStr, jgMaStr, jgPStr), {Length = #jgGrStr, Zoom = wifeJudgmentsSize, Diffuse = byJudgment("TapNoteScore_W3")})
                        self:AddAttribute(#string.format("%s | %s - %s - %s - ", wifeStr, jgMaStr, jgPStr, jgGrStr), {Length = #jgGoStr, Zoom = wifeJudgmentsSize, Diffuse = byJudgment("TapNoteScore_W4")})
                        self:AddAttribute(#string.format("%s | %s - %s - %s - %s - ", wifeStr, jgMaStr, jgPStr, jgGrStr, jgGoStr), {Length = #jgBStr, Zoom = wifeJudgmentsSize, Diffuse = byJudgment("TapNoteScore_W5")})
                        self:AddAttribute(#string.format("%s | %s - %s - %s - %s - %s - ", wifeStr, jgMaStr, jgPStr, jgGrStr, jgGoStr, jgBStr), {Length = #jgMiStr, Zoom = wifeJudgmentsSize, Diffuse = byJudgment("TapNoteScore_Miss")})
                    end
                end
            },
            LoadFont("Common Normal") .. {
                Name = "DateAndSSR",
                InitCommand = function(self)
                    self:halign(0)
                    self:xy(actuals.ScoreClearInfoSpace, actuals.ScoreItemHeight / 4 * 3)
                    self:zoom(dateSSRSize)
                    self:maxwidth(actuals.ScoreMetaInfoSpace / dateSSRSize - textZoomFudge)
                end,
                SetScoreCommand = function(self)
                    if score ~= nil then
                        local date = score:GetDate()
                        local m, d, y = expandDateString(date)
                        local leftHalf = string.format("%s %s, %s", m, d, y)
                        local ssr = score:GetSkillsetSSR("Overall")
                        local ssrStr = string.format("%05.2f", ssr)
                        self:ClearAttributes()
                        self:settextf("%s | %s", leftHalf, ssrStr)
                        self:AddAttribute(#leftHalf + #" | ", {Length = -1, Zoom = dateSSRSize, Diffuse = byMSD(ssr)})
                    end
                end
            },
            LoadFont("Common Normal") .. {
                Name = "PlayerName",
                InitCommand = function(self)
                    self:xy(actuals.ScoreItemWidth - actuals.ScorePlayerRateSpace / 2, actuals.ScoreItemHeight / 4)
                    self:zoom(playerNameSize)
                    self:maxwidth(actuals.ScorePlayerRateSpace / playerNameSize - textZoomFudge)
                end,
                SetScoreCommand = function(self)
                    if score ~= nil then
                        self:settext(score:GetName())
                    end
                end
            },
            LoadFont("Common Normal") .. {
                Name = "Rate",
                InitCommand = function(self)
                    self:xy(actuals.ScoreItemWidth - actuals.ScorePlayerRateSpace / 2, actuals.ScoreItemHeight / 4 * 3)
                    self:zoom(rateSize)
                    self:maxwidth(actuals.ScorePlayerRateSpace / rateSize - textZoomFudge)
                end,
                SetScoreCommand = function(self)
                    if score ~= nil then
                        local rt = score:GetMusicRate()
                        self:settext(getRateString(rt))
                    end
                end
            }
        }
    end
    t[#t+1] = Def.Sprite {
        Name = "Cursor",
        Texture = THEME:GetPathG("", "scoreboardGlow"),
        InitCommand = function(self)
            self:halign(0):valign(0)
            self:x(-actuals.CursorHorizontalSpan / 2)
            self:zoomto(actuals.ScoreItemWidth + actuals.CursorHorizontalSpan, actuals.ScoreItemHeight + actuals.CursorVerticalSpan)
            self:diffusealpha(0)
        end,
        SetIndexCommand = function(self, params)
            local i = params.index
            if scores[i] == nil then
                self:diffusealpha(0)
            else
                self:diffusealpha(1)
                self:y((i-1) * actuals.ScoreItemSpacing + (i-1) * actuals.ScoreItemHeight - actuals.CursorVerticalSpan / 2)
            end
        end,
    }
    
    for i = 1, itemCount do
        t[#t+1] = scoreItem(i)
    end

    t[#t+1] = Def.Quad {
        Name = "MouseWheelRegion",
        InitCommand = function(self)
            self:halign(0):valign(0)
            -- have to offset by the parent position...
            self:xy(-actuals.ScoreListLeftGap, -actuals.ScoreListUpperGap)
            self:diffusealpha(0)
            self:zoomto(actuals.FrameWidth, actuals.FrameHeight)
        end,
        MouseScrollMessageCommand = function(self, params)
            if isOver(self) then
                if params.direction == "Up" then
                    movePage(-1)
                else
                    movePage(1)
                end
            end
        end
    }
    return t
end



t[#t+1] = Def.ActorFrame {
    Name = "LeftButtons",
    InitCommand = function(self)
        self:x(actuals.LeftButtonLeftGap)
    end,

    UIElements.TextButton(1, 1, "Common Normal") .. {
        Name = "LocalButton",
        InitCommand = function(self)
            local txt = self:GetChild("Text")
            txt:valign(0):halign(0)
            self:y(actuals.LocalUpperGap)
            txt:zoom(topButtonSize)
            txt:maxwidth((actuals.VerticalDividerLeftGap - actuals.LeftButtonLeftGap) / topButtonSize - textZoomFudge)
            txt:settext("Local")
            local bg = self:GetChild("BG")
            bg:valign(0):halign(0)
            bg:zoomto(actuals.LeftButtonWidth, txt:GetZoomedHeight() + buttonSizingFudge)
            bg:y(-buttonSizingFudge / 2 + buttonBGYOffset)
        end,
        MouseDownCommand = function(self)
            isLocal = true
            MESSAGEMAN:Broadcast("ToggleLocal")
        end,
        RolloverUpdateCommand = function(self, params)
            if params.update == "in" then
                self:diffusealpha(0.8)
            else
                self:diffusealpha(1)
            end
        end
    },
    UIElements.TextButton(1, 1, "Common Normal") .. {
        Name = "OnlineButton",
        InitCommand = function(self)
            local txt = self:GetChild("Text")
            txt:valign(0):halign(0)
            self:y(actuals.OnlineUpperGap)
            txt:zoom(topButtonSize)
            txt:maxwidth((actuals.VerticalDividerLeftGap - actuals.LeftButtonLeftGap) / topButtonSize - textZoomFudge)
            txt:settext("Online")
            local bg = self:GetChild("BG")
            bg:valign(0):halign(0)
            bg:zoomto(actuals.LeftButtonWidth, txt:GetZoomedHeight() + buttonSizingFudge)
            bg:y(-buttonSizingFudge / 2 + buttonBGYOffset)
        end,
        MouseDownCommand = function(self)
            isLocal = false
            MESSAGEMAN:Broadcast("ToggleLocal")
        end,
        RolloverUpdateCommand = function(self, params)
            if params.update == "in" then
                self:diffusealpha(0.8)
            else
                self:diffusealpha(1)
            end
        end
    },

    UIElements.TextButton(1, 1, "Common Normal") .. {
        Name = "AllScoresButton",
        InitCommand = function(self)
            local txt = self:GetChild("Text")
            txt:valign(0):halign(0)
            self:y(actuals.AllScoresUpperGap)
            txt:zoom(bottomButtonSize)
            txt:maxwidth((actuals.VerticalDividerLeftGap - actuals.LeftButtonLeftGap) / bottomButtonSize - textZoomFudge)
            txt:settext("All Scores")
            local bg = self:GetChild("BG")
            bg:valign(0):halign(0)
            bg:zoomto(actuals.LeftButtonWidth, txt:GetZoomedHeight() + buttonSizingFudge)
            bg:y(-buttonSizingFudge / 2 + buttonBGYOffset)
        end,
        MouseDownCommand = function(self)
            allScores = true
            MESSAGEMAN:Broadcast("ToggleAllScores")
        end,
        RolloverUpdateCommand = function(self, params)
            if params.update == "in" then
                self:diffusealpha(0.8)
            else
                self:diffusealpha(1)
            end
        end
    },
    UIElements.TextButton(1, 1, "Common Normal") .. {
        Name = "TopScoresButton",
        InitCommand = function(self)
            local txt = self:GetChild("Text")
            txt:valign(0):halign(0)
            self:y(actuals.TopScoresUpperGap)
            txt:zoom(bottomButtonSize)
            txt:maxwidth((actuals.VerticalDividerLeftGap - actuals.LeftButtonLeftGap) / bottomButtonSize - textZoomFudge)
            txt:settext("Top Scores")
            local bg = self:GetChild("BG")
            bg:valign(0):halign(0)
            bg:zoomto(actuals.LeftButtonWidth, txt:GetZoomedHeight() + buttonSizingFudge)
            bg:y(-buttonSizingFudge / 2 + buttonBGYOffset)
        end,
        MouseDownCommand = function(self)
            allScores = false
            MESSAGEMAN:Broadcast("ToggleAllScores")
        end,
        RolloverUpdateCommand = function(self, params)
            if params.update == "in" then
                self:diffusealpha(0.8)
            else
                self:diffusealpha(1)
            end
        end
    },
    UIElements.TextButton(1, 1, "Common Normal") .. {
        Name = "CurrentRateButton",
        InitCommand = function(self)
            local txt = self:GetChild("Text")
            txt:valign(0):halign(0)
            self:y(actuals.CurrentRateUpperGap)
            txt:zoom(bottomButtonSize)
            txt:maxwidth((actuals.VerticalDividerLeftGap - actuals.LeftButtonLeftGap) / bottomButtonSize - textZoomFudge)
            txt:settext("Current Rate")
            local bg = self:GetChild("BG")
            bg:valign(0):halign(0)
            bg:zoomto(actuals.LeftButtonWidth, txt:GetZoomedHeight() + buttonSizingFudge)
            bg:y(-buttonSizingFudge / 2 + buttonBGYOffset)
        end,
        MouseDownCommand = function(self)
            allRates = false
            MESSAGEMAN:Broadcast("ToggleCurrentRate")
        end,
        RolloverUpdateCommand = function(self, params)
            if params.update == "in" then
                self:diffusealpha(0.8)
            else
                self:diffusealpha(1)
            end
        end
    },
    UIElements.TextButton(1, 1, "Common Normal") .. {
        Name = "AllRatesButton",
        InitCommand = function(self)
            local txt = self:GetChild("Text")
            txt:valign(0):halign(0)
            self:y(actuals.AllRatesUpperGap)
            txt:zoom(bottomButtonSize)
            txt:maxwidth((actuals.VerticalDividerLeftGap - actuals.LeftButtonLeftGap) / bottomButtonSize - textZoomFudge)
            txt:settext("All Rates")
            local bg = self:GetChild("BG")
            bg:valign(0):halign(0)
            bg:zoomto(actuals.LeftButtonWidth, txt:GetZoomedHeight() + buttonSizingFudge)
            bg:y(-buttonSizingFudge / 2 + buttonBGYOffset)
        end,
        MouseDownCommand = function(self)
            allRates = true
            MESSAGEMAN:Broadcast("ToggleCurrentRate")
        end,
        RolloverUpdateCommand = function(self, params)
            if params.update == "in" then
                self:diffusealpha(0.8)
            else
                self:diffusealpha(1)
            end
        end
    }

}

t[#t+1] = scoreList()


return t