
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

----------------------
-- Highlight System --
----------------------
local highlightFolder = Instance.new("Folder")
highlightFolder.Name = "PlayerHighlights"
highlightFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")

local highlightEnabled = true

local function highlightCharacter(character)
	if not character then return end

	if highlightFolder:FindFirstChild(character.Name) then
		highlightFolder[character.Name]:Destroy()
	end

	local highlight = Instance.new("Highlight")
	highlight.Name = character.Name
	highlight.Adornee = character
	highlight.FillColor = Color3.fromRGB(0, 255, 0)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.5
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	highlight.Enabled = highlightEnabled
	highlight.Parent = highlightFolder
end

local function setupPlayer(player)
	if player == LocalPlayer then return end
	player.CharacterAdded:Connect(function(char)
		highlightCharacter(char)
	end)
	if player.Character then
		highlightCharacter(player.Character)
	end
end

for _, player in pairs(Players:GetPlayers()) do
	setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(player)
	local h = highlightFolder:FindFirstChild(player.Name)
	if h then h:Destroy() end
end)

-------------------
-- Aimbot System --
-------------------
local lockEnabled = false

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0, 200, 0, 50)
statusLabel.Position = UDim2.new(0.5, -100, 0.1, 0)
statusLabel.BackgroundTransparency = 0.5
statusLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
statusLabel.TextColor3 = Color3.fromRGB(255,0,0)
statusLabel.Font = Enum.Font.FredokaOne
statusLabel.TextSize = 26
statusLabel.Text = "Camera Lock: OFF"
statusLabel.Parent = screenGui

local function getClosestPlayer()
	local closestDist = math.huge
	local closestPlayer = nil
	local myChar = LocalPlayer.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
	
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer
		and plr.Team ~= LocalPlayer.Team
		and plr.Character
		and plr.Character:FindFirstChild("HumanoidRootPart") then
			local pos = plr.Character.HumanoidRootPart.Position
			local dist = (myChar.HumanoidRootPart.Position - pos).Magnitude
			if dist < closestDist then
				closestDist = dist
				closestPlayer = plr
			end
		end
	end
	return closestPlayer
end

RunService.RenderStepped:Connect(function()
	if lockEnabled then
		local target = getClosestPlayer()
		if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = target.Character.HumanoidRootPart
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position)
		end
	end
end)

------------------------
-- Name Tag System --
------------------------
local nameTagFolder = Instance.new("Folder")
nameTagFolder.Name = "NameTags"
nameTagFolder.Parent = LocalPlayer:WaitForChild("PlayerGui")

local function addNameTag(player)
	

	local textLabel = Instance.new("TextLabel")
	textLabel.Name = player.Name
	textLabel.Size = UDim2.new(0, 200, 0, 40)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = player.Name
	textLabel.Font = Enum.Font.FredokaOne
	textLabel.TextColor3 = Color3.fromRGB(255,255,255)
	textLabel.TextStrokeTransparency = 0.3
	textLabel.TextScaled = true
	textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	textLabel.Parent = nameTagFolder
end

local function setupPlayer(player)
	if player == game.Players.LocalPlayer then return end
	player.CharacterAdded:Connect(function(char)
		highlightCharacter(char)
		addNameTag(player)
	end)
	if player.Character then
		highlightCharacter(player.Character)
		addNameTag(player)
	end
end

RunService.RenderStepped:Connect(function()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			local head = player.Character.Head
			local textLabel = nameTagFolder:FindFirstChild(player.Name)

			if textLabel then
				local pos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
				if onScreen then
					textLabel.Visible = true
					textLabel.Position = UDim2.new(0, pos.X, 0, pos.Y)

					local distance = (Camera.CFrame.Position - head.Position).Magnitude
					local scale = math.clamp(distance / 30, 0.8, 3)
					textLabel.TextSize = 20 * scale
				else
					textLabel.Visible = false
				end
			end
		end
	end
end)

----------------------
-- Toggle Key Binds --
----------------------
UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end

	if input.KeyCode == Enum.KeyCode.T then
		lockEnabled = not lockEnabled
		if lockEnabled then
			statusLabel.Text = "Camera Lock: ON"
			statusLabel.TextColor3 = Color3.fromRGB(0,255,0)
		else
			statusLabel.Text = "Camera Lock: OFF"
			statusLabel.TextColor3 = Color3.fromRGB(255,0,0)
		end
	end

	if input.KeyCode == Enum.KeyCode.B then
		highlightEnabled = not highlightEnabled
		for _, h in pairs(highlightFolder:GetChildren()) do
			h.Enabled = highlightEnabled
		end
	end
end)
