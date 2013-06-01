
package three.textures;
import three.math.Vector3;
import three.THREE;

/**
 * ...
 * @author dcm
 */

class Texture
{
	public var id:Int;
	public var name:String;
	public var image:Image; //todo - Image
	
	public var mipmaps:Array<Dynamic>;
	public var mapping:Dynamic = THREE.UVMapping;
	
	public var wrapS:Int = THREE.ClampToEdgeWrapping;
	public var wrapT:Int = THREE.ClampToEdgeWrapping;
	
	public var magFilter:Int = THREE.LinearFilter;
	public var minFilter:Int  = THREE.LinearMipMapLinearFilter;
	
	public var anisotropy:Int = 1;
	
	public var format:Int = THREE.RGBAFormat;
	public var type:Int = THREE.UnsignedByteType;
	
	public var offset:Vector3; //todo - Vector2
	public var repeat:Vector3; //^^^
	
	public var generateMipmaps:Bool = true;
	public var premultiplyAlpha:Bool = false;
	public var flipY:Bool = true;
	public var unpackAlignment:Int = 4;
	
	public var needsUpdate:Bool = false;
	public var onUpdate:Dynamic; //probably a callback fn
	
	
	public function new(
		image:Image = null, ?mapping:Dynamic, ?wrapS:Int, ?wrapT:Int,
		?magFilter:Int, ?minFilter:Int, ?format:Int, ?type:Int, ?anisotropy:Int) 
	{
		this.image = image;
		this.mipmaps = new Array<Dynamic>();
		if (wrapS != null) this.wrapS = wrapS;
		if (wrapT != null) this.wrapT = wrapT;
		
		if (magFilter != null) this.magFilter = magFilter;
		if (minFilter != null) this.minFilter = minFilter;
		if (anisotropy != null) this.anisotropy = anisotropy;
		
		if (format != null) this.format = format;
		if (type != null) this.type = type;
		
		offset = new Vector3(0, 0, 0);
		repeat = new Vector3(1, 1, 0);
	}
	
	
	public function clone (texture:Texture = null) : Texture
	{
		if (texture == null) texture = new Texture();
		//todo
		return texture;
	}

	
}