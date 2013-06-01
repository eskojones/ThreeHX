package three.renderers.renderables;
import three.math.Vector3;
import three.math.Vector4;

/**
 * ...
 * @author dcm
 */

class RenderableVertex
{
	public var positionWorld:Vector3;
	public var positionScreen:Vector4;
	public var visible:Bool = true;

	public function new() 
	{
		positionWorld = new Vector3();
		positionScreen = new Vector4();
	}
	
	public function copy (vertex:RenderableVertex)
	{
		positionWorld.copy(vertex.positionWorld);
		positionScreen.copy(vertex.positionScreen);
	}
}

