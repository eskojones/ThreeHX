
package three.textures;

import three.math.Vector2;
import three.math.Vector3;
import three.THREE;

/**
 * 
 * @author dcm
 */

class Texture
{
	public var id:Int;
	public var name:String;
	public var image:Dynamic; 
	
	public var mipmaps:Array<Dynamic>; //??
	public var mapping:Int;
	
	public var wrapS:Int;
	public var wrapT:Int;
	
	public var magFilter:Int;
	public var minFilter:Int;
	
	public var anisotropy:Int = 1;
	
	public var format:Int;
	public var type:Int;
	
	public var offset:Vector2;
	public var repeat:Vector2;
	
	public var generateMipmaps:Bool = true;
	public var premultiplyAlpha:Bool = false;
	public var flipY:Bool = true;
	public var unpackAlignment:Int = 4;
	
	public var needsUpdate:Bool = false;
	public var onUpdate:Dynamic = null; //callback function checked+called by renderers after loading texture
	
	
	public function new(
		image:Image = null, ?mapping:Dynamic, ?wrapS:Int, ?wrapT:Int,
		?magFilter:Int, ?minFilter:Int, ?format:Int, ?type:Int, ?anisotropy:Int) 
	{
		//Default constants
		this.mapping = THREE.UVMapping;
		this.wrapS = THREE.ClampToEdgeWrapping;
		this.wrapT = THREE.ClampToEdgeWrapping;
		this.magFilter = THREE.LinearFilter;
		this.minFilter = THREE.LinearMipMapLinearFilter;
		this.format = THREE.RGBAFormat;
		this.type = THREE.UnsignedByteType;
		
		this.image = image;
		this.mipmaps = new Array<Dynamic>();
		
		if (wrapS != null) this.wrapS = wrapS; else this.wrapS = THREE.ClampToEdgeWrapping;
		if (wrapT != null) this.wrapT = wrapT; else this.wrapT = THREE.ClampToEdgeWrapping;
		
		if (magFilter != null) this.magFilter = magFilter; else this.magFilter = THREE.LinearFilter;
		if (minFilter != null) this.minFilter = minFilter; else this.minFilter = THREE.LinearMipMapLinearFilter;
		if (anisotropy != null) this.anisotropy = anisotropy;
		
		if (format != null) this.format = format; else this.format = THREE.RGBAFormat;
		if (type != null) this.type = type; else this.type = THREE.UnsignedByteType;
		
		offset = new Vector2(0, 0);
		repeat = new Vector2(1, 1);
		
		if (image != null) needsUpdate = true;
	}
	
	
	public function clone (texture:Texture = null) : Texture
	{
		if (texture == null) texture = new Texture();
		texture.image = image;
		texture.mipmaps = mipmaps.slice(0);
		
		texture.mapping = mapping;
		texture.wrapS = wrapS;
		texture.wrapT = wrapT;
		
		texture.magFilter = magFilter;
		texture.minFilter = minFilter;
		
		texture.anisotropy = anisotropy;
		
		texture.format = format;
		texture.type = type;
		
		texture.offset.copy(offset);
		texture.repeat.copy(repeat);
		
		texture.generateMipmaps = generateMipmaps;
		texture.premultiplyAlpha = premultiplyAlpha;
		texture.flipY = flipY;
		texture.unpackAlignment = unpackAlignment;
		return texture;
	}

	
}