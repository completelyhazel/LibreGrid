--!strict

--[[
	LibreGrid V.1.1.0
	Made by @completely_hazel
]]

local LibreGrid = {}

local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

local Types = require(script.Types)

-- Used to check if the ray hit a non-inclined surface
local function IsAnyAbs1(Vector: Vector3)
	return math.abs(Vector.X) >= 1 or math.abs(Vector.Y) >= 1 or math.abs(Vector.Z) >= 1
end

-- Used to calculate how much the reference has to be offset by to align to the grid
local function CalculateOffset(Size: number, GridSize: number)
	if GridSize <= 0 then return 0 end -- Avoid NaN
	
	return (Size % (GridSize * 2)) / 2
end

local function Main(Raycast: RaycastResult, Reference: BasePart | Model, GridSize: number, Rotation: CFrame,
	Configuration: Types.LibreGridConfiguration): CFrame?
	
	local Size = if Reference:IsA("BasePart") then Reference.Size else Reference:GetExtentsSize()	
	local Normal = Raycast.Normal
	local RaycastPosition = Raycast.Position
	local HitInstance = Raycast.Instance
	
	if Configuration.WhitelistedNormals and not table.find(Configuration.WhitelistedNormals, Normal) then return end -- Deal with whitelisted normals
	
	local IsAbs = not IsAnyAbs1(Normal)
	local IsNormalBased = Configuration.NormalBased
	
	if IsNormalBased == true and HitInstance:IsA("BasePart") then
		RaycastPosition = HitInstance.Position + (Normal * (Size/2)) -- Modify the position so it's based on the normal instead
	end
	
	local Position = if IsAbs and Configuration.AllowFaceAlignment ~= false then CFrame.lookAlong(RaycastPosition, Normal)
		else CFrame.new(RaycastPosition)
	
	local Combination = Position * if IsAbs then Rotation:Inverse() else Rotation -- Mix the position and rotation together
	
	local RelativeSize = Combination:VectorToObjectSpace(Size):Abs()
	
	local NormalOffset = Normal * (RelativeSize / 2) -- Calculate how much the reference has to be offset to be on the surface	
	local GridAlignmentOffset = Vector3.new(
		CalculateOffset(RelativeSize.X, GridSize * if NormalOffset.X == 0 then 1 else 0),
		CalculateOffset(RelativeSize.Y, GridSize * if NormalOffset.Y == 0 then 1 else 0),
		CalculateOffset(RelativeSize.Z, GridSize * if NormalOffset.Z == 0 then 1 else 0)
	) * if IsNormalBased then 0 else 1
					
	return (if Configuration.ForceAlignedOutput then LibreGrid:RoundCFrame(Combination + GridAlignmentOffset + NormalOffset, GridSize, Configuration.RoundingMethod)
		else LibreGrid:RoundCFrame(Combination, GridSize, Configuration.RoundingMethod) + GridAlignmentOffset + NormalOffset), Raycast
end

-- Creates a default set of raycast params to avoid the reference and the character from being detected.
local function CreateDefaultParams(Reference: Instance)
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = {Reference, Player.Character}
	
	return Params
end

-- Main ray function
local function RayMain(Ray: Ray, Reference: BasePart | Model, GridSize: number,
	Rotation: CFrame?, Configuration: Types.LibreGridConfiguration?)
	
	Configuration = Configuration or {}
	Rotation = Rotation or CFrame.identity
	
	local Raycast = workspace:Raycast(Ray.Origin, Ray.Direction,
		(Configuration :: Types.LibreGridConfiguration).RaycastParams or CreateDefaultParams(Reference))

	if not Raycast then return end
	
	return Main(Raycast, Reference, GridSize, Rotation :: CFrame, Configuration :: Types.LibreGridConfiguration)
end

-- Returns a CFrame using a custom ray. Note that this will return nil if there is no hit.
function LibreGrid:GetCFrameFromRay(Ray: Ray, Reference: BasePart | Model, GridSize: number,
	Rotation: CFrame?, Configuration: Types.LibreGridConfiguration?): (CFrame?, RaycastResult?)
	
	return RayMain(Ray, Reference, GridSize, Rotation, Configuration)
end

-- Returns a CFrame using the player's current mouse position. Note that this will return nil if there is no hit.
function LibreGrid:GetCFrameAtMousePosition(Reference: BasePart | Model, GridSize: number,
	Rotation: CFrame?, Configuration: Types.LibreGridConfiguration?): (CFrame?, RaycastResult?)
	
	local MouseRay = Mouse.UnitRay

	return RayMain(Ray.new(MouseRay.Origin, MouseRay.Direction * 15_000), Reference, GridSize, Rotation :: CFrame, Configuration :: Types.LibreGridConfiguration)
end

-- Rounds a CFrame's position to the grid
function LibreGrid:RoundCFrame(NewCFrame: CFrame, GridSize: number, RoundingFunction: Types.RoundingFunction?): CFrame
	if GridSize <= 0 then return NewCFrame end -- Avoid NaN
	local Position = NewCFrame.Position
	
	RoundingFunction = RoundingFunction or math.round

	return NewCFrame.Rotation + Vector3.new(
		(RoundingFunction :: Types.RoundingFunction)(Position.X/GridSize)*GridSize,
		(RoundingFunction :: Types.RoundingFunction)(Position.Y/GridSize)*GridSize,
		(RoundingFunction :: Types.RoundingFunction)(Position.Z/GridSize)*GridSize
	)
end

return LibreGrid
