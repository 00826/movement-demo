-- LocalScript
assert(script.ClassName == "LocalScript", "script is not a LocalScript")

-- services
local UIS					= game:GetService("UserInputService")
local CAS					= game:GetService("ContextActionService")

local MoverUtil				= require(script.Parent:WaitForChild("MoverUtil"))

-- variables, instances
local Player				= game:GetService("Players").LocalPlayer
local PlayerGui				= Player:FindFirstChild("PlayerGui") or Player:WaitForChild("PlayerGui")
local Character				= Player.Character or Player.CharacterAdded:Wait()
local RootPart : BasePart	= Character:WaitForChild("HumanoidRootPart")
local Humanoid : Humanoid	= Character:WaitForChild("Humanoid")

local Camera				= workspace.CurrentCamera

-- settings
local BaseSpeed				= game:GetService("StarterPlayer").CharacterWalkSpeed -- variable, default value is 16
local SprintSpeed			= 32		-- variable
local DoubleJumpPower		= 80		-- variable
local DashVelocity			= 80		-- variable
local DashCooldown			= 1			-- variable

local DoubleTapTimeout		= 0.2		-- grace period to trigger double-tap

-- booleans
local CanSprint				= false		-- can client trigger the sprint double-tap?
local DoubleJumped			= false		-- did client already use their double-jump?
local DashReset				= true		-- did client reset their air-dash?

local LastDash				= 0			-- time of last successful dash

-- base functions
local function Dash(_, InputState : Enum.UserInputState, InputObject : InputObject) -- dash
	if InputState == Enum.UserInputState.Begin then
		-- cooldown logic
		local TimeOfRequest = tick()
		local Delta = TimeOfRequest - LastDash
		if Delta < DashCooldown then return end

		-- can only-dash-once-in-air logic
		if Humanoid.FloorMaterial == Enum.Material.Air then
			if not DashReset then return end
			DashReset = false
		end

		-- now that all the checks are passed, actually do the dash
		print("dash")
		local Direction = Humanoid.MoveDirection -- default .movedirection
		if Direction.Magnitude == 0 then -- if the player is not moving, fallback on the direction their character is facing
			Direction = RootPart.CFrame.LookVector
		end

		local RelativeDirection = MoverUtil:GetRelativeDirection(Direction, Camera.CFrame) -- moverutil function
		MoverUtil:ApplyMover({ -- moverutil function; apply mover to HumanoidRootPart
			BasePart = RootPart; -- target of function
			Lifetime = 0.12; -- duration of bodymover
			Type = "BodyVelocity"; -- will use Instance.new("BodyVelocity") to act upon the HumanoidRootPart
			Properties = { -- properties of BodyVelocity
				Velocity = RelativeDirection * DashVelocity; -- v = direction * speed
				MaxForce = Vector3.new(30000, 0, 30000) -- y-component is 0 so they cannot dash up/down
			}
		})
	end
end

local function DoubleJump(_, InputState : Enum.UserInputState, InputObject : InputObject) -- double jump
	if InputState == Enum.UserInputState.Begin then
		if Humanoid.FloorMaterial ~= Enum.Material.Air then return end -- cannot double-jump when on ground
		if DoubleJumped then return end -- cannot double jump more than once
		DoubleJumped = true -- set boolean to true, indicating that the player just triggered the double-jump
		print("double jump")
		RootPart.AssemblyLinearVelocity *= Vector3.new(1, 0, 1) -- neutralize y-component of HumanoidRootPart.AssemblyLinearVelocity
		RootPart.AssemblyLinearVelocity += Vector3.new(0, DoubleJumpPower, 0) -- add velocity to HumanoidRootPart.AssemblyLinearVelocity
	end
end

local function ToggleSprint(_, InputState : Enum.UserInputState, InputObject : InputObject) -- sprint
	if InputState == Enum.UserInputState.Begin then
		Character:SetAttribute("Sprinting", true)
	elseif InputState == Enum.UserInputState.End then
		Character:SetAttribute("Sprinting", nil)
	end
end

-- input detection
CAS:BindAction("Sprint", ToggleSprint, true, Enum.KeyCode.ButtonL3) -- bind sprint for console
CAS:BindAction("Dash", Dash, true, Enum.KeyCode.Q, Enum.KeyCode.ButtonL1) -- bind dash for pc, console

-- DoubleJump and Sprint cannot be bound using CAS because it uses the spacebar, so it will be connected here
UIS.InputBegan:Connect(function(Input : InputObject, Typing : boolean)
	if Input.KeyCode == Enum.KeyCode.W then -- sprint for pc
		if Typing then return end
		-- logic is explained in post
		if CanSprint == false then
			CanSprint = true
			task.spawn(function()
				task.wait(DoubleTapTimeout)
				if CanSprint == true then CanSprint = false end
			end)
		else
			Character:SetAttribute("Sprinting", true)
			CanSprint = false
		end
	elseif Input.KeyCode == Enum.KeyCode.Space or Input.KeyCode == Enum.KeyCode.ButtonA then -- double jump fpr pc, console
		if Typing then return end
		DoubleJump(nil, Input.UserInputState)
	end
end)
UIS.InputEnded:Connect(function(Input : InputObject, Typing : boolean)
	if Input.KeyCode == Enum.KeyCode.W then -- sprint for PC
		if Typing then return end
		Character:SetAttribute("Sprinting", nil)
	end
end)

-- double-jump -- aforementioned ghetto workaround for TouchGui (mobile compatibility)
-- for some reason .Activated and .Mouse1ButtonClick will fire when the input is RELEASED (LOL)
-- accounts for mobile
if UIS.TouchEnabled then
	local TouchGui : ScreenGui = PlayerGui:FindFirstChild("TouchGui") or PlayerGui:WaitForChild("TouchGui") -- get mobile TouchGUI
	local JumpButton : ImageButton = TouchGui.TouchControlFrame:WaitForChild("JumpButton") -- get mobile jump button
	JumpButton.MouseButton1Down:Connect(function() -- .Mouse1ButtonDown appears to be the only fix
		DoubleJump(nil, Enum.UserInputState.Begin) -- call DoubleJump function with necessary arguments
	end)
end

-- .changed connections

Character.AttributeChanged:Connect(function(Attribute : string)
	if Attribute ~= "Sprinting" then return end
	local Value = Character:GetAttribute("Sprinting")
	print(("sprint %s"):format(Value == true and "start" or "end"))

	if Value == true then -- is now sprinting
		Humanoid.WalkSpeed = SprintSpeed
	else -- no longer sprinting
		Humanoid.WalkSpeed = BaseSpeed
	end
end)

Humanoid.StateChanged:Connect(function(_, NewState : Enum.HumanoidStateType)
	if NewState == Enum.HumanoidStateType.Landed then
		print("landed, resetting double jump, dash")
		DoubleJumped = false
		DashReset = true
	end
end)