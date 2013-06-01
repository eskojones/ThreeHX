
package three.renderers.renderables;

import three.materials.Material;
import three.math.Color;
import three.THREE;

/**
 * 
 * @author dcm
 */

class RenderableLine extends Renderable
{
	
	public var v1:RenderableVertex;
	public var v2:RenderableVertex;
	
	public var vertexColors:Array<Color>;
	

	public function new() 
	{
		super();
		type = THREE.RenderableLine;
		
		v1 = new RenderableVertex();
		v2 = new RenderableVertex();
		vertexColors.push(new Color());
		vertexColors.push(new Color());
	}
	
}
