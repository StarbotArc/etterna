local focused = false
local t = Def.ActorFrame {
    Name = "GoalsPageFile",
    InitCommand = function(self)
        -- hide all general box tabs on startup
        self:diffusealpha(0)
    end,
    GeneralTabSetMessageCommand = function(self, params)
        if params and params.tab ~= nil then
            if params.tab == SCUFF.goalstabindex then
                self:z(200)
                self:smooth(0.2)
                self:diffusealpha(1)
                focused = true
                self:playcommand("UpdateGoalsTab")
            else
                self:z(-100)
                self:smooth(0.2)
                self:diffusealpha(0)
                focused = false
            end
        end
    end,
    WheelSettledMessageCommand = function(self, params)
        if not focused then return end
    end,
    ChangedStepsMessageCommand = function(self, params)
        if not focused then return end
    end
}

local ratios = {
    EdgeBuffer = 11 / 1920, -- intended buffer from leftmost edge, rightmost edge, and distance away from center of frame
    UpperLipHeight = 43 / 1080,
    LipSeparatorThickness = 2 / 1080,
    
    PageTextRightGap = 33 / 1920, -- right of frame, right of text
    PageNumberUpperGap = 525 / 1080, -- bottom of upper lip to top of text

    ItemListUpperGap = 35 / 1080, -- bottom of upper lip to top of topmost item
    ItemAllottedSpace = 435 / 1080, -- top of topmost item to top of bottommost item
    ItemSpacing = 45 / 1080, -- top of item to top of next item
}

local actuals = {
    EdgeBuffer = ratios.EdgeBuffer * SCREEN_WIDTH,
    UpperLipHeight = ratios.UpperLipHeight * SCREEN_HEIGHT,
    LipSeparatorThickness = ratios.LipSeparatorThickness * SCREEN_HEIGHT,
    PageTextRightGap = ratios.PageTextRightGap * SCREEN_WIDTH,
    PageNumberUpperGap = ratios.PageNumberUpperGap * SCREEN_HEIGHT,
    ItemListUpperGap = ratios.ItemListUpperGap * SCREEN_HEIGHT,
    ItemAllottedSpace = ratios.ItemAllottedSpace * SCREEN_HEIGHT,
    ItemSpacing = ratios.ItemSpacing * SCREEN_HEIGHT,
}

-- scoping magic
do
    -- copying the provided ratios and actuals tables to have access to the sizing for the overall frame
    local rt = Var("ratios")
    for k,v in pairs(rt) do
        ratios[k] = v
    end
    local at = Var("actuals")
    for k,v in pairs(at) do
        actuals[k] = v
    end
end

local goalTextSize = 1
local pageTextSize = 0.9

local choiceTextSize = 0.7
local buttonHoverAlpha = 0.6
local buttonActiveStrokeColor = color("0.85,0.85,0.85,0.8")
local textzoomFudge = 5

local goalListAnimationSeconds = 0.05

local function goalList()
    -- modifiable parameters
    local goalItemCount = 5

    -- internal var storage
    local page = 1
    local maxPage = 1

    local function movePage(n)
        if maxPage <= 1 then
            return
        end

        -- math to make pages loop both directions
        local nn = (page + n) % (maxPage + 1)
        if nn == 0 then
            nn = n > 0 and 1 or maxPage
        end
        page = nn
    end

    local function goalListItem(i)
        local index = i

        return UIElements.TextButton(1, 1, "Common Normal") .. {
            Name = "GoalItem_"..i,
            InitCommand = function(self)
                local txt = self:GetChild("Text")
                local bg = self:GetChild("BG")
                txt:halign(0):valign(0)
                bg:halign(0)

                self:x(actuals.EdgeBuffer)
                self:y(actuals.UpperLipHeight + actuals.ItemListUpperGap + actuals.ItemAllottedSpace / goalItemCount * (i-1 - goalItemCount))
                txt:zoom(goalTextSize)
                txt:maxwidth(actuals.Width / goalTextSize - textzoomFudge)
                txt:settext(" ")
                bg:zoomto(actuals.Width, actuals.UpperLipHeight)
                bg:y(txt:GetZoomedHeight() / 2)
            end,
            UpdateGoalListCommand = function(self)
                local txt = self:GetChild("Text")
                index = (page-1) * goalItemCount + i
                self:finishtweening()
                self:diffusealpha(0)
            end,
            ClickCommand = function(self, params)
                if self:IsInvisible() then return end
                if params.update == "OnMouseDown" then
                    --
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

    local function goalChoices()
        -- keeping track of which choices are on at any moment (keys are indices, values are true/false/nil)
        local activeChoices = {}

        -- identify each choice using this table
        --  Name: The name of the choice (NOT SHOWN TO THE USER)
        --  Type: Toggle/Exclusive/Tap
        --      Toggle - This choice can be clicked multiple times to scroll through choices
        --      Exclusive - This choice is one out of a set of Exclusive choices. Only one Exclusive choice can be picked at once
        --      Tap - This choice can only be pressed (if visible by Condition) and will only run TapFunction at that time
        --  Display: The string the user sees. One option for each choice must be given if it is a Toggle choice
        --  Condition: A function that returns true or false. Determines if the choice should be visible or not
        --  IndexGetter: A function that returns an index for its status, according to the Displays set
        --  TapFunction: A function that runs when the button is pressed
        local choiceDefinitions = {
            {   -- Sort by Priority
                Name = "assign",
                Type = "Exclusive",
                Display = {"Priority"},
                IndexGetter = function() return 1 end,
                Condition = function() return true end,
                TapFunction = function() end,
            },
            {   -- Sort by Rate
                Name = "assign",
                Type = "Exclusive",
                Display = {"Rate"},
                IndexGetter = function() return 1 end,
                Condition = function() return true end,
                TapFunction = function() end,
            },
            {   -- Sort by Difficulty
                Name = "assign",
                Type = "Exclusive",
                Display = {"Difficulty"},
                IndexGetter = function() return 1 end,
                Condition = function() return true end,
                TapFunction = function() end,
            },
            {   -- Sort by Song (Song + ChartKey)
                Name = "assign",
                Type = "Exclusive",
                Display = {"Name"},
                IndexGetter = function() return 1 end,
                Condition = function() return true end,
                TapFunction = function() end,
            },
            {   -- Sort by Set Date
                Name = "assign",
                Type = "Exclusive",
                Display = {"Date"},
                IndexGetter = function() return 1 end,
                Condition = function() return true end,
                TapFunction = function() end,
            },
            {   -- New Goal on current Chart
                Name = "assign",
                Type = "Exclusive",
                Display = {"New Goal"},
                IndexGetter = function() return 1 end,
                Condition = function() return true end,
                TapFunction = function() end,
            },
            {   -- Toggle between Show All Goals and Show Goals On This Song
                Name = "assign",
                Type = "Exclusive",
                Display = {"Showing All", "Song Only"},
                IndexGetter = function() return 1 end,
                Condition = function() return true end,
                TapFunction = function() end,
            },
        }

        local function createChoice(i)
            local definition = choiceDefinitions[i]
            local displayIndex = 1

            return UIElements.TextButton(1, 1, "Common Normal") .. {
                Name = "ChoiceButton_" ..i,
                InitCommand = function(self)
                    local txt = self:GetChild("Text")
                    local bg = self:GetChild("BG")
                    bg:diffusealpha(0.1)

                    -- this position is the center of the text
                    -- divides the space into slots for the choices then places them half way into them
                    -- should work for any count of choices
                    -- and the maxwidth will make sure they stay nonoverlapping
                    self:x((actuals.Width / #choiceDefinitions) * (i-1) + (actuals.Width / #choiceDefinitions / 2))
                    txt:zoom(choiceTextSize)
                    txt:maxwidth(actuals.Width / #choiceDefinitions / choiceTextSize - textzoomFudge)
                    bg:zoomto(actuals.Width / #choiceDefinitions, actuals.UpperLipHeight)
                    self:playcommand("UpdateText")
                end,
                UpdateTextCommand = function(self)
                    local txt = self:GetChild("Text")
                    -- update index
                    displayIndex = definition.IndexGetter()

                    -- update visibility by condition
                    if definition.Condition() then
                        self:diffusealpha(1)
                    else
                        self:diffusealpha(0)
                    end

                    if activeChoices[i] then
                        txt:strokecolor(buttonActiveStrokeColor)
                    else
                        txt:strokecolor(color("0,0,0,0"))
                    end

                    -- update display
                    txt:settext(definition.Display[displayIndex])
                end,
                ClickCommand = function(self, params)
                    if self:IsInvisible() then return end
                    if params.update == "OnMouseDown" then
                        -- exclusive choices cause activechoices to be forced to this one
                        if definition.Type == "Exclusive" then
                            activeChoices = {[i]=true}
                        else
                            -- uhh i didnt implement any other type that would ... be used for.. this
                        end

                        -- run the tap function
                        if definition.TapFunction ~= nil then
                            definition.TapFunction()
                        end
                        self:GetParent():GetParent():playcommand("UpdateGoalList")
                        self:GetParent():playcommand("UpdateText")
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
                self:y(actuals.UpperLipHeight / 2)
            end,
        }

        for i = 1, #choiceDefinitions do
            t[#t+1] = createChoice(i)
        end

        return t
    end

    local t = Def.ActorFrame {
        Name = "GoalListFrame",
        BeginCommand = function(self)
            self:playcommand("UpdateGoalList")
            self:playcommand("UpdateText")
        end,
        UpdateGoalsTabCommand = function(self)
            page = 1
            self:playcommand("UpdateGoalList")
            self:playcommand("UpdateText")
        end,
        UpdateGoalListCommand = function(self)
            -- this sets all the data things over and over and over
            goalList = {}
        end,
        
        goalChoices(),
        Def.Quad {
            Name = "MouseWheelRegion",
            InitCommand = function(self)
                self:halign(0):valign(0)
                self:diffusealpha(0)
                self:zoomto(actuals.Width, actuals.Height)
            end,
            MouseScrollMessageCommand = function(self, params)
                if isOver(self) and focused then
                    if params.direction == "Up" then
                        movePage(-1)
                    else
                        movePage(1)
                    end
                    self:GetParent():playcommand("UpdateGoalList")
                end
            end
        },
        LoadFont("Common Normal") .. {
            Name = "PageText",
            InitCommand = function(self)
                self:halign(1):valign(0)
                self:xy(actuals.Width - actuals.PageTextRightGap, actuals.PageNumberUpperGap)
                self:zoom(pageTextSize)
                self:maxwidth(actuals.Width / pageTextSize - textzoomFudge)
            end,
            UpdateGoalListCommand = function(self)
                local lb = (page-1) * (goalItemCount) + 1
                if lb > #goalList then
                    lb = #goalList
                end
                local ub = page * goalItemCount
                if ub > #goalList then
                    ub = #goalList
                end
                self:settextf("%d-%d/%d", lb, ub, #goalList)
            end
        }
    }

    for i = 1, goalItemCount do
        t[#t+1] = goalListItem(i)
    end

    return t
end

t[#t+1] = Def.Quad {
    Name = "UpperLip",
    InitCommand = function(self)
        self:halign(0):valign(0)
        self:zoomto(actuals.Width, actuals.UpperLipHeight)
        self:diffuse(color("#111111"))
        self:diffusealpha(0.6)
    end
}

t[#t+1] = Def.Quad {
    Name = "LipTop",
    InitCommand = function(self)
        self:halign(0)
        self:zoomto(actuals.Width, actuals.LipSeparatorThickness)
        self:diffuse(color(".4,.4,.4,.7"))
    end
}

t[#t+1] = goalList()

return t