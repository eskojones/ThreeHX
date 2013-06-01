
package three.math;

/**
 * 
 * @author Three.js Project (http://threejs.org)
 * @author dcm
 */

class Matrix3
{
	
	public var elements:Array<Float>;
	
	
	public function new (
		n11:Float = 1, n12:Float = 0, n13:Float = 0,
		n21:Float = 0, n22:Float = 1, n23:Float = 0,
		n31:Float = 0, n32:Float = 0, n33:Float = 1) 
	{
		elements = new Array<Float>();
		var i = 0;
		while (i++ < 9) elements.push(0.0);
		this.set(n11, n12, n13, n21, n22, n23, n31, n32, n33);
	}
	
	
	public function set (
		n11:Float = 1, n12:Float = 0, n13:Float = 0,
		n21:Float = 0, n22:Float = 1, n23:Float = 0,
		n31:Float = 0, n32:Float = 0, n33:Float = 1) : Matrix3
	{
		var e = elements;
		e[0] = n11; e[3] = n12; e[6] = n13;
		e[1] = n21; e[4] = n22; e[7] = n23;
		e[2] = n31; e[5] = n32; e[8] = n33;
		return this;
	}
	
	
	public function identity () :Matrix3
	{
		set(
			1, 0, 0,
			0, 1, 0,
			0, 0, 1
		);
		return this;
	}
	
	
	public function copy (m:Matrix3) : Matrix3
	{
		var me = m.elements;
		set(
			me[0], me[3], me[6],
			me[1], me[4], me[7],
			me[2], me[5], me[8]
		);
		return this;
	}
	
	
	public function multiplyVector3 (v:Vector3) : Vector3
	{
		return v.applyMatrix3(this);
	}
	
	
	public function multiplyVector3Array (a:Array<Float>) : Array<Float>
	{
		var v1 = new Vector3();
		var i = 0, il = a.length;
		while (i < il)
		{
			v1.x = a[i];
			v1.y = a[i + 1];
			v1.z = a[i + 2];
			v1.applyMatrix3(this);
			
			a[i] = v1.x;
			a[i + 1] = v1.y;
			a[i + 2] = v1.z;
			i++;
		}
		return a;
	}
	
	
	public function multiplyScalar (s:Float) : Matrix3
	{
		var e = elements;
		e[0] *= s; e[3] *= s; e[6] *= s;
		e[1] *= s; e[4] *= s; e[7] *= s;
		e[2] *= s; e[5] *= s; e[8] *= s;
		return this;
	}
	
	
	public function determinant () : Float
	{
		var te = elements;
		var a = te[0], b = te[1], c = te[2];
		var d = te[3], e = te[4], f = te[5];
		var g = te[6], h = te[7], i = te[8];
		return a * e * i - a * f * h - b * d * i + b * f * g + c * d * h - c * e * g;
	}
	
	
	public function getInverse (m:Matrix4) : Matrix3
	{
		var me = m.elements;
		var te = elements;
		te[0] =  me[10] * me[5] - me[6] * me[9];
		te[1] = -me[10] * me[1] + me[2] * me[9];
		te[2] =  me[6]  * me[1] - me[2] * me[5];
		te[3] = -me[10] * me[4] + me[6] * me[8];
		te[4] =  me[10] * me[0] - me[2] * me[8];
		te[5] = -me[6]  * me[0] + me[2] * me[4];
		te[6] =  me[9]  * me[4] - me[5] * me[8];
		te[7] = -me[9]  * me[0] + me[1] * me[8];
		te[8] =  me[5]  * me[0] - me[1] * me[4];
		
		var det = me[0] * te[0] + me[1] * te[3] + me[2] * te[6];
		
		if (det == 0)
		{
			trace('Matrix3.getInverse: cant invert matrix, determinant is 0');
			identity();
			return this;
		}
		
		multiplyScalar(1.0 / det);
		return this;
	}
	
	
	public function transpose () : Matrix3
	{
		var tmp:Float, m = elements;
		tmp = m[1]; m[1] = m[3]; m[3] = tmp;
		tmp = m[2]; m[2] = m[6]; m[6] = tmp;
		tmp = m[5]; m[5] = m[7]; m[7] = tmp;
		return this;
	}
	
	
	public function getNormalMatrix (m:Matrix4) : Matrix3
	{
		return getInverse(m).transpose();
	}
	
	
	public function transposeIntoArray (r:Array<Float>) : Matrix3
	{
		var m = elements;
		r[0] = m[0];
		r[1] = m[3];
		r[2] = m[6];
		r[3] = m[1];
		r[4] = m[4];
		r[5] = m[7];
		r[6] = m[2];
		r[7] = m[5];
		r[8] = m[8];
		return this;
	}
	
	
	public function clone () : Matrix3
	{
		var e = elements;
		return new Matrix3(
			e[0], e[3], e[6],
			e[1], e[4], e[7],
			e[2], e[5], e[8]
		);
	}
	
}

