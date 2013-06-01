
package three.core;
import haxe.rtti.Generic;
import three.math.Color;
import three.math.Vector3;

/**
 * ...
 * @author dcm
 */

class Face4 extends Face3
{
	public var d:Int;
	
	
	public function new(a:Int, b:Int, c:Int, d:Int, ?normals:Array<Vector3>, ?colors:Array<Color>, materialIndex:Int = 0) 
	{
		super(a, b, c, normals, colors, materialIndex);
		this.d = d;
	}
	
	
	override public function clone () : Face4
	{
		var face = new Face4(a, b, c, d);
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