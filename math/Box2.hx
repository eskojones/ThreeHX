
package three.math;

/**
 * 
 * @author dcm
 */

class Box2
{
	
	public var min:Vector2;
	public var max:Vector2;

	
	public function new(min:Vector2 = null, max:Vector2 = null) 
	{
		if (min == null) this.min = new Vector2(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
		else this.min.copy(min);
		
		if (max == null) this.max = new Vector2(-Math.POSITIVE_INFINITY, -Math.POSITIVE_INFINITY);
		else this.max.copy(max);
	}
	
	
	public function set (min:Vector2, max:Vector2) : Box2
	{
		this.min.copy(min);
		this.max.copy(max);
		return this;
	}
	
	
	public function setFromPoints (points:Array<Vector2>) : Box2
	{
		if (points.length == 0)
		{
			makeEmpty();
			return this;
		}
		
		var point = points[0];
		min.copy(point);
		max.copy(point);
		
		var i = 1, l = points.length;
		while (i < l)
		{
			point = points[i++];
			if (point.x < min.x) min.x = point.x;
			else if (point.x > max.x) max.x = point.x;
			
			if (point.y < min.y) min.y = point.y;
			else if (point.y > max.y) max.y = point.y;
		}
		return this;
	}
	
	
	public function setFromCenterAndSize (center:Vector2, size:Vector2) : Box2
	{
		var v1 = new Vector2();
		var halfSize = v1.copy(size).multiplyScalar(0.5);
		min.copy(center).sub(halfSize);
		max.copy(center).add(halfSize);
		return this;
	}
	
	
	public function copy (box:Box2) : Box2
	{
		min.copy(box.min);
		max.copy(box.max);
		return this;
	}
	
	
	public function makeEmpty () : Box2
	{
		min.x = min.y = Math.POSITIVE_INFINITY;
		max.x = max.y = -Math.POSITIVE_INFINITY;
		return this;
	}
	
	
	public function empty () : Bool
	{
		return ( max.x < min.x ) || ( max.y < min.y );
	}
	
	
	public function center (optTarget:Vector2 = null) : Vector2
	{
		var result = (optTarget != null ? optTarget : new Vector2());
		return result.addVectors(min, max).multiplyScalar(0.5);
	}
	
	
	public function size (optTarget = null) : Vector2
	{
		var result = (optTarget != null ? optTarget : new Vector2());
		return result.subVectors(max, min);
	}
	
	
	public function expandByPoint (point:Vector2) : Box2
	{
		min.min(point);
		max.max(point);
		return this;
	}
	
	
	public function expandByVector (v:Vector2) : Box2
	{
		min.sub(v);
		max.add(v);
		return this;
	}
	
	
	public function expandByScalar (s:Float) : Box2
	{
		min.addScalar( -s);
		max.addScalar(s);
		return this;
	}
	
	
	public function containsPoint (point:Vector2) : Bool
	{
		if (point.x < min.x || point.x > max.x
		 || point.y < min.y || point.y > max.y) return false;
		return true;
	}
	
	
	public function containsBox (box:Box2) : Bool
	{
		if ( (min.x <= box.min.x) && (box.max.x <= max.x)
		  && (min.y <= box.min.y) && (box.max.y <= max.y) ) return true;
		return false;
	}
	
	
	public function getParameter (point:Vector2) : Vector2
	{
		return new Vector2(
			( point.x - min.x ) / ( max.x - min.x ),
			( point.y - min.y ) / ( max.y - min.y )
		);
	}
	
	
	public function isIntersectionBox (box:Box2) : Bool
	{
		if (box.max.x < min.x || box.min.x > max.x
		 || box.max.y < min.y || box.min.y > max.y) return false;
		return true;
	}
	
	
	public function clampPoint (point:Vector2, optTarget:Vector2 = null) : Vector2
	{
		var result = (optTarget != null ? optTarget : new Vector2());
		return result.copy(point).clamp(min, max);
	}
	
	
	public function distanceToPoint (point:Vector2) : Float
	{
		var v1 = new Vector2();
		var clampedPoint = v1.copy(point).clamp(min, max);
		return clampedPoint.sub(point).length();
	}
	
	
	public function intersect (box:Box2) : Box2
	{
		min.max(box.min);
		max.min(box.max);
		return this;
	}
	
	
	public function union (box:Box2) : Box2
	{
		min.min(box.min);
		max.max(box.max);
		return this;
	}
	
	
	public function translate (offset:Vector2) : Box2
	{
		min.add(offset);
		max.add(offset);
		return this;
	}
	
	
	public function equals (box:Box2) : Bool
	{
		return box.min.equals(min) && box.max.equals(max);
	}
	
	
	public function clone () : Box2
	{
		return new Box2().copy(this);
	}
	
	
}

