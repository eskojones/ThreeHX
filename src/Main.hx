package ;

import three.*;
import three.cameras.PerspectiveCamera;
import three.renderers.CanvasRenderer;
import three.scenes.Scene;


/**
 * ...
 * @author dcm
 */

class Main 
{
	
	static function main() 
	{
		var renderer = new CanvasRenderer({ width: 800, height: 600 });
		var scene = new Scene();
		var camera = new PerspectiveCamera(60, 800 / 600, 0.1, 2000);
		
	}
	
}