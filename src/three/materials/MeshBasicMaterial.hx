
package three.materials;
import three.math.Color;

/**
 * ...
 * @author dcm
 */

class MeshBasicMaterial extends Material
{
	public var color:Color;
	public var map:Dynamic; //todo - THREE.Texture
	public var lightMap:Dynamic; //not sure what type goes here?
	
	public var specularMap:Dynamic;
	
	public var envMap:Dynamic;
	public var combine:Dynamic; //todo - THREE Constants (THREE.MultiplyOperation)
	public var reflectivity:Float = 1.0;
	public var refractionRatio:Float = 0.98;
	
	public var fog:Bool = true;
	
	public var shading:Dynamic; //todo - constants (THREE.SmoothShading)
	
	public var wireframe:Bool = false;
	public var wireframeLineWidth:Float = 1.0;
	public var wireframeLinecap:String = 'round';
	public var wireframeLinejoin:String = 'round';
	
	public var vertexColors:Dynamic; //todo - constants (THREE.NoColors)
	
	public var skinning:Bool = false;
	public var morphTargets:Bool = false;

	public function new(parameters:Dynamic = null) 
	{
		super();
		color = new Color(0xffffff);
		setValues(parameters);
	}
	
	
	override public function clone (material:Material = null) : Material
	{
		var mat = new MeshBasicMaterial();
		super.clone(cast(mat, Material));
		mat.color.copy(color);
		mat.map = map;
		mat.lightMap = lightMap;
		mat.specularMap = specularMap;
		mat.envMap = envMap;
		mat.combine = combine;
		mat.reflectivity = reflectivity;
		mat.refractionRatio = refractionRatio;
		mat.fog = fog;
		mat.shading = shading;
		mat.wireframe = wireframe;
		mat.wireframeLineWidth = wireframeLineWidth;
		mat.wireframeLinecap = wireframeLinecap;
		mat.wireframeLinejoin = wireframeLinejoin;
		mat.vertexColors = vertexColors;
		mat.skinning = skinning;
		mat.morphTargets = morphTargets;
		return mat;
	}
}