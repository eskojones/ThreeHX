
package three.math;

/**
 * 
 * @author Three.js Project (http://threejs.org)
 * @author dcm
 */

class Sphere
{
	
	public var center:Vector3;
	public var radius:Float;

	
	public function new(center:Vector3 = null, radius:Float = 0) 
	{
		this.center = (center != null ? center : new Vector3());
		this.radius = radius;
	}
	
	
	public function set (center:Vector3, radius:Float) : Sphere
	{
		this.center.copy(center);
		this.radius = radius;
		return this;
	}
	
	
	public function setFromCenterAndPoints (center:Vector3, points:Array<Vector3>) : Sphere
	{
		var maxRadiusSq:Float = 0;
		var i = 0, l = points.length;
		while (i < l)
		{
			var radiusSq = center.distanceToSquared(points[i]);
			maxRadiusSq = Math.max(maxRadiusSq, radiusSq);
			i++;
		}
		
		this.center = center;
		this.radius = Math.sqrt(maxRadiusSq);
		return this;
	}
	
	
	public function copy (sphere:Sphere) : Sphere
	{
		center.copy(sphere.center);
		radius = sphere.radius;
		return this;
	}
	
	
	public function empty () : Bool
	{
		return (radius <= 0);
	}
	
	
	public function containsPoint (point:Vector3) : Bool
	{
		return (point.distanceToSquared(center) <= (radius * radius));
	}
	
	
	public function distanceToPoint (point:Vector3) : Float
	{
		return (point.distanceTo(center) - radius);
	}
	
	
	public function intersectsSphere (sphere:Sphere) : Bool
	{
		var radiusSum = radius + sphere.radius;
		return ( sphere.center.distanceToSquared(center) <= (radiusSum * radiusSum) );
	}
	
	
	public function clampPoint (point:Vector3, optTarget:Vector3 = null) : Vector3
	{
		var deltaLengthSq = center.distanceToSquared(point);
		var result = (optTarget != null ? optTarget : new Vector3());
		result.copy(point);
		
		if (deltaLengthSq > (radius * radius))
		{
			result.sub(center).normalize();
			result.multiplyScalar(radius).add(center);
		}
		return result;
	}
	
	
	public function getBoundingBox (optTarget:Dynamic) : Dynamic
	{
		var box = optTarget;
		box.set(center, center);
		box.expandByScalar(radius);
		return box;
	}
	
	
	public function applyMatrix4 (m:Matrix4) : Sphere
	{
		center.applyMatrix4(m);
		radius = radius * m.getMaxScaleOnAxis();
		return this;
	}
	
	
	public function translate (offset:Vector3) : Sphere
	{
		center.add(offset);
		return this;
	}
	
	
	public function equals (sphere:Sphere) : Bool
	{
		return sphere.center.equals(center) && (sphere.radius == radius);
	}
	
	
	public function clone () : Sphere
	{
		return new Sphere().copy(this);
	}

	
}