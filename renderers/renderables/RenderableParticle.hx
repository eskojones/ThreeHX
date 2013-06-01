
package three.renderers.renderables;

import three.materials.Material;
import three.math.Vector2;
import three.math.Vector3;
import three.THREE;

/**
 * 
 * @author dcm
 */

class RenderableParticle extends Renderable
{
	
	public var object:RenderableObject = null;
	public var x:Float = null;
	public var y:Float = null;

	public var rotation:Vector3 = null;
	public var scale:Vector2 = null;
	
	public function new() 
	{
		super();
		type = THREE.RenderableParticle;

		scale = new Vector2();
	}
	
}