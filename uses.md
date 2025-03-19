## Use cases

### 1. 3D Studio-like placement system

https://github.com/user-attachments/assets/b40c1fe2-5505-4044-a222-194c3de7f7de

3D placement system just like Studio's, parts snapping on the surface of all parts with the ability to rotate the part.

For this example, we will use the built-in `GetCFrameAtMousePosition` function as it will deal with all the raycasting shenanigans for us. We will use `RunServicee.PreRender` to run this function every frame, but in a real scenario, you'd prefer using a good ol' `UserInputService.InputChanged` connection.

```luau
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LibreGrid = require("LIBREGRID'S LOCATION")

local GhostPart = Instance.new("Part")
GhostPart.Anchored = true
GhostPart.CanCollide = false

GhostPart.Size = Vector3.new(4, 5, 3) -- Set your custom part size!

GhostPart.Parent = workspace

local Rotation = CFrame.identity -- 0, 0, 0 rotation

RunService.PreRender:Connect(function()
	local NewCFrame = LibreGrid:GetCFrameAtMousePosition(GhostPart, 1, Rotation)
	if not NewCFrame then return end -- GetCFrameAtMousePosition might return nil if no hit was detected
	
	GhostPart.CFrame = NewCFrame -- You could also use :PivotTo()
end)

UserInputService.InputEnded:Connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.R then
		Rotation *= CFrame.Angles(0, math.rad(90), 0) -- Add 90º to the rotation when the player presses R
	end
end)
```

### 2. Minecraft-ish block placement system


https://github.com/user-attachments/assets/a4add954-8357-49d4-ab0d-5f05210bac43


3D placement system just like Minecraft's, parts perfectly aligned to the grid on the surface of all parts.

Just like the previous example, we will use the built-in `GetCFrameAtMousePosition` function as it will deal with all the raycasting shenanigans for us. We will use `RunServicee.PreRender` to run this function every frame, but in a real scenario, you'd prefer using a good ol' `UserInputService.InputChanged` connection.

We're gonna use LibreGrid's configuration to do this. For this example, we will use the `NormalBased` configuration to tell LibreGrid to calculate the CFrame based on the normal and not the ray hit.

```luau
local RunService = game:GetService("RunService")

local LibreGrid = require("LIBREGRID'S LOCATION")

local GhostPart = Instance.new("Part")
GhostPart.Anchored = true
GhostPart.CanCollide = false

GhostPart.Size = Vector3.new(3, 3, 3)

GhostPart.Parent = workspace

RunService.PreRender:Connect(function()
	local NewCFrame = LibreGrid:GetCFrameAtMousePosition(GhostPart, 3, nil, {
		ForceAlignedOutput = true, -- Force the position to output as multiples of 3
 		AllowFaceAlignment = false, -- Disable aligning to tilted surfaces
 		NormalBased = true
	})
	if not NewCFrame then return end
	
	GhostPart.CFrame = NewCFrame
end)
```

I used this script on the server to generate the terrain, in case you're interested:
```luau
local Seed = Random.new():NextNumber(-5000, 5000)

for x = 1, 50 do
	for z = 1, 50 do
		local Part = Instance.new("Part")
		Part.Size = Vector3.new(3,3,3)
		Part.BrickColor = BrickColor.new("Bright green")
		Part.Anchored = true
		Part.Material = Enum.Material.Grass

		local Height = math.noise(x / 20, z / 20, Seed) * 20
		Height -= Height % 3 -- Round the height
		
		Part.Position = Vector3.new(x*3, height, z*3)
		
		Part.Parent = workspace
	end
end
```

***NOTE: You will require all the parts to be 3x3 in size and on a 3x3 grid for this to work correctly!***


### 3. 2D Furniture placement system


https://github.com/user-attachments/assets/c38f8ebc-44b2-493d-8b6b-008819944781


2D placement system where you can place blocks (like furniture) only on the floor (skips walls and non-floor surfaces). 

Just like the two previous examples, we will use the built-in `GetCFrameAtMousePosition` function as it will deal with all the raycasting shenanigans for us. We will use `RunServicee.PreRender` to run this function every frame, but in a real scenario, you'd prefer using a good ol' `UserInputService.InputChanged` connection.

We will use the `WhitelistedNormals` configuration to tell LibreGrid which normals can be operated. In this case, it'll only be the top normal (0, 1, 0).

```luau
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LibreGrid = require(script.LibreGrid)

local GhostPart = Instance.new("Part")
GhostPart.Anchored = true
GhostPart.CanCollide = false
GhostPart.Color = Color3.fromRGB(197, 51, 51)
GhostPart.Transparency = 0.5
GhostPart.Material = Enum.Material.Neon
GhostPart.CastShadow = false

GhostPart.Size = Vector3.new(4, 4, 6)

GhostPart.Parent = workspace

local Rotation = CFrame.identity -- 0, 0, 0 rotation

RunService.PreRender:Connect(function()
	local NewCFrame = LibreGrid:GetCFrameAtMousePosition(GhostPart, 1, Rotation, {
		AllowFaceAlignment = false,
		WhitelistedNormals = {Vector3.new(0, 1, 0)} -- Here we tell LibreGrid to only accept 0, 1, 0 normals (top surface)
	})
	if not NewCFrame then return end
	
	GhostPart.CFrame = NewCFrame
end)

UserInputService.InputEnded:Connect(function(Input)
	if Input.KeyCode == Enum.KeyCode.R then
		Rotation *= CFrame.Angles(0, math.rad(45), 0) -- Add 45º to the rotation when the player presses R
	end
end)
```

Additionally, you could provide some `RaycastParams` using the `RaycastParams` configuration to determine which parts will be considered the floor. You could also switch the `WhitelistedNormals` configuration mid-placement to include the horizontal directions if you wish to implement a wall placement system too.
