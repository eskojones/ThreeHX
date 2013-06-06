package three.lights;
import three.core.Object3D;

/**
 * ...
 * @author dcm
 */
class PointLight extends Light
{
	
	public var intensity:Float = 1.0;
	public var distance:Float = 0.0;

	public function new(hex:Int, intensity:Float = 1.0, distance:Float = 0.0) 
	{
		super(hex);
		this.intensity = intensity;
		this.distance = distance;
	}
	
}