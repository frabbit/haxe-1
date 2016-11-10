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


using cpp.NativeArray;

typedef ByteArrayImpl = Array< cpp.UInt8 >;

abstract ByteArray(ByteArrayImpl) {
	public var length(get,never) : Int;

	inline function new (impl:ByteArrayImpl) {
		this = impl;
	}

	public inline function getData ():BytesData {
		return this;
	}
	
	inline function raw () return this;

	public static inline function ofData (data:BytesData) {
		return mk(data);
	}

	inline function get_length ():Int {
		return untyped this.length;
	}

	static inline function mk (data:ByteArrayImpl):ByteArray {
		return new ByteArray(data);
	}

	public inline function get( pos : Int ) : Int { 
		return untyped this[pos];
	}

	public inline function set( pos : Int, v : Int ) : Void { 
		untyped this[pos] = v;
	}

	public inline function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		this.blit(pos, src.raw(), srcpos, len);
	}

	public inline function fill( pos : Int, len : Int, value : Int ):Void { 
		untyped __global__.__hxcpp_memory_memset(this,pos,len,value);
	}

	public inline function sub( pos : Int, len : Int ) : ByteArray { 
		return mk(this.slice(pos,pos+len));
	}

	public inline function compare( other : ByteArray ) : Int { 
		return this.memcmp(other.raw());
	}

	public inline function getDouble( pos : Int ) : Float { 
		return untyped __global__.__hxcpp_memory_get_double(this,pos);
	}

	public inline function getFloat( pos : Int ) : Float { 
		return untyped __global__.__hxcpp_memory_get_float(this,pos);
	}

	public inline function setDouble( pos : Int, v : Float ) : Void { 
		untyped __global__.__hxcpp_memory_set_double(this,pos,v);
	}

	public inline function setFloat( pos : Int, v : Float ) : Void { 
		untyped __global__.__hxcpp_memory_set_float(this,pos,v);
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

	public function getString( pos : Int, len : Int ) : String { 
		var result:String="";
		untyped __global__.__hxcpp_string_of_bytes(this,result,pos,len);
		return result;
	}

	public inline function toString() : String { 
		return getString(0,length);
	}

	public inline function fastGet( pos : Int ) : Int { 
		return untyped this.unsafeGet(pos);
	}

	public static function alloc( length : Int ) : ByteArray { 
		var a = new ByteArrayImpl();
		if (length>0) cpp.NativeArray.setSize(a, length);
		return mk(a);
	}

	public static function ofString( s : String ) : ByteArray { 
		var a = new ByteArrayImpl();
		untyped __global__.__hxcpp_bytes_of_string(a,s);
		return mk(a);
	}


}
