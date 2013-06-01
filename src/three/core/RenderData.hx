
package three.core;
import three.lights.Light;
import three.renderers.renderables.RenderableObject;

/**
 * ...
 * @author dcm
 */

class RenderData
{
	public var objects:Array<RenderableObject>;
	public var sprites:Array<Dynamic>; //todo
	public var lights:Array<Light>;
	public var elements:Array<Dynamic>; //RenderableVertex
	
	public function new ()
	{
		objects = new Array<RenderableObject>();
		sprites = new Array<Dynamic>();
		lights = new Array<Light>();
		elements = new Array<Dynamic>();
	}
}


