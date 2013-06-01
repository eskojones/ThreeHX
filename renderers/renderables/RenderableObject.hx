
package three.renderers.renderables;

import three.core.Object3D;
import three.THREE;

/**
 * 
 * @author dcm
 */

class RenderableObject extends Renderable
{

	public var object:Object3D = null;
	
	
	public function new() 
	{
		super();
		type = THREE.RenderableObject;
		
	}
	
}