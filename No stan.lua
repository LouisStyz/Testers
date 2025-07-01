local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local humanoid = player.Character:WaitForChild("Humanoid")

local minWalkSpeed = 19
local sigilosoEnabled = true

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "SigilosoMobileUI"
gui.ResetOnSpawn = false

-- 🛡️ BOTÓN DRAGGABLE
local dragButton = Instance.new("TextButton")
dragButton.Size = UDim2.new(0, 150, 0, 40)
dragButton.Position = UDim2.new(0, 80, 0, 200)
dragButton.Text = "🛡️ no stun: ON"
dragButton.BackgroundColor3 = Color3.fromRGB(40, 170, 90)
dragButton.TextColor3 = Color3.new(1, 1, 1)
dragButton.Font = Enum.Font.GothamBold
dragButton.TextSize = 14
dragButton.AutoButtonColor = false
dragButton.Parent = gui

-- DRAG TÁCTIL
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	dragButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
		startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

dragButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = dragButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
		update(input)
	end
end)

-- TOGGLE
dragButton.MouseButton1Click:Connect(function()
	sigilosoEnabled = not sigilosoEnabled
	dragButton.Text = sigilosoEnabled and "🛡️no stun: ON" or "🛡️ no stun: OFF"
	local newColor = sigilosoEnabled and Color3.fromRGB(40, 170, 90) or Color3.fromRGB(170, 40, 40)
	TweenService:Create(dragButton, TweenInfo.new(0.25), { BackgroundColor3 = newColor }):Play()
end)

-- SLIDER WALK SPEED
local sliderBack = Instance.new("Frame")
sliderBack.Size = UDim2.new(0, 150, 0, 6)
sliderBack.Position = UDim2.new(0, 80, 0, 260)
sliderBack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
sliderBack.Parent = gui

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, (minWalkSpeed - 10) * 5, 0, 6)
sliderFill.Position = sliderBack.Position
sliderFill.BackgroundColor3 = Color3.fromRGB(80, 170, 255)
sliderFill.Parent = sliderBack

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(0, 150, 0, 20)
sliderLabel.Position = UDim2.new(0, 80, 0, 235)
sliderLabel.Text = "Min WalkSpeed: " .. minWalkSpeed
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.new(1, 1, 1)
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.TextSize = 13
sliderLabel.Parent = gui

-- TOQUE DESLIZANTE
sliderBack.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		local conn
		conn = UserInputService.InputChanged:Connect(function(move)
			if move.UserInputType == Enum.UserInputType.Touch or move.UserInputType == Enum.UserInputType.MouseMovement then
				local x = math.clamp(move.Position.X - sliderBack.AbsolutePosition.X, 0, 150)
				sliderFill.Size = UDim2.new(0, x, 0, 6)
				minWalkSpeed = math.floor(x / 5) + 10
				sliderLabel.Text = "Min WalkSpeed: " .. minWalkSpeed
			end
		end)
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				conn:Disconnect()
			end
		end)
	end
end)

-- BLOQUEADOR SIGILOSO
local lastBlocked

local mt = getrawmetatable(game)
setreadonly(mt, false)
local oldNewIndex = mt.__newindex

mt.__newindex = newcclosure(function(self, key, value)
	if not checkcaller() and self:IsA("Humanoid") and sigilosoEnabled then
		if key == "WalkSpeed" and value < minWalkSpeed then
			if value ~= lastBlocked then
				print("[SIGILOSO] Bloqueado WalkSpeed:", value, "→", self.WalkSpeed)
				lastBlocked = value
			end
			return
		end
	end
	return oldNewIndex(self, key, value)
end)

print("[✔] Sistema móvil sigiloso activado.")
