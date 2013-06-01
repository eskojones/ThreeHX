
package three.core;
import three.materials.MeshFaceMaterial;
import three.math.Matrix4;
import three.math.Plane;
import three.math.Ray;
import three.math.Sphere;
import three.math.Triangle;
import three.math.Vector3;
import three.objects.Mesh;
import three.THREE;

/**
 * ...
 * @author dcm
 */

class Raycaster
{
	public var ray:Ray;
	public var near:Float = 0.0;
	public var far:Float = 0.0;
	public var precision:Float = 0.0001;
	
	public var sphere:Sphere;
	public var localRay:Ray;
	public var facePlane:Plane;
	public var intersectPoint:Vector3;
	public var matrixPosition:Vector3;
	public var inverseMatrix:Matrix4;

	public function new(origin:Vector3, direction:Vector3, near:Float = null, far = null) 
	{
		ray = new Ray(origin, direction);
		if (ray.direction.lengthSq() > 0) ray.direction.normalize();
		
		if (near != null) this.near = near;
		if (far != null) this.far = far; else this.far = Math.POSITIVE_INFINITY;
		
		sphere = new Sphere();
		localRay = new Ray();
		facePlane = new Plane();
		intersectPoint = new Vector3();
		matrixPosition = new Vector3();
		inverseMatrix = new Matrix4();
	}
	
	
	public function descSort (a:Dynamic, b:Dynamic) : Float
	{
		return a.distance - b.distance;
	}
	
	
	public function intersectObject (object:Object3D, raycaster:Raycaster, intersects:Array<Dynamic>) : Array<Dynamic>
	{
		//todo - THREE.Particle
		if (Std.is(object, Mesh) == true)
		{
			var obj = cast(object, Mesh);
			matrixPosition.getPositionFromMatrix(obj.matrixWorld);
			sphere.set(
				matrixPosition,
				obj.geometry.boundingSphere.radius * obj.matrixWorld.getMaxScaleOnAxis()
			);
			
			if (raycaster.ray.isIntersectionSphere(sphere) == false) return intersects;
			
			var geometry = obj.geometry;
			var vertices = obj.geometry.vertices;
			
			var isFaceMaterial = Std.is(obj.material, MeshFaceMaterial); //todo - THREE.MeshFaceMaterial
			var objectMaterials = isFaceMaterial == true ? cast(obj.material, MeshFaceMaterial).materials : null; //todo - ^^^
			
			var side = obj.material.side;
			var a:Vector3, b:Vector3, c:Vector3, d:Vector3;
			var precision = raycaster.precision;
			
			inverseMatrix.getInverse(obj.matrixWorld);
			localRay.copy(raycaster.ray).applyMatrix4(inverseMatrix);
			
			var f = 0, fl = geometry.faces.length;
			while (f < fl)
			{
				var face = geometry.faces[f++];
				var material = isFaceMaterial == true ? objectMaterials[face.materialIndex] : obj.material;
				if (material == null) continue;
				
				facePlane.setFromNormalAndCoplanarPoint(face.normal, vertices[face.a]);
				var planeDistance = localRay.distanceToPlane(facePlane);
				
				if (Math.abs(planeDistance) < precision) continue;
				if (planeDistance < 0) continue;
				side = material.side;
				if (side != THREE.DoubleSide)
				{
					var planeSign = localRay.direction.dot(facePlane.normal);
					if ( !( planeSign == THREE.FrontSide ? planeSign < 0 : planeSign > 0 ) ) continue;
				}
				
				if (planeDistance < raycaster.near || planeDistance > raycaster.far) continue;
				
				intersectPoint = localRay.at(planeDistance, intersectPoint);
				
				if (Std.is(face, Face3) == true)
				{
					a = vertices[face.a];
					b = vertices[face.b];
					c = vertices[face.c];
					if (Triangle.containsPoint(intersectPoint,a,b,c) == false) continue;
				} else if (Std.is(face, Face4) == true)
				{
					a = vertices[face.a];
					b = vertices[face.b];
					c = vertices[face.c];
					d = vertices[face.d];
					if ( ( ! Triangle.containsPoint( intersectPoint, a, b, d ) ) &&
						 ( ! Triangle.containsPoint( intersectPoint, b, c, d ) ) ) continue;
				} else {
					trace('Raycaster.intersectObject: invalid face type!');
				}
				
				intersects.push({
					distance: planeDistance,
					point: raycaster.ray.at(planeDistance),
					face: face,
					faceIndex: f,
					object: object
				});
			}
		}
		
		return intersects;
	}
	
	
	public function intersectDescendants (object:Object3D, raycaster:Raycaster, intersects:Array<Dynamic>)
	{
		var descendants = object.getDescendants();
		var i = 0, l = descendants.length;
		while (i < l)
		{
			intersectObject(descendants[i++], raycaster, intersects);
		}
	}
	
	
	public function set (origin:Vector3, direction:Vector3)
	{
		ray.set(origin, direction);
		if (ray.direction.length() > 0) ray.direction.normalize();
	}
	
	
	public function intersectObjects (objects:Array<Object3D>, recursive:Bool = true) : Array<Dynamic>
	{
		var intersects = new Array<Dynamic>();
		var i = 0, l = objects.length;
		while (i < l)
		{
			var obj = objects[i++];
			intersectObject(obj, this, intersects);
			if (recursive == true) intersectDescendants(obj, this, intersects);
		}
		
		intersects.sort(function (a:Dynamic, b:Dynamic) : Int {
			return (a.distance - b.distance < 0 ? -1 : 1);
		});
		
		return intersects;
	}
	
	
}