
package three.core;

import haxe.ds.Vector;
import three.cameras.Camera;
import three.lights.Light;
import three.materials.Material;
import three.materials.MeshFaceMaterial;
import three.math.Box3;
import three.math.Frustum;
import three.math.Matrix3;
import three.math.Matrix4;
import three.math.Ray;
import three.math.Vector3;
import three.math.Vector4;
import three.objects.Mesh;
import three.renderers.renderables.Renderable;
import three.renderers.renderables.RenderableFace3;
import three.renderers.renderables.RenderableFace4;
import three.renderers.renderables.RenderableLine;
import three.renderers.renderables.RenderableObject;
import three.renderers.renderables.RenderableParticle;
import three.renderers.renderables.RenderableVertex;
import three.scenes.Scene;
import three.THREE;

/**
 * 
 * @author dcm
 */

class Projector
{
	
	public var renderData:RenderData;

	public var objectCurrent:RenderableObject;
	public var objectCount:Int = 0;
	public var objectPool:Array<RenderableObject>;
	public var objectPoolLength:Int = 0;
	
	public var vertexCurrent:RenderableVertex;
	public var vertexCount:Int = 0;
	public var vertexPool:Array<RenderableVertex>;
	public var vertexPoolLength:Int = 0;
	
	public var face3Current:RenderableFace3;
	public var face3Count:Int = 0;
	public var face3Pool:Array<RenderableFace3>;
	public var face3PoolLength:Int = 0;
	
	public var face4Current:RenderableFace4;
	public var face4Count:Int = 0;
	public var face4Pool:Array<RenderableFace4>;
	public var face4PoolLength:Int = 0;
	
	public var lineCurrent:RenderableLine;
	public var lineCount:Int = 0;
	public var linePool:Array<RenderableLine>;
	public var linePoolLength:Int = 0;
	
	public var particleCurrent:RenderableParticle;
	public var particleCount:Int = 0;
	public var particlePool:Array<RenderableParticle>;
	public var particlePoolLength:Int = 0;
	
	public var vector3:Vector3;
	public var vector4:Vector4;
	
	public var clipBox:Box3;
	public var boundingBox:Box3;
	public var points3:Array<Dynamic>;
	public var points4:Array<Dynamic>;
	
	public var viewMatrix:Matrix4;
	public var viewProjectionMatrix:Matrix4;
	
	public var modelMatrix:Matrix4;
	public var modelViewProjectionMatrix:Matrix4;
	
	public var normalMatrix:Matrix3;
	public var normalViewMatrix:Matrix3;
	
	public var centroid:Vector3;
	
	public var frustum:Frustum;
	
	public var clippedVertex1PositionScreen:Vector4;
	public var clippedVertex2PositionScreen:Vector4;
	
	
	public function new() 
	{
		objectPool = new Array<RenderableObject>();
		vertexPool = new Array<RenderableVertex>();
		face3Pool = new Array<RenderableFace3>();
		face4Pool = new Array<RenderableFace4>();
		linePool = new Array<RenderableLine>();
		particlePool = new Array<RenderableParticle>();
		
		renderData = new RenderData();
		
		vector3 = new Vector3();
		vector4 = new Vector4();
		
		clipBox = new Box3(new Vector3(-1,-1,-1), new Vector3(1,1,1));
		boundingBox = new Box3();
		
		points3 = new Array<Dynamic>();
		points4 = new Array<Dynamic>();
		
		viewMatrix = new Matrix4();
		viewProjectionMatrix = new Matrix4();
		modelViewProjectionMatrix = new Matrix4();
		normalMatrix = new Matrix3();
		normalViewMatrix = new Matrix3();
		
		centroid = new Vector3();
		frustum = new Frustum();
		
		clippedVertex1PositionScreen = new Vector4();
		clippedVertex2PositionScreen = new Vector4();
	}
	
	
	public function projectVector (v:Vector3, camera:Camera) : Vector3
	{
		camera.matrixWorldInverse.getInverse(camera.matrixWorld);
		viewProjectionMatrix.multiplyMatrices(camera.projectionMatrix, camera.matrixWorldInverse);
		return v.applyProjection(viewProjectionMatrix);
	}
	
	
	public function unprojectVector (v:Vector3, camera:Camera) : Vector3
	{
		camera.projectionMatrixInverse.getInverse(camera.projectionMatrix);
		viewProjectionMatrix.multiplyMatrices(camera.matrixWorld, camera.projectionMatrixInverse);
		return v.applyProjection(viewProjectionMatrix);
	}
	
	
	public function pickingRay (v:Vector3, camera:Camera) : Raycaster
	{
		v.z = -1.0;
		var end = new Vector3(v.x, v.y, 1.0);
		unprojectVector(v, camera);
		unprojectVector(end, camera);
		end.sub(v).normalize();
		return new Raycaster(v, end);
	}
	
	
	public function projectObject (parent:Object3D)
	{
		//Iterate the children of this object
		var c = 0, cl = parent.children.length;
		while (c < cl)
		{
			var object = parent.children[c++];
			if (object.visible == false) continue;
			
			if (object.type == THREE.Light) renderData.lights.push(cast(object, Light));
			else if (object.type == THREE.Mesh) //todo - THREE.Line
			{
				if (object.frustumCulled == false || frustum.intersectsObject(object) == true)
				{
					objectCurrent = getNextObjectInPool();
					objectCurrent.object = object;
					if (object.renderDepth != null) objectCurrent.z = object.renderDepth;
					else 
					{
						var v1 = new Vector3();
						v1.getPositionFromMatrix(object.matrixWorld);
						v1.applyProjection(viewProjectionMatrix);
						objectCurrent.z = v1.z;
					}
					
					renderData.objects.push(objectCurrent);
				}
				
			//todo - Sprite, Particle, 
			} else {
				
				objectCurrent = getNextObjectInPool();
				objectCurrent.object = object;
				
				if (object.renderDepth != null) objectCurrent.z = object.renderDepth;
				else
				{
					vector3.getPositionFromMatrix(object.matrixWorld);
					vector3.applyProjection(viewProjectionMatrix);
					objectCurrent.z = vector3.z;
				}
				
				renderData.objects.push(objectCurrent);
				
			}
			
			projectObject(object);
			
		}
		
	}
	
	
	public function projectGraph (root:Object3D, sortObjects:Bool = true) : RenderData
	{
		objectCount = 0;
		renderData.objects = new Array<RenderableObject>();
		projectObject(root);
		
		if (sortObjects == true) renderData.objects.sort(
			function (a:RenderableObject, b:RenderableObject) : Int
			{
				return (b.z - a.z < 0 ? -1 : 1);
			}
		);
		
		return renderData;
	}
	
	
	public function projectScene (scene:Scene, camera:Camera, sortObjects:Bool = true, sortElements:Bool = true) : RenderData
	{
		var object:Object3D;
		
		face3Count = 0;
		face4Count = 0;
		lineCount = 0;
		particleCount = 0;
		renderData.elements = new Array<Renderable>();
		
		if (scene.autoUpdate == true) scene.updateMatrixWorld();
		if (camera.parent == null) camera.updateMatrixWorld();
		
		viewMatrix.copy(camera.matrixWorldInverse.getInverse(camera.matrixWorld));
		viewProjectionMatrix.multiplyMatrices(camera.projectionMatrix, viewMatrix);
		
		normalViewMatrix.getNormalMatrix(viewMatrix);
		frustum.setFromMatrix(viewProjectionMatrix);
		
		projectGraph(scene, sortObjects);
		
		var o = 0, ol = renderData.objects.length;
		while (o < ol)
		{
			object = renderData.objects[o].object;
			modelMatrix = object.matrixWorld;
			vertexCount = 0;
			if (Std.is(object, Mesh) == true) projectScene_Mesh(cast(object, Mesh));
			//todo - rest of the renderables here
			o++;
		}
		
		//todo: sort elements 
		
		return renderData;
	}
	
	
	
	
	//split from projectScene() to help readability...
	inline private function projectScene_Mesh (mesh:Mesh)
	{
		var geometry:Geometry = mesh.geometry;
		var vertices:Array<Vector3> = geometry.vertices;
		var faces:Array<Face4> = geometry.faces;
		var faceVertexUvs = geometry.faceVertexUvs;
		var visible = false;
		
		normalMatrix.getNormalMatrix(modelMatrix);
		var isFaceMaterial = Std.is(mesh.material, MeshFaceMaterial);
		var objectMaterials = (isFaceMaterial == true ? mesh.material : null);
		
		//for-each vertex...
		var v = 0, vl = vertices.length;
		while (v < vl)
		{
			vertexCurrent = getNextVertexInPool();
			
			vertexCurrent.positionWorld.copy(vertices[v]);
			vertexCurrent.positionWorld.applyMatrix4(modelMatrix);
			
			//Manual .copy() here because positionWorld is Vector3 while positionScreen is Vector4
			vertexCurrent.positionScreen.x = vertexCurrent.positionWorld.x;
			vertexCurrent.positionScreen.y = vertexCurrent.positionWorld.y;
			vertexCurrent.positionScreen.z = vertexCurrent.positionWorld.z;
			vertexCurrent.positionScreen.w = 1;
			vertexCurrent.positionScreen.applyMatrix4(viewProjectionMatrix);
			
			vertexCurrent.positionScreen.x /= vertexCurrent.positionScreen.w;
			vertexCurrent.positionScreen.y /= vertexCurrent.positionScreen.w;
			vertexCurrent.positionScreen.z /= vertexCurrent.positionScreen.w;
			
			vertexCurrent.visible = ! ( vertexCurrent.positionScreen.x < -1 || vertexCurrent.positionScreen.x > 1
									 || vertexCurrent.positionScreen.y < -1 || vertexCurrent.positionScreen.y > 1
									 || vertexCurrent.positionScreen.z < -1 || vertexCurrent.positionScreen.z > 1 );
			v++;
		}
		
		//for-each face...
		var f = 0, fl = faces.length;
		while (f < fl)
		{
			var type = 3;
			var face:Face4 = faces[f++]; //Note: references to `f` from here on are (f - 1)
			var material:Material = ( isFaceMaterial == true ? cast(mesh.material, MeshFaceMaterial).materials[face.materialIndex] : mesh.material );
			if (material == null) continue;
			var side = material.side;
			
			//check for Face4 first here because it extends Face3 so a face3 check will be true also
			if (Std.is(face, Face4) == true)
			{
				var v1:RenderableVertex = vertexPool[face.a];
				var v2:RenderableVertex = vertexPool[face.b];
				var v3:RenderableVertex = vertexPool[face.c];
				var v4:RenderableVertex = vertexPool[face.d];
				
				points4[0] = v1.positionScreen;
				points4[1] = v2.positionScreen;
				points4[2] = v3.positionScreen;
				points4[3] = v4.positionScreen;
				
				//Negating the original condition here as it is less nesting
				if (v1.visible == false && v2.visible == false && v3.visible == false && v4.visible == false
				 && clipBox.isIntersectionBox(boundingBox.setFromPoints(points4)) == false) continue;
				
				visible = ( v4.positionScreen.x - v1.positionScreen.x ) 
						* ( v2.positionScreen.y - v1.positionScreen.y ) 
						- ( v4.positionScreen.y - v1.positionScreen.y ) 
						* ( v2.positionScreen.x - v1.positionScreen.x ) < 0 ||
						  ( v2.positionScreen.x - v3.positionScreen.x )
						* ( v4.positionScreen.y - v3.positionScreen.y )
						- ( v2.positionScreen.y - v3.positionScreen.y )
						* ( v4.positionScreen.x - v3.positionScreen.x ) < 0;
				
				//Negating original condition again
				if (side != THREE.DoubleSide && visible != (side == THREE.FrontSide)) continue;
				
				face4Current = getNextFace4InPool();
				face4Current.v1.copy(v1);
				face4Current.v2.copy(v2);
				face4Current.v3.copy(v3);
				face4Current.v4.copy(v4);
				type = 4;
				
			} else if (Std.is(face, Face3) == true)
			{
				var v1:RenderableVertex = vertexPool[face.a];
				var v2:RenderableVertex = vertexPool[face.b];
				var v3:RenderableVertex = vertexPool[face.c];
				
				points3[0] = v1.positionScreen;
				points3[1] = v2.positionScreen;
				points3[2] = v3.positionScreen;
				
				//Negating original condition
				if (v1.visible == false && v2.visible == false && v3.visible == false
				 && clipBox.isIntersectionBox(boundingBox.setFromPoints(points3)) == false) continue;
				
				visible = ( ( v3.positionScreen.x - v1.positionScreen.x )
						  * ( v2.positionScreen.y - v1.positionScreen.y )
						  - ( v3.positionScreen.y - v1.positionScreen.y )
						  * ( v2.positionScreen.x - v1.positionScreen.x ) ) < 0;
				
				//Negating original condition
				if (side != THREE.DoubleSide && visible != (side == THREE.FrontSide)) continue;
				
				face3Current = getNextFace3InPool();
				face3Current.v1.copy(v1);
				face3Current.v2.copy(v2);
				face3Current.v3.copy(v3);
			}
			
			//Assign to a dynamic here because it is either Face3 or Face4
			var current:Dynamic = (type == 4 ? face4Current : face3Current);
			current.normalModel.copy(face.normal);
			
			if (visible == false && (side == THREE.BackSide || side == THREE.DoubleSide))
			{
				current.normalModel.negate();
			}
			
			current.normalModel.applyMatrix3(normalMatrix);
			current.normalModel.normalize();
			
			current.normalModelView.copy(current.normalModel);
			current.normalModelView.applyMatrix3(normalViewMatrix);
			
			current.centroidModel.copy(face.centroid);
			current.centroidModel.applyMatrix4(modelMatrix);
			
			var faceVertexNormals:Array<Vector3> = face.vertexNormals;
			
			var n = 0, nl = faceVertexNormals.length;
			while (n < nl)
			{
				var normalModel:Vector3 = current.vertexNormalsModel[n];
				normalModel.copy(faceVertexNormals[n]);
				
				if (visible == false && (side == THREE.BackSide || side == THREE.DoubleSide))
				{
					normalModel.negate();
				}
				
				normalModel.applyMatrix3(normalMatrix);
				normalModel.normalize();
				
				var normalModelView:Vector3 = current.vertexNormalsModelView[n];
				normalModelView.copy(normalModel);
				normalModelView.applyMatrix3(normalViewMatrix);
				n++;
			}
			
			current.vertexNormalsLength = faceVertexNormals.length;
			
			var c = 0, cl = faceVertexUvs.length;
			while (c < cl)
			{
				var uvs:Array<Vector3> = faceVertexUvs[c][f - 1]; //-1 since we incremented `f` early
				if (uvs == null) continue;
				var u = 0, ul = uvs.length;
				while (u < ul)
				{
					current.uvs[c][u] = uvs[u];
					u++;
				}
				c++;
			}
			
			current.color = face.color;
			current.material = material;
			
			centroid.copy(current.centroidModel);
			centroid.applyProjection(viewProjectionMatrix);
			
			current.z = centroid.z;
			renderData.elements.push(current);
		}
	}
	
	
	
	
	
	//Pools
	
	public function getNextObjectInPool () : RenderableObject
	{
		if (objectCount == objectPoolLength)
		{
			var obj = new RenderableObject();
			objectPool.push(obj);
			objectPoolLength++;
			objectCount++;
			return obj;
		}
		return objectPool[objectCount++];
	}
	
	
	public function getNextVertexInPool () : RenderableVertex
	{
		if (vertexCount == vertexPoolLength)
		{
			var vert = new RenderableVertex();
			vertexPool.push(vert);
			vertexPoolLength++;
			vertexCount++;
			return vert;
		}
		return vertexPool[vertexCount++];
	}
	
	
	public function getNextFace3InPool () : RenderableFace3
	{
		if (face3Count == face3PoolLength)
		{
			var f3 = new RenderableFace3();
			face3Pool.push(f3);
			face3PoolLength++;
			face3Count++;
			return f3;
		}
		return face3Pool[face3Count++];
	}
	
	
	public function getNextFace4InPool () : RenderableFace4
	{
		if (face4Count == face4PoolLength)
		{
			var f4 = new RenderableFace4();
			face4Pool.push(f4);
			face4PoolLength++;
			face4Count++;
			return f4;
		}
		return face4Pool[face4Count++];
	}
	
	
	public function getNextLineInPool () : RenderableLine
	{
		if (lineCount == linePoolLength)
		{
			var line = new RenderableLine();
			linePool.push(line);
			linePoolLength++;
			lineCount++;
			return line;
		}
		return linePool[lineCount++];
	}
	
	
	public function getNextParticleInPool () : RenderableParticle
	{
		if (particleCount == particlePoolLength)
		{
			var particle = new RenderableParticle();
			particlePool.push(particle);
			particlePoolLength++;
			particleCount++;
			return particle;
		}
		return particlePool[particleCount++];
	}
	
	
	public function painterSort (a:Dynamic, b:Dynamic) : Float
	{
		return b.z - a.z;
	}
	
	
	public function clipLine (s1:Vector4, s2:Vector4) : Bool
	{
		var alpha1:Float = 0, alpha2:Float = 1;
		
		var bc1near = s1.z + s1.w;
		var bc2near = s2.z + s2.w;
		var bc1far = -s1.z + s1.w;
		var bc2far = -s2.z + s2.w;
		
		if (bc1near >= 0 && bc2near >= 0 && bc1far >= 0 && bc2far >= 0) return true;
		else if ( (bc1near < 0 && bc2near < 0) || (bc1far < 0 && bc2far < 0) ) return false
		else {
			if (bc1near < 0) alpha1 = Math.max(alpha1, bc1near / (bc1near - bc2near));
			else if (bc2near < 0) alpha2 = Math.min(alpha2, bc1near / (bc1near - bc2near));
			
			if (bc1far < 0) alpha1 = Math.max(alpha1, bc1far / (bc1far - bc2far));
			else if (bc2far < 0) alpha2 = Math.min(alpha2, bc1far / (bc1far - bc2far));
			
			if (alpha2 < alpha1) return false;
			else {
				s1.lerp(s2, alpha1);
				s2.lerp(s1, 1 - alpha2);
				return true;
			}
		}
	}
}



