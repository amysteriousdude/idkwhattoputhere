--[[
    Mysterious UI Library v1.0
    A modern, lightweight UI library for Roblox exploits
    
    Features:
    - Infinite tabs with horizontal scroll
    - Virtual scrolling (only renders visible elements)
    - Element pooling (recycles off-screen elements)
    - CSS-like theming
    - Zero external dependencies
    - No telemetry
    - File-based debug logging
    - Keyboard navigation
    - 14 element classes
    
    by Mysterious
]]

local MysteriousUI = {}
MysteriousUI.__index = MysteriousUI

--// ============================================================
--// SERVICES (no cloneref, no external deps)
--// ============================================================
local Services = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    RunService = game:GetService("RunService"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService"),
    GuiService = game:GetService("GuiService"),
}

local LocalPlayer = Services.Players.LocalPlayer

--// ============================================================
--// DEBUG SYSTEM
--// ============================================================
local DEBUG_ENABLED = false
local DEBUG_LOG_FILE = "MysteriousUI_debug.log"

local function debugLog(level, msg, ...)
    if not DEBUG_ENABLED then return end
    local timestamp = os.date("%H:%M:%S")
    local formatted = string.format("[%s] [%s] %s", timestamp, level, string.format(msg, ...))
    pcall(function()
        if isfile and writefile then
            local existing = ""
            if isfile(DEBUG_LOG_FILE) then
                existing = readfile(DEBUG_LOG_FILE)
            end
            writefile(DEBUG_LOG_FILE, existing .. formatted .. "\n")
        end
    end)
    if level == "ERROR" then
        warn("[MysteriousUI] " .. formatted)
    end
end

--// ============================================================
--// THEME SYSTEM
--// ============================================================
local Themes = {
    Dark = {
        Background = Color3.fromRGB(18, 18, 18),
        Surface = Color3.fromRGB(25, 25, 25),
        SurfaceHover = Color3.fromRGB(30, 30, 30),
        Element = Color3.fromRGB(32, 32, 32),
        ElementHover = Color3.fromRGB(38, 38, 38),
        Stroke = Color3.fromRGB(45, 45, 45),
        StrokeLight = Color3.fromRGB(55, 55, 55),
        Accent = Color3.fromRGB(0, 120, 215),
        AccentHover = Color3.fromRGB(0, 140, 245),
        AccentDark = Color3.fromRGB(0, 80, 150),
        Text = Color3.fromRGB(235, 235, 235),
        TextDim = Color3.fromRGB(160, 160, 160),
        TextDark = Color3.fromRGB(100, 100, 100),
        Success = Color3.fromRGB(40, 180, 80),
        Warning = Color3.fromRGB(240, 180, 40),
        Error = Color3.fromRGB(220, 50, 50),
        ToggleOn = Color3.fromRGB(0, 146, 214),
        ToggleOff = Color3.fromRGB(80, 80, 80),
        SliderTrack = Color3.fromRGB(40, 40, 40),
        SliderFill = Color3.fromRGB(0, 120, 215),
        TabActive = Color3.fromRGB(0, 120, 215),
        TabInactive = Color3.fromRGB(40, 40, 40),
        TabText = Color3.fromRGB(180, 180, 180),
        TabTextActive = Color3.fromRGB(255, 255, 255),
        Scrollbar = Color3.fromRGB(60, 60, 60),
        ScrollbarHover = Color3.fromRGB(80, 80, 80),
        Dropdown = Color3.fromRGB(30, 30, 30),
        DropdownHover = Color3.fromRGB(40, 40, 40),
        Input = Color3.fromRGB(22, 22, 22),
        InputStroke = Color3.fromRGB(50, 50, 50),
        Placeholder = Color3.fromRGB(120, 120, 120),
        Notification = Color3.fromRGB(22, 22, 22),
        NotificationStroke = Color3.fromRGB(50, 50, 50),
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 245),
        Surface = Color3.fromRGB(255, 255, 255),
        SurfaceHover = Color3.fromRGB(250, 250, 250),
        Element = Color3.fromRGB(250, 250, 250),
        ElementHover = Color3.fromRGB(240, 240, 240),
        Stroke = Color3.fromRGB(220, 220, 220),
        StrokeLight = Color3.fromRGB(200, 200, 200),
        Accent = Color3.fromRGB(0, 102, 204),
        AccentHover = Color3.fromRGB(0, 122, 234),
        AccentDark = Color3.fromRGB(0, 80, 160),
        Text = Color3.fromRGB(30, 30, 30),
        TextDim = Color3.fromRGB(120, 120, 120),
        TextDark = Color3.fromRGB(160, 160, 160),
        Success = Color3.fromRGB(34, 160, 68),
        Warning = Color3.fromRGB(200, 150, 30),
        Error = Color3.fromRGB(200, 40, 40),
        ToggleOn = Color3.fromRGB(0, 120, 200),
        ToggleOff = Color3.fromRGB(180, 180, 180),
        SliderTrack = Color3.fromRGB(220, 220, 220),
        SliderFill = Color3.fromRGB(0, 102, 204),
        TabActive = Color3.fromRGB(0, 102, 204),
        TabInactive = Color3.fromRGB(230, 230, 230),
        TabText = Color3.fromRGB(100, 100, 100),
        TabTextActive = Color3.fromRGB(255, 255, 255),
        Scrollbar = Color3.fromRGB(200, 200, 200),
        ScrollbarHover = Color3.fromRGB(170, 170, 170),
        Dropdown = Color3.fromRGB(255, 255, 255),
        DropdownHover = Color3.fromRGB(245, 245, 245),
        Input = Color3.fromRGB(255, 255, 255),
        InputStroke = Color3.fromRGB(200, 200, 200),
        Placeholder = Color3.fromRGB(160, 160, 160),
        Notification = Color3.fromRGB(255, 255, 255),
        NotificationStroke = Color3.fromRGB(220, 220, 220),
    },
    AMOLED = {
        Background = Color3.fromRGB(0, 0, 0),
        Surface = Color3.fromRGB(10, 10, 10),
        SurfaceHover = Color3.fromRGB(18, 18, 18),
        Element = Color3.fromRGB(15, 15, 15),
        ElementHover = Color3.fromRGB(25, 25, 25),
        Stroke = Color3.fromRGB(30, 30, 30),
        StrokeLight = Color3.fromRGB(40, 40, 40),
        Accent = Color3.fromRGB(0, 150, 255),
        AccentHover = Color3.fromRGB(30, 170, 255),
        AccentDark = Color3.fromRGB(0, 100, 200),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(150, 150, 150),
        TextDark = Color3.fromRGB(80, 80, 80),
        Success = Color3.fromRGB(0, 200, 80),
        Warning = Color3.fromRGB(255, 200, 0),
        Error = Color3.fromRGB(255, 50, 50),
        ToggleOn = Color3.fromRGB(0, 150, 255),
        ToggleOff = Color3.fromRGB(50, 50, 50),
        SliderTrack = Color3.fromRGB(25, 25, 25),
        SliderFill = Color3.fromRGB(0, 150, 255),
        TabActive = Color3.fromRGB(0, 150, 255),
        TabInactive = Color3.fromRGB(20, 20, 20),
        TabText = Color3.fromRGB(140, 140, 140),
        TabTextActive = Color3.fromRGB(255, 255, 255),
        Scrollbar = Color3.fromRGB(40, 40, 40),
        ScrollbarHover = Color3.fromRGB(60, 60, 60),
        Dropdown = Color3.fromRGB(10, 10, 10),
        DropdownHover = Color3.fromRGB(20, 20, 20),
        Input = Color3.fromRGB(5, 5, 5),
        InputStroke = Color3.fromRGB(35, 35, 35),
        Placeholder = Color3.fromRGB(100, 100, 100),
        Notification = Color3.fromRGB(10, 10, 10),
        NotificationStroke = Color3.fromRGB(35, 35, 35),
    },
    Nord = {
        Background = Color3.fromRGB(46, 52, 64),
        Surface = Color3.fromRGB(59, 66, 82),
        SurfaceHover = Color3.fromRGB(67, 76, 94),
        Element = Color3.fromRGB(67, 76, 94),
        ElementHover = Color3.fromRGB(76, 86, 106),
        Stroke = Color3.fromRGB(76, 86, 106),
        StrokeLight = Color3.fromRGB(89, 100, 120),
        Accent = Color3.fromRGB(136, 192, 208),
        AccentHover = Color3.fromRGB(143, 188, 187),
        AccentDark = Color3.fromRGB(94, 129, 172),
        Text = Color3.fromRGB(236, 239, 244),
        TextDim = Color3.fromRGB(180, 190, 205),
        TextDark = Color3.fromRGB(120, 130, 150),
        Success = Color3.fromRGB(163, 190, 140),
        Warning = Color3.fromRGB(235, 203, 139),
        Error = Color3.fromRGB(191, 97, 106),
        ToggleOn = Color3.fromRGB(136, 192, 208),
        ToggleOff = Color3.fromRGB(76, 86, 106),
        SliderTrack = Color3.fromRGB(59, 66, 82),
        SliderFill = Color3.fromRGB(136, 192, 208),
        TabActive = Color3.fromRGB(136, 192, 208),
        TabInactive = Color3.fromRGB(59, 66, 82),
        TabText = Color3.fromRGB(180, 190, 205),
        TabTextActive = Color3.fromRGB(236, 239, 244),
        Scrollbar = Color3.fromRGB(76, 86, 106),
        ScrollbarHover = Color3.fromRGB(89, 100, 120),
        Dropdown = Color3.fromRGB(59, 66, 82),
        DropdownHover = Color3.fromRGB(67, 76, 94),
        Input = Color3.fromRGB(46, 52, 64),
        InputStroke = Color3.fromRGB(76, 86, 106),
        Placeholder = Color3.fromRGB(120, 130, 150),
        Notification = Color3.fromRGB(59, 66, 82),
        NotificationStroke = Color3.fromRGB(76, 86, 106),
    },
    TokyoNight = {
        Background = Color3.fromRGB(26, 27, 38),
        Surface = Color3.fromRGB(36, 40, 59),
        SurfaceHover = Color3.fromRGB(44, 48, 68),
        Element = Color3.fromRGB(44, 48, 68),
        ElementHover = Color3.fromRGB(54, 58, 78),
        Stroke = Color3.fromRGB(54, 58, 78),
        StrokeLight = Color3.fromRGB(68, 72, 92),
        Accent = Color3.fromRGB(122, 162, 247),
        AccentHover = Color3.fromRGB(137, 173, 250),
        AccentDark = Color3.fromRGB(86, 122, 210),
        Text = Color3.fromRGB(192, 202, 245),
        TextDim = Color3.fromRGB(137, 143, 180),
        TextDark = Color3.fromRGB(86, 90, 120),
        Success = Color3.fromRGB(158, 206, 106),
        Warning = Color3.fromRGB(224, 175, 104),
        Error = Color3.fromRGB(247, 118, 142),
        ToggleOn = Color3.fromRGB(122, 162, 247),
        ToggleOff = Color3.fromRGB(54, 58, 78),
        SliderTrack = Color3.fromRGB(36, 40, 59),
        SliderFill = Color3.fromRGB(122, 162, 247),
        TabActive = Color3.fromRGB(122, 162, 247),
        TabInactive = Color3.fromRGB(36, 40, 59),
        TabText = Color3.fromRGB(137, 143, 180),
        TabTextActive = Color3.fromRGB(192, 202, 245),
        Scrollbar = Color3.fromRGB(54, 58, 78),
        ScrollbarHover = Color3.fromRGB(68, 72, 92),
        Dropdown = Color3.fromRGB(36, 40, 59),
        DropdownHover = Color3.fromRGB(44, 48, 68),
        Input = Color3.fromRGB(26, 27, 38),
        InputStroke = Color3.fromRGB(54, 58, 78),
        Placeholder = Color3.fromRGB(86, 90, 120),
        Notification = Color3.fromRGB(36, 40, 59),
        NotificationStroke = Color3.fromRGB(54, 58, 78),
    },
    RosePine = {
        Background = Color3.fromRGB(25, 23, 36),
        Surface = Color3.fromRGB(38, 35, 53),
        SurfaceHover = Color3.fromRGB(49, 46, 65),
        Element = Color3.fromRGB(49, 46, 65),
        ElementHover = Color3.fromRGB(60, 56, 76),
        Stroke = Color3.fromRGB(60, 56, 76),
        StrokeLight = Color3.fromRGB(84, 80, 98),
        Accent = Color3.fromRGB(224, 222, 244),
        AccentHover = Color3.fromRGB(245, 224, 220),
        AccentDark = Color3.fromRGB(144, 140, 170),
        Text = Color3.fromRGB(224, 222, 244),
        TextDim = Color3.fromRGB(144, 140, 170),
        TextDark = Color3.fromRGB(110, 106, 134),
        Success = Color3.fromRGB(156, 207, 216),
        Warning = Color3.fromRGB(246, 193, 119),
        Error = Color3.fromRGB(235, 111, 146),
        ToggleOn = Color3.fromRGB(224, 222, 244),
        ToggleOff = Color3.fromRGB(60, 56, 76),
        SliderTrack = Color3.fromRGB(38, 35, 53),
        SliderFill = Color3.fromRGB(224, 222, 244),
        TabActive = Color3.fromRGB(224, 222, 244),
        TabInactive = Color3.fromRGB(38, 35, 53),
        TabText = Color3.fromRGB(144, 140, 170),
        TabTextActive = Color3.fromRGB(224, 222, 244),
        Scrollbar = Color3.fromRGB(60, 56, 76),
        ScrollbarHover = Color3.fromRGB(84, 80, 98),
        Dropdown = Color3.fromRGB(38, 35, 53),
        DropdownHover = Color3.fromRGB(49, 46, 65),
        Input = Color3.fromRGB(25, 23, 36),
        InputStroke = Color3.fromRGB(60, 56, 76),
        Placeholder = Color3.fromRGB(110, 106, 134),
        Notification = Color3.fromRGB(38, 35, 53),
        NotificationStroke = Color3.fromRGB(60, 56, 76),
    },
}

--// ============================================================
--// ACCENT COLOR OVERRIDE
--// ============================================================
local function overrideAccent(theme, color)
    local r, g, b = color.R, color.G, color.B
    local function lighter(c, amt)
        return Color3.new(math.min(1, c.R + amt), math.min(1, c.G + amt), math.min(1, c.B + amt))
    end
    local function darker(c, amt)
        return Color3.new(math.max(0, c.R - amt), math.max(0, c.G - amt), math.max(0, c.B - amt))
    end
    theme.Accent = color
    theme.AccentHover = lighter(color, 0.08)
    theme.AccentDark = darker(color, 0.15)
    theme.ToggleOn = color
    theme.SliderFill = color
    theme.TabActive = color
end

--// ============================================================
--// UTILITY
--// ============================================================
local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" and k ~= "Children" then
            pcall(function() inst[k] = v end)
        end
    end
    if props and props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = inst
        end
    end
    if props and props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local function tween(obj, info, goals)
    local t = Services.TweenService:Create(obj, info or TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), goals)
    t:Play()
    return t
end

local function lerp(a, b, t)
    return a + (b - a) * t
end

local function clamp(v, min, max)
    return math.max(min, math.min(max, v))
end

local function getCorner(radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius or 6)})
end

local function getStroke(color, thickness)
    return create("UIStroke", {Color = color, Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end

local function getPadding(top, right, bottom, left)
    return create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bottom or 0),
        PaddingLeft = UDim.new(0, left or 0),
    })
end

local function getTextBounds(text, font, size)
    local temp = create("TextLabel", {Text = text, Font = font, TextSize = size, Visible = false})
    temp.Parent = Services.CoreGui
    local bounds = temp.TextBounds
    temp:Destroy()
    return bounds
end

--// ============================================================
--// VIRTUAL SCROLLER
--// ============================================================
local VirtualScroller = {}
VirtualScroller.__index = VirtualScroller

function VirtualScroller.new(scrollFrame, itemHeight, createElement)
    local self = setmetatable({}, VirtualScroller)
    self.Frame = scrollFrame
    self.ItemHeight = itemHeight
    self.CreateElement = createElement
    self.Items = {}
    self.VisibleItems = {}
    self.PooledElements = {}
    self.ActiveElements = {}
    self.Padding = 4
    self.Offset = 0

    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollingDirection = Enum.ScrollingDirection.Y

    local layout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, self.Padding),
    })
    layout.Parent = scrollFrame

    self.Layout = layout
    return self
end

function VirtualScroller:SetItems(items)
    self.Items = items
    self:Update()
end

function VirtualScroller:AddItem(item)
    table.insert(self.Items, item)
    self:Update()
end

function VirtualScroller:RemoveItem(index)
    table.remove(self.Items, index)
    self:Update()
end

function VirtualScroller:Clear()
    self.Items = {}
    for _, el in pairs(self.ActiveElements) do
        el:Destroy()
    end
    self.ActiveElements = {}
    self.PooledElements = {}
end

function VirtualScroller:Pool(element)
    element.Visible = false
    table.insert(self.PooledElements, element)
end

function VirtualScroller:GetFromPool()
    if #self.PooledElements > 0 then
        return table.remove(self.PooledElements)
    end
    return nil
end

function VirtualScroller:Update()
    local canvasHeight = #self.Items * (self.ItemHeight + self.Padding)
    self.Frame.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)

    local scrollPos = self.Frame.CanvasPosition.Y
    local viewHeight = self.Frame.AbsoluteSize.Y
    local startIndex = math.max(1, math.floor(scrollPos / (self.ItemHeight + self.Padding)))
    local endIndex = math.min(#self.Items, math.ceil((scrollPos + viewHeight) / (self.ItemHeight + self.Padding)) + 1)

    --// Pool items that are out of view
    for i, el in pairs(self.ActiveElements) do
        if i < startIndex or i > endIndex then
            self:Pool(el)
            self.ActiveElements[i] = nil
        end
    end

    --// Create/update items in view
    for i = startIndex, endIndex do
        if not self.ActiveElements[i] then
            local pooled = self:GetFromPool()
            if pooled then
                self.ActiveElements[i] = pooled
                pooled.Visible = true
            else
                local newEl = self.CreateElement(self.Items[i], i)
                if newEl then
                    newEl.LayoutOrder = i
                    newEl.Parent = self.Frame
                    self.ActiveElements[i] = newEl
                end
            end
        end
    end
end

function VirtualScroller:Destroy()
    self:Clear()
    self.Frame:Destroy()
end

--// ============================================================
--// NOTIFICATION SYSTEM
--// ============================================================
local NotificationManager = {}
NotificationManager.__index = NotificationManager

function NotificationManager.new(container)
    local self = setmetatable({}, NotificationManager)
    self.Container = container
    self.Queue = {}
    return self
end

function NotificationManager:Show(data)
    local theme = Themes.Dark
    local notif = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = theme.Notification,
        BorderSizePixel = 0,
        Parent = self.Container,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8)}).Parent = notif
    create("UIStroke", {Color = theme.NotificationStroke, Thickness = 1}).Parent = notif
    create("UIPadding", {PaddingTop = UDim.new(0, 12), PaddingBottom = UDim.new(0, 12), PaddingLeft = UDim.new(0, 14), PaddingRight = UDim.new(0, 14)}).Parent = notif

    local title = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = data.Title or "Notification",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })

    local content = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = data.Content or "",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = theme.TextDim,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif,
    })
    content.AutomaticSize = Enum.AutomaticSize.Y

    local layout = create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)})
    layout.Parent = notif

    notif.AutomaticSize = Enum.AutomaticSize.Y

    --// Animate in
    notif.BackgroundTransparency = 1
    title.TextTransparency = 1
    content.TextTransparency = 1

    task.spawn(function()
        tween(notif, TweenInfo.new(0.3), {BackgroundTransparency = 0.05})
        tween(title, TweenInfo.new(0.3), {TextTransparency = 0})
        tween(content, TweenInfo.new(0.3), {TextTransparency = 0.15})
    end)

    --// Auto remove
    local duration = data.Duration or 3
    task.delay(duration, function()
        tween(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        tween(title, TweenInfo.new(0.3), {TextTransparency = 1})
        tween(content, TweenInfo.new(0.3), {TextTransparency = 1})
        task.delay(0.35, function()
            notif:Destroy()
        end)
    end)

    debugLog("INFO", "Notification: %s - %s", data.Title or "", data.Content or "")
end

--// ============================================================
--// MAIN LIBRARY
--// ============================================================
function MysteriousUI.new(config)
    config = config or {}
    local self = setmetatable({}, MysteriousUI)

    self.Theme = Themes[config.Theme or "Dark"]
    self.ThemeName = config.Theme or "Dark"
    self.Tabs = {}
    self.CurrentTab = nil
    self.Flags = {}
    self.Notifications = nil

    debugLog("INFO", "Creating window: %s", config.Name or "Mysterious UI")

    --// Build GUI
    local screenGui = create("ScreenGui", {
        Name = "MysteriousUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100,
        ResetOnSpawn = false,
    })

    --// Parent to appropriate location
    if gethui then
        screenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(screenGui)
        screenGui.Parent = Services.CoreGui
    else
        screenGui.Parent = Services.CoreGui
    end
    self.Gui = screenGui

    --// Main container
    local mainFrame = create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 520, 0, 580),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        Parent = screenGui,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10)}).Parent = mainFrame
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = mainFrame

    --// Shadow
    local shadow = create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6015897843",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = 0,
        Parent = mainFrame,
    })

    --// Topbar
    local topbar = create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 10)}).Parent = topbar

    --// Title
    local title = create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 16, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name or "Mysterious UI",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar,
    })

    --// Close button
    local closeBtn = create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 7),
        BackgroundColor3 = self.Theme.Error,
        BackgroundTransparency = 0.8,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = self.Theme.Text,
        AutoButtonColor = false,
        Parent = topbar,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = closeBtn

    --// Minimize button
    local minBtn = create("TextButton", {
        Name = "Minimize",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -76, 0, 7),
        BackgroundColor3 = self.Theme.Warning,
        BackgroundTransparency = 0.8,
        Text = "−",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = self.Theme.Text,
        AutoButtonColor = false,
        Parent = topbar,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = minBtn

    self.Main = mainFrame
    self.Topbar = topbar

    --// Search bar for filtering tabs
    local searchContainer = create("Frame", {
        Name = "SearchContainer",
        Size = UDim2.new(1, -16, 0, 32),
        Position = UDim2.new(0, 8, 0, 48),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        Parent = mainFrame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = searchContainer
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = searchContainer

    local searchIcon = create("TextLabel", {
        Size = UDim2.new(0, 24, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "🔍",
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = self.Theme.TextDim,
        Parent = searchContainer,
    })

    local searchBox = create("TextBox", {
        Name = "SearchBox",
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search tabs...",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        PlaceholderColor3 = self.Theme.Placeholder,
        ClearTextOnFocus = false,
        Parent = searchContainer,
    })

    local searchClear = create("TextButton", {
        Name = "Clear",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -24, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "×",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = self.Theme.TextDim,
        AutoButtonColor = false,
        Visible = false,
        Parent = searchContainer,
    })

    self.SearchBox = searchBox
    self.SearchClear = searchClear
    self.SearchContainer = searchContainer

    --// Tab bar (horizontal scroll for infinite tabs)
    local tabBarContainer = create("Frame", {
        Name = "TabBarContainer",
        Size = UDim2.new(1, 0, 0, 38),
        Position = UDim2.new(0, 0, 0, 84),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = mainFrame,
    })

    local tabBarScroll = create("ScrollingFrame", {
        Name = "TabBar",
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.X,
        ScrollingDirection = Enum.ScrollingDirection.X,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ScrollBarImageTransparency = 1,
        Parent = tabBarContainer,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
    }).Parent = tabBarScroll
    create("UIPadding", {PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)}).Parent = tabBarScroll

    self.TabBar = tabBarScroll

    --// Content area
    local contentArea = create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -126),
        Position = UDim2.new(0, 0, 0, 122),
        BackgroundColor3 = self.Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = mainFrame,
    })

    --// Notification container
    local notifContainer = create("Frame", {
        Name = "Notifications",
        Size = UDim2.new(0, 300, 1, 0),
        Position = UDim2.new(1, 10, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = screenGui,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Top,
    }).Parent = notifContainer

    self.ContentArea = contentArea
    self.Notifications = NotificationManager.new(notifContainer)

    --// Dragging
    local dragging, dragStart, startPos
    topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    --// Close button
    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3})
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.8})
    end)

    --// Window resize (bottom-right corner)
    local resizeHandle = create("TextButton", {
        Name = "ResizeHandle",
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -2, 1, -2),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Text = "⤡",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = self.Theme.TextDim,
        AutoButtonColor = false,
        ZIndex = 5,
        Parent = mainFrame,
    })

    local resizing, resizeStart, resizeStartSize
    resizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            resizeStartSize = mainFrame.AbsoluteSize
        end
    end)
    Services.UserInputService.InputEnded:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)
    Services.UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            local newWidth = math.clamp(resizeStartSize.X + delta.X, 380, 900)
            local newHeight = math.clamp(resizeStartSize.Y + delta.Y, 200, 800)
            mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        end
    end)

    --// Window transparency
    local transparency = 0
    Services.UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and Services.UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
            local mouseX = input.Position.X
            local screenW = Services.GuiService:GetGuiInset().X + workspace.CurrentCamera.ViewportSize.X
            transparency = clamp((mouseX / screenW) * 0.6, 0, 0.6)
            mainFrame.BackgroundTransparency = transparency
        end
    end)

    --// Minimize to taskbar icon
    local taskbarIcon = create("TextButton", {
        Name = "TaskbarIcon",
        Size = UDim2.new(0, 120, 0, 36),
        Position = UDim2.new(0.5, 0, 1, -44),
        AnchorPoint = Vector2.new(0.5, 1),
        BackgroundColor3 = self.Theme.Surface,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Visible = false,
        Parent = screenGui,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8)}).Parent = taskbarIcon
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = taskbarIcon
    create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = "🔧 " .. (config.Name or "UI"),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = taskbarIcon,
    })
    taskbarIcon.MouseButton1Click:Connect(function()
        mainFrame.Visible = true
        taskbarIcon.Visible = false
        tween(mainFrame, TweenInfo.new(0.2), {BackgroundTransparency = 0})
    end)

    --// Minimize
    local minimized = false
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            mainFrame.Visible = false
            taskbarIcon.Visible = true
        else
            mainFrame.Visible = true
            taskbarIcon.Visible = false
        end
    end)
    minBtn.MouseEnter:Connect(function()
        tween(minBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.3})
    end)
    minBtn.MouseLeave:Connect(function()
        tween(minBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.8})
    end)

    --// Tab search filtering
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = searchBox.Text:lower()
        searchClear.Visible = query ~= ""
        for _, tab in ipairs(self.Tabs) do
            if query == "" then
                tab.Button.Visible = true
            else
                tab.Button.Visible = tab.Name:lower():find(query, 1, true) ~= nil
            end
        end
    end)
    searchClear.MouseButton1Click:Connect(function()
        searchBox.Text = ""
        searchClear.Visible = false
    end)

    --// Keyboard: K to toggle, / to search
    Services.UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.K then
            mainFrame.Visible = not mainFrame.Visible
            if mainFrame.Visible then
                taskbarIcon.Visible = false
            end
        elseif input.KeyCode == Enum.KeyCode.Slash and mainFrame.Visible then
            searchBox:CaptureFocus()
        end
    end)

    --// Store references for cleanup
    self._connections = {}

    debugLog("INFO", "Window created successfully")
    return self
end

--// ============================================================
--// TAB SYSTEM (infinite tabs)
--// ============================================================
function MysteriousUI:CreateTab(config)
    if type(config) == "string" then
        config = {Name = config, Icon = nil}
    end

    local tab = {}
    tab.Name = config.Name
    tab.Elements = {}
    tab.Order = #self.Tabs + 1

    debugLog("INFO", "Creating tab: %s", config.Name)

    --// Tab button
    local tabBtnWidth = math.max(80, config.Name:len() * 9 + 40 + (config.Icon and 20 or 0))
    local tabBtn = create("TextButton", {
        Name = config.Name,
        Size = UDim2.new(0, tabBtnWidth, 0, 30),
        BackgroundColor3 = self.Theme.TabInactive,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = tab.Order,
        Parent = self.TabBar,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = tabBtn

    local tabIcon = nil
    if config.Icon then
        tabIcon = create("TextLabel", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(0, 8, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Text = config.Icon,
            Font = Enum.Font.Gotham,
            TextSize = 14,
            TextColor3 = self.Theme.TabText,
            Parent = tabBtn,
        })
    end

    local tabLabel = create("TextLabel", {
        Size = UDim2.new(1, config.Icon and -28 or -12, 1, 0),
        Position = UDim2.new(0, config.Icon and 28 or 6, 0, 0),
        BackgroundTransparency = 1,
        Text = config.Name,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = self.Theme.TabText,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = tabBtn,
    })

    --// Tab content page
    local tabPage = create("ScrollingFrame", {
        Name = config.Name,
        Size = UDim2.new(1, -12, 1, -8),
        Position = UDim2.new(0, 6, 0, 4),
        BackgroundTransparency = 1,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Theme.Scrollbar,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        Visible = false,
        Parent = self.ContentArea,
    })
    local contentLayout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    }).Parent = tabPage
    create("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 20)}).Parent = tabPage

    tab.Button = tabBtn
    tab.Label = tabLabel
    tab.Page = tabPage
    tab.Layout = contentLayout

    --// Tab click handler
    tabBtn.MouseButton1Click:Connect(function()
        self:SwitchTab(tab)
    end)
    tabBtn.MouseEnter:Connect(function()
        if self.CurrentTab ~= tab then
            tween(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.ElementHover})
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.CurrentTab ~= tab then
            tween(tabBtn, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.TabInactive})
        end
    end)

    table.insert(self.Tabs, tab)

    --// Auto-switch to first tab
    if #self.Tabs == 1 then
        self:SwitchTab(tab)
    end

    --// Element creator functions on the tab
    tab.CreateSection = function(_, name) return self:CreateSection(tab, name) end
    tab.CreateDivider = function(_) return self:CreateDivider(tab) end
    tab.CreateParagraph = function(_, data) return self:CreateParagraph(tab, data) end
    tab.CreateLabel = function(_, text, icon) return self:CreateLabel(tab, text, icon) end
    tab.CreateButton = function(_, data) return self:CreateButton(tab, data) end
    tab.CreateToggle = function(_, data) return self:CreateToggle(tab, data) end
    tab.CreateSlider = function(_, data) return self:CreateSlider(tab, data) end
    tab.CreateDropdown = function(_, data) return self:CreateDropdown(tab, data) end
    tab.CreateInput = function(_, data) return self:CreateInput(tab, data) end
    tab.CreateKeybind = function(_, data) return self:CreateKeybind(tab, data) end
    tab.CreateColorPicker = function(_, data) return self:CreateColorPicker(tab, data) end
    tab.CreateInfoCard = function(_, data) return self:CreateInfoCard(tab, data) end
    tab.CreateStatusIndicator = function(_, data) return self:CreateStatusIndicator(tab, data) end
    tab.CreateToggleGroup = function(_, data) return self:CreateToggleGroup(tab, data) end
    tab.CreateProgressBar = function(_, data) return self:CreateProgressBar(tab, data) end
    tab.CreateProgressRing = function(_, data) return self:CreateProgressRing(tab, data) end
    tab.CreateImageCard = function(_, data) return self:CreateImageCard(tab, data) end
    tab.CreateCodeBlock = function(_, data) return self:CreateCodeBlock(tab, data) end
    tab.CreateButtonGroup = function(_, data) return self:CreateButtonGroup(tab, data) end
    tab.CreateCollapsibleSection = function(_, data) return self:CreateCollapsibleSection(tab, data) end

    return tab
end

function MysteriousUI:SwitchTab(tab)
    if self.CurrentTab == tab then return end

    debugLog("INFO", "Switching to tab: %s", tab.Name)

    --// Hide all pages
    for _, t in ipairs(self.Tabs) do
        t.Page.Visible = false
        tween(t.Button, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.TabInactive})
        tween(t.Label, TweenInfo.new(0.2), {TextColor3 = self.Theme.TabText})
    end

    --// Show selected
    tab.Page.Visible = true
    self.CurrentTab = tab
    tween(tab.Button, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.TabActive})
    tween(tab.Label, TweenInfo.new(0.2), {TextColor3 = self.Theme.TabTextActive})
end

--// ============================================================
--// ELEMENT CLASSES
--// ============================================================

--// SECTION
function MysteriousUI:CreateSection(tab, name)
    local order = #tab.Elements + 1
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        Text = string.upper(name),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = self.Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })
    create("Frame", {
        Size = UDim2.new(1, -10, 0, 1),
        Position = UDim2.new(0, 4, 1, -2),
        BackgroundColor3 = self.Theme.Stroke,
        BorderSizePixel = 0,
        Parent = frame,
    })

    table.insert(tab.Elements, {Type = "Section", Name = name, Instance = frame})
    debugLog("INFO", "Section created: %s", name)
    return frame
end

--// DIVIDER
function MysteriousUI:CreateDivider(tab)
    local order = #tab.Elements + 1
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 8),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })
    create("Frame", {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.Theme.Stroke,
        BorderSizePixel = 0,
        Parent = frame,
    })
    table.insert(tab.Elements, {Type = "Divider", Instance = frame})
    return frame
end

--// LABEL
function MysteriousUI:CreateLabel(tab, text, icon)
    local order = #tab.Elements + 1
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })
    create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = text or "",
        Font = Enum.Font.Gotham,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = frame,
    })
    table.insert(tab.Elements, {Type = "Label", Text = text, Instance = frame})
    return frame
end

--// PARAGRAPH
function MysteriousUI:CreateParagraph(tab, data)
    if type(data) == "string" then
        data = {Title = data, Content = ""}
    end
    local order = #tab.Elements + 1
    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = tab.Page,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = frame
    create("UIPadding", {PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)}).Parent = frame
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = frame

    local layout = create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4)}).Parent = frame

    if data.Title then
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = data.Title,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = self.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
            Parent = frame,
        })
    end

    if data.Content and data.Content ~= "" then
        local contentLabel = create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = data.Content,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = self.Theme.TextDim,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 2,
            Parent = frame,
        })
    end

    table.insert(tab.Elements, {Type = "Paragraph", Data = data, Instance = frame})
    debugLog("INFO", "Paragraph created: %s", data.Title or "")
    return frame
end

--// BUTTON
function MysteriousUI:CreateButton(tab, data)
    local order = #tab.Elements + 1
    local btnHeight = 36

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, btnHeight),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })

    local button = create("TextButton", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = button
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = button

    local label = create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = data.Name or "Button",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = button,
    })

    local value = create("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = data.Value or "",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = self.Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = button,
    })

    button.MouseEnter:Connect(function()
        tween(button, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.ElementHover})
    end)
    button.MouseLeave:Connect(function()
        tween(button, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Element})
    end)
    button.MouseButton1Click:Connect(function()
        if data.Callback then
            local ok, err = pcall(data.Callback)
            if not ok then
                debugLog("ERROR", "Button callback error: %s", tostring(err))
                self:Notify({Title = "Error", Content = tostring(err), Duration = 5})
            end
        end
    end)

    local element = {
        Type = "Button",
        Name = data.Name,
        Instance = frame,
        Button = button,
        Label = label,
        Value = value,
        Set = function(_, val)
            value.Text = tostring(val)
        end,
    }

    if data.Flag then
        self.Flags[data.Flag] = element
    end

    table.insert(tab.Elements, element)
    debugLog("INFO", "Button created: %s", data.Name or "")
    return element
end

--// TOGGLE
function MysteriousUI:CreateToggle(tab, data)
    local order = #tab.Elements + 1
    local toggleWidth = 40
    local toggleHeight = 22
    local currentValue = data.CurrentValue or false

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })

    local toggleBg = create("TextButton", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = toggleBg
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = toggleBg

    local label = create("TextLabel", {
        Size = UDim2.new(1, -60, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = data.Name or "Toggle",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleBg,
    })

    local switchFrame = create("Frame", {
        Size = UDim2.new(0, toggleWidth, 0, toggleHeight),
        Position = UDim2.new(1, -toggleWidth - 12, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = currentValue and self.Theme.ToggleOn or self.Theme.ToggleOff,
        BorderSizePixel = 0,
        Parent = toggleBg,
    })
    create("UICorner", {CornerRadius = UDim.new(0, toggleHeight / 2)}).Parent = switchFrame

    local circle = create("Frame", {
        Size = UDim2.new(0, toggleHeight - 4, 0, toggleHeight - 4),
        Position = currentValue and UDim2.new(1, -toggleHeight + 2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.Theme.Text,
        BorderSizePixel = 0,
        Parent = switchFrame,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = circle

    local function updateVisual()
        tween(switchFrame, TweenInfo.new(0.2), {
            BackgroundColor3 = currentValue and self.Theme.ToggleOn or self.Theme.ToggleOff
        })
        tween(circle, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Position = currentValue and UDim2.new(1, -toggleHeight + 2, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        })
    end

    local function toggle()
        currentValue = not currentValue
        updateVisual()
        if data.Callback then
            local ok, err = pcall(data.Callback, currentValue)
            if not ok then
                debugLog("ERROR", "Toggle callback error: %s", tostring(err))
            end
        end
    end

    toggleBg.MouseButton1Click:Connect(toggle)
    toggleBg.MouseEnter:Connect(function()
        tween(toggleBg, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.ElementHover})
    end)
    toggleBg.MouseLeave:Connect(function()
        tween(toggleBg, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Element})
    end)

    local element = {
        Type = "Toggle",
        Name = data.Name,
        Instance = frame,
        CurrentValue = currentValue,
        Set = function(_, val)
            currentValue = val
            updateVisual()
        end,
        Get = function(_)
            return currentValue
        end,
    }

    if data.Flag then
        self.Flags[data.Flag] = element
    end

    table.insert(tab.Elements, element)
    debugLog("INFO", "Toggle created: %s = %s", data.Name or "", tostring(currentValue))
    return element
end

--// SLIDER
function MysteriousUI:CreateSlider(tab, data)
    local order = #tab.Elements + 1
    local min = data.Min or 0
    local max = data.Max or 100
    local current = data.CurrentValue or data.Default or min
    local increment = data.Increment or 1
    local suffix = data.Suffix or ""

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })

    local bg = create("Frame", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = bg
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = bg

    local label = create("TextLabel", {
        Size = UDim2.new(0.5, 0, 0, 20),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = data.Name or "Slider",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = bg,
    })

    local valueLabel = create("TextLabel", {
        Size = UDim2.new(0.5, -12, 0, 20),
        Position = UDim2.new(0.5, 0, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(current) .. suffix,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = self.Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = bg,
    })

    local track = create("Frame", {
        Size = UDim2.new(1, -24, 0, 6),
        Position = UDim2.new(0, 12, 0, 32),
        BackgroundColor3 = self.Theme.SliderTrack,
        BorderSizePixel = 0,
        Parent = bg,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = track

    local fill = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = self.Theme.SliderFill,
        BorderSizePixel = 0,
        Parent = track,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = fill

    local knob = create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = track,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = knob
    create("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 2, Transparency = 0.5}).Parent = knob

    local function updateVisual()
        local ratio = (current - min) / (max - min)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        knob.Position = UDim2.new(ratio, 0, 0.5, 0)
        valueLabel.Text = tostring(current) .. suffix
    end

    updateVisual()

    --// Slider interaction
    local sliding = false
    local function slide(input)
        local trackAbsPos = track.AbsolutePosition.X
        local trackAbsSize = track.AbsoluteSize.X
        local relX = clamp((input.Position.X - trackAbsPos) / trackAbsSize, 0, 1)
        current = math.floor((relX * (max - min) + min) / increment) * increment
        current = clamp(current, min, max)
        updateVisual()
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
        end
    end)
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            slide(input)
        end
    end)
    Services.UserInputService.InputEnded:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            sliding = false
            if data.Callback then
                local ok, err = pcall(data.Callback, current)
                if not ok then
                    debugLog("ERROR", "Slider callback error: %s", tostring(err))
                end
            end
        end
    end)
    Services.UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            slide(input)
        end
    end)

    local element = {
        Type = "Slider",
        Name = data.Name,
        Instance = frame,
        CurrentValue = current,
        Set = function(_, val)
            current = clamp(val, min, max)
            updateVisual()
        end,
        Get = function(_)
            return current
        end,
    }

    if data.Flag then
        self.Flags[data.Flag] = element
    end

    table.insert(tab.Elements, element)
    debugLog("INFO", "Slider created: %s = %s", data.Name or "", tostring(current))
    return element
end

--// DROPDOWN
function MysteriousUI:CreateDropdown(tab, data)
    local order = #tab.Elements + 1
    local options = data.Options or {}
    local currentOption = data.CurrentValue or data.Default or options[1] or "None"
    local isOpen = false
    local dropdownHeight = 32
    local itemHeight = 28

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, dropdownHeight),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        ClipsDescendants = false,
        Parent = tab.Page,
    })

    local bg = create("TextButton", {
        Size = UDim2.new(1, -10, 0, dropdownHeight),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = bg
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = bg

    local label = create("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = data.Name or "Dropdown",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = bg,
    })

    local valueLabel = create("TextLabel", {
        Size = UDim2.new(0.5, -30, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(currentOption),
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = self.Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = bg,
    })

    local arrow = create("TextLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -28, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = "▼",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = self.Theme.TextDim,
        Parent = bg,
    })

    --// Dropdown list
    local listHeight = #options * itemHeight + 8
    local list = create("ScrollingFrame", {
        Size = UDim2.new(1, -10, 0, math.min(listHeight, 200)),
        Position = UDim2.new(0, 5, 0, dropdownHeight + 4),
        BackgroundColor3 = self.Theme.Dropdown,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.Theme.Scrollbar,
        CanvasSize = UDim2.new(0, 0, 0, listHeight),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 5,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = list
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = list
    create("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4)}).Parent = list
    local listLayout = create("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2)}).Parent = list

    --// Populate list
    for i, option in ipairs(options) do
        local item = create("TextButton", {
            Size = UDim2.new(1, -8, 0, itemHeight),
            BackgroundColor3 = self.Theme.Dropdown,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            LayoutOrder = i,
            ZIndex = 6,
            Parent = list,
        })
        create("UICorner", {CornerRadius = UDim.new(0, 4)}).Parent = item

        create("TextLabel", {
            Size = UDim2.new(1, -16, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = option,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = self.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 7,
            Parent = item,
        })

        item.MouseEnter:Connect(function()
            tween(item, TweenInfo.new(0.1), {BackgroundColor3 = self.Theme.DropdownHover})
        end)
        item.MouseLeave:Connect(function()
            tween(item, TweenInfo.new(0.1), {BackgroundColor3 = self.Theme.Dropdown})
        end)
        item.MouseButton1Click:Connect(function()
            currentOption = option
            valueLabel.Text = tostring(option)
            isOpen = false
            list.Visible = false
            arrow.Text = "▼"
            if data.Callback then
                local ok, err = pcall(data.Callback, option)
                if not ok then
                    debugLog("ERROR", "Dropdown callback error: %s", tostring(err))
                end
            end
        end)
    end

    --// Toggle dropdown
    bg.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        list.Visible = isOpen
        arrow.Text = isOpen and "▲" or "▼"
        if isOpen then
            frame.Size = UDim2.new(1, 0, 0, dropdownHeight + listHeight + 8)
        else
            frame.Size = UDim2.new(1, 0, 0, dropdownHeight)
        end
    end)

    local element = {
        Type = "Dropdown",
        Name = data.Name,
        Instance = frame,
        CurrentOption = currentOption,
        Set = function(_, val)
            currentOption = val
            valueLabel.Text = tostring(val)
        end,
        Get = function(_)
            return currentOption
        end,
        Refresh = function(_, newOptions)
            options = newOptions
            --// Rebuild list
            for _, child in pairs(list:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for i, option in ipairs(options) do
                local item = create("TextButton", {
                    Size = UDim2.new(1, -8, 0, itemHeight),
                    BackgroundColor3 = self.Theme.Dropdown,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    LayoutOrder = i,
                    ZIndex = 6,
                    Parent = list,
                })
                create("UICorner", {CornerRadius = UDim.new(0, 4)}).Parent = item
                create("TextLabel", {
                    Size = UDim2.new(1, -16, 1, 0),
                    Position = UDim2.new(0, 8, 0, 0),
                    BackgroundTransparency = 1,
                    Text = option,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = self.Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7,
                    Parent = item,
                })
                item.MouseButton1Click:Connect(function()
                    currentOption = option
                    valueLabel.Text = tostring(option)
                    isOpen = false
                    list.Visible = false
                    arrow.Text = "▼"
                    if data.Callback then
                        pcall(data.Callback, option)
                    end
                end)
            end
        end,
    }

    if data.Flag then
        self.Flags[data.Flag] = element
    end

    table.insert(tab.Elements, element)
    debugLog("INFO", "Dropdown created: %s (%d options)", data.Name or "", #options)
    return element
end

--// INPUT
function MysteriousUI:CreateInput(tab, data)
    local order = #tab.Elements + 1
    local currentValue = data.CurrentValue or data.Default or ""

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })

    local bg = create("Frame", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = bg
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = bg

    local label = create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 20),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = data.Name or "Input",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = bg,
    })

    local inputBox = create("TextBox", {
        Size = UDim2.new(1, -24, 0, 24),
        Position = UDim2.new(0, 12, 0, 28),
        BackgroundColor3 = self.Theme.Input,
        BorderSizePixel = 0,
        Text = currentValue,
        PlaceholderText = data.Placeholder or "Type here...",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = self.Theme.Text,
        PlaceholderColor3 = self.Theme.Placeholder,
        ClearTextOnFocus = false,
        Parent = bg,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 4)}).Parent = inputBox
    create("UIStroke", {Color = self.Theme.InputStroke, Thickness = 1}).Parent = inputBox
    create("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}).Parent = inputBox

    inputBox.FocusLost:Connect(function()
        currentValue = inputBox.Text
        if data.Callback then
            local ok, err = pcall(data.Callback, currentValue)
            if not ok then
                debugLog("ERROR", "Input callback error: %s", tostring(err))
            end
        end
    end)

    local element = {
        Type = "Input",
        Name = data.Name,
        Instance = frame,
        CurrentValue = currentValue,
        Set = function(_, val)
            currentValue = val
            inputBox.Text = val
        end,
        Get = function(_)
            return currentValue
        end,
    }

    if data.Flag then
        self.Flags[data.Flag] = element
    end

    table.insert(tab.Elements, element)
    debugLog("INFO", "Input created: %s", data.Name or "")
    return element
end

--// KEYBIND
function MysteriousUI:CreateKeybind(tab, data)
    local order = #tab.Elements + 1
    local currentBind = data.CurrentKeybind or data.Default or "None"
    local listening = false

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })

    local bg = create("Frame", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = bg
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = bg

    local label = create("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = data.Name or "Keybind",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = bg,
    })

    local bindBtn = create("TextButton", {
        Size = UDim2.new(0, 80, 0, 24),
        Position = UDim2.new(1, -92, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.Theme.Input,
        BorderSizePixel = 0,
        Text = currentBind,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = self.Theme.Text,
        AutoButtonColor = false,
        Parent = bg,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 4)}).Parent = bindBtn
    create("UIStroke", {Color = self.Theme.InputStroke, Thickness = 1}).Parent = bindBtn

    bindBtn.MouseButton1Click:Connect(function()
        listening = true
        bindBtn.Text = "..."
        tween(bindBtn, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Accent})
    end)

    local conn
    conn = Services.UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
            currentBind = input.KeyCode.Name
            bindBtn.Text = currentBind
            listening = false
            tween(bindBtn, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.Input})
            conn:Disconnect()
            if data.Callback then
                pcall(data.Callback, currentBind)
            end
        end
    end)

    local element = {
        Type = "Keybind",
        Name = data.Name,
        Instance = frame,
        CurrentKeybind = currentBind,
        Set = function(_, val)
            currentBind = val
            bindBtn.Text = val
        end,
        Get = function(_)
            return currentBind
        end,
    }

    if data.Flag then
        self.Flags[data.Flag] = element
    end

    table.insert(tab.Elements, element)
    debugLog("INFO", "Keybind created: %s = %s", data.Name or "", currentBind)
    return element
end

--// COLOR PICKER
function MysteriousUI:CreateColorPicker(tab, data)
    local order = #tab.Elements + 1
    local currentColor = data.Color or data.CurrentValue or Color3.new(1, 1, 1)
    local isOpen = false

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })

    local bg = create("Frame", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = bg
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = bg

    local label = create("TextLabel", {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = data.Name or "Color",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = bg,
    })

    local colorBtn = create("TextButton", {
        Size = UDim2.new(0, 30, 0, 20),
        Position = UDim2.new(1, -42, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = currentColor,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = bg,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 4)}).Parent = colorBtn
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = colorBtn

    --// Simple color picker (RGB sliders)
    local pickerFrame = create("Frame", {
        Size = UDim2.new(1, -10, 0, 100),
        Position = UDim2.new(0, 5, 0, 40),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 5,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = pickerFrame
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = pickerFrame

    local function makeRGBSlider(name, yOffset, colorComponent)
        create("TextLabel", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0, yOffset),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = self.Theme.TextDim,
            ZIndex = 6,
            Parent = pickerFrame,
        })
        local track = create("Frame", {
            Size = UDim2.new(1, -50, 0, 6),
            Position = UDim2.new(0, 40, 0, yOffset + 7),
            BackgroundColor3 = self.Theme.SliderTrack,
            BorderSizePixel = 0,
            ZIndex = 6,
            Parent = pickerFrame,
        })
        create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = track
        local fill = create("Frame", {
            Size = UDim2.new(currentColor[colorComponent], 0, 1, 0),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 7,
            Parent = track,
        })
        create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = fill
        local knob = create("Frame", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(currentColor[colorComponent], 0, 0.5, 0),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = Color3.new(1, 1, 1),
            BorderSizePixel = 0,
            ZIndex = 8,
            Parent = track,
        })
        create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = knob

        local sliding = false
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
        end)
        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                local relX = clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                currentColor = Color3.new(
                    colorComponent == "R" and relX or currentColor.R,
                    colorComponent == "G" and relX or currentColor.G,
                    colorComponent == "B" and relX or currentColor.B
                )
                fill.Size = UDim2.new(relX, 0, 1, 0)
                knob.Position = UDim2.new(relX, 0, 0.5, 0)
                colorBtn.BackgroundColor3 = currentColor
            end
        end)
        Services.UserInputService.InputEnded:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = false
                if data.Callback then pcall(data.Callback, currentColor) end
            end
        end)
        Services.UserInputService.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                local relX = clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                currentColor = Color3.new(
                    colorComponent == "R" and relX or currentColor.R,
                    colorComponent == "G" and relX or currentColor.G,
                    colorComponent == "B" and relX or currentColor.B
                )
                fill.Size = UDim2.new(relX, 0, 1, 0)
                knob.Position = UDim2.new(relX, 0, 0.5, 0)
                colorBtn.BackgroundColor3 = currentColor
            end
        end)
    end

    makeRGBSlider("R", 10, "R")
    makeRGBSlider("G", 38, "G")
    makeRGBSlider("B", 66, "B")

    colorBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        pickerFrame.Visible = isOpen
    end)

    local element = {
        Type = "ColorPicker",
        Name = data.Name,
        Instance = frame,
        Color = currentColor,
        Set = function(_, color)
            currentColor = color
            colorBtn.BackgroundColor3 = color
        end,
        Get = function(_)
            return currentColor
        end,
    }

    if data.Flag then
        self.Flags[data.Flag] = element
    end

    table.insert(tab.Elements, element)
    debugLog("INFO", "ColorPicker created: %s", data.Name or "")
    return element
end

--// INFO CARD (rich element with icon, title, subtitle, description)
function MysteriousUI:CreateInfoCard(tab, data)
    local order = #tab.Elements + 1
    local cardHeight = data.Height or 80

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, cardHeight),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = tab.Page,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8)}).Parent = frame
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = frame
    create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }).Parent = frame

    local layout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    }).Parent = frame

    --// Icon (optional)
    if data.Icon then
        local icon = create("TextLabel", {
            Size = UDim2.new(0, 24, 0, 24),
            BackgroundTransparency = 1,
            Text = data.Icon,
            Font = Enum.Font.GothamBold,
            TextSize = 18,
            TextColor3 = data.IconColor or self.Theme.Accent,
            LayoutOrder = 1,
            Parent = frame,
        })
    end

    --// Title
    if data.Title then
        create("TextLabel", {
            Size = UDim2.new(1, data.Icon and -32 or 0, 0, 18),
            BackgroundTransparency = 1,
            Text = data.Title,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = self.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            LayoutOrder = 2,
            Parent = frame,
        })
    end

    --// Subtitle
    if data.Subtitle then
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            BackgroundTransparency = 1,
            Text = data.Subtitle,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = self.Theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 3,
            Parent = frame,
        })
    end

    --// Description
    if data.Description then
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = data.Description,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = self.Theme.TextDim,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 4,
            Parent = frame,
        })
    end

    --// Right-aligned value
    if data.Value then
        create("TextLabel", {
            Size = UDim2.new(0, 60, 0, 18),
            Position = UDim2.new(1, -60, 0, 0),
            BackgroundTransparency = 1,
            Text = data.Value,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = data.ValueColor or self.Theme.Success,
            TextXAlignment = Enum.TextXAlignment.Right,
            LayoutOrder = 5,
            Parent = frame,
        })
    end

    frame.AutomaticSize = Enum.AutomaticSize.Y

    local element = {
        Type = "InfoCard",
        Name = data.Title or "InfoCard",
        Instance = frame,
        Set = function(_, key, val)
            --// Update child by key
        end,
    }

    table.insert(tab.Elements, element)
    debugLog("INFO", "InfoCard created: %s", data.Title or "")
    return element
end

--// STATUS INDICATOR (colored dot + text + optional subtitle)
function MysteriousUI:CreateStatusIndicator(tab, data)
    local order = #tab.Elements + 1
    local statusColors = {
        Online = self.Theme.Success,
        Active = self.Theme.Success,
        Warning = self.Theme.Warning,
        Error = self.Theme.Error,
        Offline = self.Theme.TextDark,
    }
    local currentStatus = data.Status or "Offline"
    local dotColor = statusColors[currentStatus] or self.Theme.TextDark

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })

    local bg = create("Frame", {
        Size = UDim2.new(1, -10, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = bg
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = bg

    --// Status dot
    local dot = create("Frame", {
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(0, 14, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = dotColor,
        BorderSizePixel = 0,
        Parent = bg,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = dot

    --// Label
    local label = create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = data.Name or "Status",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = bg,
    })

    --// Status text
    local statusText = create("TextLabel", {
        Size = UDim2.new(0, 80, 1, 0),
        Position = UDim2.new(1, -92, 0, 0),
        BackgroundTransparency = 1,
        Text = currentStatus,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = dotColor,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = bg,
    })

    local function updateStatus(newStatus)
        currentStatus = newStatus
        dotColor = statusColors[newStatus] or self.Theme.TextDark
        dot.BackgroundColor3 = dotColor
        statusText.Text = newStatus
        statusText.TextColor3 = dotColor
    end

    local element = {
        Type = "StatusIndicator",
        Name = data.Name or "Status",
        Instance = frame,
        Status = currentStatus,
        Set = function(_, val)
            updateStatus(tostring(val))
        end,
        Get = function(_)
            return currentStatus
        end,
    }

    table.insert(tab.Elements, element)
    debugLog("INFO", "StatusIndicator created: %s = %s", data.Name or "", currentStatus)
    return element
end

--// TOGGLE GROUP (multiple toggles in a card)
function MysteriousUI:CreateToggleGroup(tab, data)
    local order = #tab.Elements + 1
    local toggles = data.Toggles or {}

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = tab.Page,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8)}).Parent = frame
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = frame
    create("UIPadding", {
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
    }).Parent = frame

    local layout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
    }).Parent = frame

    local elements = {}
    for i, toggleData in ipairs(toggles) do
        local el = self:CreateToggle(tab, {
            Name = toggleData.Name,
            CurrentValue = toggleData.Default or false,
            Callback = toggleData.Callback,
            Flag = toggleData.Flag,
        })
        el.LayoutOrder = order + i
        el.Instance.Parent = frame
        table.insert(elements, el)
    end

    frame.AutomaticSize = Enum.AutomaticSize.Y

    local element = {
        Type = "ToggleGroup",
        Name = data.Name or "ToggleGroup",
        Instance = frame,
        Elements = elements,
    }

    table.insert(tab.Elements, element)
    debugLog("INFO", "ToggleGroup created: %s (%d toggles)", data.Name or "", #toggles)
    return element
end

--// PROGRESS BAR (horizontal bar with label)
function MysteriousUI:CreateProgressBar(tab, data)
    local order = #tab.Elements + 1
    local value = data.Value or 0
    local max = data.Max or 100
    local barHeight = data.Height or 20

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, barHeight + 20),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })

    local label = create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 16),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = data.Name or "Progress",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    local valueLabel = create("TextLabel", {
        Size = UDim2.new(1, -10, 0, 16),
        Position = UDim2.new(0, 5, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(value) .. "/" .. tostring(max),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = self.Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame,
    })

    local track = create("Frame", {
        Size = UDim2.new(1, -10, 0, barHeight),
        Position = UDim2.new(0, 5, 0, 18),
        BackgroundColor3 = self.Theme.SliderTrack,
        BorderSizePixel = 0,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 4)}).Parent = track

    local fill = create("Frame", {
        Size = UDim2.new(value / max, 0, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
        BorderSizePixel = 0,
        Parent = track,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 4)}).Parent = fill

    local function updateVisual()
        local ratio = clamp(value / max, 0, 1)
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        valueLabel.Text = tostring(value) .. "/" .. tostring(max)
    end

    local element = {
        Type = "ProgressBar",
        Name = data.Name or "Progress",
        Instance = frame,
        Value = value,
        Set = function(_, val)
            value = clamp(val, 0, max)
            updateVisual()
        end,
        Get = function(_)
            return value
        end,
    }

    table.insert(tab.Elements, element)
    debugLog("INFO", "ProgressBar created: %s", data.Name or "")
    return element
end

--// PROGRESS RING (circular progress indicator)
function MysteriousUI:CreateProgressRing(tab, data)
    local order = #tab.Elements + 1
    local value = data.Value or 0
    local max = data.Max or 100
    local size = data.Size or 60
    local thickness = data.Thickness or 4
    local color = data.Color or self.Theme.Accent

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, size + 30),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })

    local bgCircle = create("Frame", {
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(0, 10, 0, 15),
        BackgroundTransparency = 1,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = bgCircle
    create("UIStroke", {
        Color = self.Theme.SliderTrack,
        Thickness = thickness,
        Transparency = 0.5,
    }).Parent = bgCircle

    local fillCircle = create("Frame", {
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(0, 10, 0, 15),
        BackgroundTransparency = 1,
        Parent = frame,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0)}).Parent = fillCircle
    local fillStroke = create("UIStroke", {
        Color = color,
        Thickness = thickness,
        Transparency = 0,
    }).Parent = fillCircle

    local valueLabel = create("TextLabel", {
        Size = UDim2.new(0, size, 0, size),
        Position = UDim2.new(0, 10, 0, 15),
        BackgroundTransparency = 1,
        Text = tostring(math.floor(value / max * 100)) .. "%",
        Font = Enum.Font.GothamBold,
        TextSize = size * 0.25,
        TextColor3 = self.Theme.Text,
        Parent = frame,
    })

    local nameLabel = create("TextLabel", {
        Size = UDim2.new(1, -(size + 30), 0, 20),
        Position = UDim2.new(0, size + 25, 0, 15),
        BackgroundTransparency = 1,
        Text = data.Name or "Progress",
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    local descLabel = nil
    if data.Description then
        descLabel = create("TextLabel", {
            Size = UDim2.new(1, -(size + 30), 0, 16),
            Position = UDim2.new(0, size + 25, 0, 35),
            BackgroundTransparency = 1,
            Text = data.Description,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = self.Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })
    end

    local function updateVisual()
        local ratio = clamp(value / max, 0, 1)
        valueLabel.Text = tostring(math.floor(ratio * 100)) .. "%"
        fillCircle.Size = UDim2.new(0, size * ratio, 0, size * ratio)
        fillCircle.Position = UDim2.new(0, 10 + size * (1 - ratio) / 2, 0, 15 + size * (1 - ratio) / 2)
    end

    local element = {
        Type = "ProgressRing",
        Name = data.Name or "Progress",
        Instance = frame,
        Value = value,
        Set = function(_, val)
            value = clamp(val, 0, max)
            updateVisual()
        end,
        Get = function(_)
            return value
        end,
    }

    table.insert(tab.Elements, element)
    debugLog("INFO", "ProgressRing created: %s", data.Name or "")
    return element
end

--// IMAGE CARD (card with image display)
function MysteriousUI:CreateImageCard(tab, data)
    local order = #tab.Elements + 1
    local cardHeight = data.Height or 120

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, cardHeight),
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = tab.Page,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8)}).Parent = frame
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = frame

    if data.Image then
        local image = create("ImageLabel", {
            Size = UDim2.new(1, 0, 0, cardHeight * 0.6),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = self.Theme.Surface,
            BorderSizePixel = 0,
            Image = data.Image,
            ScaleType = data.ScaleType or Enum.ScaleType.Fit,
            Parent = frame,
        })
        create("UICorner", {CornerRadius = UDim.new(0, 8)}).Parent = image
    end

    if data.Title then
        create("TextLabel", {
            Size = UDim2.new(1, -16, 0, 18),
            Position = UDim2.new(0, 8, 0, cardHeight * 0.62),
            BackgroundTransparency = 1,
            Text = data.Title,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = self.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            Parent = frame,
        })
    end

    if data.Subtitle then
        create("TextLabel", {
            Size = UDim2.new(1, -16, 0, 14),
            Position = UDim2.new(0, 8, 0, cardHeight * 0.62 + 18),
            BackgroundTransparency = 1,
            Text = data.Subtitle,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = self.Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })
    end

    if data.Callback then
        local btn = create("TextButton", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = frame,
        })
        btn.MouseButton1Click:Connect(function()
            pcall(data.Callback)
        end)
    end

    local element = {
        Type = "ImageCard",
        Name = data.Title or "ImageCard",
        Instance = frame,
    }

    table.insert(tab.Elements, element)
    debugLog("INFO", "ImageCard created: %s", data.Title or "")
    return element
end

--// CODE BLOCK (monospace text display)
function MysteriousUI:CreateCodeBlock(tab, data)
    local order = #tab.Elements + 1

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme.Input,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = tab.Page,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = frame
    create("UIStroke", {Color = self.Theme.InputStroke, Thickness = 1}).Parent = frame
    create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
    }).Parent = frame

    local codeLabel = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = data.Code or "-- code here",
        Font = Enum.Font.Code,
        TextSize = data.TextSize or 12,
        TextColor3 = data.CodeColor or Color3.fromRGB(180, 220, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        RichText = data.RichText or false,
        Parent = frame,
    })

    if data.Label then
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = data.Label,
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = self.Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = frame,
        })
    end

    local element = {
        Type = "CodeBlock",
        Name = data.Label or "Code",
        Instance = frame,
        Set = function(_, code)
            codeLabel.Text = code
        end,
    }

    table.insert(tab.Elements, element)
    debugLog("INFO", "CodeBlock created: %s", data.Label or "")
    return element
end

--// BUTTON GROUP (multiple buttons in a row)
function MysteriousUI:CreateButtonGroup(tab, data)
    local order = #tab.Elements + 1
    local buttons = data.Buttons or {}

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = tab.Page,
    })

    local layout = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        Padding = UDim.new(0, 6),
    }).Parent = frame

    for i, btnData in ipairs(buttons) do
        local btn = create("TextButton", {
            Size = UDim2.new(0, math.max(80, btnData.Name:len() * 7 + 24), 0, 32),
            BackgroundColor3 = btnData.Color or self.Theme.Accent,
            BorderSizePixel = 0,
            Text = btnData.Name or "Button",
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = Color3.new(1, 1, 1),
            AutoButtonColor = false,
            LayoutOrder = i,
            Parent = frame,
        })
        create("UICorner", {CornerRadius = UDim.new(0, 6)}).Parent = btn

        btn.MouseEnter:Connect(function()
            tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = self.Theme.AccentHover})
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, TweenInfo.new(0.15), {BackgroundColor3 = btnData.Color or self.Theme.Accent})
        end)
        btn.MouseButton1Click:Connect(function()
            if btnData.Callback then
                pcall(btnData.Callback)
            end
        end)
    end

    local element = {
        Type = "ButtonGroup",
        Name = data.Name or "ButtonGroup",
        Instance = frame,
    }

    table.insert(tab.Elements, element)
    debugLog("INFO", "ButtonGroup created: %s (%d buttons)", data.Name or "", #buttons)
    return element
end

--// COLLAPSIBLE SECTION
function MysteriousUI:CreateCollapsibleSection(tab, data)
    local order = #tab.Elements + 1
    local collapsed = data.Collapsed or false

    local frame = create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme.Element,
        BorderSizePixel = 0,
        LayoutOrder = order,
        Parent = tab.Page,
    })
    create("UICorner", {CornerRadius = UDim.new(0, 8)}).Parent = frame
    create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1}).Parent = frame

    local header = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = frame,
    })

    local arrow = create("TextLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundTransparency = 1,
        Text = collapsed and "▶" or "▼",
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextColor3 = self.Theme.TextDim,
        Parent = header,
    })

    create("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = data.Name or "Section",
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })

    local content = create("Frame", {
        Size = UDim2.new(1, -16, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Position = UDim2.new(0, 8, 0, 36),
        BackgroundTransparency = 1,
        Visible = not collapsed,
        Parent = frame,
    })
    create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
    }).Parent = content

    header.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        content.Visible = not collapsed
        arrow.Text = collapsed and "▶" or "▼"
    end)

    local element = {
        Type = "CollapsibleSection",
        Name = data.Name or "Section",
        Instance = frame,
        Content = content,
        IsCollapsed = function(_)
            return collapsed
        end,
        SetCollapsed = function(_, val)
            collapsed = val
            content.Visible = not collapsed
            arrow.Text = collapsed and "▶" or "▼"
        end,
    }

    table.insert(tab.Elements, element)
    debugLog("INFO", "CollapsibleSection created: %s", data.Name or "")
    return element
end

--// PUBLIC API
function MysteriousUI:Notify(data)
    if self.Notifications then
        self.Notifications:Show(data)
    end
end

function MysteriousUI:SetTheme(themeName)
    if Themes[themeName] then
        self.Theme = Themes[themeName]
        self.ThemeName = themeName
        debugLog("INFO", "Theme changed to: %s", themeName)
    end
end

function MysteriousUI:SetAccent(color)
    overrideAccent(self.Theme, color)
    debugLog("INFO", "Accent color changed")
end

function MysteriousUI:AddTheme(name, themeTable)
    Themes[name] = themeTable
    debugLog("INFO", "Custom theme added: %s", name)
end

function MysteriousUI:GetThemes()
    local names = {}
    for name, _ in pairs(Themes) do
        table.insert(names, name)
    end
    return names
end

function MysteriousUI:GetFlag(flagName)
    return self.Flags[flagName]
end

function MysteriousUI:SetFlag(flagName, value)
    if self.Flags[flagName] and self.Flags[flagName].Set then
        self.Flags[flagName]:Set(value)
    end
end

function MysteriousUI:GetAllFlags()
    local result = {}
    for name, element in pairs(self.Flags) do
        if element.Get then
            result[name] = element:Get()
        end
    end
    return result
end

--// Config save/load via writefile/readfile
function MysteriousUI:SaveConfig(fileName)
    fileName = fileName or "MysteriousUI_config.json"
    local config = {
        Theme = self.ThemeName,
        Flags = self:GetAllFlags(),
    }
    local ok, json = pcall(function()
        return Services.HttpService:JSONEncode(config)
    end)
    if ok and json then
        pcall(function()
            writefile(fileName, json)
        end)
        debugLog("INFO", "Config saved to: %s", fileName)
        self:Notify({Title = "Config", Content = "Saved to " .. fileName, Duration = 2})
    else
        debugLog("ERROR", "Failed to encode config")
    end
end

function MysteriousUI:LoadConfig(fileName)
    fileName = fileName or "MysteriousUI_config.json"
    local ok, content = pcall(function()
        return readfile(fileName)
    end)
    if ok and content then
        local decodeOk, config = pcall(function()
            return Services.HttpService:JSONDecode(content)
        end)
        if decodeOk and config then
            if config.Theme and Themes[config.Theme] then
                self:SetTheme(config.Theme)
            end
            if config.Flags then
                for flagName, value in pairs(config.Flags) do
                    self:SetFlag(flagName, value)
                end
            end
            debugLog("INFO", "Config loaded from: %s", fileName)
            self:Notify({Title = "Config", Content = "Loaded from " .. fileName, Duration = 2})
        end
    else
        debugLog("INFO", "No config file found: %s", fileName)
    end
end

--// Element search
function MysteriousUI:SearchElements(query)
    query = query:lower()
    local results = {}
    for _, tab in ipairs(self.Tabs) do
        for _, element in ipairs(tab.Elements) do
            if element.Name and element.Name:lower():find(query, 1, true) then
                table.insert(results, {Tab = tab.Name, Element = element})
            end
        end
    end
    return results
end

--// Get all tab names
function MysteriousUI:GetTabNames()
    local names = {}
    for _, tab in ipairs(self.Tabs) do
        table.insert(names, tab.Name)
    end
    return names
end

--// Home page creator (dashboard)
function MysteriousUI:CreateHomePage(data)
    local homeTab = self:CreateTab({Name = "Home", Icon = "🏠"})
    local page = homeTab

    if data then
        if data.Greeting then
            page:CreateParagraph({Title = data.Greeting, Content = data.Subtitle or ""})
        end
        if data.InfoCards then
            for _, card in ipairs(data.InfoCards) do
                page:CreateInfoCard({
                    Icon = card.Icon,
                    Title = card.Title,
                    Subtitle = card.Subtitle,
                    Description = card.Description,
                    Value = card.Value,
                    ValueColor = card.ValueColor,
                })
            end
        end
        if data.QuickActions then
            page:CreateButtonGroup({
                Name = "Quick Actions",
                Buttons = data.QuickActions,
            })
        end
        if data.Stats then
            for _, stat in ipairs(data.Stats) do
                page:CreateProgressRing({
                    Name = stat.Name,
                    Value = stat.Value,
                    Max = stat.Max or 100,
                    Size = stat.Size or 50,
                    Color = stat.Color,
                    Description = stat.Description,
                })
            end
        end
    end

    return homeTab
end

function MysteriousUI:Destroy()
    debugLog("INFO", "Destroying UI")
    if self._connections then
        for _, conn in ipairs(self._connections) do
            pcall(function() conn:Disconnect() end)
        end
    end
    if self.Gui then
        self.Gui:Destroy()
    end
end

function MysteriousUI:Toggle()
    if self.Gui then
        self.Gui.Enabled = not self.Gui.Enabled
    end
end

return MysteriousUI
