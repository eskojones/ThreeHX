package three.renderers;

import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.Element;
import js.html.Image;
import js.html.ImageData;
import js.html.Uint8ClampedArray;
import three.cameras.Camera;
import three.core.Projector;
import three.core.RenderData;
import three.materials.Material;
import three.math.Box2;
import three.math.Box3;
import three.math.Color;
import three.math.Vector2;
import three.math.Vector3;
import three.math.Vector4;
import three.renderers.renderables.RenderableFace3;
import three.renderers.renderables.RenderableFace4;
import three.renderers.renderables.RenderableLine;
import three.renderers.renderables.RenderableParticle;
import three.renderers.renderables.RenderableVertex;
import three.scenes.Scene;
import three.THREE;

/**
 * ...
 * @author dcm
 */

class CanvasRenderer
{
	public var domElement:Element;
	
	private var canvasWidth:Float;
	private var canvasHeight:Float;
	private var canvasWidthHalf:Float;
	private var canvasHeightHalf:Float;
	
	public var devicePixelRatio:Float = 1.0;
	public var sortObjects:Bool = true;
	public var sortElements:Bool = true;
	
	private var canvas:CanvasElement;
	private var context:CanvasRenderingContext2D;
	
	private var projector:Projector;
	private var renderData:RenderData;
	
	public var autoClear:Bool = true;
	public var clearColor:Color;
	public var clearAlpha:Float = 0.0;
	
	private var contextGlobalAlpha:Float = 1.0;
	private var contextGlobalCompositeOperation:Int = 0;
	private var contextStrokeStyle:String;
	private var contextFillStyle:String;
	private var contextLineWidth:Float;
	private var contextLineCap:String;
	private var contextLineJoin:String;
	private var contextDashSize:String;
	private var contextGapSize:Float = 0.0;
	
	private var v1:RenderableVertex;
	private var v2:RenderableVertex;
	private var v3:RenderableVertex;
	private var v4:RenderableVertex;
	private var v5:RenderableVertex;
	private var v6:RenderableVertex;
	
	private var v1x:Float = 0.0;
	private var v2x:Float = 0.0;
	private var v3x:Float = 0.0;
	private var v4x:Float = 0.0;
	private var v5x:Float = 0.0;
	private var v6x:Float = 0.0;
	
	private var v1y:Float = 0.0;
	private var v2y:Float = 0.0;
	private var v3y:Float = 0.0;
	private var v4y:Float = 0.0;
	private var v5y:Float = 0.0;
	private var v6y:Float = 0.0;
	
	private var color:Color;
	private var color1:Color;
	private var color2:Color;
	private var color3:Color;
	private var color4:Color;
	
	private var diffuseColor:Color;
	private var emissiveColor:Color;
	
	private var lightColor:Color;
	
	private var patterns:Map<String,Dynamic>;
	private var imageDatas:Map<String,ImageData>;
	
	private var near:Float;
	private var far:Float;
	
	private var image:Image;
	private var uvs:Array<Dynamic>;
	
	private var uv1x:Float = 0.0;
	private var uv1y:Float = 0.0;
	
	private var uv2x:Float = 0.0;
	private var uv2y:Float = 0.0;
	
	private var uv3x:Float = 0.0;
	private var uv3y:Float = 0.0;
	
	private var clipBox:Box2;
	private var clearBox:Box2;
	private var elemBox:Box2;
	
	private var ambientLight:Color;
	private var directionalLights:Color;
	private var pointLights:Color;
	
	private var vector3:Vector3;
	
	private var pixelMap:CanvasElement;
	private var pixelMapContext:CanvasRenderingContext2D;
	private var pixelMapImage:ImageData;
	private var pixelMapData:Uint8ClampedArray;
	private var gradientMap:CanvasElement;
	private var gradientMapContext:CanvasRenderingContext2D;
	private var gradientMapQuality:Int = 16;
	
	public var info:Dynamic;

	public function new(parameters:Dynamic = null) 
	{
		projector = new Projector();
		canvas = Browser.document.createCanvasElement();
		context = canvas.getContext2d();
		
		clearColor = new Color(0x000000);
		
		v5 = new RenderableVertex();
		v6 = new RenderableVertex();
		
		color = new Color();
		color1 = new Color();
		color2 = new Color();
		color3 = new Color();
		color4 = new Color();
		
		diffuseColor = new Color();
		emissiveColor = new Color();
		
		lightColor = new Color();
		
		patterns = new Map<String,Dynamic>();
		imageDatas = new Map<String,ImageData>();
		
		clipBox = new Box2();
		clearBox = new Box2();
		elemBox = new Box2();
		
		ambientLight = new Color();
		directionalLights = new Color();
		pointLights = new Color();
		
		vector3 = new Vector3();
		
		pixelMap = Browser.document.createCanvasElement();
		pixelMap.width = pixelMap.height = 2;
		
		pixelMapContext = pixelMap.getContext2d();
		pixelMapContext.fillStyle = 'rgba(0,0,0,1)';
		pixelMapContext.fillRect(0, 0, 2, 2);
		
		pixelMapImage = pixelMapContext.getImageData(0, 0, 2, 2);
		pixelMapData = pixelMapImage.data;
		
		gradientMap = Browser.document.createCanvasElement();
		gradientMap.width = gradientMap.height = gradientMapQuality;
		
		gradientMapContext = gradientMap.getContext2d();
		gradientMapContext.translate( -gradientMapQuality / 2, -gradientMapQuality / 2);
		gradientMapContext.scale(gradientMapQuality, gradientMapQuality);
		
		gradientMapQuality--; //THREE: Fix UVs
		
		//todo - dash+gap fallbacks for Firefox etc were here, should we use reflection to emulate this?
		
		domElement = canvas;
		
		if (Reflect.hasField(parameters, 'devicePixelRatio') == true)
			devicePixelRatio = parameters.devicePixelRatio;
		else devicePixelRatio = Browser.window.devicePixelRatio;
		
		info = {
			render: {
				vertices: 0,
				faces: 0
			}
		};
		
	}
	
	
	//WebGLRenderer compatibility
	public function supportsVertexTextures () 
	{
	}
	public function setFaceCulling ()
	{
	}
	
	
	public function setSize (width:Float, height:Float, updateStyle:Bool = true)
	{
		canvasWidth = width * devicePixelRatio;
		canvasHeight = height * devicePixelRatio;
		
		canvasWidthHalf = Math.floor(canvasWidth / 2);
		canvasHeightHalf = Math.floor(canvasHeight / 2);
		
		if (devicePixelRatio != 1 && updateStyle != false)
		{
			canvas.style.width = width + 'px';
			canvas.style.height = height + 'px';
		}
		
		clipBox.set(
			new Vector2( -canvasWidthHalf, -canvasHeightHalf),
			new Vector2(canvasWidthHalf, canvasHeightHalf)
		);
		
		clearBox.set(
			new Vector2( -canvasWidthHalf, -canvasHeightHalf),
			new Vector2(canvasWidthHalf, canvasHeightHalf)
		);
		
		contextGlobalAlpha = 1;
		contextGlobalCompositeOperation = 0;
		contextStrokeStyle = null;
		contextFillStyle = null;
		contextLineWidth = null;
		contextLineCap = null;
		contextLineJoin = null;
	}
	
	
	public function setClearColor (color:Color, alpha:Float = null)
	{
		clearColor.set(color);
		clearAlpha = (alpha != null ? alpha : 1.0);
		
		clearBox.set(
			new Vector2( -canvasWidthHalf, -canvasHeightHalf),
			new Vector2(canvasWidthHalf, canvasHeightHalf)
		);
	}
	
	
	public function setClearColorHex (hex:Int, alpha:Float = null)
	{
		trace('CanvasRenderer.setClearColorHex is deprecated');
	}
	
	
	public function getMaxAnisotropy () : Int
	{
		return 0;
	}
	
	
	public function clear () : Void
	{
		context.setTransform(1, 0, 0, -1, canvasWidthHalf, canvasHeightHalf);
		
		if (clearBox.empty() == true) return;
		
		clearBox.intersect(clipBox);
		clearBox.expandByScalar(2);
		
		if (clearAlpha < 1)
		{
			context.clearRect(
				Math.round(clearBox.min.x) | 0,
				Math.round(clearBox.min.y) | 0,
				Math.round( clearBox.max.x - clearBox.min.x ) | 0,
				Math.round( clearBox.max.y - clearBox.min.y ) | 0
			);
		}
		
		if (clearAlpha > 0)
		{
			setBlending(THREE.NormalBlending);
			setOpacity(1);
			var r = Math.floor(clearColor.r * 255);
			var g = Math.floor(clearColor.r * 255);
			var b = Math.floor(clearColor.r * 255);
			setFillStyle('rgba($r,$g,$b,$clearAlpha)');
			
			context.fillRect(
				Math.round(clearBox.min.x) | 0,
				Math.round(clearBox.min.y) | 0,
				Math.round( clearBox.max.x - clearBox.min.x ) | 0,
				Math.round( clearBox.max.y - clearBox.min.y ) | 0
			);
		}
		
		clearBox.makeEmpty();
	}
	
	
	public function render (scene:Scene, camera:Camera) : Void
	{
		if (autoClear == true) clear();
		
		context.setTransform(1, 0, 0, -1, canvasWidthHalf, canvasHeightHalf);
		info.render.vertices = 0;
		info.render.faces = 0;
		
		renderData = projector.projectScene(scene, camera, sortObjects, sortElements);
		var elements = renderData.elements;
		var lights = renderData.lights;
		
		calculateLights();
		
		var e = 0, el = elements.length;
		while (e < el)
		{
			var element = elements[e++];
			var material:Material = element.material;
			if (material == null || material.visible == false) continue;
			
			elemBox.makeEmpty();
			if (Std.is(element, RenderableParticle) == true)
			{
				v1 = element;
				v1.x *= canvasWidthHalf;
				v1.y *= canvasHeightHalf;
				
				renderParticle(v1, element, material);
				
			} else if (Std.is(element, RenderableLine) == true)
			{
				v1 = element.v1;
				v2 = element.v2;
				
				v1.positionScreen.x *= canvasWidthHalf;
				v1.positionScreen.y *= canvasHeightHalf;
				
				v2.positionScreen.x *= canvasWidthHalf;
				v2.positionScreen.y *= canvasHeightHalf;
				
				elemBox.setFromPoints([
					v1.positionScreen, v2.positionScreen
				]);
				
				if (clipBox.isIntersectionBox(elemBox) == true)
				{
					renderLine(v1, v2, element, material);
				}
				
			} else if (Std.is(element, RenderableFace3) == true)
			{
				
			} else if (Std.is(element, RenderableFace4) == true)
			{
				
			}
			
			clearBox.union(elemBox);
			
			
		}
		
		context.setTransform(1, 0, 0, 1, 0, 0);
		
		
	}
	
	
}

