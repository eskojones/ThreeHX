
package three.math;

/**
 * ...
 * @author dcm
 */

class Triangle
{
	public var a:Vector3;
	public var b:Vector3;
	public var c:Vector3;
	

	public function new(a:Vector3 = null, b:Vector3 = null, c:Vector3 = null) 
	{
		if (a != null) this.a = a; else this.a = new Vector3();
		if (b != null) this.b = b; else this.b = new Vector3();
		if (c != null) this.c = c; else this.c = new Vector3();
	}
	
	
	static public function normal (a:Vector3, b:Vector3, c:Vector3, optTarget:Vector3 = null) : Vector3
	{
		var v0 = new Vector3();
		var result = (optTarget != null ? optTarget : new Vector3());
		result.subVectors(c, b);
		v0.subVectors(a, b);
		result.cross(v0);
		
		var length = result.lengthSq();
		if (length > 0) return result.multiplyScalar(1 / Math.sqrt(length));
		return result.set(0, 0, 0);
	}
	
	
	static public function barycoordFromPoint (point:Vector3, a:Vector3, b:Vector3, c:Vector3, optTarget:Vector3 = null) : Vector3
	{
		var result = (optTarget != null ? optTarget : new Vector3());
		
		var v0 = new Vector3();
		var v1 = new Vector3();
		var v2 = new Vector3();
		v0.subVectors(c, a);
		v1.subVectors(b, a);
		v2.subVectors(point, a);
		
		var dot00 = v0.dot(v0);
		var dot01 = v0.dot(v1);
		var dot02 = v0.dot(v2);
		var dot11 = v1.dot(v1);
		var dot12 = v1.dot(v2);
		
		var denom = ( dot00 * dot11 - dot01 * dot01 );
		if (denom == 0) return result.set( -2, -1, -1);
		
		var invDenom = 1 / denom;
		var u = ( dot11 * dot02 - dot01 * dot12 ) * invDenom;
		var v = ( dot00 * dot12 - dot01 * dot02 ) * invDenom;
		return result.set(1 - u - v, v, u);
	}
	
	
	static public function containsPoint (point:Vector3, a:Vector3, b:Vector3, c:Vector3) : Bool
	{
		var v1 = new Vector3();
		var result = Triangle.barycoordFromPoint(point, a, b, c, v1);
		return ( result.x >= 0 ) && ( result.y >= 0 ) && ( result.x + result.z <= 1 );
	}
	
	
	public function set (a:Vector3, b:Vector3, c:Vector3) : Triangle
	{
		this.a.copy(a);
		this.b.copy(b);
		this.c.copy(c);
		return this;
	}
	
	
	public function setFromPointsAndIndices (points:Array<Vector3>, i0:Int, i1:Int, i2:Int) : Triangle
	{
		a.copy(points[i0]);
		b.copy(points[i1]);
		c.copy(points[i2]);
		return this;
	}
	
	
	public function copy (triangle:Triangle) : Triangle
	{
		a.copy(triangle.a);
		b.copy(triangle.b);
		c.copy(triangle.c);
		return this;
	}
	
	
	public function area () : Float
	{
		var v0 = new Vector3();
		var v1 = new Vector3();
		v0.subVectors(c, b);
		v1.subVectors(a, b);
		return v0.cross(v1).length() * 0.5;
	}
	
	
	public function midpoint (optTarget:Vector3 = null) : Vector3
	{
		var result = (optTarget != null ? optTarget : new Vector3());
		return result.addVectors(a, b).add(c).multiplyScalar(0.333333); //replaced 1 / 3
	}
	
	
	public function _normal (optTarget:Vector3 = null) : Vector3
	{
		return Triangle.normal(a, b, c, optTarget);
	}
	
	
	public function plane (optTarget:Plane = null) : Plane
	{
		var result = (optTarget != null ? optTarget : new Plane());
		return result.setFromCoplanarPoints(a, b, c);
	}
	
	
	public function _barycoordFromPoint (point:Vector3, optTarget:Vector3 = null) : Vector3
	{
		return Triangle.barycoordFromPoint(point, a, b, c, optTarget);
	}
	
	
	public function _containsPoint (point:Vector3) : Bool
	{
		return Triangle.containsPoint(point, a, b, c);
	}
	
	
	public function equals (triangle:Triangle) : Bool
	{
		return triangle.a.equals(a) && triangle.b.equals(b) && triangle.c.equals(c);
	}
	
	
	public function clone () : Triangle
	{
		return new Triangle().copy(this);
	}
	

}

