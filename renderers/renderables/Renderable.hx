
package three.renderers.renderables;

import three.materials.Material;

/**
 * 
 * @author dcm
 */

class Renderable
{
	//Superclass for all renderables to avoid having to cast so much
	
	public var type:Int = null;
	public var material:Material = null;
	public var z:Float = null;

	
	public function new() 
	{
	}
	
}