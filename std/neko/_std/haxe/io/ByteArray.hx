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

private typedef ByteArrayImpl = BytesData;


abstract ByteArray(ByteArrayImpl) {

	public static inline var getIsChecked = false;
	public static inline var setIsChecked = false;
	public static inline var blitCanThrow = true;
	public static inline var subCanThrow = true;
	public static inline var getStringCanThrow = true;

	public var length(get,never) : Int;

	inline function get_length ():Int {
		return untyped __dollar__ssize(this);
	}

	inline static function mk (impl:ByteArrayImpl) {
		return new ByteArray(impl);
	}

	public inline function getData ():BytesData {
		return this;
	}
	
	public static inline function ofData (data:BytesData) {
		return mk(data);
	}

	inline function new (impl:ByteArrayImpl) {
		this = impl;
	}

	inline function raw ():ByteArrayImpl return this;

	public inline function get( pos : Int ) : Int { 
		return untyped $sget(this,pos);
	}

	public inline function set( pos : Int, v : Int ) : Void { 
		untyped $sset(this,pos,v);
	}

	public inline function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		return untyped $sblit(this,pos,src.raw(),srcpos,len);
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		for( i in 0...len ) set(pos++, value);
	}

	public inline function sub( pos : Int, len : Int ) : ByteArray { 
		return mk(untyped __dollar__ssub(this,pos,len));
	}

	public inline function compare( other : ByteArray ) : Int { 
		return untyped __dollar__compare(this,other.raw());
	}
	
	public inline function getDouble( pos : Int ) : Float { 
		#if neko_v21
		return untyped $sgetd(this, pos, false);
		#else
		return FPHelper.i64ToDouble(getInt32(pos),getInt32(pos+4));
		#end
	}

	#if neko_v21 inline #end
	public function getFloat( pos : Int ) : Float { 
		#if neko_v21
		return untyped $sgetf(this, pos, false);
		#else
		var b = new haxe.io.BytesInput(haxe.io.Bytes.ofData(this),pos,4);
		return b.readFloat();
		#end
	}

	public inline function setDouble( pos : Int, v : Float ) : Void { 
		#if neko_v21
		untyped $ssetd(this, pos, v, false);
		#else
		untyped $sblit(this, pos, FPHelper._double_bytes(v,false), 0, 8);
		#end
	}

	public inline function setFloat( pos : Int, v : Float ) : Void { 
		#if neko_v21
		untyped $ssetf(this, pos, v, false);
		#else
		untyped $sblit(this, pos, FPHelper._float_bytes(v,false), 0, 4);
		#end
	}

	public inline function getUInt16( pos : Int ) : Int { 
		#if neko_v21
		return untyped $sget16(this, pos, false);
		#else
		return get(pos) | (get(pos + 1) << 8);
		#end
	}

	public inline function setUInt16( pos : Int, v : Int ) : Void { 
		#if neko_v21
		untyped $sset16(this, pos, v, false);
		#else
		set(pos, v);
		set(pos + 1, v >> 8);
		#end
	}

	public inline function getInt32( pos : Int ) : Int { 
		#if neko_v21
		return untyped $sget32(this, pos, false);
		#else
		return get(pos) | (get(pos + 1) << 8) | (get(pos + 2) << 16) | (get(pos+3) << 24);
		#end

	}
	
	public function getInt64( pos : Int ) : haxe.Int64 { 
		return haxe.Int64.make(getInt32(pos+4),getInt32(pos));
	}
	
	public inline function setInt32( pos : Int, v : Int ) : Void { 
		#if neko_v21
		untyped $sset32(this, pos, v, false);
		#else
		set(pos, v);
		set(pos + 1, v >> 8);
		set(pos + 2, v >> 16);
		set(pos + 3, v >>> 24);
		#end
	}
	
	public function setInt64( pos : Int, v : haxe.Int64 ) : Void { 
		setInt32(pos, v.low);
		setInt32(pos + 4, v.high);
	}

	public inline function getString( pos : Int, len : Int ) : String { 
		return new String(untyped __dollar__ssub(this,pos,len));
	}

	public inline function toString() : String {
		return getString(0, length); 
	}

	public static function alloc( length : Int ) : ByteArray { 
		return mk(untyped __dollar__smake(length));
	}

	public static inline function ofString( s : String ) : ByteArray {
		return mk( untyped __dollar__ssub(s.__s,0,s.length));
	}

}
