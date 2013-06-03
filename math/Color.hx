
package three.math;

/**
 * 
 * @author dcm
 */

class Color
{
	
	public var r:Float = 1.0;
	public var g:Float = 1.0;
	public var b:Float = 1.0;

	
	public function new(value:Int = null) 
	{
		if (value != null) set(value);
	}

	
	public function set (value:Dynamic) : Color
	{
		if      (Std.is(value, Color) == true) copy(value);
		else if (Std.is(value, Int) == true) setHex(value);
		else if (Std.is(value, String) == true) setStyle(value);
		return this;
	}
	
	
	public function setHex (hex:Int) : Color
	{
		r = (hex >> 16 & 255) / 255;
		g = (hex >> 8 & 255) / 255;
		b = (hex & 255) / 255;
		return this;
	}
	
	
	public function setRGB (r:Float, g:Float, b:Float) : Color
	{
		this.r = r;
		this.g = g;
		this.b = b;
		return this;
	}
	
	
	public function hue2rgb (p:Float, q:Float, t:Float) : Float
	{
		if (t < 0) t += 1;
		if (t > 1) t -= 1;
		if (t < 1 / 6) return p + (q - p) * 6 * t;
		if (t < 1 / 2) return q;
		if (t < 2 / 3) return p + (q - p) * 6 * (2 / 3 - t);
		return p;
	}
	
	
	public function setHSL (h:Float, s:Float, l:Float) : Color
	{
		if (s == 0) r = g = b = l;
		else {
			var p = l <= 0.5 ? l * (1 + s) : l + s - (l * s);
			var q = (2 * l) - p;
			r = hue2rgb(q, p, h + 1 / 3);
			g = hue2rgb(q, p, h);
			b = hue2rgb(q, p, h - 1 / 3);
		}
		return this;
	}
	
	
	public function setStyle (style:String) : Color
	{
		var r1:EReg = ~/^rgb\((\d+),(\d+),(\d+)\)$/i;
		if (r1.match(style) != null)
		{
			var rgbExpr:EReg = ~/^rgb\((\d+),(\d+),(\d+)\)$/i;
			var color = rgbExpr.split(style);
			r = Math.min(255, Std.parseInt(color[1])) / 255;
			g = Math.min(255, Std.parseInt(color[2])) / 255;
			b = Math.min(255, Std.parseInt(color[3])) / 255;
			return this;
			
		}
		
		//todo - finish this... (maybe)
		return this;
	}
	
	
	public function copy (color:Color) : Color
	{
		r = color.r;
		g = color.g;
		b = color.b;
		return this;
	}
	
	
	public function copyGammaToLinear (color:Color) : Color
	{
		r = color.r * color.r;
		g = color.g * color.g;
		b = color.b * color.b;
		return this;
	}
	
	
	public function copyLinearToGamma (color:Color) : Color
	{
		r = Math.sqrt(color.r);
		g = Math.sqrt(color.g);
		b = Math.sqrt(color.b);
		return this;
	}
	
	
	public function convertGammaToLinear () : Color
	{
		var tr = r, tg = g, tb = b;
		r = tr * tr;
		g = tg * tg;
		b = tb * tb;
		return this;
	}
	
	
	public function convertLinearToGamma () : Color
	{
		r = Math.sqrt(r);
		g = Math.sqrt(g);
		b = Math.sqrt(b);
		return this;
	}
	
	
	public function getHex () : Int
	{
		return Math.round(r * 255) << 16 ^ Math.round(g * 255) << 8 ^ Math.round(b * 255) << 0;
	}
	
	
	public function getHexString () : String
	{
		var hex = getHex();
		return '000000'; //todo - int->hexstring
	}
	
	
	public function getHSL () : Dynamic
	{
		//todo
		return { };
	}
	
	
	public function getStyle () : String
	{
		var tr = (Math.round(r * 255) | 0);
		var tg = (Math.round(g * 255) | 0);
		var tb = (Math.round(b * 255) | 0);
		return 'rgb($tr,$tg,$tb)';
	}
	
	
	public function offsetHSL (h:Float, s:Float, l:Float) : Color
	{
		//todo
		return this;
	}
	
	
	public function add (color:Color) : Color
	{
		r += color.r;
		g += color.g;
		b += color.b;
		return this;
	}
	
	
	public function addColors (c1:Color, c2:Color) : Color
	{
		r = c1.r + c2.r;
		g = c1.g + c2.g;
		b = c1.b + c2.b;
		return this;
	}
	
	
	public function addScalar (s:Float) : Color
	{
		r += s;
		g += s;
		b += s;
		return this;
	}
	
	
	public function multiply (c:Color) : Color
	{
		r *= c.r;
		g *= c.g;
		b *= c.b;
		return this;
	}
	
	
	public function multiplyScalar (s:Float) : Color
	{
		r *= s;
		g *= s;
		b *= s;
		return this;
	}
	
	
	public function lerp (c:Color, alpha:Float) : Color
	{
		r += (c.r - r) * alpha;
		g += (c.g - g) * alpha;
		b += (c.b - b) * alpha;
		return this;
	}
	
	
	public function equals (c:Color) : Bool
	{
		return ( c.r == r ) && ( c.g == g ) && ( c.b == b );
	}
	
	
	public function clone () : Color
	{
		return new Color().setRGB(r, g, b);
	}
	
	
}



