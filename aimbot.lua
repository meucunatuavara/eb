local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local Teams = game:GetService("Teams")

local localPlayer = Players.LocalPlayer
local target = nil
local aiming = false
local guiVisible = false
local selectedTeam = nil

local aimKey = Enum.UserInputType.MouseButton2
local toggleGUIKey = Enum.KeyCode.Zero
local fovRadius = 50
local predictionFactor = 0.05
local showESP = false

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Color = Color3.new(1, 1, 0)
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Radius = fovRadius
fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

local validKeys = {
    "JsPwWdUsPzQn", "YmWhHsWxVxTy", "TaXcTwHxPfJd", "XqMwOzEbLyLv", "YvJkExYiRdKl"
}

local function validateKey(key)
    for _, validKey in ipairs(validKeys) do
        if key == validKey then
            return true
        end
    end
    return false
end

-- Criação da Interface de Validação
local screenGui = Instance.new("ScreenGui", game.CoreGui)
screenGui.Name = "AimbotKeyValidation"

local frame = Instance.new("Frame", screenGui)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.Size = UDim2.new(0, 300, 0, 200)
frame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Text = "Enter Activation Key"
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextColor3 = Color3.new(1, 1, 1)
title.Size = UDim2.new(1, -20, 0, 40)
title.Position = UDim2.new(0, 10, 0, 5)
title.BackgroundTransparency = 1

local keyInput = Instance.new("TextBox", frame)
keyInput.Font = Enum.Font.SourceSans
keyInput.TextSize = 18
keyInput.TextColor3 = Color3.new(1, 1, 1)
keyInput.Size = UDim2.new(1, -20, 0, 40)
keyInput.Position = UDim2.new(0, 10, 0, 60)
keyInput.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
keyInput.PlaceholderText = "Enter your key"

local submitButton = Instance.new("TextButton", frame)
submitButton.Text = "Submit"
submitButton.Font = Enum.Font.SourceSans
submitButton.TextSize = 18
submitButton.TextColor3 = Color3.new(1, 1, 1)
submitButton.Size = UDim2.new(0.8, 0, 0, 40)
submitButton.Position = UDim2.new(0.1, 0, 0.6, 0)
submitButton.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)

local errorMessage = Instance.new("TextLabel", frame)
errorMessage.Text = ""
errorMessage.Font = Enum.Font.SourceSans
errorMessage.TextSize = 16
errorMessage.TextColor3 = Color3.new(1, 0, 0)
errorMessage.Size = UDim2.new(1, -20, 0, 30)
errorMessage.Position = UDim2.new(0, 10, 0, 120)
errorMessage.BackgroundTransparency = 1

local function startAimbot()
    guiVisible = true
    fovCircle.Visible = true
    showESP = true
    frame:Destroy() -- Remove a tela de validação
end

submitButton.MouseButton1Click:Connect(function()
    local enteredKey = keyInput.Text
    if validateKey(enteredKey) then
        startAimbot()
    else
        errorMessage.Text = "Invalid Key! Please try again."
    end
end)

local function getClosestTarget()
    local closestPlayer, closestDistance = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and (not selectedTeam or player.Team == selectedTeam) and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if distance < closestDistance and distance <= fovRadius then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end
    return closestPlayer
end

local function aimAtTarget()
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local velocity = target.Character:FindFirstChild("HumanoidRootPart").Velocity or Vector3.zero
        local predictedPosition = head.Position + velocity * predictionFactor

        local smoothness = 0.5
        local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, predictedPosition)
        Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothness)
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == aimKey then
        aiming = true
        target = getClosestTarget()
    elseif input.KeyCode == toggleGUIKey then
        guiVisible = not guiVisible
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == aimKey then
        aiming = false
        target = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if guiVisible then
        fovCircle.Position = UserInputService:GetMouseLocation()
        if aiming and target then
            aimAtTarget()
        end
    end
end)
