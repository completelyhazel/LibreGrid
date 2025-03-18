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

https://github.com/user-attachments/assets/6be5af74-e908-4bcd-bb32-07bdaf4df84f

3D placement system just like Minecraft's, parts perfectly aligned to the grid on the surface of all parts.

Just like the previous example, we will use the built-in `GetCFrameAtMousePosition` function as it will deal with all the raycasting shenanigans for us. We will use `RunServicee.PreRender` to run this function every frame, but in a real scenario, you'd prefer using a good ol' `UserInputService.InputChanged` connection.

```luau
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LibreGrid = require("LIBREGRID'S LOCATION")

local GhostPart = Instance.new("Part")
GhostPart.Anchored = true
GhostPart.CanCollide = false

GhostPart.Size = Vector3.new(3, 3, 3)

GhostPart.Parent = workspace

RunService.PreRender:Connect(function()
	local NewCFrame = LibreGrid:GetCFrameAtMousePosition(GhostPart, 3, nil, {ForceAlignedOutput = true, AllowFaceAlignment = false})
	if not NewCFrame then return end
	
	GhostPart.CFrame = NewCFrame
end)
```

***NOTE: You will require all the parts to be in a 3x3 size and grid in order for this to work correctly!***

### 3. 2D Furniture placement system
