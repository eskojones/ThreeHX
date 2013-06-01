
package three.renderers;

import haxe.ds.Vector;
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
import three.lights.Light;
import three.materials.Material;
import three.math.Box2;
import three.math.Box3;
import three.math.Color;
import three.math.Vector2;
import three.math.Vector3;
import three.math.Vector4;
import three.renderers.renderables.Renderable;
import three.renderers.renderables.RenderableFace3;
import three.renderers.renderables.RenderableFace4;
import three.renderers.renderables.RenderableLine;
import three.renderers.renderables.RenderableParticle;
import three.renderers.renderables.RenderableVertex;
import three.scenes.Scene;
import three.textures.Texture;
import three.THREE;

/**
 * 
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
	public var clearAlpha:Float = 1.0;
	
	private var contextGlobalAlpha:Float = 1.0;
	private var contextGlobalCompositeOperation:Int = 0;
	private var contextStrokeStyle:String;
	private var contextFillStyle:String;
	private var contextLineWidth:Float = 1.0;
	private var contextLineCap:String;
	private var contextLineJoin:String;
	private var contextDashSize:Float = 0.0;
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
		if (parameters == null) parameters = { };
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
	
	
	//WebGLRenderer compatibility (not needed anymore i guess ;))
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
			var element:Renderable = elements[e++];
			var material:Material = element.material;
			if (material == null || material.visible == false) continue;
			
			elemBox.makeEmpty();

			if (element.type == THREE.RenderableParticle)
			{
				var element:RenderableParticle = cast(element, RenderableParticle);
				element.x *= canvasWidthHalf;
				element.y *= canvasHeightHalf;
				
				renderParticle(element, element, material);
				
			} else if (element.type == THREE.RenderableLine)
			{
				var element:RenderableLine = cast(element, RenderableLine);
				v1 = element.v1;
				v2 = element.v2;
				
				v1.positionScreen.x *= canvasWidthHalf;
				v1.positionScreen.y *= canvasHeightHalf;
				
				v2.positionScreen.x *= canvasWidthHalf;
				v2.positionScreen.y *= canvasHeightHalf;
				
				var vec2_1 = new Vector2(v1.positionScreen.x, v1.positionScreen.y);
				var vec2_2 = new Vector2(v2.positionScreen.x, v2.positionScreen.y);
				
				elemBox.setFromPoints([ vec2_1, vec2_2 ]);
				
				if (clipBox.isIntersectionBox(elemBox) == true)
				{
					renderLine(v1, v2, element, material);
				}
				
			} else if (element.type == THREE.RenderableFace3)
			{
				var element:RenderableFace3 = cast(element, RenderableFace3);
				v1 = element.v1; v2 = element.v2; v3 = element.v3;
				
				if (v1.positionScreen.z < -1 || v1.positionScreen.z > 1) continue;
				if (v2.positionScreen.z < -1 || v2.positionScreen.z > 1) continue;
				if (v3.positionScreen.z < -1 || v3.positionScreen.z > 1) continue;
				
				v1.positionScreen.x *= canvasWidthHalf; v1.positionScreen.y *= canvasHeightHalf;
				v2.positionScreen.x *= canvasWidthHalf; v2.positionScreen.y *= canvasHeightHalf;
				v3.positionScreen.x *= canvasWidthHalf; v3.positionScreen.y *= canvasHeightHalf;
				
				if (material.overdraw == true)
				{
					expand(v1.positionScreen, v2.positionScreen);
					expand(v2.positionScreen, v3.positionScreen);
					expand(v3.positionScreen, v1.positionScreen);
				}
				
				var vec2_1 = new Vector2(v1.positionScreen.x, v1.positionScreen.y);
				var vec2_2 = new Vector2(v1.positionScreen.x, v1.positionScreen.y);
				var vec2_3 = new Vector2(v1.positionScreen.x, v1.positionScreen.y);
				
				elemBox.setFromPoints([ vec2_1, vec2_2, vec2_3 ]);
				
				if (clipBox.isIntersectionBox(elemBox) == true)
				{
					renderFace3(v1, v2, v3, 0, 1, 2, element, material);
				}
				
			} else if (element.type == THREE.RenderableFace4)
			{
				var element:RenderableFace4 = cast(element, RenderableFace4);
				v1 = element.v1; v2 = element.v2; v3 = element.v3; v4 = element.v4;
				
				if (v1.positionScreen.z < -1 || v1.positionScreen.z > 1) continue;
				if (v2.positionScreen.z < -1 || v2.positionScreen.z > 1) continue;
				if (v3.positionScreen.z < -1 || v3.positionScreen.z > 1) continue;
				if (v4.positionScreen.z < -1 || v4.positionScreen.z > 1) continue;
				
				v1.positionScreen.x *= canvasWidthHalf; v1.positionScreen.y *= canvasHeightHalf;
				v2.positionScreen.x *= canvasWidthHalf; v2.positionScreen.y *= canvasHeightHalf;
				v3.positionScreen.x *= canvasWidthHalf; v3.positionScreen.y *= canvasHeightHalf;
				v4.positionScreen.x *= canvasWidthHalf; v4.positionScreen.y *= canvasHeightHalf;
				
				v5.positionScreen.copy(v2.positionScreen);
				v6.positionScreen.copy(v4.positionScreen);
				
				if (material.overdraw == true)
				{
					expand(v1.positionScreen, v2.positionScreen);
					expand(v2.positionScreen, v4.positionScreen);
					expand(v4.positionScreen, v1.positionScreen);
					
					expand(v3.positionScreen, v5.positionScreen);
					expand(v3.positionScreen, v6.positionScreen);
				}
				
				var vec2_1 = new Vector2(v1.positionScreen.x, v1.positionScreen.y);
				var vec2_2 = new Vector2(v2.positionScreen.x, v2.positionScreen.y);
				var vec2_3 = new Vector2(v3.positionScreen.x, v3.positionScreen.y);
				var vec2_4 = new Vector2(v4.positionScreen.x, v4.positionScreen.y);
				
				elemBox.setFromPoints([ vec2_1, vec2_2, vec2_3, vec2_4 ]);
				
				if (clipBox.isIntersectionBox(elemBox) == true)
				{
					renderFace4(v1, v2, v3, v4, v5, v6, element, material);
				}
			}
			
			clearBox.union(elemBox);
			
			
		}
		
		context.setTransform(1, 0, 0, 1, 0, 0);
		
		
	}
	
	
	inline private function calculateLights () 
	{
		ambientLight.setRGB(0, 0, 0);
		directionalLights.setRGB(0, 0, 0);
		pointLights.setRGB(0, 0, 0);
		
		var lights = renderData.lights;
		
		var l = 0, ll = lights.length;
		while (l < ll)
		{
			var light = lights[l++];
			lightColor.copy(light.color);
			//todo - lights :)
			/*
			if (Std.is(light, AmbientLight) == true)
			{
				ambientLight.add(lightColor);
			} else if (Std.is(light, DirectionalLight) == true)
			{
				directionalLights.add(lightColor);
			} else if (Std.is(light, PointLight) == true)
			{
				pointLights.add(lightColor);
			}
			*/
		}
		
	}
	
	
	inline private function calculateLight (position:Vector3, normal:Vector3, color:Color)
	{
		var lights = renderData.lights;
		var l = 0, ll = lights.length;
		while (l < ll)
		{
			var light = lights[l++];
			lightColor.copy(light.color);
			/*
			if (Std.is(light, DirectionalLight) == true)
			{
				light = cast(light, DirectionalLight);
				var lightPosition = vector3.getPositionFromMatrix(light.matrixWorld).normalize();
				var amount = normal.dot(lightPosition);
				if (amount <= 0) continue;
				amount *= light.intensity;
				color.add(lightColor.multiplyScalar(amount));
				
			} else if (Std.is(light, PointLight) == true)
			{
				light = cast(light, PointLight);
				var lightPosition = vector3.getPositionFromMatrix(light.matrixWorld);
				var amount = normal.dot(vector3.subVectors(lightPosition, position).normalize());
				if (amount <= 0) continue;
				amount *= light.intensity;
				color.add(lightColor.multiplyScalar(amount));
				
			}
			*/
		}
	}
	
	
	inline private function renderParticle (v1:RenderableParticle, element:Renderable, material:Material)
	{
		setOpacity(material.opacity);
		setBlending(material.blending);
		
		var width:Float, height:Float, scaleX:Float, scaleY:Float;
		//todo - Materials
		/*
		if (Std.is(material, ParticleBasicMaterial) == true)
		{
			
		} else if (Std.is(material, ParticleCanvasMaterial) == true)
		{
			
		}
		*/
	}
	
	
	inline private function renderLine (v1:RenderableVertex, v2:RenderableVertex, element:Renderable, material:Material)
	{
		setOpacity(material.opacity);
		setBlending(material.blending);
		
		context.beginPath();
		context.moveTo(v1.positionScreen.x, v1.positionScreen.y);
		context.lineTo(v2.positionScreen.x, v2.positionScreen.y);
		//todo - Material types :)
		/*
		if (Std.is(material, LineBasicMaterial) == true)
		{
			setLineWidth(material.linewidth);
			setLineCap(material.linecap);
			setLineJoin(material.linejoin);
			
			if (material.vertexColors != THREE.VertexColors)
			{
				setStrokeStyle(material.color.getStyle());
			} else {
				//todo - else block at line 623 
			}
			
			context.stroke();
			elemBox.expandByScalar(material.linewidth * 2);
		} else if (Std.is(material, LineDashedMaterial) == true)
		{
			setLineWidth(material.linewidth);
			setLineCap(material.linecap);
			setLineJoin(material.linejoin);
			setStrokeStyle(material.color.getStyle());
			setDashAndGap(material.dashSize, material.gapSize);
			
			context.stroke();
			elemBox.expandByScalar(material.linewidth * 2);
			setDashAndGap(null, null);
		}
		*/
		
	}
	
	
	inline private function renderFace3 (v1:RenderableVertex, v2:RenderableVertex, v3:RenderableVertex, uv1:Int, uv2:Int, uv3:Int, element:Renderable, material:Material)
	{
		info.render.vertices += 3;
		info.render.faces++;
		
		setOpacity(material.opacity);
		setBlending(material.blending);
		
		v1x = v1.positionScreen.x; v1y = v1.positionScreen.y;
		v2x = v2.positionScreen.x; v2y = v2.positionScreen.y;
		v3x = v3.positionScreen.x; v3y = v3.positionScreen.y;
		
		drawTriangle(v1x, v1y, v2x, v2y, v3x, v3y);
		/*
		if ((Std.is(material, MeshLambertMaterial) == true 
		  || Std.is(material, MeshPhongMaterial) == true) 
		  && material.map == null)
		{
			diffuseColor.copy(material.color);
			emissiveColor.copy(material.emissive);
			if (material.vertexColors == THREE.FaceColors) diffuseColor.multiply(element.color);
			
			if (material.wireframe == false 
			 && material.shading == THREE.SmoothShading 
			 && element.vertexNormalsLength == 3)
			{
				color1.copy(ambientLight);
				color2.copy(ambientLight);
				color3.copy(ambientLight);
				
				calculateLight(element.v1.positionWorld, element.vertexNormalsModel[0], color1);
				calculateLight(element.v2.positionWorld, element.vertexNormalsModel[1], color2);
				calculateLight(element.v3.positionWorld, element.vertexNormalsModel[2], color3);
				
				color1.multiply(diffuseColor).add(emissiveColor);
				color2.multiply(diffuseColor).add(emissiveColor);
				color3.multiply(diffuseColor).add(emissiveColor);
				color4.addColors(color2, color3).multiplyScalar(0.5);
				
				image = getGradientTexture(color1, color2, color3, color4);
				
				clipImage(v1x, v1y, v2x, v2y, v3x, v3y, 0, 0, 1, 0, 0, 1, image);
			} else {
				color.copy(ambientLight);
				calculateLight(element.centroidModel, element.normalModel, color);
				color.multiply(diffuseColor).add(emissiveColor);
				if (material.wireframe == true) 
				{
					strokePath(color, material.wireframeLinewidth, material.wireframeLinecap, material.wireframeLinejoin);
				} else {
					fillPath(color);
				}
			}
		} else if (Std.is(material, MeshBasicMaterial) == true 
				|| Std.is(material, MeshLambertMaterial) == true 
				|| Std.is(material, MeshPhongMaterial) == true)
		{
			if (material.map != null)
			{
				if (Std.is(material.map.mapping, UVMapping) == true)
				{
					uvs = element.uvs[0];
					patternPath(v1x, v1y, v2x, v2y, v3x, v3y, 
								uvs[uv1].x, uvs[uv1].y, uvs[uv2].x, uvs[uv2].y, 
								uvs[uv3].x, uvs[uv3].y, material.map);
				}
			} else if (material.envMap != null)
			{
				//todo - elseif block at line 739
			} else {
				//todo - else block at line 764
			}
		} else if (Std.is(material, MeshDepthMaterial) == true)
		{
			//todo - MeshDepthMaterial
		} else if (Std.is(material, MeshNormalMaterial) == true)
		{
			//todo - MeshNormalMaterial
		}
		*/
	}
	
	
	inline private function renderFace4 (
		v1:RenderableVertex, v2:RenderableVertex, v3:RenderableVertex, 
		v4:RenderableVertex, v5:RenderableVertex, v6:RenderableVertex, 
		element:Renderable, material:Material)
	{
		//todo
	}
	
	
	inline private function drawTriangle (x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float)
	{
		context.beginPath();
		context.moveTo(x0, y0);
		context.lineTo(x1, y1);
		context.lineTo(x2, y2);
		context.closePath();
	}
	
	
	inline private function drawQuad (x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float, x3:Float, y3:Float)
	{
		context.beginPath();
		context.moveTo(x0, y0);
		context.lineTo(x1, y1);
		context.lineTo(x2, y2);
		context.lineTo(x3, y3);
		context.closePath();
	}
	
	
	inline private function strokePath (color:Color, linewidth:Float, linecap:String, linejoin:String)
	{
		setLineWidth(linewidth);
		setLineCap(linecap);
		setLineJoin(linejoin);
		setStrokeStyle(color.getStyle());
		
		context.stroke();
		elemBox.expandByScalar(linewidth * 2);
	}
	
	
	inline private function fillPath (color:Color)
	{
		setFillStyle(color.getStyle());
		context.fill();
	}
	
	
	inline private function patternPath (x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float, u0:Float, v0:Float, u1:Float, v1:Float, u2:Float, v2:Float, texture:Texture)
	{
		//todo
	}
	
	
	inline private function clipImage (x0:Float, y0:Float, x1:Float, y1:Float, x2:Float, y2:Float, u0:Float, v0:Float, u1:Float, v1:Float, u2:Float, v2:Float, image:Image)
	{
		//todo
	}
	
	
	inline private function getGradientTexture (color1:Color, color2:Color, color3:Color, color4:Color) : CanvasElement
	{
		pixelMapData[0] = Math.round( color1.r * 255 ) | 0;
		pixelMapData[1] = Math.round( color1.g * 255 ) | 0;
		pixelMapData[2] = Math.round( color1.b * 255 ) | 0;
		
		pixelMapData[4] = Math.round( color2.r * 255 ) | 0;
		pixelMapData[5] = Math.round( color2.g * 255 ) | 0;
		pixelMapData[6] = Math.round( color2.b * 255 ) | 0;
		
		pixelMapData[8] = Math.round( color3.r * 255 ) | 0;
		pixelMapData[9] = Math.round( color3.g * 255 ) | 0;
		pixelMapData[10] = Math.round( color3.b * 255 ) | 0;
		
		pixelMapData[12] = Math.round( color4.r * 255 ) | 0;
		pixelMapData[13] = Math.round( color4.g * 255 ) | 0;
		pixelMapData[14] = Math.round( color4.b * 255 ) | 0;
		
		pixelMapContext.putImageData(pixelMapImage, 0, 0);
		gradientMapContext.drawImage(pixelMap, 0, 0);
		
		return gradientMap;
	}
	
	
	inline private function expand (v1:Vector4, v2:Vector4)
	{
		var x = v2.x - v1.x, y = v2.y - v1.y;
		var det = x * x + y * y;
		
		if (det != 0)
		{
			var idet = 1 / Math.sqrt(det);
		
			x *= idet; y *= idet;
		
			v2.x += x; v2.y += y;
			v1.x -= x; v1.y -= y;
		}
	}
	
	
	inline private function setOpacity (value:Float)
	{
		if (contextGlobalAlpha != value)
		{
			context.globalAlpha = value;
			contextGlobalAlpha = value;
		}
	}
	
	
	inline private function setBlending (value:Int)
	{
		if (contextGlobalCompositeOperation != value)
		{
			if (value == THREE.NormalBlending) context.globalCompositeOperation = 'source-over';
			else if (value == THREE.AdditiveBlending) context.globalCompositeOperation = 'lighter';
			else if (value == THREE.SubtractiveBlending) context.globalCompositeOperation = 'darker';
			contextGlobalCompositeOperation = value;
		}
	}
	
	
	inline private function setLineWidth (value:Float)
	{
		if (contextLineWidth != value) 
		{
			context.lineWidth = value;
			contextLineWidth = value;
		}
	}
	
	
	inline private function setLineCap (value:String)
	{
		if (contextLineCap != value)
		{
			context.lineCap = value;
			contextLineCap = value;
		}
	}
	
	
	inline private function setLineJoin (value:String) 
	{
		if (contextLineJoin != value)
		{
			context.lineJoin = value;
			contextLineJoin = value;
		}
	}
	
	
	inline private function setStrokeStyle (value:String)
	{
		if (contextStrokeStyle != value)
		{
			context.strokeStyle = value;
			contextStrokeStyle = value;
		}
	}
	
	
	inline private function setFillStyle (value:String) 
	{
		if (contextFillStyle != value)
		{
			context.fillStyle = value;
			contextFillStyle = value;
		}
	}
	
	
	inline private function setDashAndGap (dashSizeValue:Float, gapSizeValue:Float)
	{
		if (contextDashSize != dashSizeValue || contextGapSize != gapSizeValue)
		{
			context.setLineDash([ dashSizeValue, gapSizeValue ]);
			contextDashSize = dashSizeValue;
			contextGapSize = gapSizeValue;
		}
	}
}

