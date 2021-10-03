-- gameplay customization
-- assume that customization is active if this file is loaded

local snm = Var("LoadingScreen")

local ratios = {
    MenuHeight = 500 / 1080,
    MenuWidth = 600 / 1920,
    MenuDraggerHeight = 75 / 1080,
    EdgePadding = 10 / 1920,
}
local actuals = {
    MenuHeight = ratios.MenuHeight * SCREEN_HEIGHT,
    MenuWidth = ratios.MenuWidth * SCREEN_WIDTH,
    MenuDraggerHeight = ratios.MenuDraggerHeight * SCREEN_HEIGHT,
    EdgePadding = ratios.EdgePadding * SCREEN_WIDTH,
}

local uiBGAlpha = 0.6
local textButtonHeightFudgeScalarMultiplier = 1.4
local buttonHoverAlpha = 0.6
local cursorAlpha = 0.5
local cursorAnimationSeconds = 0.05

local elementNameTextSize = 1
local elementCoordTextSize = 1
local elementSizeTextSize = 1
local elementListTextSize = 1

local function spaceNoteFieldCols(inc)
	if inc == nil then inc = 0 end
	local hCols = math.floor(#noteColumns/2)
	for i, col in ipairs(noteColumns) do
	    col:addx((i-hCols-1) * inc)
	end
end

local t = Def.ActorFrame {
    Name = "GameplayElementsCustomizer",
    InitCommand = function(self)
        -- in the off chance we end up in customization when in syncmachine, dont turn on autoplay
        if snm ~= "ScreenGameplaySyncMachine" then
            GAMESTATE:SetAutoplay(true)
        else
            GAMESTATE:SetAutoplay(false)
        end
    end,
    BeginCommand = function(self)
        local screen = SCREENMAN:GetTopScreen()

        local lifebar = screen:GetLifeMeter(PLAYER_1)
        local nf = screen:GetChild("PlayerP1"):GetChild("NoteField")
        local noteColumns = nf:get_column_actors()

        registerActorToCustomizeGameplayUI(lifebar)
        registerActorToCustomizeGameplayUI(nf, 4)

        Movable.pressed = false
        Movable.current = "None"
        Movable.DeviceButton_r.element = nf
        Movable.DeviceButton_t.element = noteColumns
        Movable.DeviceButton_r.condition = true
        Movable.DeviceButton_t.condition = true
        --self:GetChild("LifeP1"):GetChild("Border"):SetFakeParent(lifebar)
        Movable.DeviceButton_j.element = lifebar
        Movable.DeviceButton_j.condition = true
        Movable.DeviceButton_k.element = lifebar
        Movable.DeviceButton_k.condition = true
        Movable.DeviceButton_l.element = lifebar
        Movable.DeviceButton_l.condition = true
        Movable.DeviceButton_n.condition = true
        Movable.DeviceButton_n.DeviceButton_up.arbitraryFunction = spaceNoteFieldCols
        Movable.DeviceButton_n.DeviceButton_down.arbitraryFunction = spaceNoteFieldCols
    end,
    OnCommand = function(self)
        -- most elements either need BeginCommand or InitCommand to run for them to be registered
        -- Order of execution: Init -> Begin -> On
        -- now that everything is registered, do the thing
        local elements = getCustomizeGameplayElements()
    end,
}

local function makeUI()
    local itemsPerPage = 8
    local itemListFrame = nil

    -- init moved to OnCommand due to timing reasons
    local elements = {}
    local page = 1
    local maxPage = 1

    local cursorPos = 1
    local selectedElement = nil
    local selectedElementCoords = {}
    local selectedElementSizes = {}

    local allowedSpace = actuals.MenuHeight - actuals.MenuDraggerHeight - (actuals.EdgePadding*2)
    local topItemY = -actuals.MenuHeight/2 + actuals.MenuDraggerHeight + actuals.EdgePadding

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

        local currentPageLowerBound = (page-1) * itemsPerPage + 1
        local currentPageUpperBound = page * itemsPerPage
        if cursorPos < currentPageLowerBound then
            cursorPos = currentPageLowerBound
            if itemListFrame ~= nil then
                itemListFrame:queuecommand("UpdateCursor")
            end
        elseif cursorPos > currentPageUpperBound then
            cursorPos = currentPageUpperBound
            if itemListFrame ~= nil then
                itemListFrame:queuecommand("UpdateCursor")
            end
        end

        if itemListFrame ~= nil then
            itemListFrame:playcommand("UpdateItemList")
        end
    end

    local function moveCursor(n)
        cursorPos = cursorPos + n
        if cursorPos > #elements then
            cursorPos = 1
            page = 1
            if maxPage ~= 1 and itemListFrame ~= nil then
                itemListFrame:playcommand("UpdateItemList")
            end
        elseif cursorPos < 1 then
            cursorPos = #elements
            page = maxPage
            if maxPage ~= 1 and itemListFrame ~= nil then
                itemListFrame:playcommand("UpdateItemList")
            end
        end

        local currentPageLowerBound = (page-1) * itemsPerPage + 1
        local currentPageUpperBound = page * itemsPerPage
        if cursorPos < currentPageLowerBound then
            -- lazy: move only 1 page but its possible to move many pages
            page = page-1
            if itemListFrame ~= nil then
                itemListFrame:playcommand("UpdateItemList")
            end
        elseif cursorPos > currentPageUpperBound then
            -- lazy: move only 1 page but its possible to move many pages
            page = page+1
            if itemListFrame ~= nil then
                itemListFrame:playcommand("UpdateItemList")
            end
        end

        if itemListFrame ~= nil then
            itemListFrame:playcommand("UpdateCursor")
        end
    end

    local function visibilityBySelectedElement(self, reverse)
        if reverse then
            self:visible(selectedElement ~= nil)
        else
            self:visible(selectedElement == nil)
        end
    end

    local function updateSelectedElementValues()
        if selectedElement == nil then return end
        selectedElementCoords = getCoordinatesForElementName(selectedElement)
        selectedElementSizes = getSizesForElementName(selectedElement)
    end

    local function item(i)
        local index = i
        local element = elements[index]
        return UIElements.TextButton(1, 1, "Common Normal") .. {
            Name = "Item_"..i,
            InitCommand = function(self)
                local txt = self:GetChild("Text")
                local bg = self:GetChild("BG")
                txt:halign(0)
                txt:zoom(elementListTextSize)
                txt:maxwidth((actuals.MenuWidth-(actuals.EdgePadding*2)) / elementListTextSize)
                bg:halign(0)
                self:x(-actuals.MenuWidth + actuals.EdgePadding)
                self:y(topItemY + (allowedSpace / itemsPerPage) * (i-1) + (allowedSpace / itemsPerPage / 2))

                self.alphaDeterminingFunction = function(self)
                    local hovermultiplier = isOver(bg) and buttonHoverAlpha or 1
                    local visiblemultiplier = self:IsInvisible() and 0 or 1
                    self:diffusealpha(1 * hovermultiplier * visiblemultiplier)
                end
            end,
            SetItemCommand = function(self)
                visibilityBySelectedElement(self)

                local txt = self:GetChild("Text")
                local bg = self:GetChild("BG")
                index = (page - 1) * itemsPerPage + i
                element = elements[index]
                if element ~= nil then
                    self:diffusealpha(1)
                    txt:settext(element:GetName())
                    bg:zoomto(txt:GetZoomedWidth(), txt:GetZoomedHeight() * textButtonHeightFudgeScalarMultiplier)
                else
                    self:diffusealpha(0)
                end
            end,
            UpdateCursorCommand = function(self)
                if index == cursorPos then
                    local cursor = self:GetParent():GetChild("Cursor")
                    cursor:finishtweening()
                    cursor:smooth(cursorAnimationSeconds)
                    cursor:xy(self:GetX(), self:GetY())
                    local bg = self:GetChild("BG")
                    cursor:zoomto(bg:GetZoomedWidth(), bg:GetZoomedHeight())
                    cursor:diffusealpha(cursorAlpha)
                end
            end,
            RolloverUpdateCommand = function(self, params)
                if self:IsInvisible() then return end
                if selectedElement == nil then
                    cursorPos = index
                    self:playcommand("UpdateCursor")
                end
                self:alphaDeterminingFunction()
            end,
            ClickCommand = function(self, params)
                if self:IsInvisible() then return end
                if params.update == "OnMouseDown" then
                    cursorPos = index
                    self:playcommand("UpdateCursor")
                    self:alphaDeterminingFunction()
                end
            end,
        }
    end

    local t = Def.ActorFrame {
        Name = "ItemListContainer",
        InitCommand = function(self)
            itemListFrame = self
            -- make container above all other button elements
            -- not guaranteed but this works for now
            self:z(10)
        end,
        OnCommand = function(self)
            -- these are initialized here because most elements either need BeginCommand or InitCommand to run for them to be registered
            -- Order of execution: Init -> Begin -> On
            elements = getCustomizeGameplayElements()
            table.sort(
                elements,
                function(a, b)
                    return a:GetName():lower() < b:GetName():lower()
                end
            )
            maxPage = math.ceil(#elements / itemsPerPage)

            SCREENMAN:GetTopScreen():AddInputCallback(function(event)
                if event.type ~= "InputEventType_Release" then -- allow Repeat and FirstPress
                    local gameButton = event.button
                    local key = event.DeviceInput.button
                    local up = gameButton == "Up" or gameButton == "MenuUp"
                    local down = gameButton == "Down" or gameButton == "MenuDown"
                    local right = gameButton == "MenuRight" or gameButton == "Right"
                    local left = gameButton == "MenuLeft" or gameButton == "Left"
                    local enter = gameButton == "Start"
                    local ctrl = INPUTFILTER:IsBeingPressed("left ctrl") or INPUTFILTER:IsBeingPressed("right ctrl")
                    local shift = INPUTFILTER:IsShiftPressed()
                    local back = key == "DeviceButton_escape" or key == "DeviceButton_backspace"

                    if selectedElement ~= nil then
                        if up or down or left or right then
                            if shift then
                                -- fine movement
                            else
                                -- regular movement
                            end
                        elseif back then
                            if ctrl then
                                -- reset to default
                            else
                                -- undo changes and return
                            end
                        elseif enter then
                            -- save position and return
                        end
                    else
                        if up or left then
                            -- up
                            moveCursor(-1)
                        elseif down or right then
                            -- down
                            moveCursor(1)
                        elseif enter then
                            -- select category, select element
                        elseif back then
                            -- up one level
                        end
                    end
                end
            end)
            self:playcommand("UpdateItemList")
            self:playcommand("UpdateCursor")
            self:finishtweening()
        end,
        UpdateItemListCommand = function(self)
            self:playcommand("SetItem")
        end,
        CustomizeGameplayElementSelectedMessageCommand = function(self, params)
            if params == nil or params.name == nil then return end

            local name = params.name
            selectedElement = name
            updateSelectedElementValues()
            self:playcommand("UpdateItemList")
        end,
        CustomizeGameplayElementMovedMessageCommand = function(self, params)
            if params == nil or params.name == nil then return end

            local name = params.name
            updateSelectedElementValues()
            self:playcommand("UpdateItemInfo")
        end,

        Def.Quad {
            Name = "BG",
            InitCommand = function(self)
                self:halign(1)
                self:zoomto(actuals.MenuWidth, actuals.MenuHeight)
                registerActorToColorConfigElement(self, "main", "PrimaryBackground")
                self:diffusealpha(uiBGAlpha)
            end,
            MouseScrollMessageCommand = function(self, params)
                if isOver(self) then
                    if params.direction == "Up" then
                        movePage(-1)
                    else
                        movePage(1)
                    end
                    self:GetParent():playcommand("UpdateItemList")
                end
            end
        },
        UIElements.QuadButton(1) .. { 
            Name = "DraggableLip",
            InitCommand = function(self)
                self:halign(1):valign(0)
                self:y(-actuals.MenuHeight / 2)
                self:zoomto(actuals.MenuWidth, actuals.MenuDraggerHeight)
                registerActorToColorConfigElement(self, "main", "SecondaryBackground")
                self:diffusealpha(uiBGAlpha)
            end,
            MouseDragCommand = function(self, params)
                local newx = params.MouseX - (self.initialClickX or 0)
                local newy = params.MouseY - (self.initialClickY or 0)
                self:GetParent():addx(newx):addy(newy)
            end,
            MouseDownCommand = function(self, params)
                self.initialClickX = params.MouseX
                self.initialClickY = params.MouseY
            end,
        },
        Def.ActorFrame {
            Name = "SelectedElementPage",
            InitCommand = function(self)
                self:y(topItemY + (allowedSpace / itemsPerPage / 2))
                self:x(-actuals.MenuWidth/2)
            end,
            UpdateItemListCommand = function(self)
                visibilityBySelectedElement(self, true)
                if selectedElement ~= nil then
                    self:playcommand("UpdateItemInfo")
                end
            end,
            UpdateItemInfoCommand = function(self)
                -- line management
                self.cl = 0
                self.sl = 0
                if selectedElementCoords["x"] then self.cl = self.cl + 1 end
                if selectedElementCoords["y"] then self.cl = self.cl + 1 end
                if selectedElementCoords["rotation"] then self.cl = self.cl + 1 end
                if selectedElementSizes["zoom"] then self.sl = self.sl + 1 end
                if selectedElementSizes["width"] then self.sl = self.sl + 1 end
                if selectedElementSizes["height"] then self.sl = self.sl + 1 end
                if selectedElementSizes["spacing"] then self.sl = self.sl + 1 end
            end,

            LoadFont("Common Normal") .. {
                Name = "ElementName",
                InitCommand = function(self)
                    local line = 1
                    self:valign(0)
                    self:y((allowedSpace / itemsPerPage) * (line - 1) - (allowedSpace / itemsPerPage)/2)
                    self:settext(" ")
                    self:maxwidth(actuals.MenuWidth / elementNameTextSize)
                end,
                UpdateItemInfoCommand = function(self)
                    self:settextf("%s", selectedElement)
                end,
            },
            LoadFont("Common Normal") .. {
                Name = "CurrentCoordinates",
                InitCommand = function(self)
                    local line = 2
                    self:valign(0)
                    self:y((allowedSpace / itemsPerPage) * (line - 1) - (allowedSpace / itemsPerPage)/2)
                    self:settext(" ")
                    self:maxwidth(actuals.MenuWidth / elementCoordTextSize)
                end,
                UpdateItemInfoCommand = function(self, params)
                    local outstr = {}
                    if selectedElementCoords["x"] ~= nil then
                        outstr[#outstr+1] = string.format("X: %5.2f", selectedElementCoords["x"])
                    end
                    if selectedElementCoords["y"] ~= nil then
                        outstr[#outstr+1] = string.format("Y: %5.2f", selectedElementCoords["y"])
                    end
                    if selectedElementCoords["rotation"] ~= nil then
                        outstr[#outstr+1] = string.format("Rotation: %5.2f", selectedElementCoords["rotation"])
                    end
                    self:settextf(table.concat(outstr, "\n"))
                end,
            },
            LoadFont("Common Normal") .. {
                Name = "CurrentSizing",
                InitCommand = function(self)
                    self:valign(0)
                    self:settext(" ")
                    self:maxwidth(actuals.MenuWidth / elementSizeTextSize)
                end,
                UpdateItemInfoCommand = function(self, params)
                    local outstr = {}
                    local coordLines = self:GetParent().cl
                    local coordactor = self:GetParent():GetChild("CurrentCoordinates")
                    self:y(coordactor:GetY() + coordactor:GetZoomedHeight() + (allowedSpace / itemsPerPage)/2)
                    
                    if selectedElementSizes["zoom"] ~= nil then
                        outstr[#outstr+1] = string.format("Zoom: %5.2f", selectedElementSizes["zoom"])
                    end
                    if selectedElementSizes["width"] ~= nil then
                        outstr[#outstr+1] = string.format("Width: %5.2f", selectedElementSizes["width"])
                    end
                    if selectedElementSizes["height"] ~= nil then
                        outstr[#outstr+1] = string.format("Height: %5.2f", selectedElementSizes["height"])
                    end
                    if selectedElementSizes["spacing"] ~= nil then
                        outstr[#outstr+1] = string.format("Spacing: %5.2f", selectedElementSizes["spacing"])
                    end
                    self:settextf(table.concat(outstr, "\n"))
                end
            },
        }
    }

    for i = 1, itemsPerPage do
        t[#t+1] = item(i)
    end

    t[#t+1] = Def.Quad {
        Name = "Cursor",
        InitCommand = function(self)
            self:halign(0)
            registerActorToColorConfigElement(self, "main", "SeparationDivider")
            self:diffusealpha(cursorAlpha)
        end,
        UpdateItemListCommand = function(self)
            visibilityBySelectedElement(self)
        end,
    }
    return t
end

t[#t+1] = Def.ActorFrame {
    Name = "UIContainer",
    InitCommand = function(self)
        self:xy(SCREEN_WIDTH, SCREEN_CENTER_Y)
    end,
    makeUI(),
}

return t