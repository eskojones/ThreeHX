package three.extras;
import three.core.Face3;
import three.core.Face4;
import three.core.Geometry;
import three.core.Object3D;
import three.math.Color;
import three.math.Matrix3;
import three.math.Vector2;
import three.math.Vector3;
import three.objects.Mesh;

/**
 * ...
 * @author dcm
 */
class GeometryUtils
{

	static public function merge (geometry1:Geometry, object2:Mesh, materialIndexOffset:Int = 0)
	{
		var geometry2 = object2.geometry;
		var vertexOffset = geometry1.vertices.length;
		var uvPosition = geometry1.faceVertexUvs[0].length;
		var vertices1 = geometry1.vertices;
		var vertices2 = geometry2.vertices;
		var faces1 = geometry1.faces;
		var faces2 = geometry2.faces;
		var uvs1:Array<Array<Vector2>> = geometry1.faceVertexUvs[0];
		var uvs2:Array<Array<Vector2>> = geometry2.faceVertexUvs[0];
		
		if (object2.matrixAutoUpdate) object2.updateMatrix();
		var matrix = object2.matrix;
		var normalMatrix = new Matrix3().getNormalMatrix(matrix);
		
		var i = 0, il = vertices2.length;
		while (i < il)
		{
			var vertex = vertices2[i];
			var vertexCopy = vertex.clone();
			vertexCopy.applyMatrix4(matrix);
			vertices1.push(vertexCopy);
			i++;
		}
		
		i = 0; il = faces2.length;
		while (i < il)
		{
			var face = faces2[i];
			var faceVertexNormals:Array<Vector3> = face.vertexNormals;
			var faceVertexColors:Array<Color> = face.vertexColors;
			var faceCopy:Dynamic;
			
			if (Std.is(face, Face3) == true)
			{
				faceCopy = new Face3(face.a + vertexOffset, face.b + vertexOffset, face.c + vertexOffset);
			} else {
				faceCopy = new Face4(face.a + vertexOffset, face.b + vertexOffset, face.c + vertexOffset, face.d + vertexOffset);
			}
			
			faceCopy.normal.copy(face.normal);
			faceCopy.normal.applyMatrix3(normalMatrix).normalize();
			
			var j = 0, jl = faceVertexNormals.length;
			while (j < jl)
			{
				var normal:Vector3 = faceVertexNormals[j].clone();
				normal.applyMatrix3(normalMatrix).normalize();
				faceCopy.vertexNormals.push(normal);
				j++;
			}
			
			faceCopy.color.copy(face.color);
			
			j = 0; jl = faceVertexColors.length;
			while (j < jl)
			{
				var color = faceVertexColors[j];
				faceCopy.vertexColors.push(color.clone());
				j++;
			}
			
			faceCopy.materialIndex = face.materialIndex + materialIndexOffset;
			faceCopy.centroid.copy(face.centroid);
			faceCopy.centroid.applyMatrix4(matrix);
			faces1.push(faceCopy);
			i++;
		}
		
		i = 0; il = uvs2.length;
		while (i < il)
		{
			var uv = uvs2[i], uvCopy = new Array<Vector2>();
			var j = 0, jl = uv.length;
			while (j < jl)
			{
				uvCopy.push(new Vector2(uv[j].x, uv[j].y));
				j++;
			}
			
			uvs1.push(uvCopy);
			i++;
		}
		
		
	}
	
	
}

