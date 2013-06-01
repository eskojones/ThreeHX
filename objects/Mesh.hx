
package three.objects;

import three.core.Geometry;
import three.core.Object3D;
import three.materials.Material;
import three.materials.MeshBasicMaterial;

/**
 * ...
 * @author dcm
 */

class Mesh extends Object3D
{
	public var geometry:Geometry;
	public var material:Material;

	public function new(geometry:Geometry = null, material:Dynamic = null) 
	{
		super();
		if (geometry != null) setGeometry(geometry);
		setMaterial(material);
	}
	
	
	public function setGeometry (geometry:Geometry)
	{
		this.geometry = geometry;
		if (this.geometry.boundingSphere == null) 
			this.geometry.computeBoundingSphere();
		
		updateMorphTargets();
	}
	
	
	public function setMaterial (material:Dynamic = null)
	{
		if (material != null) this.material = material;
		else this.material = new MeshBasicMaterial( { color: Math.random() * 0xffffff, wireframe: true } );
	}
	
	
	public function updateMorphTargets () : Void
	{
		if (geometry.morphTargets.length == 0) return;
		
		//todo - whenever
		/*
		morphTargetBase = -1;
		morphTargetForcedOrder = new Array();
		morphTargetInfluence = new Array();
		morphTargetDictionary = new Map<String,Int>();
		
		var m = 0, ml = geometry.morphTargets.length;
		while (m < ml)
		{
			morphTargetInfluences.push(0);
			morphTargetDictionary.set(geometry.morphTargets[m].name, m);
			m++;
		}
		*/
		return;
	}
	
	
	public function getMorphTargetIndexByName (name:String) : Int
	{
		return 0; //todo
		/*
		if (morphTargetDictionary.exists(name) == false) 
		{
			trace('Mesh.getMorphTargetIndexByName: $name does not exist!');
			return 0;
		}
		return morphTargetDictionary.get(name);
		*/
	}
	
	
	override public function clone (object:Object3D = null) : Object3D
	{
		if (object == null) object = new Mesh(geometry, material);
		super.clone(object);
		return object;
	}
	
	
}