-- Create a custom GUI
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local TabsFrame = Instance.new("Frame")
local CombatButton = Instance.new("TextButton")
local ESPButton = Instance.new("TextButton")
local MiscButton = Instance.new("TextButton")
local ContentFrame = Instance.new("Frame")
local CombatTab = Instance.new("Frame")
local ESPTab = Instance.new("Frame")
local MiscTab = Instance.new("Frame")

-- Variables
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.NumSides = 100
FOVCircle.Radius = 100
FOVCircle.Filled = false
FOVCircle.Visible = false
FOVCircle.ZIndex = 999
FOVCircle.Transparency = 1
FOVCircle.Color = Color3.fromRGB(255, 0, 0)

-- Settings
local Settings = {
    AimbotEnabled = false,
    TeamCheck = false, 
    AimPart = "Head",
    Sensitivity = 1.0,
    FOVSize = 100,
    ShowFOV = false,
    PredictionEnabled = false,
    PredictionAmount = 0.15,
    AimKey = Enum.UserInputType.MouseButton2
}

-- ESP Configuration
local ESP = {
    Enabled = true,
    OutlineColor = Color3.new(1, 1, 1), -- White outline
    FillColor = Color3.new(0, 1, 0), -- Green fill
    Transparency = 0.5,
    OutlineThickness = 2,
    TeamCheck = false, -- Set to true if you want to exclude teammates
    SkeletonColor = Color3.fromRGB(255, 0, 0), -- Default skeleton color
    SkeletonThickness = 2 -- Default skeleton line thickness
}

-- Create ESP container
local ESPContainer = Instance.new("Folder")
ESPContainer.Name = "ESPContainer"
ESPContainer.Parent = game.CoreGui

-- Function to create ESP for a player
local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local espFolder = Instance.new("Folder")
    espFolder.Name = player.Name .. "_ESP"
    espFolder.Parent = ESPContainer
    
    -- Create highlight effect (outline around character)
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillColor = ESP.FillColor
    highlight.OutlineColor = ESP.OutlineColor
    highlight.FillTransparency = ESP.Transparency
    highlight.OutlineTransparency = 0
    highlight.Parent = espFolder
    
    -- Update ESP
    local function UpdateESP()
        if not ESP.Enabled then
            highlight.Enabled = false
            return
        end
        
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            highlight.Enabled = false
            return
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid or humanoid.Health <= 0 then
            highlight.Enabled = false
            return
        end
        
        -- Update the highlight's parent to the character
        highlight.Enabled = true
        highlight.Adornee = character
    end
    
    -- Connect update function
    local connection = RunService.RenderStepped:Connect(UpdateESP)
    
    -- Clean up when player leaves
    player.AncestryChanged:Connect(function(_, parent)
        if parent == nil then
            espFolder:Destroy()
            connection:Disconnect()
        end
    end)
end

-- Initialize ESP for existing players
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        CreateESP(player)
    end
end

-- Set up ESP for players who join later
Players.PlayerAdded:Connect(CreateESP)

-- Toggle ESP function
local function ToggleESP()
    ESP.Enabled = not ESP.Enabled
end

-- Setup GUI
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Name = "CersixGUI"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.Parent = MainFrame
UICorner.CornerRadius = UDim.new(0, 8)

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 0, 0, 0)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Cersix"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

TabsFrame.Name = "TabsFrame"
TabsFrame.Parent = MainFrame
TabsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TabsFrame.Position = UDim2.new(0, 10, 0, 40)
TabsFrame.Size = UDim2.new(0, 100, 0, 250)

local function CreateTabButton(name, position)
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Parent = TabsFrame
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Position = position
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Font = Enum.Font.Gotham
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.Parent = button
    corner.CornerRadius = UDim.new(0, 4)
    
    return button
end

CombatButton = CreateTabButton("Combat", UDim2.new(0, 0, 0, 10))
ESPButton = CreateTabButton("ESP", UDim2.new(0, 0, 0, 50))
MiscButton = CreateTabButton("Misc", UDim2.new(0, 0, 0, 90))

ContentFrame.Name = "ContentFrame"
ContentFrame.Parent = MainFrame
ContentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ContentFrame.Position = UDim2.new(0, 120, 0, 40)
ContentFrame.Size = UDim2.new(0, 270, 0, 250)

local function CreateTab(name)
    local tab = Instance.new("Frame")
    tab.Name = name .. "Tab"
    tab.Parent = ContentFrame
    tab.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tab.Size = UDim2.new(1, 0, 1, 0)
    tab.Visible = false
    
    local corner = Instance.new("UICorner")
    corner.Parent = tab
    corner.CornerRadius = UDim.new(0, 4)
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Parent = tab
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    return tab, scrollFrame
end

CombatTab, CombatScroll = CreateTab("Combat")
ESPTab, ESPScroll = CreateTab("ESP")
MiscTab, MiscScroll = CreateTab("Misc")

-- Tab switching logic
CombatButton.MouseButton1Click:Connect(function()
    CombatTab.Visible = true
    ESPTab.Visible = false
    MiscTab.Visible = false
    
    CombatButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    ESPButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MiscButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

ESPButton.MouseButton1Click:Connect(function()
    CombatTab.Visible = false
    ESPTab.Visible = true
    MiscTab.Visible = false
    
    CombatButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ESPButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    MiscButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

MiscButton.MouseButton1Click:Connect(function()
    CombatTab.Visible = false
    ESPTab.Visible = false
    MiscTab.Visible = true
    
    CombatButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    ESPButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    MiscButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
end)

-- Helper function to create UI elements
local function CreateToggle(parent, name, default, callback, yPos)
    local toggle = Instance.new("Frame")
    toggle.Name = name .. "Toggle"
    toggle.Parent = parent
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.Position = UDim2.new(0, 10, 0, yPos)
    toggle.Size = UDim2.new(0, 230, 0, 30)
    
    local corner = Instance.new("UICorner")
    corner.Parent = toggle
    corner.CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel")
    label.Parent = toggle
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0, 180, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local button = Instance.new("TextButton")
    button.Parent = toggle
    button.BackgroundColor3 = default and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    button.Position = UDim2.new(0, 200, 0.5, -10)
    button.Size = UDim2.new(0, 20, 0, 20)
    button.Font = Enum.Font.SourceSans
    button.Text = ""
    button.TextColor3 = Color3.fromRGB(0, 0, 0)
    button.TextSize = 14
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.Parent = button
    buttonCorner.CornerRadius = UDim.new(0, 4)
    
    local enabled = default
    
    button.MouseButton1Click:Connect(function()
        enabled = not enabled
        button.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
        callback(enabled)
    end)
    
    return toggle
end

local function CreateSlider(parent, name, min, max, default, callback, yPos)
    local slider = Instance.new("Frame")
    slider.Name = name .. "Slider"
    slider.Parent = parent
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    slider.Position = UDim2.new(0, 10, 0, yPos)
    slider.Size = UDim2.new(0, 230, 0, 50)
    
    local corner = Instance.new("UICorner")
    corner.Parent = slider
    corner.CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel")
    label.Parent = slider
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0, 180, 0, 20)
    label.Font = Enum.Font.Gotham
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Parent = slider
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0, 190, 0, 0)
    valueLabel.Size = UDim2.new(0, 40, 0, 20)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 14
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Parent = slider
    sliderBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    sliderBg.Position = UDim2.new(0, 10, 0, 30)
    sliderBg.Size = UDim2.new(0, 210, 0, 10)
    
    local sliderBgCorner = Instance.new("UICorner")
    sliderBgCorner.Parent = sliderBg
    sliderBgCorner.CornerRadius = UDim.new(0, 4)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Parent = sliderBg
    sliderFill.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
    sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    sliderFill.BorderSizePixel = 0
    
    local sliderFillCorner = Instance.new("UICorner")
    sliderFillCorner.Parent = sliderFill
    sliderFillCorner.CornerRadius = UDim.new(0, 4)
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Parent = sliderBg
    sliderButton.BackgroundTransparency = 1
    sliderButton.Size = UDim2.new(1, 0, 1, 0)
    sliderButton.Text = ""
    
    local function updateSlider(input)
        local pos = UDim2.new(math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1), 0, 1, 0)
        sliderFill.Size = pos
        
        local value = math.floor(min + ((max - min) * pos.X.Scale))
        valueLabel.Text = tostring(value)
        callback(value)
    end
    
    sliderButton.MouseButton1Down:Connect(function(input)
        updateSlider({Position = Vector2.new(input.X, input.Y)})
        local connection
        connection = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider({Position = Vector2.new(input.Position.X, input.Position.Y)})
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                if connection then connection:Disconnect() end
            end
        end)
    end)
    
    return slider
end

local function CreateButton(parent, name, callback, yPos)
    local button = Instance.new("TextButton")
    button.Name = name .. "Button"
    button.Parent = parent
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.Size = UDim2.new(0, 230, 0, 30)
    button.Font = Enum.Font.Gotham
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 14
    
    local corner = Instance.new("UICorner")
    corner.Parent = button
    corner.CornerRadius = UDim.new(0, 4)
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

local function CreateDropdown(parent, name, options, default, callback, yPos)
    local dropdown = Instance.new("Frame")
    dropdown.Name = name .. "Dropdown"
    dropdown.Parent = parent
    dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    dropdown.Position = UDim2.new(0, 10, 0, yPos)
    dropdown.Size = UDim2.new(0, 230, 0, 30)
    
    local corner = Instance.new("UICorner")
    corner.Parent = dropdown
    corner.CornerRadius = UDim.new(0, 4)
    
    local label = Instance.new("TextLabel")
    label.Parent = dropdown
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 10, 0, 0)
    label.Size = UDim2.new(0, 100, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = name
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    
    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Parent = dropdown
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Position = UDim2.new(0, 110, 0, 0)
    selectedLabel.Size = UDim2.new(0, 90, 1, 0)
    selectedLabel.Font = Enum.Font.Gotham
    selectedLabel.Text = default
    selectedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    selectedLabel.TextSize = 14
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local dropButton = Instance.new("TextButton")
    dropButton.Parent = dropdown
    dropButton.BackgroundTransparency = 1
    dropButton.Position = UDim2.new(0, 200, 0, 0)
    dropButton.Size = UDim2.new(0, 30, 1, 0)
    dropButton.Font = Enum.Font.Gotham
    dropButton.Text = "▼"
    dropButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropButton.TextSize = 14
    
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Parent = dropdown
    optionsFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    optionsFrame.Position = UDim2.new(0, 0, 1, 5)
    optionsFrame.Size = UDim2.new(1, 0, 0, #options * 25)
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 5
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.Parent = optionsFrame
    optionsCorner.CornerRadius = UDim.new(0, 4)
    
    for i, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Parent = optionsFrame
        optionButton.BackgroundTransparency = 1
        optionButton.Position = UDim2.new(0, 0, 0, (i-1) * 25)
        optionButton.Size = UDim2.new(1, 0, 0, 25)
        optionButton.Font = Enum.Font.Gotham
        optionButton.Text = option
        optionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        optionButton.TextSize = 14
        optionButton.ZIndex = 6
        
        optionButton.MouseButton1Click:Connect(function()
            selectedLabel.Text = option
            optionsFrame.Visible = false
            callback(option)
        end)
    end
    
    dropButton.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
    end)
    
    return dropdown
end

-- Populate Combat Tab
CreateToggle(CombatScroll, "Enable Aimbot", false, function(value)
    Settings.AimbotEnabled = value
end, 10)

CreateToggle(CombatScroll, "Show FOV", false, function(value)
    Settings.ShowFOV = value
    FOVCircle.Visible = value
end, 50)

CreateSlider(CombatScroll, "FOV Size", 10, 500, 100, function(value)
    Settings.FOVSize = value
    FOVCircle.Radius = value
end, 90)

CreateToggle(CombatScroll, "Prediction", false, function(value)
    Settings.PredictionEnabled = value
end, 150)

CreateDropdown(CombatScroll, "Aim Part", {"Head", "Torso", "HumanoidRootPart"}, "Head", function(value)
    Settings.AimPart = value
end, 190)

-- Populate ESP Tab
CreateToggle(ESPScroll, "Enable ESP", true, function(value)
    ESP.Enabled = value
    ToggleESP()
end, 10)

CreateToggle(ESPScroll, "Outline ESP", true, function(value)
    -- Toggle between highlight and drawing ESP
    if value then
        -- Clear existing ESP objects
        ESPContainer:ClearAllChildren()
        
        -- Recreate ESP for all players
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                CreateESP(player)
            end
        end
    end
end, 50)

-- New Skeleton ESP Toggle
CreateToggle(ESPScroll, "Enable Skeleton ESP", false, function(value)
    if value then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                DrawESP(player)
            end
        end
    end
end, 90)

-- New Skeleton Color Slider
CreateSlider(ESPScroll, "Skeleton Color", 0, 255, 255, function(value)
    ESP.SkeletonColor = Color3.fromRGB(value, 0, 0) -- Example: Red color based on slider
end, 130)

-- New Skeleton Thickness Slider
CreateSlider(ESPScroll, "Skeleton Thickness", 1, 10, 2, function(value)
    ESP.SkeletonThickness = value
end, 170)

CreateSlider(ESPScroll, "Max Distance", 100, 5000, 1000, function(value)
    -- Update max distance for ESP
end, 210)

-- Populate Misc Tab
CreateButton(MiscScroll, "Infinite Jump", function()
    local InfiniteJumpEnabled = true
    UserInputService.JumpRequest:connect(function()
        if InfiniteJumpEnabled then
            LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
        end
    end)
    
    -- Create notification
    local notification = Instance.new("Frame")
    notification.Parent = ScreenGui
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notification.Position = UDim2.new(1, -220, 0, 20)
    notification.Size = UDim2.new(0, 200, 0, 60)
    notification.AnchorPoint = Vector2.new(0, 0)
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.Parent = notification
    notifCorner.CornerRadius = UDim.new(0, 6)
    
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Parent = notification
    notifTitle.BackgroundTransparency = 1
    notifTitle.Position = UDim2.new(0, 10, 0, 5)
    notifTitle.Size = UDim2.new(1, -20, 0, 20)
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.Text = "Infinite Jump"
    notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifTitle.TextSize = 14
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local notifText = Instance.new("TextLabel")
    notifText.Parent = notification
    notifText.BackgroundTransparency = 1
    notifText.Position = UDim2.new(0, 10, 0, 25)
    notifText.Size = UDim2.new(1, -20, 0, 30)
    notifText.Font = Enum.Font.Gotham
    notifText.Text = "Infinite Jump has been enabled!"
    notifText.TextColor3 = Color3.fromRGB(200, 200, 200)
    notifText.TextSize = 12
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextWrapped = true
    
    game:GetService("TweenService"):Create(notification, TweenInfo.new(0.5), {Position = UDim2.new(1, -220, 0, 20)}):Play()
    
    delay(5, function()
        game:GetService("TweenService"):Create(notification, TweenInfo.new(0.5), {Position = UDim2.new(1, 20, 0, 20)}):Play()
        wait(0.5)
        notification:Destroy()
    end)
end, 10)

CreateButton(MiscScroll, "Speed Boost", function()
    LocalPlayer.Character.Humanoid.WalkSpeed = 50
    
    -- Create notification
    local notification = Instance.new("Frame")
    notification.Parent = ScreenGui
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notification.Position = UDim2.new(1, -220, 0, 20)
    notification.Size = UDim2.new(0, 200, 0, 60)
    notification.AnchorPoint = Vector2.new(0, 0)
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.Parent = notification
    notifCorner.CornerRadius = UDim.new(0, 6)
    
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Parent = notification
    notifTitle.BackgroundTransparency = 1
    notifTitle.Position = UDim2.new(0, 10, 0, 5)
    notifTitle.Size = UDim2.new(1, -20, 0, 20)
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.Text = "Speed Boost"
    notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifTitle.TextSize = 14
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local notifText = Instance.new("TextLabel")
    notifText.Parent = notification
    notifText.BackgroundTransparency = 1
    notifText.Position = UDim2.new(0, 10, 0, 25)
    notifText.Size = UDim2.new(1, -20, 0, 30)
    notifText.Font = Enum.Font.Gotham
    notifText.Text = "Speed has been increased to 50!"
    notifText.TextColor3 = Color3.fromRGB(200, 200, 200)
    notifText.TextSize = 12
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextWrapped = true
    
    game:GetService("TweenService"):Create(notification, TweenInfo.new(0.5), {Position = UDim2.new(1, -220, 0, 20)}):Play()
    
    delay(5, function()
        game:GetService("TweenService"):Create(notification, TweenInfo.new(0.5), {Position = UDim2.new(1, 20, 0, 20)}):Play()
        wait(0.5)
        notification:Destroy()
    end)
end, 50)

CreateButton(MiscScroll, "Super Jump", function()
    LocalPlayer.Character.Humanoid.JumpPower = 100
    
    -- Create notification
    local notification = Instance.new("Frame")
    notification.Parent = ScreenGui
    notification.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    notification.Position = UDim2.new(1, -220, 0, 20)
    notification.Size = UDim2.new(0, 200, 0, 60)
    notification.AnchorPoint = Vector2.new(0, 0)
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.Parent = notification
    notifCorner.CornerRadius = UDim.new(0, 6)
    
    local notifTitle = Instance.new("TextLabel")
    notifTitle.Parent = notification
    notifTitle.BackgroundTransparency = 1
    notifTitle.Position = UDim2.new(0, 10, 0, 5)
    notifTitle.Size = UDim2.new(1, -20, 0, 20)
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.Text = "Super Jump"
    notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifTitle.TextSize = 14
    notifTitle.TextXAlignment = Enum.TextXAlignment.Left
    
    local notifText = Instance.new("TextLabel")
    notifText.Parent = notification
    notifText.BackgroundTransparency = 1
    notifText.Position = UDim2.new(0, 10, 0, 25)
    notifText.Size = UDim2.new(1, -20, 0, 30)
    notifText.Font = Enum.Font.Gotham
    notifText.Text = "Jump power has been increased to 100!"
    notifText.TextColor3 = Color3.fromRGB(200, 200, 200)
    notifText.TextSize = 12
    notifText.TextXAlignment = Enum.TextXAlignment.Left
    notifText.TextWrapped = true
    
    game:GetService("TweenService"):Create(notification, TweenInfo.new(0.5), {Position = UDim2.new(1, -220, 0, 20)}):Play()
    
    delay(5, function()
        game:GetService("TweenService"):Create(notification, TweenInfo.new(0.5), {Position = UDim2.new(1, 20, 0, 20)}):Play()
        wait(0.5)
        notification:Destroy()
    end)
end, 90)

CreateButton(MiscScroll, "Reset Character", function()
    LocalPlayer.Character:BreakJoints()
end, 130)

-- Skeleton ESP Function
local function DrawLine(color, thickness)
    local l = Drawing.new("Line")
    l.Visible = false
    l.From = Vector2.new(0, 0)
    l.To = Vector2.new(1, 1)
    l.Color = color
    l.Thickness = thickness
    l.Transparency = 1
    return l
end

local function DrawESP(plr)
    repeat wait() until plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil
    local limbs = {}
    local R15 = (plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R15) and true or false
    if R15 then 
        limbs = {
            -- Spine
            Head_UpperTorso = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            UpperTorso_LowerTorso = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            -- Left Arm
            UpperTorso_LeftUpperArm = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            LeftUpperArm_LeftLowerArm = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            LeftLowerArm_LeftHand = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            -- Right Arm
            UpperTorso_RightUpperArm = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            RightUpperArm_RightLowerArm = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            RightLowerArm_RightHand = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            -- Left Leg
            LowerTorso_LeftUpperLeg = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            LeftUpperLeg_LeftLowerLeg = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            LeftLowerLeg_LeftFoot = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            -- Right Leg
            LowerTorso_RightUpperLeg = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            RightUpperLeg_RightLowerLeg = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            RightLowerLeg_RightFoot = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
        }
    else 
        limbs = {
            Head_Spine = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            Spine = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            LeftArm = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            LeftArm_UpperTorso = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            RightArm = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            RightArm_UpperTorso = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            LeftLeg = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            LeftLeg_LowerTorso = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            RightLeg = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness),
            RightLeg_LowerTorso = DrawLine(ESP.SkeletonColor, ESP.SkeletonThickness)
        }
    end
    local function Visibility(state)
        for i, v in pairs(limbs) do
            v.Visible = state
        end
    end

    local function UpdaterR15()
        local connection
        connection = RunService.RenderStepped:Connect(function()
            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 then
                local HUM, vis = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis then
                    -- Head
                    local H = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if limbs.Head_UpperTorso.From ~= Vector2.new(H.X, H.Y) then
                        --Spine
                        local UT = Camera:WorldToViewportPoint(plr.Character.UpperTorso.Position)
                        local LT = Camera:WorldToViewportPoint(plr.Character.LowerTorso.Position)
                        -- Left Arm
                        local LUA = Camera:WorldToViewportPoint(plr.Character.LeftUpperArm.Position)
                        local LLA = Camera:WorldToViewportPoint(plr.Character.LeftLowerArm.Position)
                        local LH = Camera:WorldToViewportPoint(plr.Character.LeftHand.Position)
                        -- Right Arm
                        local RUA = Camera:WorldToViewportPoint(plr.Character.RightUpperArm.Position)
                        local RLA = Camera:WorldToViewportPoint(plr.Character.RightLowerArm.Position)
                        local RH = Camera:WorldToViewportPoint(plr.Character.RightHand.Position)
                        -- Left leg
                        local LUL = Camera:WorldToViewportPoint(plr.Character.LeftUpperLeg.Position)
                        local LLL = Camera:WorldToViewportPoint(plr.Character.LeftLowerLeg.Position)
                        local LF = Camera:WorldToViewportPoint(plr.Character.LeftFoot.Position)
                        -- Right leg
                        local RUL = Camera:WorldToViewportPoint(plr.Character.RightUpperLeg.Position)
                        local RLL = Camera:WorldToViewportPoint(plr.Character.RightLowerLeg.Position)
                        local RF = Camera:WorldToViewportPoint(plr.Character.RightFoot.Position)

                        --Head
                        limbs.Head_UpperTorso.From = Vector2.new(H.X, H.Y)
                        limbs.Head_UpperTorso.To = Vector2.new(UT.X, UT.Y)

                        --Spine
                        limbs.UpperTorso_LowerTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_LowerTorso.To = Vector2.new(LT.X, LT.Y)

                        -- Left Arm
                        limbs.UpperTorso_LeftUpperArm.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_LeftUpperArm.To = Vector2.new(LUA.X, LUA.Y)

                        limbs.LeftUpperArm_LeftLowerArm.From = Vector2.new(LUA.X, LUA.Y)
                        limbs.LeftUpperArm_LeftLowerArm.To = Vector2.new(LLA.X, LLA.Y)

                        limbs.LeftLowerArm_LeftHand.From = Vector2.new(LLA.X, LLA.Y)
                        limbs.LeftLowerArm_LeftHand.To = Vector2.new(LH.X, LH.Y)

                        -- Right Arm
                        limbs.UpperTorso_RightUpperArm.From = Vector2.new(UT.X, UT.Y)
                        limbs.UpperTorso_RightUpperArm.To = Vector2.new(RUA.X, RUA.Y)

                        limbs.RightUpperArm_RightLowerArm.From = Vector2.new(RUA.X, RUA.Y)
                        limbs.RightUpperArm_RightLowerArm.To = Vector2.new(RLA.X, RLA.Y)

                        limbs.RightLowerArm_RightHand.From = Vector2.new(RLA.X, RLA.Y)
                        limbs.RightLowerArm_RightHand.To = Vector2.new(RH.X, RH.Y)

                        -- Left Leg
                        limbs.LowerTorso_LeftUpperLeg.From = Vector2.new(LT.X, LT.Y)
                        limbs.LowerTorso_LeftUpperLeg.To = Vector2.new(LUL.X, LUL.Y)

                        limbs.LeftUpperLeg_LeftLowerLeg.From = Vector2.new(LUL.X, LUL.Y)
                        limbs.LeftUpperLeg_LeftLowerLeg.To = Vector2.new(LLL.X, LLL.Y)

                        limbs.LeftLowerLeg_LeftFoot.From = Vector2.new(LLL.X, LLL.Y)
                        limbs.LeftLowerLeg_LeftFoot.To = Vector2.new(LF.X, LF.Y)

                        -- Right Leg
                        limbs.LowerTorso_RightUpperLeg.From = Vector2.new(LT.X, LT.Y)
                        limbs.LowerTorso_RightUpperLeg.To = Vector2.new(RUL.X, RUL.Y)

                        limbs.RightUpperLeg_RightLowerLeg.From = Vector2.new(RUL.X, RUL.Y)
                        limbs.RightUpperLeg_RightLowerLeg.To = Vector2.new(RLL.X, RLL.Y)

                        limbs.RightLowerLeg_RightFoot.From = Vector2.new(RLL.X, RLL.Y)
                        limbs.RightLowerLeg_RightFoot.To = Vector2.new(RF.X, RF.Y)
                    end

                    if limbs.Head_UpperTorso.Visible ~= true then
                        Visibility(true)
                    end
                else 
                    if limbs.Head_UpperTorso.Visible ~= false then
                        Visibility(false)
                    end
                end
            else 
                if limbs.Head_UpperTorso.Visible ~= false then
                    Visibility(false)
                end
                if game.Players:FindFirstChild(plr.Name) == nil then 
                    for i, v in pairs(limbs) do
                        v:Remove()
                    end
                    connection:Disconnect()
                end
            end
        end)
    end

    local function UpdaterR6()
        local connection
        connection = game:GetService("RunService").RenderStepped:Connect(function()
            if plr.Character ~= nil and plr.Character:FindFirstChild("Humanoid") ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") ~= nil and plr.Character.Humanoid.Health > 0 then
                local HUM, vis = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                if vis then
                    local H = Camera:WorldToViewportPoint(plr.Character.Head.Position)
                    if limbs.Head_Spine.From ~= Vector2.new(H.X, H.Y) then
                        local T_Height = plr.Character.Torso.Size.Y/2 - 0.2
                        local UT = Camera:WorldToViewportPoint((plr.Character.Torso.CFrame * CFrame.new(0, T_Height, 0)).p)
                        local LT = Camera:WorldToViewportPoint((plr.Character.Torso.CFrame * CFrame.new(0, -T_Height, 0)).p)

                        local LA_Height = plr.Character["Left Arm"].Size.Y/2 - 0.2
                        local LUA = Camera:WorldToViewportPoint((plr.Character["Left Arm"].CFrame * CFrame.new(0, LA_Height, 0)).p)
                        local LLA = Camera:WorldToViewportPoint((plr.Character["Left Arm"].CFrame * CFrame.new(0, -LA_Height, 0)).p)

                        local RA_Height = plr.Character["Right Arm"].Size.Y/2 - 0.2
                        local RUA = Camera:WorldToViewportPoint((plr.Character["Right Arm"].CFrame * CFrame.new(0, RA_Height, 0)).p)
                        local RLA = Camera:WorldToViewportPoint((plr.Character["Right Arm"].CFrame * CFrame.new(0, -RA_Height, 0)).p)

                        local LL_Height = plr.Character["Left Leg"].Size.Y/2 - 0.2
                        local LUL = Camera:WorldToViewportPoint((plr.Character["Left Leg"].CFrame * CFrame.new(0, LL_Height, 0)).p)
                        local LLL = Camera:WorldToViewportPoint((plr.Character["Left Leg"].CFrame * CFrame.new(0, -LL_Height, 0)).p)

                        local RL_Height = plr.Character["Right Leg"].Size.Y/2 - 0.2
                        local RUL = Camera:WorldToViewportPoint((plr.Character["Right Leg"].CFrame * CFrame.new(0, RL_Height, 0)).p)
                        local RLL = Camera:WorldToViewportPoint((plr.Character["Right Leg"].CFrame * CFrame.new(0, -RL_Height, 0)).p)

                        -- Head
                        limbs.Head_Spine.From = Vector2.new(H.X, H.Y)
                        limbs.Head_Spine.To = Vector2.new(UT.X, UT.Y)

                        --Spine
                        limbs.Spine.From = Vector2.new(UT.X, UT.Y)
                        limbs.Spine.To = Vector2.new(LT.X, LT.Y)

                        --Left Arm
                        limbs.LeftArm.From = Vector2.new(LUA.X, LUA.Y)
                        limbs.LeftArm.To = Vector2.new(LLA.X, LLA.Y)

                        limbs.LeftArm_UpperTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.LeftArm_UpperTorso.To = Vector2.new(LUA.X, LUA.Y)

                        --Right Arm
                        limbs.RightArm.From = Vector2.new(RUA.X, RUA.Y)
                        limbs.RightArm.To = Vector2.new(RLA.X, RLA.Y)

                        limbs.RightArm_UpperTorso.From = Vector2.new(UT.X, UT.Y)
                        limbs.RightArm_UpperTorso.To = Vector2.new(RUA.X, RUA.Y)

                        --Left Leg
                        limbs.LeftLeg.From = Vector2.new(LUL.X, LUL.Y)
                        limbs.LeftLeg.To = Vector2.new(LLL.X, LLL.Y)

                        limbs.LeftLeg_LowerTorso.From = Vector2.new(LT.X, LT.Y)
                        limbs.LeftLeg_LowerTorso.To = Vector2.new(LUL.X, LUL.Y)

                        --Right Leg
                        limbs.RightLeg.From = Vector2.new(RUL.X, RUL.Y)
                        limbs.RightLeg.To = Vector2.new(RLL.X, RLL.Y)

                        limbs.RightLeg_LowerTorso.From = Vector2.new(LT.X, LT.Y)
                        limbs.RightLeg_LowerTorso.To = Vector2.new(RUL.X, RUL.Y)
                    end

                    if limbs.Head_Spine.Visible ~= true then
                        Visibility(true)
                    end
                else 
                    if limbs.Head_Spine.Visible ~= false then
                        Visibility(false)
                    end
                end
            else 
                if limbs.Head_Spine.Visible ~= false then
                    Visibility(false)
                end
                if game.Players:FindFirstChild(plr.Name) == nil then 
                    for i, v in pairs(limbs) do
                        v:Remove()
                    end
                    connection:Disconnect()
                end
            end
        end)
    end

    if R15 then
        coroutine.wrap(UpdaterR15)()
    else 
        coroutine.wrap(UpdaterR6)()
    end
end

for i, v in pairs(game:GetService("Players"):GetPlayers()) do
    if v.Name ~= LocalPlayer.Name then
        DrawESP(v)
    end
end

game.Players.PlayerAdded:Connect(function(newplr)
    if newplr.Name ~= LocalPlayer.Name then
        DrawESP(newplr)
    end
end)

-- Aimbot Functionality
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Settings.AimKey and Settings.AimbotEnabled then
        local target = nil
        local closestDistance = Settings.FOVSize
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local screenPos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                
                if onScreen and distance < closestDistance then
                    closestDistance = distance
                    target = player
                end
            end
        end
        
        if target then
            local aimPart = target.Character:FindFirstChild(Settings.AimPart)
            if aimPart then
                Mouse.Move:Wait()
                aimPart.Position = Vector3.new(aimPart.Position.X, aimPart.Position.Y, aimPart.Position.Z)
            end
        end
    end
end)
