
package three.renderers.renderables;

import three.math.Vector3;

/**
 * ...
 * @author dcm
 */

class RenderableFace4 extends RenderableFace3
{
	public var v4:RenderableVertex;
	
	public function new() 
	{
		super();
		v4 = new RenderableVertex();
		vertexNormalsModel.push(new Vector3());
		vertexNormalsModelView.push(new Vector3());
	}
	
}
