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
Frame.Size = UDim2.new(0, 220, 0, 300)
Frame.Position = UDim2.new(0, 10, 0, 10)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(1, 0, 1, -30)
ScrollingFrame.Position = UDim2.new(0, 0, 0, 30)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 5
ScrollingFrame.Parent = Frame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 30)
TitleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Text = "Player Tracker (Closest First)"
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = ScrollingFrame

-- Debounce to prevent rapid clicks
local debounce = false

-- Function to execute admin commands
local function executeCommands(player)
    if debounce then return end
    debounce = true
    if player and player.Parent then
        for _, command in ipairs(commands) do
            ExecuteCommandRemote:FireServer(player, command)
        end
    else
        warn("Invalid player")
    end
    wait(0.5) -- Small delay to ensure commands process
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

-- Function to create player button
local function createPlayerButton(player, layoutOrder)
    local Button = Instance.new("TextButton")
    Button.Name = player.Name
    Button.Size = UDim2.new(1, -10, 0, 25)
    Button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    Button.BorderSizePixel = 0
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Text = player.Name
    Button.TextSize = 12
    Button.Font = Enum.Font.SourceSans
    Button.LayoutOrder = layoutOrder
    Button.Parent = ScrollingFrame

    -- Add distance label
    local DistanceLabel = Instance.new("TextLabel")
    DistanceLabel.Name = "DistanceLabel"
    DistanceLabel.Size = UDim2.new(1, 0, 1, 0)
    DistanceLabel.BackgroundTransparency = 1
    DistanceLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
    DistanceLabel.Text = ""
    DistanceLabel.Font = Enum.Font.SourceSans
    DistanceLabel.TextSize = 10
    DistanceLabel.Parent = Button

    Button.MouseButton1Click:Connect(function()
        executeCommands(player)
    end)

    return Button
end

-- Function to update player list sorted by distance
local function updatePlayerList()
    -- Clear existing buttons
    for _, child in ipairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then
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

    -- Create buttons for each player
    for i, data in ipairs(otherPlayers) do
        local player = data.player
        local button = createPlayerButton(player, i)
        local distanceLabel = button:FindFirstChild("DistanceLabel")
        if distanceLabel then
            distanceLabel.Text = "(" .. math.floor(data.distance) .. " studs)"
        end
    end

    -- Adjust ScrollingFrame size
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, #otherPlayers * 27)
end

-- Update list when players join or leave, or every few seconds for distance updates
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(0.5) -- Small delay to ensure character fully loads
        updatePlayerList()
    end)
end)

Players.PlayerRemoving:Connect(updatePlayerList)

LocalPlayer.CharacterAdded:Connect(updatePlayerList)

-- Initial update
if LocalPlayer.Character then
    updatePlayerList()
end

-- Periodic update for distance sorting (every 3 seconds)
spawn(function()
    while true do
        wait(3)
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