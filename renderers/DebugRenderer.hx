
package three.renderers;

import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import three.cameras.Camera;
import three.core.Projector;
import three.core.RenderData;
import three.lights.AmbientLight;
import three.materials.MeshFaceMaterial;
import three.math.Color;
import three.renderers.renderables.Renderable;
import three.renderers.renderables.RenderableFace4;
import three.scenes.Scene;
import three.THREE;

/**
 * ...
 * @author dcm
 */

class DebugRenderer
{

	public var canvas:CanvasElement;
	public var context:CanvasRenderingContext2D;
	public var projector:Projector;
	public var renderData:RenderData;
	
	public var canvasWidth:Float;
	public var canvasHeight:Float;
	public var canvasWidthHalf:Float;
	public var canvasHeightHalf:Float;
	
	public var clearColor:Color;
	public var clearAlpha:Float = 1.0;
	
	public function new(width:Float = 800, height:Float = 600) 
	{
		projector = new Projector();
		canvas = Browser.document.createCanvasElement();
		setSize(width, height);
		context = canvas.getContext2d();
		Browser.document.body.appendChild(canvas);
		clearColor = new Color(0x000000);
		clearAlpha = 1.0;
		context.imageSmoothingEnabled = false;
	}
	
	
	public function setSize (width:Float, height:Float)
	{
		canvas.style.width = width + 'px';
		canvas.style.height = height + 'px';
		canvas.width = Math.round(width);
		canvas.height = Math.round(height);
		canvasWidth = width;
		canvasHeight = height;
		canvasWidthHalf = width / 2;
		canvasHeightHalf = height / 2;
	}
	
	
	public function clear ()
	{
		context.setTransform(1, 0, 0, 1, 0, 0);
		context.setFillColor(Math.round(clearColor.r * 255), Math.round(clearColor.g * 255), Math.round(clearColor.b * 255), clearAlpha);
		context.fillRect(0, 0, canvasWidth, canvasHeight);
	}
	
	
	public function render (scene:Scene, camera:Camera)
	{
		clear();
		context.setTransform(1, 0, 0, -1, canvasWidthHalf, canvasHeightHalf);
		renderData = projector.projectScene(scene, camera, true, true);
		
		var e = 0, el = renderData.elements.length;
		while (e < el)
		{
			var element:Renderable = renderData.elements[e++];
			if (element.type == THREE.RenderableFace4) 
			{
				var element:RenderableFace4 = cast(element, RenderableFace4);
				var v1 = element.v1, v2 = element.v2, v3 = element.v3, v4 = element.v4;
				if (v1.positionScreen.z < -1 || v1.positionScreen.z > 1) continue;
				if (v2.positionScreen.z < -1 || v2.positionScreen.z > 1) continue;
				if (v3.positionScreen.z < -1 || v3.positionScreen.z > 1) continue;
				if (v4.positionScreen.z < -1 || v4.positionScreen.z > 1) continue;
				renderFace4(element);
			}
		}
		
		context.setTransform(1, 0, 0, 1, 0, 0);
	}
	
	
	inline public function renderFace4 (element:RenderableFace4)
	{
		var x1 = element.v1.positionScreen.x * canvasWidthHalf;
		var y1 = element.v1.positionScreen.y * canvasHeightHalf;
		var x2 = element.v2.positionScreen.x * canvasWidthHalf;
		var y2 = element.v2.positionScreen.y * canvasHeightHalf;
		var x3 = element.v3.positionScreen.x * canvasWidthHalf;
		var y3 = element.v3.positionScreen.y * canvasHeightHalf;
		var x4 = element.v4.positionScreen.x * canvasWidthHalf;
		var y4 = element.v4.positionScreen.y * canvasHeightHalf;
		
		var material = element.material;
		if (Std.is(material, MeshFaceMaterial) == true) material = cast(material, MeshFaceMaterial).materials[0];
		var c = material.color.clone();
		var r = Math.round(material.color.r * 255);
		var g = Math.round(material.color.g * 255);
		var b = Math.round(material.color.b * 255);
		context.globalAlpha = material.opacity;
		//if (material.blending == THREE.NormalBlending) context.globalCompositeOperation = 'source-over';
		//else if (material.blending == THREE.AdditiveBlending) context.globalCompositeOperation = 'lighter';
		//else if (material.blending == THREE.SubtractiveBlending) context.globalCompositeOperation = 'darker';

		if (element.material.wireframe == true)
		{
			context.beginPath();
			context.moveTo(x1, y1);
			context.lineTo(x2, y2);
			context.lineTo(x3, y3);
			context.lineTo(x4, y4);
			context.closePath();
			context.strokeStyle = 'rgb($r,$g,$b)';
			context.stroke();
		} else {
			
			var x5 = element.v2.positionScreen.x * canvasWidthHalf;
			var y5 = element.v2.positionScreen.y * canvasHeightHalf;
			var x6 = element.v4.positionScreen.x * canvasWidthHalf;
			var y6 = element.v4.positionScreen.y * canvasHeightHalf;
			/*
			context.beginPath();
			context.moveTo(x1, y1);
			context.lineTo(x2, y2);
			context.lineTo(x4, y4);
			context.lineTo(x5, y5);
			context.lineTo(x3, y3);
			context.lineTo(x6, y6);
			context.closePath();
			*/
			context.beginPath();
			context.moveTo(x1, y1);
			context.lineTo(x2, y2);
			context.lineTo(x3, y3);
			context.lineTo(x4, y4);
			context.closePath();
			context.fillStyle = 'rgb($r,$g,$b)';
			context.fill();
		}
		
	}
	
	
}