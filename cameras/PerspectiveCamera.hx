package three.cameras;

import three.extras.MathUtils;

/**
 * ...
 * @author dcm
 */
class PerspectiveCamera extends Camera
{

	public var fov:Float;
	public var aspect:Float;
	public var near:Float;
	public var far:Float;
	
	public var fullWidth:Float = null;
	public var fullHeight:Float = null;
	public var x:Float = null;
	public var y:Float = null;
	public var width:Float = null;
	public var height:Float = null;
	
	public function new(fov:Float = 50, aspect:Float = 1, near:Float = 0.1, far:Float = 2000) 
	{
		super();
		this.fov = fov;
		this.aspect = aspect;
		this.near = near;
		this.far = far;
		updateProjectionMatrix();
	}
	
	
	public function setLens (focalLength:Float, frameHeight:Float = 24)
	{
		fov = 2 * MathUtils.radToDeg(Math.atan(frameHeight / ( focalLength * 2 ) ) );
		updateProjectionMatrix();
	}
	
	
	public function setViewOffset (fullWidth:Float, fullHeight:Float, x:Float, y:Float, width:Float, height:Float)
	{
		this.fullWidth = fullWidth;
		this.fullHeight = fullHeight;
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		updateProjectionMatrix();
	}
	
	
	public function updateProjectionMatrix ()
	{
		if (fullWidth != null)
		{
			var aspectRatio = fullWidth / fullHeight;
			var top = Math.tan(MathUtils.degToRad(fov * 0.5)) * near;
			var bottom = -top;
			var left = aspectRatio * bottom;
			var right = aspectRatio * top;
			var w = Math.abs(right - left);
			var h = Math.abs(top - bottom);
			
			projectionMatrix.makeFrustum(
				left + x * w / fullWidth,
				left + (x + width) * w / fullWidth,
				top - (y + height) * h / fullHeight,
				top - y * h / fullHeight,
				near,
				far
			);
			
		} else projectionMatrix.makePerspective(fov, aspect, near, far);
		
	}
	
	
}


