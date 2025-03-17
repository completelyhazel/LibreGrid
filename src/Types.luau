
export type LibreGridConfiguration = {
	RaycastParams: RaycastParams?, -- By default, LibreGrid will blacklist the reference and the player's character.
	ForceAlignedOutput: boolean?, -- Force CFrames to output 100% rounded to the grid at all times (NOT RECOMMENDED). DEFAULT: false
	AllowFaceAlignment: boolean?, -- Allows the module to rotate references to match the face of tilted parts. DEFAULT: true
	WhitelistedNormals: {Vector3}? -- If specified, LibreGrid will return nil when operating with normals that aren't specified here. DEFAULT: nil
}

return true
