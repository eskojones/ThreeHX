
package three.renderers.renderables;

import three.math.Vector3;
import three.math.Vector4;
import three.THREE;

/**
 * 
 * @author dcm
 */

class RenderableVertex extends Renderable
{
	
	public var positionWorld:Vector3;
	public var positionScreen:Vector4;
	public var visible:Bool = true;

	
	public function new() 
	{
		super();
		type = THREE.RenderableVertex;
		
		positionWorld = new Vector3();
		positionScreen = new Vector4();
	}
	
	public function copy (vertex:RenderableVertex)
	{
		positionWorld.copy(vertex.positionWorld);
		positionScreen.copy(vertex.positionScreen);
	}
}

