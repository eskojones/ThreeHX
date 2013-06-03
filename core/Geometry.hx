
package three.core;

import three.math.Box3;
import three.math.Color;
import three.math.Matrix3;
import three.math.Matrix4;
import three.math.Sphere;
import three.math.Vector2;
import three.math.Vector3;

/**
 * 
 * @author dcm
 */

class Geometry
{
	
	public var id:Int;
	public var name:String;
	public var vertices:Array<Vector3>;
	public var colors:Array<Color>;
	public var normals:Array<Vector3>;
	
	public var faces:Array<Dynamic>;
	public var faceUvs:Array<Dynamic>;
	public var faceVertexUvs:Array<Dynamic>;
	
	//not yet
	public var morphTargets:Array<Vector3>;
	public var morphColors:Array<Color>;
	public var morphNormals:Array<Vector3>;
	public var skinWeights:Array<Dynamic>;
	public var skinIndices:Array<Dynamic>;
	
	public var lineDistances:Array<Dynamic>;
	
	public var boundingBox:Box3;
	public var boundingSphere:Sphere;
	
	public var hasTangents:Bool;
	
	public var isDynamic:Bool;
	public var verticesNeedUpdate:Bool;
	public var elementsNeedUpdate:Bool;
	public var uvsNeedUpdate:Bool;
	public var normalsNeedUpdate:Bool;
	public var tangentsNeedUpdate:Bool;
	public var colorsNeedUpdate:Bool;
	public var lineDistancesNeedUpdate:Bool;
	public var buffersNeedUpdate:Bool;
	

	public function new() 
	{
		vertices = new Array<Vector3>();
		colors = new Array<Color>();
		normals = new Array<Vector3>();
		faces = new Array<Dynamic>(); //Face3 or Face4
		faceUvs = new Array<Dynamic>(); //NOTE: only temporary v3, change to v2 when its done
		faceVertexUvs = new Array<Dynamic>();
		faceVertexUvs.push(new Array<Vector2>());
		
		morphTargets = new Array<Vector3>();
		morphColors = new Array<Color>();
		morphNormals = new Array<Vector3>();
		skinWeights = new Array<Dynamic>();
		skinIndices = new Array<Dynamic>();
		lineDistances = new Array<Dynamic>();
		
		boundingBox = new Box3();
		boundingSphere = new Sphere();
		
		hasTangents = false;
		isDynamic = true;
		verticesNeedUpdate = false;
		elementsNeedUpdate = false;
		uvsNeedUpdate = false;
		normalsNeedUpdate = false;
		tangentsNeedUpdate = false;
		colorsNeedUpdate = false;
		lineDistancesNeedUpdate = false;
		buffersNeedUpdate = false;
	}
	
	
	public function applyMatrix (m:Matrix4)
	{
		var normalMatrix = new Matrix3().getNormalMatrix(m);
		
		var i = 0, l = vertices.length;
		while (i < l) vertices[i++].applyMatrix4(m);
		
		i = 0; l = faces.length;
		while (i < l)
		{
			var face = faces[i];
			face.normal.applyMatrix3(normalMatrix).normalize();
			
			//since faces[] is Dynamic...
			var faceVertexNormals:Array<Vector3> = face.vertexNormals;
			
			var j = 0, jl = faceVertexNormals.length;
			while (j < jl)
			{
				faceVertexNormals[j++].applyMatrix3(normalMatrix).normalize();
			}
			i++;
		}
	}
	
	
	public function computeCentroids ()
	{
		var f = 0, fl = faces.length, face:Face4;
		while (f < fl)
		{
			face = cast(faces[f++], Face4);
			face.centroid.set(0, 0, 0);
			
			if (Std.is(face, Face4) == true)
			{
				face.centroid.add(vertices[face.a]);
				face.centroid.add(vertices[face.b]);
				face.centroid.add(vertices[face.c]);
				face.centroid.add(vertices[face.d]);
				face.centroid.divideScalar(4);
			} else 
			{
				face.centroid.add(vertices[face.a]);
				face.centroid.add(vertices[face.b]);
				face.centroid.add(vertices[face.c]);
				face.centroid.divideScalar(3);
			}
		}
	}
	
	
	public function computeFaceNormals ()
	{
		var cb = new Vector3(), ab = new Vector3();
		
		var f = 0, fl = faces.length, face:Face4;
		while (f < fl)
		{
			face = cast(faces[f++], Face4);
			var vA = vertices[face.a];
			var vB = vertices[face.b];
			var vC = vertices[face.c];
			cb.subVectors(vC, vB);
			ab.subVectors(vA, vB);
			cb.cross(ab);
			cb.normalize();
			face.normal.copy(cb);
		}
	}
	
	
	public function computeVertexNormals ()
	{
		//todo - when i can be bothered...
	}
	
	
	public function computeMorphNormals ()
	{
		//todo - ...
	}
	
	
	public function computeTangents ()
	{
		//todo - ...
	}
	
	
	public function computeLineDistances ()
	{
		//todo - ...
	}
	
	
	public function computeBoundingBox ()
	{
		if (boundingBox == null) boundingBox = new Box3();
		boundingBox.setFromPoints(vertices);
	}
	
	
	public function computeBoundingSphere ()
	{
		if (boundingSphere == null) boundingSphere = new Sphere();
		boundingSphere.setFromCenterAndPoints(boundingSphere.center, vertices);
	}
	
	
	public function mergeVertices ()
	{
		//todo - find duplicate vertices and remove, correcting face indices
		var verticesMap = new Map<String,Int>();
		var unique = [];
		var changes = [];
		var v:Vector3, key:String;
		var precisionPoints = 4;
		var precision = Math.pow(10, precisionPoints);
		var indices = [];
		
		/*
		
		//Make the map of vertices -> indices
		var i = 0, il = vertices.length;
		while (i < il)
		{
			v = vertices[i];
			key = [ Math.round(v.x * precision), Math.round(v.y * precision), Math.round(v.z * precision) ].join('_');
			
			if (verticesMap.exists(key) == false)
			{
				verticesMap.set(key, i);
				unique.push(vertices[i]);
				changes[i] = unique.length - 1;
			} else {
				changes[i] = changes[verticesMap.get(key)];
			}
			i++;
		}
		
		var faceIndicesToRemove = [];
		i = 0; il = faces.length;
		while (i < il)
		{
			var face = faces[i];
			
			if (Std.is(face, Face3) == true)
			{
				var face:Face3 = cast(face, Face3);
				face.a = changes[face.a];
				face.b = changes[face.b];
				face.c = changes[face.c];
				
				indices = [face.a, face.b, face.c];
				var dupIndex = -1;
				
				var n = 0;
				while (n < 3)
				{
					if (indices[n] == indices[(n + 1) % 3])
					{
						dupIndex = n;
						faceIndicesToRemove.push(i);
						break;
					}
					n++;
				}
				
				
			} else if (Std.is(face, Face4) == true)
			{
				var face:Face4 = cast(face, Face4);
				face.a = changes[face.a];
				face.b = changes[face.b];
				face.c = changes[face.c];
				face.d = changes[face.d];
				
				indices = [ face.a, face.b, face.c, face.d ];
				var dupIndex = -1;
				
				var n = 0;
				while (n < 4)
				{
					if (indices[n] == indices[(n + 1) % 4])
					{
						if (dupIndex >= 0) faceIndicesToRemove.push(i);
						dupIndex = n;
					}
					n++;
				}
				
				if (dupIndex >= 0)
				{
					indices.splice(dupIndex, 1);
					var newFace = new Face3(indices[0], indices[1], indices[2], [face.normal], face.color, face.materialIndex);
					var j = 0, jl = faceVertexUvs.length;
					while (j < jl)
					{
						var u:Vector3 = faceVertexUvs[j][i];
						if (u != null) u.splice(dupIndex, 1);
						j++;
					}
					
					if (face.vertexNormals && face.vertexNormals.length > 0)
					{
						newFace.vertexNormals = face.vertexNormals;
						newFace.vertexNormals.splice(dupIndex, 1);
					}
					
					if (face.vertexColors && face.vertexColors.length > 0)
					{
						newFace.vertexColors = face.vertexColors;
						newFace.vertexColors.splice(dupIndex, 1);
					}
					
					faces[i] = newFace;
				}
			}
		}
		
		var i = faceIndicesToRemove.length - 1;
		while (i >= 0)
		{
			faces.splice(i, 1);
			var j = 0, jl = faceVertexUvs.length;
			while (j < jl)
			{
				faceVertexUvs[j].splice(i, 1);
				j++;
			}
			i--;
		}
		
		var diff = vertices.length - unique.length;
		vertices = unique;
		return diff;
		*/
	}
	
	
	public function clone () 
	{
		//todo - faceVertexUvs is not correct
		var geometry = new Geometry();
		
		var i = 0, l = vertices.length;
		while (i < l) geometry.vertices.push(vertices[i++].clone());
		
		i = 0; l = faces.length;
		while (i < l) geometry.faces.push(faces[i++].clone());
		
		/*
		var uvs:Array<Vector2> = faceVertexUvs[0];
		i = 0; l = uvs.length;
		while (i < l) 
		{
			var uv = uvs[i];
			var uvCopy = new Array<Vector2>();
			var j = 0, jl = uvs.length;
			while (j < jl)
			{
				uvCopy.push(new Vector2(uv[j].x, uv[j].y));
				j++;
			}
			
			geometry.faceVertexUvs[0].push(uvCopy);
			i++;
		}
		*/
		
		return geometry;
	}
	
	
	public function dispose ()
	{
	}
	
	
}
