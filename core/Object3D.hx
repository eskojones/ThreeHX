package three.core;

import haxe.Json;
import js.Lib;
import three.extras.Utils;
import three.math.Matrix4;
import three.math.Quaternion;
import three.math.Vector3;
import three.scenes.Scene;

/**
 * ...
 * @author Three.js Project (http://threejs.org)
 * @author dcm
 */

class Object3D
{
	public var id:Int;
	public var name:String;
	public var parent:Object3D;
	public var children:Array<Object3D>;
	
	public var up:Vector3;
	public var position:Vector3;
	public var rotation:Vector3;
	public var eulerOrder:String;
	public var scale:Vector3;
	
	public var renderDepth:Dynamic;
	
	public var rotationAutoUpdate:Bool;
	
	public var matrix:Matrix4;
	public var matrixWorld:Matrix4;
	
	public var matrixAutoUpdate:Bool;
	public var matrixWorldNeedsUpdate:Bool;
	
	public var quaternion:Quaternion;
	public var useQuaternion:Bool;
	
	public var visible:Bool;
	public var frustumCulled:Bool;
	public var userData:Dynamic;
	
	public var castShadow:Bool;
	public var receiveShadow:Bool;
	public var target:Object3D;

	
	public function new() 
	{
		id = 0;
		name = '';
		parent = null;
		children = new Array<Object3D>();
		up = new Vector3(0, 1, 0);
		position = new Vector3();
		rotation = new Vector3();
		eulerOrder = 'XYZ';
		scale = new Vector3(1, 1, 1);
		
		renderDepth = null;
		
		rotationAutoUpdate = true;
		
		matrix = new Matrix4();
		matrixWorld = new Matrix4();
		
		matrixAutoUpdate = true;
		matrixWorldNeedsUpdate = true;
		
		quaternion = new Quaternion();
		useQuaternion = false;
		
		visible = true;
		castShadow = false;
		receiveShadow = false;
		target = null;
		frustumCulled = true;
	}
	
	
	public function applyMatrix (m:Matrix4)
	{
		var m1 = new Matrix4();
		matrix.multiplyMatrices(m, matrix);
		position.getPositionFromMatrix(matrix);
		scale.getScaleFromMatrix(matrix);
		m1.extractRotation(matrix);
		
		if (useQuaternion == true) quaternion.setFromRotationMatrix(m1);
		else rotation.setEulerFromRotationMatrix(m1, eulerOrder);
	}
	
	
	public function rotateOnAxis (axis:Vector3, angle:Float) : Object3D
	{
		var q1 = new Quaternion();
		var q2 = new Quaternion();
		q1.setFromAxisAngle(axis, angle);
		if (useQuaternion == true) quaternion.multiply(q1);
		else {
			q2.setFromEuler(rotation, eulerOrder);
			q2.multiply(q1);
			rotation.setEulerFromQuaternion(q2, eulerOrder);
		}
		return this;
	}
	
	
	public function translateOnAxis (axis:Vector3, distance:Float) : Object3D
	{
		var v1 = new Vector3();
		v1.copy(axis);
		if (useQuaternion == true) v1.applyQuaternion(quaternion);
		else v1.applyEuler(rotation, eulerOrder);
		position.add(v1.multiplyScalar(distance));
		return this;
	}
	
	
	public function translate (distance:Float, axis:Vector3) : Object3D
	{
		return translateOnAxis(axis, distance);
	}
	
	
	public function translateX (distance:Float) : Object3D
	{
		return translateOnAxis(new Vector3(1, 0, 0), distance);
	}
	
	
	public function translateY (distance:Float) : Object3D
	{
		return translateOnAxis(new Vector3(0, 1, 0), distance);
	}
	
	
	public function translateZ (distance:Float) : Object3D
	{
		return translateOnAxis(new Vector3(0, 0, 1), distance);
	}
	
	
	public function localToWorld (v:Vector3) : Vector3
	{
		return v.applyMatrix4(matrixWorld);
	}
	
	
	public function worldToLocal (v:Vector3) : Vector3
	{
		var m1 = new Matrix4();
		return v.applyMatrix4(m1.getInverse(matrixWorld));
	}
	
	
	public function lookAt (v:Vector3)
	{
		var m1 = new Matrix4();
		m1.lookAt(v, position, up);
		if (useQuaternion == true) quaternion.setFromRotationMatrix(m1);
		else rotation.setEulerFromRotationMatrix(m1, eulerOrder);
	}
	
	
	public function add (object:Object3D) : Void
	{
		if (object == this) 
		{
			trace('Object3D.add: An object cant be added as a child of itself.');
			return;
		}
		
		if (object.parent != null) object.parent.remove(object);
		
		object.parent = this;
		children.push(object);
		var scene = this;
		while (scene.parent != null) 
		{
			scene = scene.parent;
		}
		
		//if (Std.is(scene, Scene) == true) 
		cast(scene, Scene).__addObject(object);
	}
	
	
	public function remove (object:Object3D) : Bool
	{
		var index = Utils.indexOf(children, object);
		if (index == -1) return false;
		
		object.parent = null;
		children.splice(index, 1);
		
		var scene = this;
		while (scene.parent != null) scene = scene.parent;
		
		//if (Std.is(scene, Scene) == false) return true;
		
		cast(scene, Scene).__removeObject(object);
		return true;
	}
	
	
	public function traverse (fnCallback:Dynamic)
	{
		fnCallback(this);
		var i = 0, l = children.length;
		while (i < l) children[i++].traverse(fnCallback);
	}
	
	
	public function getObjectById (id:Int, recursive:Bool = false) : Object3D
	{
		var i = 0, l = children.length;
		while (i < l)
		{
			var child = children[i];
			if (child.id == id) return child;
			
			if (recursive == true)
			{
				child = child.getObjectById(id, recursive);
				if (child != null) return child;
			}
			i++;
		}
		return null;
	}
	
	
	public function getObjectByName (name:String, recursive:Bool = false) : Object3D
	{
		var i = 0, l = children.length;
		while (i < l)
		{
			var child = children[i++];
			if (child.name == name) return child;
			
			if (recursive == true)
			{
				child = child.getObjectByName(name, recursive);
				if (child != null) return child;
			}
		}
		return null;
	}
	
	
	public function getChildByName (name:String, recursive:Bool = false) : Object3D
	{
		//Deprecated: Renamed to .getObjectByName(name,recursive)
		return getObjectByName(name, recursive);
	}
	
	
	public function getDescendants () : Array<Object3D>
	{
		//todo - Unsure how this should work under Haxe
		var a = new Array<Object3D>();
		return a;
	}
	
	
	public function updateMatrix ()
	{
		if (useQuaternion == false) matrix.makeFromPositionEulerScale(position, rotation, scale, eulerOrder);
		else matrix.makeFromPositionQuaternionScale(position, quaternion, scale);
		matrixWorldNeedsUpdate = true;
	}
	
	
	public function updateMatrixWorld (force:Bool = false)
	{
		if (matrixAutoUpdate == true) updateMatrix();
		
		if (matrixWorldNeedsUpdate == true || force == true)
		{
			if (parent == null) matrixWorld.copy(matrix);
			else matrixWorld.multiplyMatrices(parent.matrixWorld, matrix);
			
			matrixWorldNeedsUpdate = false;
			force = true;
		}
		
		var i = 0, l = children.length;
		while (i < l)
		{
			children[i++].updateMatrixWorld(force);
		}
		
	}
	
	
	public function clone (object:Object3D = null) : Object3D
	{
		if (object == null) object = new Object3D();
		
		object.name = name;
		object.up.copy(up);
		object.position.copy(position);
		object.rotation.copy(rotation);
		object.eulerOrder = eulerOrder;
		object.scale.copy(scale);
		
		object.renderDepth = renderDepth;
		object.rotationAutoUpdate = rotationAutoUpdate;
		
		object.matrix.copy(matrix);
		object.matrixWorld.copy(matrixWorld);
		
		object.matrixAutoUpdate = matrixAutoUpdate;
		object.matrixWorldNeedsUpdate = matrixWorldNeedsUpdate;
		
		object.quaternion.copy(quaternion);
		object.useQuaternion = useQuaternion;
		
		object.visible = visible;
		
		object.castShadow = castShadow;
		object.receiveShadow = receiveShadow;
		
		object.frustumCulled = frustumCulled;
		
		object.userData = Json.parse(Json.stringify(userData));
		
		var i = 0, l = children.length;
		while (i < l)
		{
			var child = children[i++];
			object.add(child.clone());
		}
		
		return object;
	}
	
	
}