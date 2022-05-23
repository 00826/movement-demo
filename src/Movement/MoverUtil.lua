-- ModuleScript
assert(script.ClassName == "ModuleScript", "script is not a ModuleScript")

-- create new type MoverInfo -- THIS IS ONLY FOR READABILITY/VISUAL AID
export type MoverInfo	= { --create new type "MoverInfo"
	BasePart : BasePart; -- basepart that the bodymover will act on
	Type : string; -- type of bodymover ("BodyVelocity", "BodyGyro", etc)
	Properties : Dictionary<any>; -- properties of bodymover ^
	Lifetime : number? -- how long will the bodymover act upon the basepart?
}

local Main = {}

--@desc		Applies Instance.new(`MoverInfo.Type`) to part `MoverInfo.BasePart` with properties `MoverInfo.Properties`, for an optional duration of `MoverInfo.Lifetime` seconds
--@param	{MoverInfo : MoverInfo} type MoverInfo
--@returns	returns BodyMover

function Main:ApplyMover(MoverInfo : MoverInfo): BodyMover
	local Mover = Instance.new(MoverInfo.Type) -- create new BodyMover as defined by MoverInfo
	assert(Mover, ("%s is not instance or no Mover type provided"):format(MoverInfo.Type or "nil")) -- assert() failsafe
	for Property, Value in pairs(MoverInfo.Properties) do -- apply properties to Mover
		Mover[Property] = Value
	end
	Mover.Parent = MoverInfo.BasePart -- parent Mover to target BasePart
	if MoverInfo.Lifetime then -- if lifetime is provided, then set lifetime
		coroutine.wrap(function() -- Debris service is inefficient, better-off writing your own
			task.wait(MoverInfo.Lifetime)
			Mover:Destroy()
		end)()
	end
	return Mover -- return mover being applied
end

--@desc		see @returns
--@param	{Direction : Vector3} normalized Vector3
--@param	{RelativeTo : CFrame} CFrame
--@returns	returns a normalized Vector3, where the CFrame (Y-rotation only) is oriented in the direction of the Direction vector

function Main:GetRelativeDirection(Direction : Vector3, RelativeTo : CFrame): Vector3
	return CFrame.lookAt(RelativeTo.Position, (RelativeTo.Position + Direction)).LookVector
end

return Main