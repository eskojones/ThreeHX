
package three.textures;


/**
 * TODO
 * @author dcm
 */

class Image
{
	
	//multi-target class for image data (not ImageData)
	public var data:Array<Int> = null;
	public var width:Int = 0;
	public var height:Int = 0;

	
	public function new(width:Int = null, height:Int = null) 
	{
		data = new Array<Int>();
		
		if (width != null) 
		{
			this.width = width;
			this.height = height;
		}
		
	}
	
}