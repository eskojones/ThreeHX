
package three.extras.geometries;

import three.core.Face4;
import three.core.Geometry;
import three.math.Vector3;

/**
 * 
 * @author dcm
 */

class CubeGeometry extends Geometry
{

	public var width:Float;
	public var height:Float;
	public var depth:Float;
	
	public var widthSegments:Int;
	public var heightSegments:Int;
	public var depthSegments:Int;
	
	
	public function new(width:Float, height:Float, depth:Float, 
						widthSegments:Int = 1, heightSegments:Int = 1, depthSegments:Int = 1) 
	{
		super();
		this.width = width;
		this.height = height;
		this.depth = depth;
		this.widthSegments = widthSegments;
		this.heightSegments = heightSegments;
		this.depthSegments = depthSegments;
		
		var whalf:Float = width / 2;
		var hhalf:Float = height / 2;
		var dhalf:Float = depth / 2;
		
		/*
		 * materialIndex in the original source were unique for each plane
		 * but in Haxe arrays dont 'wrap around' like in JS, so we'll set them all to 0 for this.
		 */
		buildPlane('z', 'y', -1, -1, depth, height, whalf, 0); //px
		buildPlane('z', 'y',  1, -1, depth, height, -whalf, 0); //nx
		buildPlane('x', 'z',  1,  1, width, depth,  hhalf, 0); //py
		buildPlane('x', 'z',  1, -1, width, depth,  -hhalf, 0); //ny
		buildPlane('x', 'y',  1, -1, width, height, dhalf, 0); //pz
		buildPlane('x', 'y', -1, -1, width, height, -dhalf, 0); //nz
		
		mergeVertices();
		computeCentroids();
	}
	
	
	public function buildPlane (u:String, v:String, udir:Int, vdir:Int, width:Float, height:Float, depth:Float, materialIndex:Int) 
	{
		var w:String = 'z', ix:Int, iy:Int;
		var gridX = widthSegments;
		var gridY = heightSegments;
		var whalf = width / 2;
		var hhalf = height / 2;
		var offset = vertices.length;
		
		if ( (u == 'x' && v == 'y') || (u == 'y' && v == 'x') ) 
		{
			w = 'z';
		} else if ( (u == 'x' && v == 'z') || (u == 'z' && v == 'x') )
		{
			w = 'y';
			gridY = depthSegments;
		} else if ( (u == 'z' && v == 'y') || (u == 'y' && v == 'z') )
		{
			w = 'x';
			gridX = depthSegments;
		}
		
		var gridX1 = gridX + 1;
		var gridY1 = gridY + 1;
		var segment_width = width / gridX;
		var segment_height = height / gridY;
		
		var normal = new Vector3();
		Reflect.setField(normal, w, depth > 0 ? 1 : -1);
		
		var iy = 0;
		while (iy < gridY1)
		{
			var ix = 0;
			while (ix < gridX1)
			{
				var vec = new Vector3();
				Reflect.setField(vec, u, (ix * segment_width - whalf) * udir);
				Reflect.setField(vec, v, (iy * segment_height - hhalf) * vdir);
				Reflect.setField(vec, w, depth);
				vertices.push(vec);
				ix++;
			}
			iy++;
		}
		
		iy = 0;
		while (iy < gridY)
		{
			ix = 0;
			while (ix < gridX)
			{
				var a = ix + gridX1 * iy;
				var b = ix + gridX1 * (iy + 1);
				var c = (ix + 1) + gridX1 * (iy + 1);
				var d = (ix + 1) + gridX1 * iy;
				var face = new Face4(a + offset, b + offset, c + offset, d + offset);
				face.normal.copy(normal);
				face.vertexNormals.push(normal.clone());
				face.vertexNormals.push(normal.clone());
				face.vertexNormals.push(normal.clone());
				face.vertexNormals.push(normal.clone());
				face.materialIndex = materialIndex;
				
				faces.push(face);
				faceVertexUvs[0].push([
					new Vector3(ix / gridX, 1 - iy / gridY),
					new Vector3(ix / gridX, 1 - (iy + 1) / gridY),
					new Vector3((ix + 1) / gridX, 1 - (iy + 1) / gridY),
					new Vector3((ix + 1) / gridX, 1 - iy / gridY)
				]);
				
				ix++;
			}
			iy++;
		}
		
		//do we really need to do this here? 
		//seems like a waste since we can just do it once at the end (or am i wrong?)
		//mergeVertices();
		//computeCentroids();
	}
	
	
}