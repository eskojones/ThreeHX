
package three.renderers.renderables;
import three.materials.Material;
import three.math.Vector3;

/**
 * ...
 * @author dcm
 */

class RenderableParticle
{
	public var object:RenderableObject = null;
	public var x:Float = null;
	public var y:Float = null;
	public var z:Float = null;

	public var rotation:Vector3 = null;
	public var scale:Vector3; //should be v2, does it matter?
	
	public var material:Material = null;
	
	public function new() 
	{
		scale = new Vector3();
	}
	
}