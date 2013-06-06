
package three.scenes;

import three.cameras.Camera;
import three.core.Object3D;
import three.extras.Utils;
import three.lights.Light;
import three.materials.Material;

/**
 * 
 * @author dcm
 */

class Scene extends Object3D
{

	public var fog:Dynamic; //THREE.FogExp2 (???)
	public var overrideMaterial:Material;
	
	public var autoUpdate:Bool;
	
	public var __objects:Map<Object3D,Object3D>;
	public var __lights:Map<Object3D,Object3D>;
	
	public var __objectsAdded:Map<Object3D,Object3D>;
	public var __objectsRemoved:Map<Object3D,Object3D>;
	
	
	public function new() 
	{
		super();
		__objects = new Map<Object3D,Object3D>();
		__lights = new Map<Object3D,Object3D>();
		__objectsAdded = new Map<Object3D,Object3D>();
		__objectsRemoved = new Map<Object3D,Object3D>();
		
		autoUpdate = true;
		matrixAutoUpdate = false;
	}
	
	
	public function __addObject (object:Object3D)
	{
		if (Std.is(object, Light) == true)
		{
			if (__lights.exists(object) == false) __lights.set(object, object);
			if (object.target != null && object.target.parent == null) add(object.target);
			
		//todo - THREE.Bone is also a false condition here in r58
		} else if (Std.is(object, Camera) == false)
		{
			if (__objects.exists(object) == false)
			{
				__objects.set(object, object);
				__objectsAdded.set(object, object);
				
				if (__objectsRemoved.exists(object) == true) __objectsRemoved.remove(object);
			}
		}
		
		var cIter = object.children.iterator();
		while (cIter.hasNext() == true) __addObject(cIter.next());
	}
	
	
	public function __removeObject (object:Object3D) 
	{
		if (Std.is(object, Light) == true)
		{
			if (__lights.exists(object) == true) __lights.remove(object);
			
		} else if (Std.is(object, Camera) == false)
		{
			if (__objects.exists(object) == true)
			{
				__objects.set(object, object);
				__objectsRemoved.set(object, object);
				
				if (__objectsAdded.exists(object) == true) __objectsAdded.remove(object);
			}
		}
		
		var cIter = object.children.iterator();
		while (cIter.hasNext() == true) __removeObject(cIter.next());
	}
	
	
	
}

