## Usage
LibreGrid has two main functions: `GetCFrameAtMousePosition` and `GetCFrameFromRay`. It also contains a `RoundCFrame` function, that allows you to align a CFrame's translation to the grid.

<br>

### LibreGridConfiguration
Optional set of parameters used to configure how you want LibreGrid to behave:
- **RaycastParams** - `(RaycastParams)` Configures which parts will be detected. By default, this will ignore the Reference and the player's character. More info: [RaycastParams](https://create.roblox.com/docs/reference/engine/datatypes/RaycastParams)
- **ForceAlignedOutput** - `(bool)` Forces LibreGrid to output a rounded-to-the-grid result 100% of the time. LibreGrid may occasionally return non-rounded results for better user experience. It is recommended to turn this off unless you know what you're doing.
- **AllowFaceAlignment** - `(bool)` Set this to `false` if you don't want LibreGrid to rotate parts on tilted surfaces depending on the rotation of their surface.
- **WhitelistedNormals** - `({Vector3})` If specified, LibreGrid will return nil if raycasting hits a normal that isn't specified here.

<br>

### GetCFrameFromRay
- **Parameters:** Ray `(Ray)`, Reference `(BasePart or Model)`, GridSize `(number)`, Rotation `(optional CFrame)`, Configuration `(optional LibreGridConfiguration)` <br>
- **Returns:** `CFrame`, `RaycastResult`

Using a custom ray `Ray`, returns a `CFrame` rotated using `Rotation` that is aligned to the grid.

### GetCFrameAtMousePosition
- **Parameters:** Reference `(BasePart or Model)`, GridSize `(number)`, Rotation `(optional CFrame)`, Configuration `(optional LibreGridConfiguration)` <br>
- **Returns:** `CFrame`, `RaycastResult`

Using a ray that shoots from the camera to the player mouse's position, returns a `CFrame` rotated using `Rotation` that is aligned to the grid.

### RoundCFrame
- **Parameters:** CFrame `CFrame`, GridSize `(number)` <br>
- **Returns:** `CFrame`

Returns a copy of `CFrame` whose translation is rounded to `GridSize` 
