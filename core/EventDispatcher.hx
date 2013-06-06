
package three.core;

import three.extras.Utils;

/**
 * EventDispatcher by mrdoob
 * TODO: Rewrite for Haxe - THIS IS NOT WORKING YET
 * @author dcm
 */

class EventDispatcher
{
	
	private var listeners:Map < String, Map<Dynamic,Dynamic> > ;

	
	public function new() 
	{
		listeners = new Map < String, Map<Dynamic,Dynamic> > ();
	}
	
	
	public function addEventListener (type:String, listener:Dynamic) : Void
	{
		//todo - Make an appropriate Map<> that can differentiate between anon functions
		//if (listeners.exists(type) == false) listeners.set(type, new Map<Dynamic,Dynamic>());
		
		var listenersOfType = listeners.get(type);
		if (listenersOfType.exists(listener) == true) return;
		listenersOfType.set(listener, listener);
	}
	
	
	public function hasEventListener (type:String, listener:Dynamic) : Bool
	{
		if (listeners.exists(type) == false) return false;
		
		var listenersOfType = listeners.get(type);
		if (listenersOfType.exists(listener) == false) return false;
		return true;
	}
	
	
	public function removeEventListener (type:String, listener:Dynamic) : Void
	{
		if (listeners.exists(type) == false) return;
		
		var listenersOfType = listeners.get(type);
		if (listenersOfType.exists(listener) == false) return;
		listenersOfType.remove(listener);
	}
	
	
	public function dispatchEvent (event:Dynamic) : Void
	{
		if (listeners.exists(event.type) == false) return;
		
		var listenersOfType = listeners.get(event.type);
		var listenerIter = listenersOfType.iterator();
		while (listenerIter.hasNext() == true) listenerIter.next()(event);
	}
	
}