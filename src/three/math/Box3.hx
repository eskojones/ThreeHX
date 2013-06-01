
package three.math;


/**
 * ...
 * @author Three.js Project (http://threejs.org)
 * @author dcm
 */

class Box3
{
	public var min:Vector3;
	public var max:Vector3;
	

	public function new(min:Vector3 = null, max:Vector3 = null) 
	{
		this.min = (min != null ? min : new Vector3(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY));
		this.max = (max != null ? max : new Vector3(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY));
	}

	
	public function set (min:Vector3, max:Vector3) : Box3
	{
		this.min.copy(min);
		this.max.copy(max);
		return this;
	}
	
	
	//This would be an array of Vector3 but the Projector uses it with Vector4 aswell
	public function setFromPoints (points:Array<Dynamic>) : Box3
	{
		if (points.length > 0)
		{
			var point:Vector3 = points[0];
			min.copy(point);
			max.copy(point);
			
			var i = 0, l = points.length;
			while (i < l)
			{
				point = points[i];
				if (point.x < min.x) min.x = point.x;
				else if (point.x > max.x) max.x = point.x;
				
				if (point.y < min.y) min.y = point.y;
				else if (point.y > max.y) max.y = point.y;
				
				if (point.z < min.z) min.z = point.z;
				else if (point.z > max.z) max.z = point.z;
				
				i++;
			}
			
		} else {
			makeEmpty();
		}
		return this;
	}
	
	
	public function setFromCenterAndSize (center:Vector3, size:Vector3) : Box3
	{
		var v1 = size.clone();
		var halfSize = v1.multiplyScalar(0.5);
		min.copy(center).sub(halfSize);
		max.copy(center).add(halfSize);
		return this;
	}
	
	
	public function copy (box:Box3) : Box3
	{
		min.copy(box.min);
		max.copy(box.max);
		return this;
	}
	
	
	public function makeEmpty () : Box3
	{
		min.x = min.y = min.z = Math.POSITIVE_INFINITY;
		max.x = max.y = max.z = Math.NEGATIVE_INFINITY;
		return this;
	}
	
	
	public function empty () : Bool
	{
		return ( max.x < min.x ) || ( max.y < min.y ) || ( max.z < min.z );
	}
	
	
	public function center (optTarget:Vector3 = null) : Vector3
	{
		var result = (optTarget != null ? optTarget : new Vector3());
		return result.addVectors(min, max).multiplyScalar(0.5);
	}
	
	
	public function size (optTarget:Vector3 = null) : Vector3
	{
		var result = (optTarget != null ? optTarget : new Vector3());
		return result.subVectors(max, min);
	}
	
	
	public function expandByPoint (point:Vector3) : Box3
	{
		min.min(point);
		max.max(point);
		return this;
	}
	
	
	public function expandByVector (v:Vector3) : Box3
	{
		min.sub(v);
		max.add(v);
		return this;
	}
	
	
	public function expandByScalar (s:Float) : Box3
	{
		min.addScalar(-s);
		max.addScalar(s);
		return this;
	}
	
	
	public function containsPoint (point:Vector3) : Bool
	{
		if (point.x < min.x || point.x > max.x
		 || point.y < min.y || point.y > max.y
		 || point.z < min.z || point.z > max.z) return false;
		return true;
	}
	
	
	public function containsBox (box:Box3) : Bool
	{
		if ( (min.x <= box.min.x) && (box.max.x <= max.x) 
		  && (min.y <= box.min.y) && (box.max.y <= max.y)
		  && (min.z <= box.min.z) && (box.max.z <= max.z) ) return true;
		
		return false;
	}
	
	
	public function getParameter (point:Vector3) : Vector3
	{
		return new Vector3(
			( point.x - min.x ) / ( max.x - min.x ),
			( point.y - min.y ) / ( max.y - min.y ),
			( point.z - min.z ) / ( max.z - min.z )
		);
	}
	
	
	public function isIntersectionBox (box:Box3) : Bool
	{
		if (box.max.x < min.x || box.min.x > max.x
		 || box.max.y < min.y || box.min.y > max.y
		 || box.max.z < min.z || box.min.z > max.z) return false;
		 
		return true;
	}
	
	
	public function clampPoint (point:Vector3, optTarget:Vector3 = null) : Vector3
	{
		var result = (optTarget != null ? optTarget : new Vector3());
		return result.copy(point).clamp(min, max);
	}
	
	
	public function distanceToPoint (point:Vector3) : Float
	{
		var v1 = point.clone();
		var clampedPoint = v1.clamp(min, max);
		return clampedPoint.sub(point).length();
	}
	
	
	public function getBoundingSphere (optTarget:Sphere = null) : Sphere
	{
		var v1 = new Vector3();
		var result = (optTarget != null ? optTarget : new Sphere());
		result.center = center();
		result.radius = size(v1).length() * 0.5;
		return result;
	}
	
	
	public function intersect (box:Box3) : Box3
	{
		min.max(box.min);
		max.min(box.max);
		return this;
	}
	
	
	public function union (box:Box3) : Box3
	{
		min.min(box.min);
		max.max(box.max);
		return this;
	}
	
	
	public function applyMatrix4 (m:Matrix4) : Box3
	{
		var points = new Array<Vector3>();
		points.push(new Vector3());
		points.push(new Vector3());
		points.push(new Vector3());
		points.push(new Vector3());
		points.push(new Vector3());
		points.push(new Vector3());
		points.push(new Vector3());
		points.push(new Vector3());
		
		points[0].set(min.x, min.y, min.z).applyMatrix4(m);
		points[1].set(min.x, min.y, max.z).applyMatrix4(m);
		points[2].set(min.x, max.y, min.z).applyMatrix4(m);
		points[3].set(min.x, max.y, max.z).applyMatrix4(m);
		points[4].set(max.x, min.y, min.z).applyMatrix4(m);
		points[5].set(max.x, min.y, max.z).applyMatrix4(m);
		points[6].set(max.x, max.y, min.z).applyMatrix4(m);
		points[7].set(max.x, max.y, max.z).applyMatrix4(m);
		makeEmpty();
		setFromPoints(points);
		return this;
	}
	
	
	public function translate (offset:Vector3) : Box3
	{
		min.add(offset);
		max.add(offset);
		return this;
	}
	
	
	public function equals (box:Box3) : Bool
	{
		return box.min.equals(min) && box.max.equals(max);
	}
	
	
	public function clone () : Box3
	{
		return new Box3().copy(this);
	}
	
	
	
}




