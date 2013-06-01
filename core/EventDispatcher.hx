
package three.core;

import three.extras.Utils;

/**
 * EventDispatcher
 * TODO: Rewrite for Haxe
 * @author dcm
 */

class EventDispatcher
{
	
	private var listeners:Map < String, Array<Dynamic> > ;

	
	public function new() 
	{
		listeners = new Map < String, Array<Dynamic> > ();
	}
	
	
	public function addEventListener (type:String, listener:Dynamic) : Void
	{
		if (listeners.exists(type) == false) listeners.set(type, new Array<Dynamic>());
		
		var arr = listeners.get(type);
		var i = 0, l = arr.length;
		while (i < l) if (arr[i++] == listener) return;
		arr.push(listener);
	}
	
	
	public function hasEventListener (type:String, listener:Dynamic) : Bool
	{
		if (listeners.exists(type) == false) return false;
		
		var arr = listeners.get(type);
		var idx = Utils.indexOf(arr, listener);
		if (idx == -1) return false;
		return true;
	}
	
	
	public function removeEventListener (type:String, listener:Dynamic) : Void
	{
		if (listeners.exists(type) == false) return;
		var arr = listeners.get(type);
		var idx = Utils.indexOf(arr, listener);
		if (idx == -1) return;
		arr.splice(idx, 1);
	}
	
	
	public function dispatchEvent (event:Dynamic) : Void
	{
		if (listeners.exists(event.type) == false) return;
		var arr = listeners.get(event.type);
		var i = 0, l = arr.length;
		while (i < l) arr[i++](event);
	}
	
}