
package three.math;

import three.extras.MathUtils;

/**
 * 
 * @author Three.js Project (http://threejs.org)
 * @author dcm
 */

class Vector4
{
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var w:Float;

	
	public function new (x:Float = 0, y:Float = 0, z:Float = 0, w:Float = 1) 
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
	}
	
	
	public function copy (v:Vector4) : Vector4
	{
		x = v.x;
		y = v.y;
		z = v.z;
		w = v.w;
		//if (Reflect.hasField(v, 'w') == true) w = v.w;
		return this;
	}
	
	
	public function set (x:Float, y:Float, z:Float, w:Float) : Vector4
	{
		this.x = x;
		this.y = y;
		this.z = z;
		this.w = w;
		return this;
	}
	
	
	public function setX (x:Float = 0) : Vector4
	{
		this.x = x;
		return this;
	}
	
	
	public function setY (y:Float = 0) : Vector4
	{
		this.y = y;
		return this;
	}
	
	
	public function setZ (z:Float = 0) : Vector4
	{
		this.z = z;
		return this;
	}
	
	
	public function setW (w:Float = 0) : Vector4
	{
		this.w = w;
		return this;
	}
	
	
	public function setComponent (index:Int, value:Float) : Vector4
	{
		switch (index)
		{
			case 0: x = value;
			case 1: y = value;
			case 2: z = value;
			case 3: w = value;
			default: trace('setComponent: Index is out of range ($index)');
		}
		return this;
	}
	
	public function getComponent (index:Int) : Float
	{
		switch (index)
		{
			case 0: return x;
			case 1: return y;
			case 2: return z;
			case 3: return w;
			default:
				trace('getComponent: Index is out of range ($index)');
				return 0.0;
		}
	}
	
	
	public function add (v:Vector4) : Vector4
	{
		x += v.x;
		y += v.y;
		z += v.z;
		w += v.w;
		return this;
	}
	
	
	public function addScalar (s:Float) : Vector4
	{
		x += s;
		y += s;
		z += s;
		w += w;
		return this;
	}
	
	
	public function addVectors (a:Vector4, b:Vector4) : Vector4
	{
		x = a.x + b.x;
		y = a.y + b.y;
		z = a.z + b.z;
		w = a.w + b.w;
		return this;
	}
	
	
	public function sub (v:Vector4) : Vector4
	{
		x -= v.x;
		y -= v.y;
		z -= v.z;
		w -= v.w;
		return this;
	}
	
	
	public function subVectors (a:Vector4, b:Vector4) : Vector4
	{
		x = a.x - b.x;
		y = a.y - b.y;
		z = a.z - b.z;
		w = a.w - b.w;
		return this;
	}
	
	
	public function multiply (v:Vector4) : Vector4
	{
		x *= v.x;
		y *= v.y;
		z *= v.z;
		w *= v.w;
		return this;
	}
	
	
	public function multiplyScalar (s:Float) : Vector4
	{
		x *= s;
		y *= s;
		z *= s;
		w *= s;
		return this;
	}
	
	
	public function multiplyVectors (a:Vector4, b:Vector4) : Vector4
	{
		x = a.x * b.x;
		y = a.y * b.y;
		z = a.z * b.z;
		w = a.w * b.w;
		return this;
	}
	

	
	public function divide (v:Vector4) : Vector4
	{
		x /= v.x;
		y /= v.y;
		z /= v.z;
		w /= v.w;
		return this;
	}
	
	
	public function divideScalar (s:Float) : Vector4
	{
		if (s == 0.0) return set(0, 0, 0, 1);
		x /= s;
		y /= s;
		z /= s;
		w /= s;
		return this;
	}
	
	
	public function applyMatrix4 (m:Matrix4) : Vector4
	{
		var e = m.elements;
		var x = this.x, y = this.y, z = this.z, w = this.w;
		this.x = e[0] * x + e[4] * y + e[8] * z + e[12] * w;
		this.y = e[1] * x + e[5] * y + e[9] * z + e[13] * w;
		this.z = e[2] * x + e[6] * y + e[10] * z + e[14] * w;
		this.w = e[3] * x + e[7] * y + e[11] * z + e[15] * w;
		return this;
	}
	
	
	public function setAxisAngleFromQuaternion (q:Quaternion) : Vector4
	{
		w = 2 * Math.acos(q.w);
		var s = Math.sqrt(1 - q.w * q.w);
		
		if (s < 0.0001)
		{
			x = 1;
			y = 0;
			z = 0;
		} else {
			x = q.x / s;
			y = q.y / s;
			z = q.z / s;
		}
		
		return this;
	}
	
	
	public function setAxisAngleFromRotationMatrix (m:Matrix4) : Vector4
	{
		var x = this.x, y = this.y, z = this.z, w = this.w;
		var angle, epsilon = 0.01, epsilon2 = 0.1;
		var te = m.elements;
		var m11 = te[0], m12 = te[4], m13 = te[8];
		var m21 = te[1], m22 = te[5], m23 = te[9];
		var m31 = te[2], m32 = te[6], m33 = te[10];
		
		if ( (Math.abs(m12 - m21) < epsilon)
		  && (Math.abs(m13 - m31) < epsilon)
		  && (Math.abs(m23 - m32) < epsilon) )
		{
			if ( ( Math.abs( m12 + m21 ) < epsilon2 )
			  && ( Math.abs( m13 + m31 ) < epsilon2 )
			  && ( Math.abs( m23 + m32 ) < epsilon2 )
			  && ( Math.abs( m11 + m22 + m33 - 3 ) < epsilon2 ) ) 
			{
				set( 1, 0, 0, 0 );
				return this;
			}
			
			angle = Math.PI;
			var xx = ( m11 + 1 ) / 2;
			var yy = ( m22 + 1 ) / 2;
			var zz = ( m33 + 1 ) / 2;
			var xy = ( m12 + m21 ) / 4;
			var xz = ( m13 + m31 ) / 4;
			var yz = ( m23 + m32 ) / 4;
			
			if ( ( xx > yy ) && ( xx > zz ) ) 
			{
				if ( xx < epsilon ) 
				{
					x = 0;
					y = 0.707106781;
					z = 0.707106781;
				} else {
					x = Math.sqrt( xx );
					y = xy / x;
					z = xz / x;
				}
				
			} else if ( yy > zz )
			{
				if ( yy < epsilon ) 
				{
					x = 0.707106781;
					y = 0;
					z = 0.707106781;
				} else {
					y = Math.sqrt( yy );
					x = xy / y;
					z = yz / y;
				}
				
			} else {
				if ( zz < epsilon ) {
					x = 0.707106781;
					y = 0.707106781;
					z = 0;
				} else {
					z = Math.sqrt( zz );
					x = xz / z;
					y = yz / z;
				}
			}
			set( x, y, z, angle );
			return this;
		}
		
		var s = Math.sqrt( ( m32 - m23 ) * ( m32 - m23 )
						 + ( m13 - m31 ) * ( m13 - m31 )
						 + ( m21 - m12 ) * ( m21 - m12 ) );
		
		if ( Math.abs( s ) < 0.001 ) s = 1;
		
		this.x = ( m32 - m23 ) / s;
		this.y = ( m13 - m31 ) / s;
		this.z = ( m21 - m12 ) / s;
		this.w = Math.acos( ( m11 + m22 + m33 - 1 ) / 2 );
		return this;
	}
	
	
	public function min (v:Vector4) : Vector4
	{
		if (x > v.x) x = v.x;
		if (y > v.y) y = v.y;
		if (z > v.z) z = v.z;
		if (w > v.w) w = v.w;
		return this;
	}
	
	
	public function max (v:Vector4) : Vector4
	{
		if (x < v.x) x = v.x;
		if (y < v.y) y = v.y;
		if (z < v.z) z = v.z;
		if (w < v.w) w = v.w;
		return this;
	}
	
	
	public function clamp (vmin:Vector4, vmax:Vector4) : Vector4
	{
		if (x < vmin.x) x = vmin.x; else if (x > vmax.x) x = vmax.x;
		if (y < vmin.y) y = vmin.y; else if (y > vmax.y) y = vmax.y;
		if (z < vmin.z) z = vmin.z; else if (z > vmax.z) z = vmax.z;
		if (w < vmin.w) w = vmin.w; else if (w > vmax.w) w = vmax.w;
		return this;
	}
	
	
	public function negate () : Vector4
	{
		return multiplyScalar(-1);
	}
	
	
	public function dot (v:Vector4) : Float
	{
		return x * v.x + y * v.y + z * v.z + w * v.w;
	}
	
	
	public function lengthSq () : Float
	{
		return x * x + y * y + z * z + w * w;
	}
	
	
	public function length () : Float
	{
		return Math.sqrt(x * x + y * y + z * z + w * w);
	}
	
	
	public function lengthManhattan () : Float
	{
		return Math.abs(x) + Math.abs(y) + Math.abs(z) + Math.abs(w);
	}
	
	
	public function normalize () : Vector4
	{
		return divideScalar(length());
	}
	
	
	public function setLength (l:Float) : Vector4
	{
		var oldLength = length();
		if (oldLength != 0 && l != oldLength) multiplyScalar(l / oldLength);
		return this;
	}
	
	
	public function lerp (v:Vector4, alpha:Float) : Vector4
	{
		x += (v.x - x) * alpha;
		y += (v.y - y) * alpha;
		z += (v.z - z) * alpha;
		w += (v.w - w) * alpha;
		return this;
	}
	
	
	public function equals (v:Vector4) : Bool
	{
		return ( (x == v.x) && (y == v.y) && (z == v.z) && (w == v.w) );
	}
	
	
	public function fromArray (a:Array<Float>) : Vector4
	{
		x = a[0];
		y = a[1];
		z = a[2];
		w = a[3];
		return this;
	}
	
	
	public function toArray () : Array<Float>
	{
		var a = new Array<Float>();
		a.push(x);
		a.push(y);
		a.push(z);
		a.push(w);
		return a;
	}
	
	
	public function clone () : Vector4
	{
		return new Vector4(x, y, z, w);
	}
	

}