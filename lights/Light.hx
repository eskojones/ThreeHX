package three.lights;

import three.core.Object3D;
import three.math.Color;
import three.math.Vector3;

/**
 * ...
 * @author dcm
 */

class Light extends Object3D
{
	public var color:Color;

	public function new(hex:Int = 0xffffffff) 
	{
		super();
		color = new Color(hex);
		target = null;
	}
	
	
	override public function clone (object:Object3D = null) : Object3D
	{
		if (object != null) object = new Light();
		
		super.clone(cast(object, Object3D));
		var light:Light = cast(object, Light);
		light.color.copy(color);
		return object;
	}
	
}