--!strict

--[[
	LibreGrid V.1.0.0
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
		CalculateOffset(RelativeSize.X, GridSize * if NormalOffset.X == 0 and not IsNormalBased then 1 else 0),
		CalculateOffset(RelativeSize.Y, GridSize * if NormalOffset.Y == 0 and not IsNormalBased then 1 else 0),
		CalculateOffset(RelativeSize.Z, GridSize * if NormalOffset.Z == 0 and not IsNormalBased then 1 else 0)
	)
	
	print(NormalOffset, GridAlignmentOffset)
				
	return (if Configuration.ForceAlignedOutput then LibreGrid:RoundCFrame(Combination * CFrame.new(GridAlignmentOffset) + NormalOffset, GridSize)
		else LibreGrid:RoundCFrame(Combination, GridSize) + GridAlignmentOffset + NormalOffset), Raycast
end

-- Creates a default set of raycast params to avoid the reference and the character from being detected.
local function CreateDefaultParams(Reference: Instance)
	local Params = RaycastParams.new()
	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = {Reference, Player.Character}
	
	return Params
end

-- Returns a CFrame using a custom ray. Note that this will return nil if there is no hit.
function LibreGrid:GetCFrameFromRay(Ray: Ray, Reference: BasePart | Model, GridSize: number,
	Rotation: CFrame?, Configuration: Types.LibreGridConfiguration?): (CFrame?, RaycastResult?)
	
	Configuration = Configuration or {}
	Rotation = Rotation or CFrame.identity
	
	local Raycast = workspace:Raycast(Ray.Origin, Ray.Direction,
		(Configuration :: Types.LibreGridConfiguration).RaycastParams or CreateDefaultParams(Reference))
	
	if not Raycast then return end
	
	return Main(Raycast, Reference, GridSize, Rotation :: CFrame, Configuration :: Types.LibreGridConfiguration)
end

-- Returns a CFrame using the player's current mouse position. Note that this will return nil if there is no hit.
function LibreGrid:GetCFrameAtMousePosition(Reference: BasePart | Model, GridSize: number,
	Rotation: CFrame?, Configuration: Types.LibreGridConfiguration?): (CFrame?, RaycastResult?)
	
	Configuration = Configuration or {}
	Rotation = Rotation or CFrame.identity
	
	local Ray = Mouse.UnitRay

	local Raycast = workspace:Raycast(Ray.Origin, Ray.Direction * 15_000,
		(Configuration :: Types.LibreGridConfiguration).RaycastParams or CreateDefaultParams(Reference))

	if not Raycast then return end

	return Main(Raycast, Reference, GridSize, Rotation :: CFrame, Configuration :: Types.LibreGridConfiguration)
end

-- Rounds a CFrame's position to the grid
function LibreGrid:RoundCFrame(NewCFrame: CFrame, GridSize: number): CFrame
	if GridSize <= 0 then return NewCFrame end -- Avoid NaN
	local Position = NewCFrame.Position

	return NewCFrame.Rotation + Vector3.new(
		math.round(Position.X/GridSize)*GridSize,
		math.round(Position.Y/GridSize)*GridSize,
		math.round(Position.Z/GridSize)*GridSize
	)
end

return LibreGrid
