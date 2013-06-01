

package three.renderers.renderables;

import three.materials.Material;
import three.math.Color;
import three.math.Vector3;
import three.THREE;

/**
 * 
 * @author dcm
 */

class RenderableFace4 extends Renderable
{
	
	public var v1:RenderableVertex;
	public var v2:RenderableVertex;
	public var v3:RenderableVertex;
	public var v4:RenderableVertex;
	
	public var centroidModel:Vector3;
	
	public var normalModel:Vector3;
	public var normalModelView:Vector3;
	
	public var vertexNormalsLength:Int = 0;
	public var vertexNormalsModel:Array<Vector3>;
	public var vertexNormalsModelView:Array<Vector3>;
	
	public var color:Color = null;
	public var uvs:Array<Dynamic>;
	
	
	public function new() 
	{
		super();
		type = THREE.RenderableFace4;

		v1 = new RenderableVertex();
		v2 = new RenderableVertex();
		v3 = new RenderableVertex();
		v4 = new RenderableVertex();
		
		centroidModel = new Vector3();
		
		normalModel = new Vector3();
		normalModelView = new Vector3();
		
		vertexNormalsModel = new Array<Vector3>();
		vertexNormalsModel.push(new Vector3());
		vertexNormalsModel.push(new Vector3());
		vertexNormalsModel.push(new Vector3());
		vertexNormalsModel.push(new Vector3());
		
		vertexNormalsModelView = new Array<Vector3>();
		vertexNormalsModelView.push(new Vector3());
		vertexNormalsModelView.push(new Vector3());
		vertexNormalsModelView.push(new Vector3());
		vertexNormalsModelView.push(new Vector3());
		
		uvs = new Array<Dynamic>();
		uvs.push(new Array<Vector3>());
	}
	
}
