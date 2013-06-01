
package three.math;

/**
 * ...
 * @author dcm
 */

class Vector2
{
	
	public var x:Float;
	public var y:Float;
	
	
	public function new(x:Float = 0, y:Float = 0) 
	{
		this.x = x;
		this.y = y;
	}
	
	
	public function set (x:Float, y:Float) : Vector2
	{
		this.x = x;
		this.y = y;
		return this;
	}
	
	
	public function setX (x:Float) : Vector2
	{
		this.x = x;
		return this;
	}
	
	
	public function setY (y:Float) : Vector2
	{
		this.y = y;
		return this;
	}
	
	
	public function setComponent (index:Int, value:Float) : Vector2
	{
		switch (index)
		{
			case 0: x = value;
			case 1: y = value;
			default:
				trace('Vector2.setComponent: index is out of range ($index)');
		}
		return this;
	}
	
	
	public function getComponent (index:Int) : Float
	{
		switch (index)
		{
			case 0: return x;
			case 1: return y;
			default:
				trace('Vector2.getComponent: index is out of range ($index)');
		}
		return 0;
	}
	
	
	public function copy (v:Vector2) : Vector2
	{
		x = v.x;
		y = v.y;
		return this;
	}
	
	
	public function add (v:Vector2, w:Vector2 = null) : Vector2
	{
		if (w != null) return addVectors(v, w);
		x += v.x;
		y += v.y;
		return this;
	}
	
	
	public function addVectors (a:Vector2, b:Vector2) : Vector2
	{
		x = a.x + b.x;
		y = a.y + b.y;
		return this;
	}
	
	
	public function addScalar (s:Float) : Vector2
	{
		x += s;
		y += s;
		return this;
	}
	
	
	public function sub (v:Vector2, w:Vector2 = null) : Vector2
	{
		if (w != null) return subVectors(v, w);
		x -= v.x;
		y -= v.y;
		return this;
	}
	
	
	public function subVectors(a:Vector2, b:Vector2) : Vector2
	{
		x = a.x - b.x;
		y = a.y - b.y;
		return this;
	}
	
	
	public function multiplyScalar (s:Float) : Vector2
	{
		x *= s;
		y *= s;
		return this;
	}
	
	
	public function divideScalar (s:Float) : Vector2
	{
		if (s == 0) return set(0, 0);
		x /= s;
		y /= s;
		return this;
	}
	
	
	public function min (v:Vector2) : Vector2
	{
		if (x > v.x) x = v.x;
		if (y > v.y) y = v.y;
		return this;
	}
	
	
	public function max (v:Vector2) : Vector2
	{
		if (x < v.x) x = v.x;
		if (y < v.y) y = v.y;
		return this;
	}
	
	
	public function clamp (min:Vector2, max:Vector2) : Vector2
	{
		if (x < min.x) x = min.x else if (x > max.x) x = max.x;
		if (y < min.y) y = min.y else if (y > max.y) y = max.y;
		return this;
	}
	
	
	public function negate () : Vector2
	{
		return multiplyScalar( -1);
	}
	
	
	public function dot (v:Vector2) : Float
	{
		return x * v.x + y * v.y;
	}
	
	
	public function lengthSq () : Float
	{
		return x * x + y * y;
	}
	
	
	public function length () : Float
	{
		return Math.sqrt(x * x + y * y);
	}
	
	
	public function normalize () : Vector2
	{
		return divideScalar(length());
	}
	
	
	public function distanceTo (v:Vector2) : Float
	{
		return Math.sqrt(distanceToSquared(v));
	}
	
	
	public function distanceToSquared (v:Vector2) : Float
	{
		var dx = x - v.x, dy = y - v.y;
		return dx * dx + dy * dy;
	}
	
	
	public function setLength (l:Float) : Vector2
	{
		var oldLength = length();
		if (oldLength != 0 && l != oldLength) multiplyScalar(l / oldLength);
		return this;
	}
	
	
	public function lerp (v:Vector2, alpha:Float) : Vector2
	{
		x += (v.x - x) * alpha;
		y += (v.y - y) * alpha;
		return this;
	}
	
	
	public function equals (v:Vector2) : Bool
	{
		return ( ( v.x == x ) && ( v.y == y ) );
	}
	
	
	public function fromArray (a:Array<Float>) : Vector2
	{
		x = a[0];
		y = a[1];
		return this;
	}
	
	
	public function toArray () : Array<Float>
	{
		var a = new Array<Float>();
		a.push(x);
		a.push(y);
		return a;
	}
	
	
	public function clone () : Vector2
	{
		return new Vector2(x, y);
	}
	
	
}


