package three.extras.geometries;
import three.core.Face3;
import three.core.Face4;
import three.core.Geometry;
import three.math.Sphere;
import three.math.Vector2;
import three.math.Vector3;

/**
 * ...
 * @author dcm
 */
class SphereGeometry extends Geometry
{
	public var radius:Float;
	public var widthSegments:Int;
	public var heightSegments:Int;

	public function new(
		radius:Float = 50, widthSegments:Int = 8, heightSegments:Int = 6,
		phiStart:Float = 0, phiLength:Float = null,
		thetaStart:Float = 0, thetaLength:Float = null)
	{
		super();
		this.radius = radius;
		this.widthSegments = widthSegments;
		this.heightSegments = heightSegments;
		if (phiLength == null) phiLength = Math.PI * 2;
		if (thetaLength == null) thetaLength = Math.PI;
		
		var tmpVertices = [];
		var tmpUvs = [];
		
		var y = 0;
		while (y < heightSegments)
		{
			var verticesRow = [];
			var uvsRow = [];
			
			var x = 0;
			while (x < widthSegments)
			{
				var u = x / widthSegments;
				var v = y / heightSegments;
				
				var vertex = new Vector3();
				vertex.x = -radius * Math.cos(phiStart + u * phiLength) * Math.sin(thetaStart + v * thetaLength);
				vertex.y = radius * Math.cos(thetaStart + v * thetaLength);
				vertex.z = radius * Math.sin(phiStart + u * phiLength) * Math.sin(thetaStart + v * thetaLength);
				vertices.push(vertex);
				
				verticesRow.push(vertices.length - 1);
				uvsRow.push(new Vector2(u, 1 - v));
				x++;
			}
			
			tmpVertices.push(verticesRow);
			tmpUvs.push(uvsRow);
			y++;
		}
		
		var y = 0;
		while (y < heightSegments)
		{
			var Y1 = (y + 1) % heightSegments;
			var x = 0;
			while (x < widthSegments)
			{
				var X1 = (x + 1) % widthSegments;
				var v1 = tmpVertices[y][X1];
				var v2 = tmpVertices[y][x];
				var v3 = tmpVertices[Y1][x];
				var v4 = tmpVertices[Y1][X1];
				
				var n1 = vertices[v1].clone().normalize();
				var n2 = vertices[v2].clone().normalize();
				var n3 = vertices[v3].clone().normalize();
				var n4 = vertices[v4].clone().normalize();
				
				var uv1 = tmpUvs[y][X1].clone();
				var uv2 = tmpUvs[y][x].clone();
				var uv3 = tmpUvs[Y1][x].clone();
				var uv4 = tmpUvs[Y1][X1].clone();
				
				if (Math.abs(vertices[v1].y) == radius)
				{
					faces.push(new Face3(v1, v3, v4, [n1, n3, n4]));
					faceVertexUvs[0].push([uv1, uv3, uv4]);
				} else if (Math.abs(vertices[v3].y) == radius)
				{
					faces.push(new Face3(v1, v2, v3, [n1, n2, n3]));
					faceVertexUvs[0].push([uv1, uv2, uv3]);
				} else 
				{
					faces.push(new Face4(v1, v2, v3, v4, [n1, n2, n3, n4]));
					faceVertexUvs[0].push([uv1, uv2, uv3, uv4]);
				}
				x++;
			}
			y++;
		}
		
		computeCentroids();
		computeFaceNormals();
		boundingSphere = new Sphere(new Vector3(), radius);
	}
	
}