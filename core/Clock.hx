
package three.core;

/**
 * 
 * @author dcm
 */

class Clock
{

	public var autoStart:Bool;
	public var startTime:Float;
	public var oldTime:Float;
	public var elapsedTime:Float;
	public var running:Bool;
	
	
	public function new(autoStart:Bool = true) 
	{
		this.autoStart = autoStart;
		startTime = 0;
		oldTime = 0;
		elapsedTime = 0;
		running = false;
	}
	
	
	public function start ()
	{
		startTime = Date.now().getTime();
		oldTime = startTime;
		running = true;
	}
	
	
	public function stop ()
	{
		getElapsedTime();
		running = false;
	}
	
	
	public function getElapsedTime () : Float
	{
		getDelta();
		return elapsedTime;
	}
	
	
	public function getDelta () : Float
	{
		var diff:Float = 0.0;
		
		if (autoStart == true && running == false) start();
		
		if (running == true)
		{
			var newTime = Date.now().getTime();
			diff = newTime - oldTime;
			oldTime = newTime;
			elapsedTime += diff;
		}
		
		return diff;
	}
	
	
}

