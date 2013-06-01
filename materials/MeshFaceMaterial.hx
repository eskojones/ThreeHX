
package three.materials;

/**
 * ...
 * @author dcm
 */

class MeshFaceMaterial extends Material
{
	public var materials:Array<Material>;

	public function new(materials:Array<Material> = null) 
	{
		super();
		if (materials == null) this.materials = new Array<Material>();
		else this.materials = materials.slice(0);
	}
	
	//todo - clone
}