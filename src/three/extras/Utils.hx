
package three.extras;
import three.math.Vector3;
import three.math.Vector4;

/**
 * ...
 * @author dcm
 */

class Utils
{
	static public function indexOf (a:Array<Dynamic>, value:Dynamic) : Int
	{
		var i = 0, l = a.length;
		while (i < l)
		{
			var here = a[i];
			if (here == value) return i;
			i++;
		}
		return -1;
	}
	
}

