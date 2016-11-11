/*
 * Copyright (C)2005-2016 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
package haxe.io;

typedef ByteArrayImpl = cs.NativeArray<cs.StdTypes.UInt8>;

abstract ByteArray(ByteArrayImpl) {

	public static inline var getIsChecked = true;
	public static inline var setIsChecked = true;
	
	public static inline var blitCanThrow = false;
	public static inline var subCanThrow = false;
	public static inline var getStringCanThrow = false;

	public var length(get,never) : Int;

	public inline function new (impl:ByteArrayImpl) {
		this = impl;
	}

	inline function get_length ():Int {
		return this.Length;
	}

	static inline function mk (data:ByteArrayImpl):ByteArray {
		return new ByteArray(data);
	}

	public inline function getData ():BytesData {
		return this;
	}
	
	inline function raw () return this;

	public static inline function ofData (data:BytesData) {
		return mk(data);
	}

	public inline function get( pos : Int ) : Int { 
		return this[pos];
	}

	public inline function set( pos : Int, v : Int ) : Void { 
		this[pos] = cast v;
	}

	public inline function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		cs.system.Array.Copy(src.raw(), srcpos, this, pos, len);
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		for( i in 0...len )
			set(pos++, value);
	}

	public inline function sub( pos : Int, len : Int ) : ByteArray { 
		var newarr = new cs.NativeArray(len);
		cs.system.Array.Copy(this, pos, newarr, 0, len);
		return mk(newarr);
	}

	public function compare( other : ByteArray ) : Int { 
		var b1 = this;
		var b2 = other.raw();
		var len = (length < other.length) ? length : other.length;
		for( i in 0...len )
			if( b1[i] != b2[i] )
				return untyped b1[i] - untyped b2[i];
		return length - other.length;
	}

	public inline function getDouble( pos : Int ) : Float { 
		return FPHelper.i64ToDouble(getInt32(pos),getInt32(pos+4));
	}

	public inline function getFloat( pos : Int ) : Float { 
		var b = new haxe.io.BytesInput(Bytes.ofData(this),pos,4);
		return b.readFloat();
	}

	public inline function setDouble( pos : Int, v : Float ) : Void { 
		var i = FPHelper.doubleToI64(v);
		setInt32(pos, i.low);
		setInt32(pos + 4, i.high);
	}

	public inline function setFloat( pos : Int, v : Float ) : Void { 
		setInt32(pos, FPHelper.floatToI32(v));
	}

	public inline function getUInt16( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8);
	}

	public inline function setUInt16( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
	}

	public inline function getInt32( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8) | (get(pos + 2) << 16) | (get(pos+3) << 24);
	}
	
	public inline function getInt64( pos : Int ) : haxe.Int64 { 
		return haxe.Int64.make(getInt32(pos+4),getInt32(pos));
	}
	
	public inline function setInt32( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
		set(pos + 2, v >> 16);
		set(pos + 3, v >>> 24);
	}
	
	public inline function setInt64( pos : Int, v : haxe.Int64 ) : Void { 
		setInt32(pos, v.low);
		setInt32(pos + 4, v.high);
	}

	public inline function getString( pos : Int, len : Int ) : String { 
		return cs.system.text.Encoding.UTF8.GetString(this, pos, len);
	}

	public inline function toString() : String { 
		return cs.system.text.Encoding.UTF8.GetString(this, 0, length);
	}

	public static inline function alloc( length : Int ) : ByteArray { 
		return mk(new cs.NativeArray(length));
	}

	public static inline function ofString( s : String ) : ByteArray { 
		var b = cs.system.text.Encoding.UTF8.GetBytes(s);
		return mk(b);
	}


}
