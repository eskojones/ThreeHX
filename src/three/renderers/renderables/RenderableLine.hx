
package three.renderers.renderables;
import three.materials.Material;
import three.math.Color;

/**
 * ...
 * @author dcm
 */

class RenderableLine
{
	public var z:Float = null;
	
	public var v1:RenderableVertex;
	public var v2:RenderableVertex;
	
	public var vertexColors:Array<Color>;
	public var material:Material = null;
	

	public function new() 
	{
		v1 = new RenderableVertex();
		v2 = new RenderableVertex();
		vertexColors.push(new Color());
		vertexColors.push(new Color());
	}
	
}
