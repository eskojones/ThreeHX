
package three.core;
import haxe.rtti.Generic;
import three.math.Color;
import three.math.Vector3;

/**
 * ...
 * @author dcm
 */


class Face3 implements Generic
{
	public var a:Int;
	public var b:Int;
	public var c:Int;
	public var normal:Vector3;
	public var vertexNormals:Array<Vector3>;
	
	public var color:Color;
	public var vertexColors:Array<Color>;
	
	public var vertexTangents:Array<Vector3>;
	
	public var materialIndex:Int;
	
	public var centroid:Vector3;
	

	public function new(a:Int, b:Int, c:Int, ?normals:Array<Vector3>, ?colors:Array<Color>, materialIndex:Int = 0) 
	{
		this.a = a;
		this.b = b;
		this.c = c;
		
		if (normals != null && normals.length > 0) 
		{
			normal = normals[0];
			vertexNormals = normals;
		} else {
			normal = new Vector3();
			vertexNormals = new Array<Vector3>();
		}
		
		if (colors != null && colors.length > 0)
		{
			color = colors[0];
			vertexColors = colors;
		} else {
			color = new Color();
			vertexColors = new Array<Color>();
		}
		
		vertexTangents = new Array<Vector3>();
		this.materialIndex = materialIndex;
		centroid = new Vector3();
	}
	
	
	public function clone () : Face3
	{
		var face = new Face3(a, b, c);
		face.normal.copy(normal);
		face.color.copy(color);
		face.centroid.copy(centroid);
		face.materialIndex = materialIndex;
		
		var i = 0, l = vertexColors.length;
		while (i < l) face.vertexColors.push(vertexColors[i++].clone());
		
		i = 0; l = vertexNormals.length;
		while (i < l) face.vertexNormals.push(vertexNormals[i++].clone());
		
		i = 0; l = vertexTangents.length;
		while (i < l) face.vertexTangents.push(vertexTangents[i++].clone());
		
		return face;
	}
	
	
}

