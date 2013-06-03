ThreeHX
=======
Port of Three.js to the haXe programming language

Just 'direct' porting for starters, with cleanup/re-design as time permits.





Progress
========
All of the classes from 'math'.

Scene, Cameras, Mesh, and almost all of 'core'.

No renderers yet, although there is a hacky/broken Face4-only renderer `DebugRenderer`





Example
=======
```haxe
package ;

import three.renderers.DebugRenderer;
import three.scenes.Scene;
import three.cameras.PerspectiveCamera;
import three.materials.MeshBasicMaterial;
import three.extras.geometries.CubeGeometry;
import three.objects.Mesh;

class Main
{
	static function main()
	{
		var renderer = new DebugRenderer();
		renderer.setSize(800, 600);
		
		var scene = new Scene();
		var camera = new PerspectiveCamera(50, 800 / 600, 0.1, 2000);
		
		var material = new MeshBasicMaterial();
		var geometry = new CubeGeometry(10, 10, 10);
		var cube = new Mesh(geometry, material);
		scene.add(cube);
		
		camera.position.set(50, 50, 50);
		camera.lookAt(cube.position);
		
		renderer.render(scene, camera);
	}
}
```
