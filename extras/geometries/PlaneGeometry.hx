package three.extras.geometries;
import three.core.Face4;
import three.core.Geometry;
import three.math.Vector2;
import three.math.Vector3;

/**
 * ...
 * @author dcm
 */

class PlaneGeometry extends Geometry
{
	public var width:Float;
	public var height:Float;
	public var widthSegments:Int;
	public var heightSegments:Int;
	

	public function new(width:Float, height:Float, widthSegments:Int = 1, heightSegments:Int = 1) 
	{
		super();
		this.width = width;
		this.height = height;
		this.widthSegments = widthSegments;
		this.heightSegments = heightSegments;
		
		var whalf = width / 2;
		var hhalf = height / 2;
		
		var gridX:Int = widthSegments;
		var gridZ:Int = heightSegments;
		var gridX1 = gridX + 1;
		var gridZ1 = gridZ + 1;
		
		var segment_width = width / gridX;
		var segment_height = height / gridZ;
		
		var normal = new Vector3(0, 0, 1);
		
		var iz = 0;
		while (iz < gridZ1)
		{
			var ix = 0;
			while (ix < gridX1)
			{
				var x = ix * segment_width - whalf;
				var y = iz * segment_height - hhalf;
				vertices.push(new Vector3(x, -y, 0));
				ix++;
			}
			iz++;
		}
		
		
		var iz = 0;
		while (iz < gridZ)
		{
			var ix = 0;
			while (ix < gridX)
			{
				var a = ix + gridX1 * iz;
				var b = ix + gridX1 * (iz + 1);
				var c = (ix + 1) + gridX1 * (iz + 1);
				var d = (ix + 1) + gridX1 * iz;
				var face = new Face4(a, b, c, d);
				face.normal.copy(normal);
				face.vertexNormals.push(normal.clone());
				face.vertexNormals.push(normal.clone());
				face.vertexNormals.push(normal.clone());
				face.vertexNormals.push(normal.clone());
				
				faces.push(face);
				faceVertexUvs[0].push([
					new Vector2(ix / gridX, 1 - iz / gridZ),
					new Vector2(ix / gridX, 1 - (iz + 1) / gridZ),
					new Vector2((ix + 1) / gridX, 1 - (iz + 1) / gridZ),
					new Vector2((ix +1) / gridX, 1 - iz / gridZ)
				]);
				ix++;
			}
			iz++;
		}
		
		computeCentroids();
	}
	
}

