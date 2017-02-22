package three.renderers;

import haxe.ds.StringMap;
import js.Browser;
import js.html.CanvasElement;
import js.html.Float32Array;
import js.html.Image;
import js.html.ImageElement;
import js.html.webgl.GL;
import js.html.webgl.RenderingContext;
import three.cameras.Camera;
import three.cameras.OrthographicCamera;
import three.cameras.PerspectiveCamera;
import three.core.Face4;
import three.core.Geometry;
import three.core.Object3D;
import three.lights.AmbientLight;
import three.lights.Light;
import three.lights.PointLight;
import three.materials.Material;
import three.materials.MeshBasicMaterial;
import three.math.Color;
import three.math.Frustum;
import three.math.Matrix3;
import three.math.Matrix4;
import three.math.Sphere;
import three.objects.Mesh;
import three.scenes.Scene;
import three.textures.Texture;
import three.THREE;

/**
 * ...
 * @author dcm
 */

class ShaderVariable
{
	public var type:String;
	public var name:String;
	public var value:Dynamic = null;
	public var output:Dynamic = null;
	public var index:Dynamic;
	public var dirty:Bool = false;
	
	public function new (type:String, name:String)
	{
		this.type = type;
		this.name = name;
	}
}


class ShaderObject
{
	public var vertexShader:String;
	public var fragmentShader:String;
	public var uniforms:Array<ShaderVariable>;
	public var attributes:Array<ShaderVariable>;
	public var uniform:Map<String,ShaderVariable>;
	public var attribute:Map<String,ShaderVariable>;
	public var dirtyUniforms:Bool = false;
	public var dirtyAttributes:Bool = false;
	public var program:Dynamic;
	public var vsCompiled:Dynamic;
	public var fsCompiled:Dynamic;
	
	public function new ()
	{
		uniforms = new Array<ShaderVariable>();
		attributes = new Array<ShaderVariable>();
		uniform = new Map<String,ShaderVariable>();
		attribute = new Map<String,ShaderVariable>();
	}
	
}


class WebGLRenderer
{
	public var canvas:CanvasElement;
	public var _gl:RenderingContext;
	
	public var geometryRefs:Map<Geometry,Dynamic>;
	public var textureRefs:Map<Texture,Dynamic>;
	
	public var renderData:Dynamic;
	public var pointLightMax:Int = 50;
	public var pointLightSort:Bool = true;
	
	public var fullSize:Bool = true;
	public var canvasWidth:Float = 800;
	public var canvasHeight:Float = 600;
	public var canvasWidthHalf:Float;
	public var canvasHeightHalf:Float;
	
	public var autoClear:Bool = true;
	public var clearColor:Color;
	public var clearAlpha:Float = 1.0;
	
	public var shaders:Map < String, ShaderObject > ;
	public var currentShader:String;
	
	public var viewProjectionMatrix:Matrix4;
	public var viewMatrix:Matrix4;
	public var normalMatrix:Matrix3;
	
	public var frustum:Frustum;
	public var currentCamera:Camera;
	public var currentScene:Scene;
	
	public var textureCount:Int = 0;
	
	public var blendingMode:Int = -1;

	public function new(parameters:Dynamic = null) 
	{
		//projector = new Projector();
		
		canvas = Browser.document.createCanvasElement();
		_gl = canvas.getContextWebGL();
		Browser.document.body.appendChild(canvas);
		
		clearColor = new Color(0x000000);
		clearAlpha = 1.0;
		
		if (parameters == null) parameters = { };
		var paramNames = Reflect.fields(parameters);
		var i = 0, paramCount = paramNames.length;
		while (i < paramCount)
		{
			if (Reflect.hasField(this, paramNames[i]) == false) continue;
			var value = Reflect.field(parameters, paramNames[i]);
			if (paramNames[i] == 'clearColor') clearColor.set(value);
			else Reflect.setField(this, paramNames[i], value);
			i++;
		}
		
		shaders = new Map <String, ShaderObject>();
		
		var defaultShader = new ShaderObject();
		
		defaultShader.fragmentShader = [
				'precision highp float;',
				//'uniform sampler2D uSampler;',
				
				'varying vec4 vColor;',
				'varying vec3 vLighting;',
				//'varying vec2 vTextureCoord;',
				//'varying float vUseTexture;',
				
				'void main (void) {',
				//'	if (vUseTexture == 1.0) {',
				//'		gl_FragColor = texture2D(uSampler, vTextureCoord) * vec4(vLighting, 1.0);',
				//'	} else {',
				'		gl_FragColor = vec4(vColor.rgb * vLighting, vColor.a);',
				//'	}',
				'}'
		].join('\n');
		
		defaultShader.vertexShader = [
			'attribute vec3 aVertexPosition;',
			'attribute vec3 aVertexNormal;',
			//'attribute vec2 aTextureCoord;',
			
			'uniform mat4 viewProjectionMatrix;',
			'uniform mat4 viewMatrix;',
			'uniform mat4 worldMatrix;',
			'uniform mat3 normalMatrix;',
			
			//'uniform float useTexture;',
			'uniform vec4 vertexColor;',
			
			'uniform vec4 ambientLight;',
			
			'struct PointLight {',
			'	vec4 position;', //w is Distance
			'	vec4 color;', //a is Intensity
			'};',
			
			'uniform PointLight pointLights[$pointLightMax];',
			
			'varying vec4 vColor;',
			'varying vec3 vLighting;',
			//'varying vec2 vTextureCoord;',
			//'varying float vUseTexture;',
			
			'int pointLightMax = $pointLightMax;',
			
			'vec3 calcPointLights (in vec4 worldPosition, in vec3 transformedNormal) {',
			'	vec3 lightColor = vec3(0,0,0);',
			'	vec3 lVec = vec3(0,0,0);',
			'	highp float lightWeighting;',
			'	highp float dotProduct;',
			'	highp float lDist;',
			
			'	for (int i = 0; i < $pointLightMax; i++) {',
			'		lVec = pointLights[i].position.xyz - worldPosition.xyz;',
			'		lDist = 1.0 - min( ( length(lVec) / pointLights[i].position.w ), 1.0 );',
			'		lVec = normalize(lVec);',
			'		dotProduct = dot( transformedNormal, lVec );',
			'		lightWeighting = max( dotProduct, 1.0 ) * pointLights[i].color.a;',
			'		lightColor += pointLights[i].color.rgb * lightWeighting * lDist;',
			'	}',
			
			'	return lightColor;',
			'}',
			
			
			'void main (void) {',
			'	vColor = vertexColor;', //pass color to the frag shader 
			//'	vTextureCoord = aTextureCoord;', //pass the texture UV to the frag shader
			
			//Set vertex position
			'	vec4 worldPosition = worldMatrix * vec4(aVertexPosition, 1.0);',
			'	vec4 viewPosition = viewProjectionMatrix * worldPosition;',
			'	gl_Position = viewPosition;',
			
			//Calculate point lighting and pass to frag shader
			'	vec3 transformedNormal = normalize(normalMatrix * aVertexNormal);',
			'	vLighting = min(ambientLight.rgb + calcPointLights(worldPosition, transformedNormal), 1.0);',
			//'	vUseTexture = useTexture;',
			'}',
		].join('\n');
		
		defaultShader.attributes.push(new ShaderVariable('vec3', 'aVertexPosition'));
		defaultShader.attributes.push(new ShaderVariable('vec3', 'aVertexNormal'));
		//defaultShader.attributes.push(new ShaderVariable('vec2', 'aTextureCoord'));
		
		defaultShader.uniforms.push(new ShaderVariable('mat4', 'viewProjectionMatrix'));
		defaultShader.uniforms.push(new ShaderVariable('mat4', 'viewMatrix'));
		defaultShader.uniforms.push(new ShaderVariable('mat4', 'worldMatrix'));
		defaultShader.uniforms.push(new ShaderVariable('mat3', 'normalMatrix'));
		
		defaultShader.uniforms.push(new ShaderVariable('vec4', 'vertexColor'));
		defaultShader.uniforms.push(new ShaderVariable('vec4', 'ambientLight'));
		//defaultShader.uniforms.push(new ShaderVariable('float', 'useTexture'));
		
		
		Browser.window.addEventListener('resize', onResize);
		if (fullSize == false) setSize(canvasWidth, canvasHeight);
		else {
			Browser.document.body.style.marginTop = '0px';
			Browser.document.body.style.marginLeft = '0px';
			Browser.document.body.style.marginRight = '0px';
			Browser.document.body.style.marginBottom = '0px';
			Browser.document.body.style.overflow = 'hidden';
			setSize(Browser.window.innerWidth, Browser.window.innerHeight);
		}
		
		initGL();
		initRenderData();
		setDefaultGLState();
		loadProgram('default', defaultShader);
	}
	
	
	public function initGL ()
	{
		_gl.clearColor(clearColor.r, clearColor.g, clearColor.b, clearAlpha);
		_gl.clearDepth(1.0);
	}
	
	
	public function setDefaultGLState () 
	{
		_gl.clearStencil( 0 );

		_gl.enable( GL.DEPTH_TEST );
		_gl.depthFunc( GL.LEQUAL );
		
		_gl.frontFace( GL.CCW );
		_gl.cullFace( GL.BACK );
		_gl.enable( GL.CULL_FACE );
	
		_gl.enable( GL.BLEND );
		_gl.blendEquation( GL.FUNC_ADD );
		_gl.blendFunc( GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA );
	}
	
	
	public function initRenderData ()
	{
		viewMatrix = new Matrix4();
		viewProjectionMatrix = new Matrix4();
		normalMatrix = new Matrix3();
		frustum = new Frustum();
		
		renderData = {
			object: new Array<Object3D>(),
			mesh: new Array<Mesh>(),
			light: {
				ambientLight: new Color(),
				ambientLights: new Array<AmbientLight>(),
				pointLights: new Array<PointLight>()
			}
		};
		
		geometryRefs = new Map<Geometry,Dynamic>();
		textureRefs = new Map<Texture,Dynamic>();
	}
	
	
	public function loadProgram (name:String, shaderObject:ShaderObject)
	{
		if (shaders.exists(name) == true) return false;
		shaders.set(name, shaderObject);
		useProgram(name);
		return true;
	}
	
	
	public function useProgram (name:String) : Bool
	{
		if (shaders.exists(name) == false) 
		{
			trace('useProgram: $name does not exist');
			return false;
		}
		
		if (currentShader == name) return true;
		
		var object:ShaderObject = shaders.get(name);
		if (object.program == null)
		{
			var shaderProgram = _gl.createProgram();
			//compile shader
			if (object.vertexShader != null)
			{
				var shader = _gl.createShader(GL.VERTEX_SHADER);
				_gl.shaderSource(shader, object.vertexShader);
				_gl.compileShader(shader);
				if (!_gl.getShaderParameter(shader, GL.COMPILE_STATUS)) 
				{
					trace('useProgram: Failed to compile vertex-shader for shader $name');
					trace(_gl.getShaderInfoLog(shader));
					return false;
				}
				object.vsCompiled = shader;
				_gl.attachShader(shaderProgram, shader);
				
				createAttributeMap(object);
				createUniformMap(object);
			}
			
			if (object.fragmentShader != null)
			{
				var shader = _gl.createShader(GL.FRAGMENT_SHADER);
				_gl.shaderSource(shader, object.fragmentShader);
				_gl.compileShader(shader);
				if (!_gl.getShaderParameter(shader, GL.COMPILE_STATUS)) 
				{
					trace('useProgram: Failed to compile fragment-shader for shader $name');
					trace(_gl.getShaderInfoLog(shader));
					return false;
				}
				object.fsCompiled = shader;
				_gl.attachShader(shaderProgram, shader);
			}
			
			_gl.linkProgram(shaderProgram);
			
			if (!_gl.getProgramParameter(shaderProgram, GL.LINK_STATUS))
			{
				trace('useProgram: linkProgram() failed for shader $name!');
				return false;
			}
			
			object.program = shaderProgram;
			trace('useProgram: Successfully compiled $name');
		}
		
		
		_gl.useProgram(object.program);
		
		//get attribute locations
		var i = 0, l = object.attributes.length;
		while (i < l)
		{
			var attrib = object.attributes[i++];
			attrib.index = _gl.getAttribLocation(object.program, attrib.name);
			_gl.enableVertexAttribArray(attrib.index);
		}
		
		//get uniform locations
		var i = 0, l = object.uniforms.length;
		while (i < l)
		{
			var uniform = object.uniforms[i++];
			uniform.index = _gl.getUniformLocation(object.program, uniform.name);
			uniform.dirty = true;
		}
		object.dirtyUniforms = true;
		
		currentShader = name;
		return true;
	}
	
	
	public function createAttributeMap (object:Dynamic) : Dynamic
	{
		object.attribute = new Map<String,Dynamic>();
		var i = 0, l = object.attributes.length;
		while (i < l)
		{
			var attrib = object.attributes[i++];
			var attribMap : StringMap<Dynamic> = object.attribute;
			attribMap.set(attrib.name, attrib);
		}
		return object;
	}
	
	
	public function createUniformMap (object:Dynamic) : Dynamic
	{
		object.uniform = new Map<String,Dynamic>();
		var i = 0, l = object.uniforms.length;
		while (i < l)
		{
			var uniform = object.uniforms[i++];
			var uniformMap : StringMap<Dynamic> = object.uniform;
			uniformMap.set(uniform.name, uniform);
		}
		return object;
	}
	
	
	public function getAttribute (shaderName:String, attribName:String) : Dynamic
	{
		if (shaders.exists(shaderName) == false) return null;
		var shader:Dynamic = shaders.get(shaderName);
		var shaderAttributeMap:StringMap<Dynamic> = shader.attribute;
		if (shaderAttributeMap.exists(attribName) == false) return null;
		var attrib = shaderAttributeMap.get(attribName);
		return attrib.index;
	}
	
	
	public function getUniform (shaderName:String, uniformName:String) : Dynamic
	{
		if (shaders.exists(shaderName) == false) return null;
		var shader:Dynamic = shaders.get(shaderName);
		var shaderUniformMap:StringMap<Dynamic> = shader.uniform;
		if (shaderUniformMap.exists(uniformName) == false) return null;
		var uniform = shaderUniformMap.get(uniformName);
		return uniform.index;
	}
	
	
	public function setAttribute (shaderName:String, attribName:String, value:Dynamic) : Bool
	{
		if (shaders.exists(shaderName) == false) return false;
		var shader:Dynamic = shaders.get(shaderName);
		var shaderAttributeMap:StringMap<Dynamic> = shader.attribute;
		if (shaderAttributeMap.exists(attribName) == false) return false;
		//type check here
		var attrib = shaderAttributeMap.get(attribName);
		attrib.value = value;
		attrib.dirty = true;
		shader.dirtyAttributes = true;
		return true;
	}
	
	
	public function setUniform (shaderName:String, uniformName:String, value:Dynamic) : Bool
	{
		if (shaders.exists(shaderName) == false) return null;
		var shader:Dynamic = shaders.get(shaderName);
		var shaderUniformMap : StringMap<Dynamic> = shader.uniform;
		if (shaderUniformMap.exists(uniformName) == false) return null;
		//type check here
		var uniform = shaderUniformMap.get(uniformName);
		uniform.value = value;
		uniform.dirty = true;
		shader.dirtyUniforms = true;
		return true;
	}
	
	
	public function updateAttributes (name:String = null) : Bool
	{
		if (name == null) name = currentShader;
		if (shaders.exists(name) == false) return false;
		
		var shader = shaders.get(name);
		if (shader.dirtyAttributes == false) return true;
		
		var i = 0, l = shader.attributes.length;
		while (i < l)
		{
			var attrib = shader.attributes[i++];
			if (attrib.dirty == false) continue;
			if (attrib.type == 'vec4')
			{
				attrib.output = new Float32Array(attrib.value.toArray());
				_gl.vertexAttribPointer(attrib.index, 4, GL.FLOAT, false, 0, 0);
				_gl.vertexAttrib4fv(attrib.index, attrib.output);
			} else if (attrib.type == 'vec3') 
			{
				attrib.output = new Float32Array(attrib.value.toArray());
				_gl.vertexAttribPointer(attrib.index, 3, GL.FLOAT, false, 0, 0);
				_gl.vertexAttrib3fv(attrib.index, attrib.output);
			} else if (attrib.type == 'vec2')
			{
				attrib.output = new Float32Array(attrib.value.toArray());
				_gl.vertexAttribPointer(attrib.index, 2, GL.FLOAT, false, 0, 0);
				_gl.vertexAttrib2fv(attrib.index, attrib.output);
			} else if (attrib.type == 'float')
			{
				attrib.output = new Float32Array([ cast(attrib.value, Float) ]);
				_gl.vertexAttribPointer(attrib.index, 1, GL.FLOAT, false, 0, 0);
				_gl.vertexAttrib1fv(attrib.index, attrib.output);
			}
			attrib.dirty = false;
		}
		
		shader.dirtyAttributes = false;
		return true;
	}
	
	
	public function updateUniforms (name:String = null) : Bool
	{
		if (name == null) name = currentShader;
		if (shaders.exists(name) == false) return false;
		
		var shader = shaders.get(name);
		if (shader.dirtyUniforms == false) return true;
		var i = 0, l = shader.uniforms.length;
		while (i < l)
		{
			var uniform = shader.uniforms[i++];
			if (uniform.dirty == false) continue;
			var type = uniform.type;
			
			if (type == 'mat4')
			{
				//uniform.output = new Float32Array(uniform.value.elements);
				_gl.uniformMatrix4fv(uniform.index, false, uniform.value.elements);//uniform.output);
			} else if (type == 'mat3')
			{
				uniform.output = new Float32Array(uniform.value.elements);
				_gl.uniformMatrix3fv(uniform.index, false, uniform.output);
			} else if (type == 'vec4')
			{
				uniform.output = new Float32Array(uniform.value.toArray());
				_gl.uniform4fv(uniform.index, uniform.output);
			} else if (type == 'vec3')
			{
				uniform.output = new Float32Array(uniform.value.toArray());
				_gl.uniform3fv(uniform.index, uniform.output);
			} else if (type == 'vec2')
			{
				uniform.output = new Float32Array(uniform.value.toArray());
				_gl.uniform2fv(uniform.index, uniform.output);
			} else if (type == 'float')
			{
				uniform.output = new Float32Array([cast(uniform.value, Float)]);
				_gl.uniform1fv(uniform.index, uniform.output);
			} else if (type == 'int')
			{
				uniform.output = cast(uniform.value, Int);
				_gl.uniform1iv(uniform.index, uniform.output);
			}
			uniform.dirty = false;
		}
		
		shader.dirtyUniforms = false;
		return true;
	}
		
		
	public function getCurrentProgram () : Dynamic
	{
		if (shaders.exists(currentShader) == false) return null;
		return shaders.get(currentShader);
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
		_gl.viewport(0, 0, canvas.width, canvas.height);
	}
	
	
	public function onResize (event:Dynamic) : Void
	{
		if (fullSize == true) setSize(Browser.window.innerWidth, Browser.window.innerHeight);
	}
	
	
	public function clear ()
	{
		_gl.clear(GL.COLOR_BUFFER_BIT | GL.DEPTH_BUFFER_BIT);
	}
	
	
	inline public function resetRenderData () 
	{
		renderData.mesh.splice(0, renderData.mesh.length);
		renderData.object.splice(0, renderData.object.length);
	}
	
	public function projectObject (scene:Object3D, camera:Camera)
	{
		var cIter = scene.children.iterator();
		while (cIter.hasNext() == true)
		{
			var object = cIter.next();
			if (object.visible == false) 
			{
				projectObject(object, camera);
				continue;
			}
			
			if (Std.is(object, Light))
			{
				if (Std.is(object, AmbientLight)) renderData.light.ambientLights.push(object);
				else if (Std.is(object, PointLight)) renderData.light.pointLights.push(object);
				
			} else if (Std.is(object, Mesh)) //todo - THREE.Line
			{
				if (object.frustumCulled == false || frustum.intersectsObject(object) == true)
				{
					renderData.mesh.push(object);
				}
				
			//todo - Sprite, Particle, 
			} else {
				renderData.object.push(object);
			}
			
			projectObject(object, camera);
		}
		
	}
	
	
	public function render (scene:Scene, camera:Camera)
	{
		if (scene.autoUpdate == true) scene.updateMatrixWorld();
		if (camera.parent == null) camera.updateMatrixWorld();
		
		currentCamera = camera;
		currentScene = scene;
		
		viewMatrix.copy(camera.matrixWorldInverse.getInverse(camera.matrixWorld));
		viewProjectionMatrix.multiplyMatrices(camera.projectionMatrix, viewMatrix);
		frustum.setFromMatrix(viewProjectionMatrix);
		
		resetRenderData();
		resetLights();
		projectObject(scene, camera);
		updateLights();
		if (autoClear == true) clear();
		renderMeshes();
	}
	
	
	inline private function renderMeshes ()
	{
		var i = 0, l = renderData.mesh.length;
		while (i < l)
		{
			var object = renderData.mesh[i++];
			
			//If buffers fail to create, skip this object
			if (createMeshBuffers(object) == false) continue;
			
			//Geometry reference always exists from here on
			var geometryRef:Dynamic = geometryRefs.get(object.geometry);
			
			
			//Load material, responsible for loading the shader
			setMaterial(object.material);
			
			//Get shader attribute locations
			var aVertexPosition = getAttribute(currentShader, 'aVertexPosition');
			var aVertexNormal = getAttribute(currentShader, 'aVertexNormal');
			//var aTextureCoord = getAttribute(currentShader, 'aTextureCoord');
			
			
			
			_gl.bindBuffer(GL.ARRAY_BUFFER, geometryRef.vertexBuffer);
			_gl.vertexAttribPointer(aVertexPosition, 3, GL.FLOAT, false, 0, 0);
			
				
			//Set base shader uniforms
			setUniform(currentShader, 'viewProjectionMatrix', viewProjectionMatrix);
			setUniform(currentShader, 'viewMatrix', viewMatrix);
			setUniform(currentShader, 'worldMatrix', object.matrixWorld);
			setUniform(currentShader, 'normalMatrix', normalMatrix.getNormalMatrix(object.matrixWorld));
			updateUniforms();
			
			if (geometryRef.normalBufferInit)
			{
				//If the geometry has a loaded normal buffer, render normals
				_gl.bindBuffer(GL.ARRAY_BUFFER, geometryRef.normalBuffer);
				_gl.vertexAttribPointer(aVertexNormal, 3, GL.FLOAT, false, 0, 0);
				_gl.drawArrays(GL.TRIANGLES, 0, geometryRef.normalBufferLength);
				
			} else
			{
				//Otherwise just render the vertex buffer
				_gl.drawArrays(GL.TRIANGLES, 0, geometryRef.vertexBufferLength);
			}
		}
	}
	
	
	public function createMeshBuffers (object:Mesh) : Bool
	{
		//First time rendering this geometry
		if (geometryRefs.exists(object.geometry) == false)
		{
			geometryRefs.set(object.geometry, {
				//Vertex Buffer
				vertexBuffer: null,
				vertexBufferLength: 0,
				vertexBufferInit: false,
				//Normal Buffer
				normalBuffer: null,
				normalBufferLength: 0,
				normalBufferInit: false,
				//UVs
				UVBuffer: null,
				UVBufferLength: 0,
				UVBufferInit: false
			});
		}
		
		//Create/update buffers or exit successfully if there is no need
		if (createMeshVertexBuffer(object) == false) return false;
		createMeshNormalBuffer(object);
		//createMeshUVBuffer(object);
		
		//Delete non-dynamic geometry locally
		deleteMeshLocalArrays(object);
		return true;
	}
	
	
	public function createMeshVertexBuffer (object:Mesh) : Bool
	{
		var vertices = object.geometry.vertices;
		var faces = object.geometry.faces;
		var ref:Dynamic = geometryRefs.get(object.geometry);
		
		//Buffer already exists
		if (ref.vertexBufferInit == true)
		{
			//if it doesnt need updating return successfully
			if (object.geometry.verticesNeedUpdate == false) return true;
			//Vertices need update, delete the existing buffer
			_gl.deleteBuffer(ref.vertexBuffer);
		}
		
		//Reset vars
		ref.vertexBuffer = null;
		ref.vertexBufferLength = 0;
		ref.vertexBufferInit = false;
		
		//Fail if there is nothing to put in the buffer
		if (faces.length == 0 || vertices.length == 0) return false;
		
		var buffer = new Array<Float>();
		var f = 0, fl = faces.length, len = 0;
		
		while (f < fl)
		{
			var face = faces[f];
			
			buffer.push(vertices[face.a].x);
			buffer.push(vertices[face.a].y);
			buffer.push(vertices[face.a].z);
			
			buffer.push(vertices[face.b].x);
			buffer.push(vertices[face.b].y);
			buffer.push(vertices[face.b].z);
			
			buffer.push(vertices[face.c].x);
			buffer.push(vertices[face.c].y);
			buffer.push(vertices[face.c].z);
			
			if (Std.is(face, Face4) == true)
			{
				buffer.push(vertices[face.a].x);
				buffer.push(vertices[face.a].y);
				buffer.push(vertices[face.a].z);
				
				buffer.push(vertices[face.c].x);
				buffer.push(vertices[face.c].y);
				buffer.push(vertices[face.c].z);
				
				buffer.push(vertices[face.d].x);
				buffer.push(vertices[face.d].y);
				buffer.push(vertices[face.d].z);
				len += 3;
			}
			len += 3;
			f++;
		}
		
		//Create buffer, put the local buffer into it
		ref.vertexBuffer = _gl.createBuffer();
		_gl.bindBuffer(GL.ARRAY_BUFFER, ref.vertexBuffer);
		ref.vertexBufferLength = len;
		_gl.bufferData(GL.ARRAY_BUFFER, new Float32Array(buffer), GL.STATIC_DRAW);
		ref.vertexBufferInit = true;
		
		//register cleanup events here
		object.geometry.verticesNeedUpdate = false;
		return true;
	}
	
	
	public function createMeshNormalBuffer (object:Mesh) : Bool
	{
		var faces = object.geometry.faces;
		
		var ref:Dynamic = geometryRefs.get(object.geometry);
		
		if (ref.normalBufferInit == true)
		{
			if (object.geometry.normalsNeedUpdate == false) return true;
			_gl.deleteBuffer(ref.normalBuffer);
		}
		
		ref.normalBuffer = null;
		ref.normalBufferLength = 0;
		ref.normalBufferInit = false;
		
		if (faces[0].vertexNormals.length == 0) return false;
		
		var buffer = new Array<Float>();
		var f = 0, fl = faces.length, len = 0;
		
		while (f < fl)
		{
			var face = faces[f++];
			buffer.push(face.vertexNormals[0].x);
			buffer.push(face.vertexNormals[0].y);
			buffer.push(face.vertexNormals[0].z);
			
			buffer.push(face.vertexNormals[1].x);
			buffer.push(face.vertexNormals[1].y);
			buffer.push(face.vertexNormals[1].z);
			
			buffer.push(face.vertexNormals[2].x);
			buffer.push(face.vertexNormals[2].y);
			buffer.push(face.vertexNormals[2].z);
			
			len += 3;
			if (Std.is(face, Face4) == true)
			{
				buffer.push(face.vertexNormals[0].x);
				buffer.push(face.vertexNormals[0].y);
				buffer.push(face.vertexNormals[0].z);
				
				buffer.push(face.vertexNormals[2].x);
				buffer.push(face.vertexNormals[2].y);
				buffer.push(face.vertexNormals[2].z);
				
				buffer.push(face.vertexNormals[3].x);
				buffer.push(face.vertexNormals[3].y);
				buffer.push(face.vertexNormals[3].z);
				len += 3;
			}
		}
		
		ref.normalBuffer = _gl.createBuffer();
		_gl.bindBuffer(GL.ARRAY_BUFFER, ref.normalBuffer);
		ref.normalBufferLength = len;
		_gl.bufferData(GL.ARRAY_BUFFER, new Float32Array(buffer), GL.STATIC_DRAW);
		ref.normalBufferInit = true;
		
		object.geometry.normalsNeedUpdate = false;
		return true;
	}
	
	
	public function createMeshUVBuffer (object:Mesh)
	{
		var ref = geometryRefs.get(object.geometry);
		var buffer = new Array<Float>();
		
		if (ref.UVBufferInit == true)
		{
			if (object.geometry.uvsNeedUpdate == false) return true;
			_gl.deleteBuffer(ref.UVBuffer);
		}
		
		ref.UVBuffer = null;
		ref.UVBufferLength = 0;
		ref.UVBufferInit = false;
		var i = 0, l = object.geometry.faces.length, len = 0;
		while (i < l)
		{
			buffer.push(0.0);
			buffer.push(0.0);

			buffer.push(1.0);
			buffer.push(0.0);
			
			buffer.push(1.0);
			buffer.push(1.0);
			
			buffer.push(0.0);
			buffer.push(1.0);
			len += 4;
			i++;
		}
		
		ref.UVBuffer = _gl.createBuffer();
		_gl.bindBuffer(GL.ARRAY_BUFFER, ref.UVBuffer);
		ref.UVBufferLength = len;
		_gl.bufferData(GL.ARRAY_BUFFER, new Float32Array(buffer), GL.STATIC_DRAW);
		ref.UVBufferInit = true;
		
		object.geometry.uvsNeedUpdate = false;
		return true;
	}
	
	
	inline public function deleteMeshLocalArrays (object:Mesh)
	{
		if (object.geometry.isDynamic == false)
		{
			object.geometry.vertices.splice(0, object.geometry.vertices.length);
			object.geometry.faces.splice(0, object.geometry.faces.length);
		}
	}
	
	
	inline public function resetLights ()
	{
		renderData.light.ambientLight.setHex(0x000000);
		renderData.light.ambientLights = new Array<AmbientLight>();
		renderData.light.pointLights = new Array<PointLight>();
	}
	
	
	inline public function updateLights ()
	{
		updateAmbientLight();
		updatePointLights();
	}
	
	
	inline public function updateAmbientLight ()
	{
		var i = 0, l = renderData.light.ambientLights.length;
		
		while (i < l)
		{
			var light = renderData.light.ambientLights[i++];
			renderData.light.ambientLight.copy(light.color);
		}
		
		setUniform(currentShader, 'ambientLight', renderData.light.ambientLight);
	}
	
	
	public function updatePointLights () : Void
	{
		var shaderObject = getCurrentProgram();
		if (shaderObject == null) return;
		var program = shaderObject.program;
		
		var far = 0.0;
		if (Std.is(currentCamera, PerspectiveCamera)) far = cast(currentCamera, PerspectiveCamera).far;
		else if (Std.is(currentCamera, OrthographicCamera)) far = cast(currentCamera, OrthographicCamera).far;
		
		//var cameraSphere = new Sphere(currentCamera.position, far);
		//var lightSphere = new Sphere();
		
		var pointLights:Array<PointLight> = renderData.light.pointLights;
		var i = 0, pointLightCount = pointLights.length;
		var distmap = new Map<Light,Float>();
		
		//If the light count is ridiculous, chop the end off the input array
		//if (pointLightCount > pointLightMax * 5) pointLightCount = pointLightMax * 5;
		
		if (pointLightSort)
		{
			//Sort lights by distance
			pointLights.sort(function (a:Dynamic, b:Dynamic) : Int
			{
				var distA = 0.0;
				var distB = 0.0;
				if (distmap.exists(a)) distA = distmap.get(a);
				else 
				{
					distA = a.position.distanceTo(currentCamera.position);
					distmap.set(a, distA);
				}
				
				if (distmap.exists(b)) distB = distmap.get(b);
				else 
				{
					distB = b.position.distanceTo(currentCamera.position);
					distmap.set(b, distB);
				}
				
				return (distB - distA < 0 ? 1 : -1);
			});
		}
		
		var lightnum = 0;
		while (i < pointLightCount)
		{
			var light:PointLight = pointLights[i];
			//lightSphere.set(light.position, light.distance);
			var dist = (pointLightSort ? distmap.get(light) : light.position.distanceTo(currentCamera.position));
			if (dist + light.distance > cast(currentCamera, PerspectiveCamera).far)
			//if (cameraSphere.intersectsSphere(lightSphere) == false)
			{
				//Light is not within range
				i++;
				continue;
			}
			//Write the uniforms
			var locPosition = _gl.getUniformLocation(program, 'pointLights[$lightnum].position');
			var locColor = _gl.getUniformLocation(program, 'pointLights[$lightnum].color');
			_gl.uniform4fv(locPosition, new Float32Array([ light.position.x, light.position.y, light.position.z, light.distance ]));
			_gl.uniform4fv(locColor, new Float32Array([ light.color.r, light.color.g, light.color.b, light.intensity ]));
			if (++lightnum == pointLightMax) break;
			i++;
		}
		
		//Zero the rest of our budget
		i = lightnum;
		while (i < pointLightMax)
		{
			var locPosition = _gl.getUniformLocation(program, 'pointLights[$i].position');
			var locColor = _gl.getUniformLocation(program, 'pointLights[$i].color');
			_gl.uniform4fv(locPosition, new Float32Array([ 0.0, 0.0, 0.0, 0.0 ]));
			_gl.uniform4fv(locColor, new Float32Array([ 0.0, 0.0, 0.0, 0.0 ]));
			i++;
		}
		
	}
	
	
	inline public function setMaterial (material:Dynamic)
	{
		useProgram('default'); //use shader for material type
		setUniform(currentShader, 'vertexColor', material.color);
		
		//TODO: figure out how i'm going to load texture maps without contaminating three.textures with JS-stuff
		/*
		if (Std.is(material, MeshBasicMaterial) == true)
		{
			setMaterialTexture(cast(material, MeshBasicMaterial));
		}
		*/
		
		setMaterialFaces(material);
		setBlending(material.blending, material.blendSrc, material.blendDst);
	}
	
	
	public function setMaterialTexture (material:MeshBasicMaterial) : Void
	{
		setUniform(currentShader, 'useTexture', 0.0);
		if (material.map == null) return;
		
		if (textureRefs.exists(material.map) == false)
		{
			//Never seen this material before, load it
			textureRefs.set(material.map, {
				texture: material.map,
				glTexture: _gl.createTexture(),
				slot: textureCount++,
				ready: false
			});
			var ref = textureRefs.get(material.map);
			var texture = ref.texture;
			var glTexture = ref.glTexture;
			var slot = ref.slot;
			texture.needsUpdate = true;
			texture.image = Browser.document.createImageElement();
			texture.image.onload = function (event:Dynamic) : Void { ref.ready = true; };
			texture.image.crossOrigin = 'anonymous';
			texture.image.src = texture.source;
			return;
		}
		
		var ref = textureRefs.get(material.map);
		var texture = ref.texture;
		var glTexture = ref.glTexture;
		var slot = ref.slot;
		
		if (texture.needsUpdate == true)
		{
			if (ref.ready == true)
			{
				var program = getCurrentProgram();
				setUniform(currentShader, 'useTexture', 1.0);
				_gl.activeTexture(GL.TEXTURE0 + slot);
				_gl.bindTexture(GL.TEXTURE_2D, glTexture);
				_gl.uniform1i(_gl.getUniformLocation(program.program, "uSampler"), 0);
				
				_gl.pixelStorei(GL.UNPACK_FLIP_Y_WEBGL, (texture.flipY ? 1 : 0));
				_gl.pixelStorei(GL.UNPACK_PREMULTIPLY_ALPHA_WEBGL, (texture.premultiplyAlpha ? 1 : 0));
				_gl.pixelStorei(GL.UNPACK_ALIGNMENT, texture.unpackAlignment);
				
				var glFormat = GL.RGBA;
				var glType = GL.UNSIGNED_BYTE;
				_gl.texImage2D(GL.TEXTURE_2D, 0, glFormat, glFormat, glType, cast(texture.image, ImageElement));
				_gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MAG_FILTER, GL.LINEAR);
				_gl.texParameteri(GL.TEXTURE_2D, GL.TEXTURE_MIN_FILTER, GL.LINEAR_MIPMAP_NEAREST);
				
				//if (texture.generateMipmaps == true) _gl.generateMipmap(GL.TEXTURE_2D);
				texture.image = null;
				texture.needsUpdate = false;
			}
		} else {
			setUniform(currentShader, 'useTexture', 1.0);
			
			_gl.activeTexture(GL.TEXTURE0 + slot);
			_gl.bindTexture(GL.TEXTURE_2D, glTexture);
			
		}
		
		//setUniform(currentShader, 'texID', GL.TEXTURE0 + slot);
	}
	
	
	inline public function setMaterialFaces (material:Material)
	{
		if (material.side == THREE.DoubleSide) _gl.disable(GL.CULL_FACE);
		else _gl.enable(GL.CULL_FACE);
		
		if (material.side == THREE.BackSide) _gl.frontFace(GL.CW);
		else _gl.frontFace(GL.CCW);
	}
	
	
	inline public function setBlending (blending:Int, blendSrc:Int, blendDst:Int)
	{
		if (blending != blendingMode)
		{
			if ( blending == THREE.NoBlending ) {
				_gl.disable( GL.BLEND );
			} else if ( blending == THREE.AdditiveBlending ) {
				_gl.enable( GL.BLEND );
				_gl.blendEquation( GL.FUNC_ADD );
				_gl.blendFunc( GL.SRC_ALPHA, GL.ONE );
			} else if ( blending == THREE.SubtractiveBlending ) {
				// TODO: Find blendFuncSeparate() combination
				_gl.enable( GL.BLEND );
				_gl.blendEquation( GL.FUNC_ADD );
				_gl.blendFunc( GL.ZERO, GL.ONE_MINUS_SRC_COLOR );
			} else if ( blending == THREE.MultiplyBlending ) {
				// TODO: Find blendFuncSeparate() combination
				_gl.enable( GL.BLEND );
				_gl.blendEquation( GL.FUNC_ADD );
				_gl.blendFunc( GL.ZERO, GL.SRC_COLOR );
			} else if ( blending == THREE.CustomBlending ) {
				_gl.enable( GL.BLEND );
			} else {
				_gl.enable( GL.BLEND );
				_gl.blendEquationSeparate( GL.FUNC_ADD, GL.FUNC_ADD );
				_gl.blendFuncSeparate( GL.SRC_ALPHA, GL.ONE_MINUS_SRC_ALPHA, GL.ONE, GL.ONE_MINUS_SRC_ALPHA );
			}
			blendingMode = blending;
		}
		
	}
	
}

