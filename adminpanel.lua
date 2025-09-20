local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Wait for the AdminPanelService remote events
local Net = require(ReplicatedStorage.Packages.Net)
local ExecuteCommandRemote = Net:RemoteEvent("AdminPanelService/ExecuteCommand")

-- List of commands to execute
local commands = {"ragdoll", "jumpscare", "morph", "jail", "tiny", "balloon", "inverse", "rocket"}

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "PlayerTrackerGui"

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 40) -- Fixed size for header
Frame.Position = UDim2.new(1, -260, 0, 230) -- Top right
Frame.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 100)), ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 70, 90))}
UIGradient.Parent = Frame

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(1, 0, 1, 0)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = "Admin Panel"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 16
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.TextXAlignment = Enum.TextXAlignment.Center
ToggleButton.Parent = Frame

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, 0, 0, 0) -- Initially hidden
ContentFrame.Position = UDim2.new(0, 0, 1, 0) -- Below header
ContentFrame.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = Frame

local UICornerContent = Instance.new("UICorner")
UICornerContent.CornerRadius = UDim.new(0, 12)
UICornerContent.Parent = ContentFrame

local UIGradientContent = Instance.new("UIGradient")
UIGradientContent.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 90, 110)), ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 80, 100))}
UIGradientContent.Parent = ContentFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 3)
UIListLayout.Parent = ContentFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 3)
UIPadding.PaddingBottom = UDim.new(0, 3)
UIPadding.PaddingLeft = UDim.new(0, 3)
UIPadding.PaddingRight = UDim.new(0, 3)
UIPadding.Parent = ContentFrame

-- Debounce to prevent rapid clicks
local debounce = false
local isOpen = false

-- Function to execute admin commands
local function executeCommands(player, specificCommand)
    if debounce then return end
    debounce = true
    if player and player.Parent then
        if specificCommand then
            ExecuteCommandRemote:FireServer(player, specificCommand)
        else
            for _, command in ipairs(commands) do
                ExecuteCommandRemote:FireServer(player, command)
            end
        end
    else
        warn("Invalid player")
    end
    wait(0.5)
    debounce = false
end

-- Function to get distance between two players
local function getDistance(player1, player2)
    local char1 = player1.Character
    local char2 = player2.Character
    if not char1 or not char1:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    if not char2 or not char2:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    local pos1 = char1.HumanoidRootPart.Position
    local pos2 = char2.HumanoidRootPart.Position
    return (pos1 - pos2).Magnitude
end

-- Function to create player button and additional command buttons
local function createPlayerButton(player, layoutOrder)
    local ButtonFrame = Instance.new("Frame")
    ButtonFrame.Size = UDim2.new(1, -6, 0, 35)
    ButtonFrame.BackgroundTransparency = 1
    ButtonFrame.LayoutOrder = layoutOrder
    ButtonFrame.Parent = ContentFrame

    local PlayerButton = Instance.new("TextButton")
    PlayerButton.Name = player.Name
    PlayerButton.Size = UDim2.new(0.6, 0, 1, 0)
    PlayerButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
    PlayerButton.BorderSizePixel = 0
    PlayerButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    PlayerButton.Text = player.Name
    PlayerButton.TextSize = 14
    PlayerButton.Font = Enum.Font.Gotham
    PlayerButton.Parent = ButtonFrame

    local UICornerButton = Instance.new("UICorner")
    UICornerButton.CornerRadius = UDim.new(0, 8)
    UICornerButton.Parent = PlayerButton

    local UIGradientButton = Instance.new("UIGradient")
    UIGradientButton.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 100)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 120))}
    UIGradientButton.Parent = PlayerButton

    local UICornerShadow = Instance.new("UICorner")
    UICornerShadow.CornerRadius = UDim.new(0, 8)
    UICornerShadow.Parent = PlayerButton
    local Shadow = Instance.new("UIStroke")
    Shadow.Thickness = 1
    Shadow.Color = Color3.fromRGB(0, 0, 0)
    Shadow.Transparency = 0.7
    Shadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Shadow.Parent = PlayerButton

    -- Jail Button
    local JailButton = Instance.new("TextButton")
    JailButton.Name = "JailButton"
    JailButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    JailButton.BackgroundColor3 = Color3.fromRGB(90, 140, 90)
    JailButton.BorderSizePixel = 0
    JailButton.Text = "J"
    JailButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    JailButton.TextSize = 14
    JailButton.Font = Enum.Font.Gotham
    JailButton.Position = UDim2.new(0.75, 15, 0.1, 0)
    JailButton.Parent = ButtonFrame

    local UICornerJail = Instance.new("UICorner")
    UICornerJail.CornerRadius = UDim.new(0, 8)
    UICornerJail.Parent = JailButton

    local UIGradientJail = Instance.new("UIGradient")
    UIGradientJail.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 140, 90)), ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 160, 110))}
    UIGradientJail.Parent = JailButton

    local ShadowJail = Instance.new("UIStroke")
    ShadowJail.Thickness = 1
    ShadowJail.Color = Color3.fromRGB(0, 0, 0)
    ShadowJail.Transparency = 0.7
    ShadowJail.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ShadowJail.Parent = JailButton

    -- Rocket Button
    local RocketButton = Instance.new("TextButton")
    RocketButton.Name = "RocketButton"
    RocketButton.Size = UDim2.new(0.1, 0, 0.8, 0)
    RocketButton.BackgroundColor3 = Color3.fromRGB(140, 90, 90)
    RocketButton.BorderSizePixel = 0
    RocketButton.Text = "R"
    RocketButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    RocketButton.TextSize = 14
    RocketButton.Font = Enum.Font.Gotham
    RocketButton.Position = UDim2.new(0.85, 17, 0.1, 0)
    RocketButton.Parent = ButtonFrame

    local UICornerRocket = Instance.new("UICorner")
    UICornerRocket.CornerRadius = UDim.new(0, 8)
    UICornerRocket.Parent = RocketButton

    local UIGradientRocket = Instance.new("UIGradient")
    UIGradientRocket.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 90, 90)), ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 110, 110))}
    UIGradientRocket.Parent = RocketButton

    local ShadowRocket = Instance.new("UIStroke")
    ShadowRocket.Thickness = 1
    ShadowRocket.Color = Color3.fromRGB(0, 0, 0)
    ShadowRocket.Transparency = 0.7
    ShadowRocket.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ShadowRocket.Parent = RocketButton

    -- Add distance label
    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.Name = "DistanceLabel"
    DistanceLabel.Size = UDim2.new(0, 60, 1, 0)
    DistanceLabel.Position = UDim2.new(0.6, 0, 0, 0)
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
    DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    DistanceLabel.Text = ""
    DistanceLabel.Font = Enum.Font.Gotham
    DistanceLabel.TextSize = 12
    DistanceLabel.Parent = ButtonFrame

    PlayerButton.MouseButton1Click:Connect(function()
        executeCommands(player)
    end)

    PlayerButton.MouseEnter:Connect(function()
        UIGradientButton.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 90, 110)), ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 110, 130))}
    end)

    PlayerButton.MouseLeave:Connect(function()
        UIGradientButton.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 80, 100)), ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 100, 120))}
    end)

    JailButton.MouseButton1Click:Connect(function()
        executeCommands(player, "jail")
    end)

    JailButton.MouseEnter:Connect(function()
        UIGradientJail.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 150, 100)), ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 170, 120))}
    end)

    JailButton.MouseLeave:Connect(function()
        UIGradientJail.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(90, 140, 90)), ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 160, 110))}
    end)

    RocketButton.MouseButton1Click:Connect(function()
        executeCommands(player, "rocket")
    end)

    RocketButton.MouseEnter:Connect(function()
        UIGradientRocket.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(150, 100, 100)), ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 120, 120))}
    end)

    RocketButton.MouseLeave:Connect(function()
        UIGradientRocket.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(140, 90, 90)), ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 110, 110))}
    end)

    return ButtonFrame
end

-- Function to update player list sorted by distance
local function updatePlayerList()
    -- Clear existing buttons
    for _, child in ipairs(ContentFrame:GetChildren()) do
        if child:IsA("Frame") and child.Name ~= "UIListLayout" and child.Name ~= "UIPadding" then
            child:Destroy()
        end
    end

    -- Get all players except local player
    local otherPlayers = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local distance = getDistance(LocalPlayer, player)
            table.insert(otherPlayers, {player = player, distance = distance})
        end
    end

    -- Sort by distance (closest first)
    table.sort(otherPlayers, function(a, b)
        return a.distance < b.distance
    end)

    -- Create buttons for each player only if dropdown is open
    if isOpen then
        for i, data in ipairs(otherPlayers) do
            local player = data.player
            local buttonFrame = createPlayerButton(player, i)
            local distanceLabel = buttonFrame:FindFirstChild("DistanceLabel")
            if distanceLabel then
                distanceLabel.Text = "(" .. math.floor(data.distance) .. " studs)"
            end
        end
        ContentFrame.Size = UDim2.new(1, 0, 0, #otherPlayers * 38)
    else
        ContentFrame.Size = UDim2.new(1, 0, 0, 0)
    end
end

-- Toggle dropdown visibility
ToggleButton.MouseButton1Click:Connect(function()
    isOpen = not isOpen
    updatePlayerList()
end)

-- Update list when players join or leave, or every 0.5 seconds for distance updates
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(0.5)
        updatePlayerList()
    end)
end)

Players.PlayerRemoving:Connect(updatePlayerList)

LocalPlayer.CharacterAdded:Connect(updatePlayerList)

-- Initial update
if LocalPlayer.Character then
    updatePlayerList()
end

-- Periodic update for distance sorting (every 0.5 seconds)
spawn(function()
    while true do
        wait(0.1)
        updatePlayerList()
    end
end)

-- Make GUI draggable
local dragging = false
local dragInput = nil
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Frame.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)
