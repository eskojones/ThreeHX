
package three.materials;

import three.math.Color;
import three.textures.Texture;
import three.THREE;

/**
 * 
 * @author dcm
 */

class MeshBasicMaterial extends Material
{
	
	public var map:Texture;
	public var lightMap:Dynamic; //not sure what type goes here?
	
	public var specularMap:Dynamic;
	
	public var envMap:Dynamic;
	public var combine:Int;
	public var reflectivity:Float = 1.0;
	public var refractionRatio:Float = 0.98;
	
	public var fog:Bool = true;
	
	public var shading:Int;
	
	public var vertexColors:Int;
	
	public var skinning:Bool = false;
	public var morphTargets:Bool = false;

	
	public function new(parameters:Dynamic = null) 
	{
		super();
		shading = THREE.SmoothShading;
		combine = THREE.MultiplyOperation;
		vertexColors = THREE.NoColors;
		setValues(parameters);
	}
	
	
	override public function clone (material:Material = null) : Material
	{
		var mat = new MeshBasicMaterial();
		super.clone(cast(mat, Material));
		mat.map = map;
		mat.lightMap = lightMap;
		mat.specularMap = specularMap;
		mat.envMap = envMap;
		mat.combine = combine;
		mat.reflectivity = reflectivity;
		mat.refractionRatio = refractionRatio;
		mat.fog = fog;
		mat.shading = shading;
		mat.vertexColors = vertexColors;
		mat.skinning = skinning;
		mat.morphTargets = morphTargets;
		return mat;
	}
}