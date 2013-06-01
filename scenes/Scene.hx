
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
	
	public var __objects:Array<Object3D>;
	public var __lights:Array<Object3D>;
	
	public var __objectsAdded:Array<Object3D>;
	public var __objectsRemoved:Array<Object3D>;
	
	
	public function new() 
	{
		super();
		__objects = new Array<Object3D>();
		__lights = new Array<Object3D>();
		__objectsAdded = new Array<Object3D>();
		__objectsRemoved = new Array<Object3D>();
		
		autoUpdate = true;
		matrixAutoUpdate = false;
	}
	
	
	public function __addObject (object:Object3D)
	{
		if (Std.is(object, Light) == true)
		{
			if (Utils.indexOf(__lights, object) == -1) __lights.push(object);
			if (object.target != null && object.target.parent == null) add(object.target);
			
		//todo - THREE.Bone is also a false condition here in r58
		} else if (Std.is(object, Camera) == false)
		{
			if (Utils.indexOf(__objects, object) == -1) 
			{
				__objects.push(object);
				__objectsAdded.push(object);
				
				var i = Utils.indexOf(__objectsRemoved, object);
				if (i != -1) __objectsRemoved.splice(i, 1);
			}
		}
		
		var c = 0, cl = object.children.length;
		while (c < cl)
		{
			__addObject(object.children[c++]);
		}
		
		trace('Scene.__addObject');
	}
	
	
	public function __removeObject (object:Object3D) 
	{
		if (Std.is(object, Light) == true)
		{
			var i = Utils.indexOf(__lights, object);
			if (i != -1) __lights.splice(i, 1);
			
		} else if (Std.is(object, Camera) == false)
		{
			var i = Utils.indexOf(__objects, object);
			if (i != -1)
			{
				__objects.splice(i, 1);
				__objectsRemoved.push(object);
				
				var ai = Utils.indexOf(__objectsAdded, object);
				if (ai != -1) __objectsAdded.splice(ai, 1);
			}
		}
		
		var c = 0, cl = children.length;
		while (c < cl)
		{
			__removeObject(object.children[c++]);
		}
		trace('Scene.__removeObject');
	}
	
	
	
}