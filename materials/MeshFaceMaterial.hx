
package three.materials;

/**
 * 
 * @author dcm
 */

class MeshFaceMaterial
{
	
	public var materials:Array<Material>;

	
	public function new(materials:Array<Material> = null) 
	{
		if (materials == null) this.materials = new Array<Material>();
		else this.materials = materials.slice(0);
	}
	
	//todo - clone
}