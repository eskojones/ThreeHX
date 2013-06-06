
package three.materials;

import three.math.Color;
import three.math.Vector3;
import three.THREE;

/**
 * 
 * @author dcm
 */

class Material
{
	public var id:Int;
	public var name:String;
	public var side:Int;
	
	public var color:Color; //moved here from most other Materials
	
	public var opacity:Float = 1.0;
	public var transparent:Bool = false;
	
	public var blending:Int;
	public var blendSrc:Int;
	public var blendDst:Int;
	public var blendEquation:Int;
	
	public var depthTest:Bool = true;
	public var depthWrite:Bool = true;
	
	public var polygonOffset:Bool = false;
	public var polygonOffsetFactor:Float = 0.0;
	public var polygonOffsetUnits:Float = 0.0;
	
	public var alphaTest:Float = 0.0;
	
	public var overdraw:Bool = false; //THREE: for fixing antialiasing gaps in CanvasRenderer
	
	//wireframe settings moved to the superclass because they (almost) all use it at some point
	public var wireframe:Bool = false;
	public var wireframeLineWidth:Float = 1.0;
	public var wireframeLinecap:String = 'round';
	public var wireframeLinejoin:String = 'round';
	
	public var visible:Bool = true;
	public var needsUpdate:Bool = true;

	
	public function new() 
	{
		side = THREE.FrontSide;
		blending = THREE.NormalBlending;
		blendSrc = THREE.SrcAlphaFactor;
		blendDst = THREE.OneMinusSrcAlphaFactor;
		blendEquation = THREE.AddEquation;
		
		color = new Color(Math.round(Math.random() * 0xffffff));
	}
	
	
	public function setValues (values:Dynamic = null) : Void
	{
		if (values == null) return;
		var fields = Reflect.fields(values);
		
		var i = 0, l = fields.length;
		while (i < l)
		{
			var fieldName = fields[i++];
			if (Reflect.hasField(this, fieldName) == false) continue;
			
			var fieldValue = Reflect.getProperty(values, fieldName);
			var ourValue = Reflect.getProperty(this, fieldName);
			
			if (Std.is(ourValue, Color) == true) 
			{
				cast(ourValue, Color).set(fieldValue);
				
			} else if (Std.is(ourValue, Vector3) == true && Std.is(fieldValue, Vector3) == true)
			{
				cast(ourValue, Vector3).copy(fieldValue);
				
			} else {
				ourValue = fieldValue;
			}
		}
	}
	
	
	public function clone (material:Material = null)
	{
		if (material == null) material = new Material();
		material.name = name;
		material.side = side;
		material.color.copy(color);
		material.opacity = opacity;
		material.transparent = transparent;
		material.blending = blending;
		material.blendSrc = blendSrc;
		material.blendDst = blendDst;
		material.blendEquation = blendEquation;
		material.depthTest = depthTest;
		material.depthWrite = depthWrite;
		material.polygonOffset = polygonOffset;
		material.polygonOffsetFactor = polygonOffsetFactor;
		material.polygonOffsetUnits = polygonOffsetUnits;
		material.alphaTest = alphaTest;
		material.overdraw = overdraw;
		material.visible = visible;
		material.wireframe = wireframe;
		material.wireframeLineWidth = wireframeLineWidth;
		material.wireframeLinecap = wireframeLinecap;
		material.wireframeLinejoin = wireframeLinejoin;
		return material;
	}
	
	
	public function dispose () 
	{
	}
	
	
}