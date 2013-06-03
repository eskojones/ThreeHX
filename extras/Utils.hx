
package three.extras;

/**
 * 
 * @author dcm
 */

class Utils
{
	//This can be safely deleted now. All arrays that made use of this are now Map<>
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

