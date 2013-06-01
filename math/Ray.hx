
package three.math;

/**
 * ...
 * @author dcm
 */

class Ray
{
	public var origin:Vector3;
	public var direction:Vector3;

	
	public function new(origin:Vector3 = null, direction:Vector3 = null) 
	{
		if (origin != null) this.origin = origin; 
		else this.origin = new Vector3();
		
		if (direction != null) this.direction = direction; 
		else this.direction = new Vector3();
	}
	
	
	public function set (origin:Vector3, direction:Vector3) : Ray
	{
		this.origin.copy(origin);
		this.direction.copy(direction);
		return this;
	}
	
	
	public function copy (ray:Ray) : Ray
	{
		this.origin.copy(ray.origin);
		this.direction.copy(ray.direction);
		return this;
	}
	
	
	public function at (t:Float, optTarget:Vector3 = null) : Vector3
	{
		var result = (optTarget != null ? optTarget : new Vector3());
		return result.copy(direction).multiplyScalar(t).add(origin);
	}
	
	
	public function recast (t:Float) : Vector3
	{
		return origin.copy(at(t));
	}
	
	
	public function closestPointToPoint (point:Vector3, optTarget:Vector3 = null) : Vector3
	{
		var result = (optTarget != null ? optTarget : new Vector3());
		result.subVectors(point, origin);
		var directionDistance = result.dot(direction);
		return result.copy(direction).multiplyScalar(directionDistance).add(origin);
	}
	
	
	public function distanceToPoint (point:Vector3) : Float
	{
		var v = new Vector3();
		var directionDistance = v.subVectors(v, origin).dot(direction);
		v.copy(direction).multiplyScalar(directionDistance).add(origin);
		return v.distanceTo(point);
	}
	
	
	public function isIntersectionSphere (sphere:Sphere) : Bool
	{
		return ( distanceToPoint(sphere.center) <= sphere.radius );
	}
	
	
	public function isIntersectionPlane (plane:Plane) : Bool
	{
		var denominator = plane.normal.dot(direction);
		if (denominator != 0) return true;
		
		if (plane.distanceToPoint(origin) == 0) return true;
		return false;
	}
	
	
	public function distanceToPlane (plane:Plane) : Float
	{
		var denominator = plane.normal.dot(direction);
		if (denominator == 0)
		{
			if (plane.distanceToPoint(origin) == 0) return 0;
			return null;
		}
		var t = -( origin.dot(plane.normal) + plane.constant ) / denominator;
		return t;
	}
	
	
	public function intersectPlane (plane:Plane, optTarget:Vector3 = null) : Vector3
	{
		var t = distanceToPlane(plane);
		if (t == null) return null;
		var result = (optTarget != null ? optTarget : new Vector3());
		return at(t, result);
	}
	
	
	public function applyMatrix4 (matrix:Matrix4) : Ray
	{
		direction.add(origin).applyMatrix4(matrix);
		origin.applyMatrix4(matrix);
		direction.sub(origin);
		return this;
	}
	
	
	public function equals (ray:Ray) : Bool
	{
		return ray.origin.equals(origin) && ray.direction.equals(direction);
	}
	
	
	public function clone () : Ray
	{
		return new Ray().copy(this);
	}
	
	
}

