
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
	
	
	static public inline function get<T>(arr:Array<T>, idx:Int) : T
	{
		if (idx < 0) idx += arr.length;
		if (idx >= arr.length) idx %= arr.length;
		return arr[idx];    
	}
}

