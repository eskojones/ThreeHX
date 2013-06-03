
package three;



/**
 * 
 * @author dcm
 */

class THREE
{
	
	//Object3D type-flags
	static public var Mesh:Int = 0;
	static public var Light:Int = 1;
	static public var AmbientLight:Int = 2;
	
	//Renderable type-flags
	static public var RenderableFace3:Int = 0;
	static public var RenderableFace4:Int = 1;
	static public var RenderableLine:Int = 2;
	static public var RenderableObject:Int = 3;
	static public var RenderableParticle:Int = 4;
	static public var RenderableVertex:Int = 5;
	
	
	static public var defaultEulerOrder:String = 'XYZ';
	
	
	// ----- Original THREE.js Constants -----
	
	//GL State Constants
	static public var CullFaceNone:Int = 0;
	static public var CullFaceBack:Int = 1;
	static public var CullFaceFront:Int = 2;
	static public var CullFaceFrontBack:Int = 3;
	
	static public var FrontFaceDirectionCW:Int = 0;
	static public var FrontFaceDirectionCCW:Int = 1;
	
	//Shadowing Types
	static public var BasicShadowMap:Int = 0;
	static public var PCFShadowMap:Int = 1;
	static public var PCFSoftShadowMap:Int = 2;
	
	//Material Sides
	static public var FrontSide:Int = 0;
	static public var BackSide:Int = 1;
	static public var DoubleSide:Int = 2;
	
	//Material Shading
	static public var NoShading:Int = 0;
	static public var FlatShading:Int = 1;
	static public var SmoothShading:Int = 2;
	
	//Material Colors
	static public var NoColors:Int = 0;
	static public var FaceColors:Int = 1;
	static public var VertexColors:Int = 2;
	
	//Blending
	static public var NoBlending:Int = 0;
	static public var NormalBlending:Int = 1;
	static public var AdditiveBlending:Int = 2;
	static public var SubtractiveBlending:Int = 3;
	static public var MultiplyBlending:Int = 4;
	static public var CustomBlending:Int = 5;
	
	/*
	 * Custom blending equations
	 * Numbers start from 100 to not clash with other mappings to OpenGL constants
	 */
	static public var AddEquation:Int = 100;
	static public var SubtractEquation:Int = 101;
	static public var ReverseSubtractEquation:Int = 102;
	
	//Custom blending destination factors
	static public var ZeroFactor:Int = 200;
	static public var OneFactor:Int = 201;
	static public var SrcColorFactor:Int = 202;
	static public var OneMinusSrcColorFactor:Int = 203;
	static public var SrcAlphaFactor:Int = 204;
	static public var OneMinusSrcAlphaFactor:Int = 205;
	static public var DstAlphaFactor:Int = 206;
	static public var OneMinusDstAlphaFactor:Int = 207;
	
	//Custom blending source factors
	static public var DstColorFactor:Int = 208;
	static public var OneMinusDstColorFactor:Int = 209;
	static public var SrcAlphaSaturateFactor:Int = 210;
	
	//Textures
	static public var MultiplyOperation:Int = 0;
	static public var MixOperation:Int = 1;
	static public var AddOperation:Int = 2;
	
	//Mapping Modes - these were empty functions.. 
	static public var UVMapping:Int = 0;
	static public var CubeRflectionMapping:Int = 1;
	static public var CubeRefractionMapping:Int = 2;
	static public var SphericalReflectionMapping:Int = 3;
	static public var SphericalRefractionMapping:Int = 4;
	
	//Wrapping Modes
	static public var RepeatWrapping:Int = 1000;
	static public var ClampToEdgeWrapping:Int = 1001;
	static public var MirroredRepeatWrapping:Int = 1002;
	
	//Filters
	static public var NearestFilter:Int = 1003;
	static public var NearestMipMapNearestFilter:Int = 1004;
	static public var NearestMipMapLinearFilter:Int = 1005;
	static public var LinearFilter:Int = 1006;
	static public var LinearMipMapNearestFilter:Int = 1007;
	static public var LinearMipMapLinearFilter:Int = 1008;
	
	//Data Types
	static public var UnsignedByteType:Int = 1009;
	static public var ByteType:Int = 1010;
	static public var ShortType:Int = 1011;
	static public var UnsignedShortType:Int = 1012;
	static public var IntType:Int = 1013;
	static public var UnsignedIntType:Int = 1014;
	static public var FloatType:Int = 1015;
	
	//Pixel Types
	static public var UnsignedShort4444Type:Int = 1016;
	static public var UnsignedShort5551Type:Int = 1017;
	static public var UnsignedShort565Type:Int = 1018;
	
	//Pixel Formats
	static public var AlphaFormat:Int = 1019;
	static public var RGBFormat:Int = 1020;
	static public var RGBAFormat:Int = 1021;
	static public var LuminanceFormat:Int = 1022;
	static public var LuminanceAlphaFormat:Int = 1023;
	
	//Compressed Texture Formats
	static public var RGB_S3TC_DXT1_Format:Int = 2001;
	static public var RGBA_S3TC_DXT1_Format:Int = 2002;
	static public var RGBA_S3TC_DXT3_Format:Int = 2003;
	static public var RGBA_S3TC_DXT5_Format:Int = 2004;
	
}

