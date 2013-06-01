
package three.math;

import three.extras.MathUtils;

/**
 * 
 * @author Three.js Project (http://threejs.org)
 * @author dcm
 */

class Vector3
{
	
	public var x:Float;
	public var y:Float;
	public var z:Float;

	
	public function new (x:Float = 0, y:Float = 0, z:Float = 0) 
	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	
	
	public function copy (v:Vector3) : Vector3
	{
		x = v.x;
		y = v.y;
		z = v.z;
		return this;
	}
	
	
	public function set (x:Float = 0, y:Float = 0, z:Float = 0) : Vector3
	{
		this.x = x;
		this.y = y;
		this.z = z;
		return this;
	}
	
	
	public function setX (x:Float = 0) : Vector3
	{
		this.x = x;
		return this;
	}
	
	
	public function setY (y:Float = 0) : Vector3
	{
		this.y = y;
		return this;
	}
	
	
	public function setZ (z:Float = 0) : Vector3
	{
		this.z = z;
		return this;
	}
	
	
	public function setComponent (index:Int, value:Float) : Vector3
	{
		switch (index)
		{
			case 0: x = value;
			case 1: y = value;
			case 2: z = value;
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
			default:
				trace('getComponent: Index is out of range ($index)');
				return 0.0;
		}
	}
	
	
	public function add (v:Vector3) : Vector3
	{
		x += v.x;
		y += v.y;
		z += v.z;
		return this;
	}
	
	
	public function addScalar (s:Float) : Vector3
	{
		x += s;
		y += s;
		z += s;
		return this;
	}
	
	
	public function addVectors (a:Vector3, b:Vector3) : Vector3
	{
		x = a.x + b.x;
		y = a.y + b.y;
		z = a.z + b.z;
		return this;
	}
	
	
	public function sub (v:Vector3) : Vector3
	{
		x -= v.x;
		y -= v.y;
		z -= v.z;
		return this;
	}
	
	
	public function subVectors (a:Vector3, b:Vector3) : Vector3
	{
		x = a.x - b.x;
		y = a.y - b.y;
		z = a.z - b.z;
		return this;
	}
	
	
	public function multiply (v:Vector3) : Vector3
	{
		x *= v.x;
		y *= v.y;
		z *= v.z;
		return this;
	}
	
	
	public function multiplyScalar (s:Float) : Vector3
	{
		x *= s;
		y *= s;
		z *= s;
		return this;
	}
	
	
	public function multiplyVectors (a:Vector3, b:Vector3) : Vector3
	{
		x = a.x * b.x;
		y = a.y * b.y;
		z = a.z * b.z;
		return this;
	}
	

	
	public function divide (v:Vector3) : Vector3
	{
		x /= v.x;
		y /= v.y;
		z /= v.z;
		return this;
	}
	
	
	public function divideScalar (s:Float) : Vector3
	{
		if (s == 0.0) return set(0, 0, 0);
		x /= s;
		y /= s;
		z /= s;
		return this;
	}
	
	
	public function applyMatrix3 (m:Matrix3) : Vector3
	{
		var e = m.elements;
		var x = this.x, y = this.y, z = this.z;
		this.x = e[0] * x + e[3] * y + e[6] * z;
		this.y = e[1] * x + e[4] * y + e[7] * z;
		this.z = e[2] * x + e[5] * y + e[8] * z;
		return this;
	}
	
	
	public function applyMatrix4 (m:Matrix4) : Vector3
	{
		var e = m.elements;
		var x = this.x, y = this.y, z = this.z;
		this.x = e[0] * x + e[4] * y + e[8] * z + e[12];
		this.y = e[1] * x + e[5] * y + e[9] * z + e[13];
		this.z = e[2] * x + e[6] * y + e[10] * z + e[14];
		return this;
	}
	
	
	public function applyProjection (m:Matrix4) : Vector3
	{
		var e = m.elements;
		var x = this.x, y = this.y, z = this.z;
		var d:Float = 1 / (e[3] * x + e[7] * y + e[11] * z + e[15]);
		this.x = (e[0] * x + e[4] * y + e[8] * z + e[12]) * d;
		this.y = (e[1] * x + e[5] * y + e[9] * z + e[13]) * d;
		this.z = (e[2] * x + e[6] * y + e[10] * z + e[14]) * d;
		return this;
	}
	
	public function applyQuaternion (q:Quaternion) : Vector3
	{
		var qx = q.x;
		var qy = q.y;
		var qz = q.z;
		var qw = q.w;
		
		var ix = qw * x + qy * z - qz * y;
		var iy = qw * y + qz * x - qx * z;
		var iz = qw * z + qx * y - qy * x;
		var iw = -qx * x - qy * y - qz * z;
		
		x = ix * qw + iw * -qx + iy * -qz - iz * -qy;
		y = iy * qw + iw * -qy + iz * -qx - ix * -qz;
		z = iz * qw + iw * -qz + ix * -qy - iy * -qx;
		return this;
	}
	
	public function transformDirection (m:Matrix4) : Vector3
	{
		var e = m.elements;
		var x = this.x, y = this.y, z = this.z;
		this.x = e[0] * x + e[4] * y + e[8] * z;
		this.y = e[1] * x + e[5] * y + e[9] * z;
		this.z = e[2] * x + e[6] * y + e[10] * z;
		normalize();
		return this;
	}
	
	
	public function min (v:Vector3) : Vector3
	{
		if (x > v.x) x = v.x;
		if (y > v.y) y = v.y;
		if (z > v.z) z = v.z;
		return this;
	}
	
	
	public function max (v:Vector3) : Vector3
	{
		if (x < v.x) x = v.x;
		if (y < v.y) y = v.y;
		if (z < v.z) z = v.z;
		return this;
	}
	
	
	public function clamp (vmin:Vector3, vmax:Vector3) : Vector3
	{
		if (x < vmin.x) x = vmin.x; else if (x > vmax.x) x = vmax.x;
		if (y < vmin.y) y = vmin.y; else if (y > vmax.y) y = vmax.y;
		if (z < vmin.z) z = vmin.z; else if (z > vmax.z) z = vmax.z;
		return this;
	}
	
	
	public function negate () : Vector3
	{
		return multiplyScalar(-1);
	}
	
	
	public function dot (v:Vector3) : Float
	{
		return x * v.x + y * v.y + z * v.z;
	}
	
	
	public function lengthSq () : Float
	{
		return x * x + y * y + z * z;
	}
	
	
	public function length () : Float
	{
		return Math.sqrt(x * x + y * y + z * z);
	}
	
	
	public function lengthManhattan () : Float
	{
		return Math.abs(x) + Math.abs(y) + Math.abs(z);
	}
	
	
	public function normalize () : Vector3
	{
		return divideScalar(length());
	}
	
	
	public function setLength (l:Float) : Vector3
	{
		var oldLength = length();
		if (oldLength != 0 && l != oldLength) multiplyScalar(l / oldLength);
		return this;
	}
	
	
	public function lerp (v:Vector3, alpha:Float) : Vector3
	{
		x += (v.x - x) * alpha;
		y += (v.y - y) * alpha;
		z += (v.z - z) * alpha;
		return this;
	}
	
	
	public function cross (v:Vector3) : Vector3
	{
		x = y * v.z - z * v.y;
		y = z * v.x - x * v.z;
		z = x * v.y - y * v.x;
		return this;
	}
	
	
	public function crossVectors (a:Vector3, b:Vector3) : Vector3
	{
		x = a.y * b.z - a.z * b.y;
		y = a.z * b.x - a.x * b.z;
		z = a.x * b.y - a.y * b.x;
		return this;
	}
	
	
	public function angleTo (v:Vector3) : Float
	{
		var theta:Float = dot(v) / (length() * v.length());
		if (theta < -1) theta = -1; else if (theta > 1) theta = 1;
		return Math.acos(theta);
	}
	
	
	public function distanceToSquared (v:Vector3) : Float
	{
		var dx = x - v.x;
		var dy = y - v.y;
		var dz = z - v.z;
		return dx * dx + dy * dy + dz * dz;
	}
	
	
	public function distanceTo (v:Vector3) : Float
	{
		return Math.sqrt(distanceToSquared(v));
	}
	
	
	public function setEulerFromRotationMatrix (m:Matrix4, order:String = 'XYZ') : Vector3
	{
		var te = m.elements;
		var m11 = te[0], m12 = te[4], m13 = te[8];
		var m21 = te[1], m22 = te[5], m23 = te[9];
		var m31 = te[2], m32 = te[6], m33 = te[10];
		
		//todo - support other euler orders
		if (order == 'XYZ')
		{
			y = Math.asin(Math.min(Math.max(m13, -1), 1));
			
			if (Math.abs(m13) < 0.99999)
			{
				x = Math.atan2( -m23, m33);
				z = Math.atan2( -m12, m11);
			} else {
				x = Math.atan2(m32, m22);
				z = 0;
			}
		}
		
		return this;
	}
	
	
	public function setEulerFromQuaternion (q:Quaternion, order:String = 'XYZ') : Vector3
	{
		var sqx = q.x * q.x;
		var sqy = q.y * q.y;
		var sqz = q.z * q.z;
		var sqw = q.w * q.w;
		
		if (order == 'XYZ')
		{
			x = Math.atan2( 2 * ( q.x * q.w - q.y * q.z ), ( sqw - sqx - sqy + sqz ) );
			y = Math.asin(  MathUtils.clamp( 2 * ( q.x * q.z + q.y * q.w ), -1, 1 ) );
			z = Math.atan2( 2 * ( q.z * q.w - q.x * q.y ), ( sqw + sqx - sqy - sqz ) );			
		}
		
		return this;
	}
	
	
	public function getPositionFromMatrix (m:Matrix4) : Vector3
	{
		x = m.elements[12];
		y = m.elements[13];
		z = m.elements[14];
		return this;
	}
	
	
	public function getScaleFromMatrix (m:Matrix4) : Vector3
	{
		var e = m.elements;
		var sx = set(e[0], e[1], e[2]).length();
		var sy = set(e[4], e[5], e[6]).length();
		var sz = set(e[8], e[9], e[10]).length();
		x = sx;
		y = sy;
		z = sz;
		return this;
	}
	
	
	public function getColumnFromMatrix (index:Int, m:Matrix4) : Vector3
	{
		var offset = index * 4;
		var e = m.elements;
		x = e[offset];
		y = e[offset + 1];
		z = e[offset + 2];
		return this;
	}
	
	
	public function equals (v:Vector3) : Bool
	{
		return ( (x == v.x) && (y == v.y) && (z == v.z) );
	}
	
	
	public function fromArray (a:Array<Float>) : Vector3
	{
		x = a[0];
		y = a[1];
		z = a[2];
		return this;
	}
	
	
	public function toArray () : Array<Float>
	{
		var a = new Array<Float>();
		a.push(x);
		a.push(y);
		a.push(z);
		return a;
	}
	
	
	public function clone () : Vector3
	{
		return new Vector3(x, y, z);
	}
	
	
	public function applyEuler (v:Vector3, order:String = 'XYZ') : Vector3
	{
		var q1 = new Quaternion();
		applyQuaternion(q1.setFromEuler(v, order));
		return this;
	}
	
	
	public function applyAxisAngle (axis:Vector3, angle:Float) : Vector3
	{
		var q1 = new Quaternion();
		applyQuaternion(q1.setFromAxisAngle(axis, angle));
		return this;
	}
	
	
	public function projectOnVector (v:Vector3) : Vector3
	{
		var v1 = v.clone().normalize();
		var d = dot(v1);
		copy(v1).multiplyScalar(d);
		return this;
	}
	
	
	public function projectOnPlane (planeNormal:Vector3) : Vector3
	{
		var v1 = clone().projectOnVector(planeNormal);
		return sub(v1);
	}
	
	
	public function reflect (v:Vector3) : Vector3
	{
		var v1 = clone().projectOnVector(v).multiplyScalar(2);
		return subVectors(v1, this);
	}
}