
package three.textures;

import haxe.io.Bytes;

/**
 * TODO
 * @author dcm
 */

class Image
{
	public var data:Array<Int> = null;
	public var width:Int = 0;
	public var height:Int = 0;

	public function new(width:Int = null, height:Int = null) 
	{
		if (width != null) 
		{
			this.width = width;
			this.height = height;
			data = new Array<Int>();
			var i = 0, l = width * height * 4;
			while (i++ < l) data.push(0);
		}
	}
	
}