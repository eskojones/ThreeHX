
package three.core;

import three.math.Box3;
import three.math.Color;
import three.math.Matrix3;
import three.math.Matrix4;
import three.math.Sphere;
import three.math.Vector3;

/**
 * ...
 * @author dcm
 */

class Geometry
{
	public var id:Int;
	public var name:String;
	public var vertices:Array<Vector3>;
	public var colors:Array<Color>;
	public var normals:Array<Vector3>;
	
	public var faces:Array<Face4>;
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
		faces = new Array<Face4>();
		faceUvs = new Array<Dynamic>(); //NOTE: only temporary v3, change to v2 when its done
		faceVertexUvs = new Array<Dynamic>();
		faceVertexUvs.push(new Array<Dynamic>());
		
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
			
			var j = 0, jl = face.vertexNormals.length;
			while (j < jl)
			{
				face.vertexNormals[j++].applyMatrix3(normalMatrix).normalize();
			}
			i++;
		}
	}
	
	
	public function computeCentroids ()
	{
		var f = 0, fl = faces.length, face:Face4;
		while (f < fl)
		{
			face = faces[f++];
			face.centroid.set(0, 0, 0);
			
			if (Std.is(face, Face3) == true)
			{
				face.centroid.add(vertices[face.a]);
				face.centroid.add(vertices[face.b]);
				face.centroid.add(vertices[face.c]);
				face.centroid.divideScalar(3);
			} else 
			{
				face.centroid.add(vertices[face.a]);
				face.centroid.add(vertices[face.b]);
				face.centroid.add(vertices[face.c]);
				face.centroid.add(vertices[face.d]);
				face.centroid.divideScalar(4);
			}
		}
	}
	
	
	public function computeFaceNormals ()
	{
		var cb = new Vector3(), ab = new Vector3();
		
		var f = 0, fl = faces.length, face:Face4;
		while (f < fl)
		{
			face = faces[f++];
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
		//todo - ...
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
		var uvs = faceVertexUvs[0];
		i = 0; l = uvs.length;
		while (i < l) 
		{
			var uv = uvs[i];
			var uvCopy = new Array<Vector3>();
			var j = 0, jl = uv.length;
			while (j < jl)
			{
				uvCopy.push(new Vector3(uv[j].x, uv[j].y, 0)); //NOTE: should be v2 not v3
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
		trace('Geometry.dispose: how does i can clean up after myself?');
	}
	
	
}
