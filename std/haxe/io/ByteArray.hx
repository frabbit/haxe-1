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



abstract ByteArray({}) {
	public var length(get,never) : Int;

	public function new () {
		this = throw "abstract";
	}

	public inline function getData () {
		return throw "abstract";
	}

	public static function ofData (data:BytesData) {
		return throw "abstract";
	}

	function get_length() : Int return throw "abstract";
	public function get( pos : Int ) : Int return throw "abstract";

	public function set( pos : Int, v : Int ) : Void return throw "abstract";

	public function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void return throw "abstract";

	public function fill( pos : Int, len : Int, value : Int ):Void return throw "abstract";

	public function sub( pos : Int, len : Int ) : ByteArray return throw "abstract";

	public function compare( other : ByteArray ) : Int return throw "abstract";

	public function getDouble( pos : Int ) : Float return throw "abstract";

	public function getFloat( pos : Int ) : Float return throw "abstract";

	public function setDouble( pos : Int, v : Float ) : Void return throw "abstract";

	public function setFloat( pos : Int, v : Float ) : Void return throw "abstract";

	public function getUInt16( pos : Int ) : Int return throw "abstract";

	public function setUInt16( pos : Int, v : Int ) : Void return throw "abstract";

	public function getInt32( pos : Int ) : Int return throw "abstract";
	
	public function getInt64( pos : Int ) : haxe.Int64 return throw "abstract";
	
	public function setInt32( pos : Int, v : Int ) : Void return throw "abstract";
	
	public function setInt64( pos : Int, v : haxe.Int64 ) : Void return throw "abstract";

	public function getString( pos : Int, len : Int ) : String return throw "abstract";

	public function toString() : String return throw "abstract";

	public function fastGet( pos : Int ) : Int return throw "abstract";

	public static function alloc( length : Int ) : ByteArray return throw "abstract";

	public static function ofString( s : String ) : ByteArray return throw "abstract";
}

/*
// Template

typedef ByteArrayImpl = ...
abstract ByteArray(ByteArrayImpl) {
	public var length(get,null) : Int;

	inline function new (impl:ByteArrayImpl) {
		this = impl;
	}

	inline function get_length ():Int {
		
	}

	inline function mk (data:ByteArrayImpl):ByteArray {
		return new ByteArray(data);
	}

	public function get( pos : Int ) : Int { 
		
	}

	public function set( pos : Int, v : Int ) : Void { 
		
	}

	public function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		
	}

	public function sub( pos : Int, len : Int ) : ByteArray { 
		
	}

	public function compare( other : ByteArray ) : Int { 
		
	}

	public function getDouble( pos : Int ) : Float { 
		
	}

	public function getFloat( pos : Int ) : Float { 
		
	}

	public function setDouble( pos : Int, v : Float ) : Void { 
		
	}

	public function setFloat( pos : Int, v : Float ) : Void { 
		
	}

	public function getUInt16( pos : Int ) : Int { 
		
	}

	public function setUInt16( pos : Int, v : Int ) : Void { 
		
	}

	public function getInt32( pos : Int ) : Int { 
		
	}
	
	public function getInt64( pos : Int ) : haxe.Int64 { 
		
	}
	
	public function setInt32( pos : Int, v : Int ) : Void { 
		
	}
	
	public function setInt64( pos : Int, v : haxe.Int64 ) : Void { 
		
	}

	public function getString( pos : Int, len : Int ) : String { 
		
	}

	public function toString() : String { 
		
	}

	public static function alloc( length : Int ) : ByteArray { 
		
	}

	public static function ofString( s : String ) : ByteArray { 
		
	}

	public function fastGet( pos : Int ) : Int { 
		
	}
}

// Neko

class ByteArrayImpl {
	public var length:Int;
	public var data : neko.NativeString;

	public function new (data:neko.NativeString, length:Int) {
		this.data = data;
		this.length = length;
	}
}


abstract ByteArray(ByteArrayImpl) {
	public var length(get,null) : Int;

	inline function get_length ():Int {
		return this.length;
	}

	public function new (impl:ByteArrayImpl) {
		this = impl;
	}

	inline function raw () return this.data;

	public inline function get( pos : Int ) : Int { 
		return untyped $sget(raw(),pos);
	}

	public inline function set( pos : Int, v : Int ) : Void { 
		untyped $sset(raw(),pos,v);
	}

	public inline function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		return untyped $sblit(b,pos,src.b,srcpos,len);
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		for( i in 0...len ) set(pos++, value);
	}

	public inline function sub( pos : Int, len : Int ) : ByteArray { 
		return mk(untyped __dollar__ssub(raw(),pos,len), len);
	}

	public inline function compare( other : ByteArray ) : Int { 
		return untyped __dollar__compare(raw(),other);
	}
	
	public inline function getDouble( pos : Int ) : Float { 
		#if neko_v21
		return untyped $sgetd(raw(), pos, false);
		#else
		return FPHelper.i64ToDouble(getInt32(pos),getInt32(pos+4));
		#end
	}

	#if neko_v21 inline #end
	public function getFloat( pos : Int ) : Float { 
		#if neko_v21
		return untyped $sgetf(raw(), pos, false);
		#else
		var b = new haxe.io.BytesInput(haxe.io.Bytes.fromData(new ByteArray(this)),pos,4);
		return b.readFloat();
		#end
	}

	public inline function setDouble( pos : Int, v : Float ) : Void { 
		#if neko_v21
		untyped $ssetd(raw(), pos, v, false);
		#else
		untyped $sblit(raw(), pos, FPHelper._double_bytes(v,false), 0, 8);
		#end
	}

	public inline function setFloat( pos : Int, v : Float ) : Void { 
		#if neko_v21
		untyped $ssetf(raw(), pos, v, false);
		#else
		untyped $sblit(raw(), pos, FPHelper._float_bytes(v,false), 0, 4);
		#end
	}

	public inline function getUInt16( pos : Int ) : Int { 
		#if neko_v21
		return untyped $sget16(raw(), pos, false);
		#else
		return get(pos) | (get(pos + 1) << 8);
		#end
	}

	public inline function setUInt16( pos : Int, v : Int ) : Void { 
		#if neko_v21
		untyped $sset16(raw(), pos, v, false);
		#else
		set(pos, v);
		set(pos + 1, v >> 8);
		#end
	}

	public inline function getInt32( pos : Int ) : Int { 
		#if neko_v21
		return untyped $sget32(raw(), pos, false);
		#else
		return get(pos) | (get(pos + 1) << 8) | (get(pos + 2) << 16) | (get(pos+3) << 24);
		#end

	}
	
	public function getInt64( pos : Int ) : haxe.Int64 { 
		return haxe.Int64.make(getInt32(pos+4),getInt32(pos));
	}
	
	public inline function setInt32( pos : Int, v : Int ) : Void { 
		#if neko_v21
		untyped $sset32(raw(), pos, v, false);
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
		return new String(untyped __dollar__ssub(raw(),pos,len));
	}

	public inline function toString() : String {
		return new String(untyped __dollar__ssub(raw(),0,length)); 
	}

	public static function alloc( length : Int ) : ByteArray { 
		var data = untyped __dollar__smake(length);
		return mk(data, length);
	}

	inline static function mk (data:neko.NativeString, length:Int) {
		return mk(data, length);
	}

	public static inline function ofString( s : String ) : ByteArray {
		return mk( untyped __dollar__ssub(s.__s,0,s.length), s.length)
	}

	public function fastGet( pos : Int ) : Int { 
		return untyped __dollar__sget(b,pos);
	}
}

// python

typedef ByteArrayImpl = python.Bytearray;

abstract ByteArray({}) {
	public var length(get,null) : Int;

	inline function get_length ():Int {
		return this.length;
	}

	inline function raw ():python.ByteArray {
		return this;
	}

	public function new (impl:ByteArray) {
		this = impl;
	}

	inline function mk (data:python.ByteArray) {
		return new ByteArray(data);
	}

	public function get( pos : Int ) : Int { 
		return python.Syntax.arrayAccess(this, pos);
	}

	public function set( pos : Int, v : Int ) : Void { 
		python.Syntax.arraySet(this, pos, v & 0xFF);
	}

	public function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		python.Syntax.pythonCode("{2}[{0}:{0}+{1}] = {2}[{3}:{3}+{1}]", pos, len, this, srcpos);
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		for( i in 0...len ) set(pos++, value);
	}

	public function sub( pos : Int, len : Int ) : ByteArray { 
		return mk(python.Syntax.arrayAccess(this, pos, pos+len) );
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

	public function getFloat( pos : Int ) : Float { 
		var b = new haxe.io.BytesInput(Bytes.ofData(this),pos,4);
		return b.readFloat();
	}

	public function setDouble( pos : Int, v : Float ) : Void { 
		var i = FPHelper.doubleToI64(v);
		setInt32(pos, i.low);
		setInt32(pos + 4, i.high);
	}

	public function setFloat( pos : Int, v : Float ) : Void { 
		setInt32(pos, FPHelper.floatToI32(v));
	}

	public function getUInt16( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8);
	}

	public function setUInt16( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
	}

	public function getInt32( pos : Int ) : Int { 
		var v = get(pos) | (get(pos + 1) << 8) | (get(pos + 2) << 16) | (get(pos+3) << 24);
		return if( v & 0x80000000 != 0 ) v | 0x80000000 else v;
	}
	
	public function getInt64( pos : Int ) : haxe.Int64 { 
		return haxe.Int64.make(getInt32(pos+4),getInt32(pos));
	}
	
	public function setInt32( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
		set(pos + 2, v >> 16);
		set(pos + 3, v >>> 24);
	}
	
	public function setInt64( pos : Int, v : haxe.Int64 ) : Void { 
		setInt32(pos, v.low);
		setInt32(pos + 4, v.high);
	}

	public function getString( pos : Int, len : Int ) : String { 
		return python.Syntax.pythonCode("{2}[{0}:{0}+{1}].decode('UTF-8','replace')", pos, len, this);
	}

	public function toString() : String { 
		return getString(0,length);
	}

	public static function alloc( length : Int ) : ByteArray { 
		return mk(new python.Bytearray(length));
	}

	public static function ofString( s : String ) : ByteArray { 
		return mk(new python.Bytearray(s, "UTF-8"));
	}

	public function fastGet( pos : Int ) : Int { 
		return return b[pos];
	}
}


// cpp

typedef ByteArrayImpl = Array< cpp.UInt8 >;

abstract ByteArray({}) {
	public var length(get,null) : Int;

	public function new (impl:ByteArrayImpl) {
		this = impl;
	}

	inline function raw ():Array<cpp.UInt8> return impl;

	inline function get_length ():Int {
		return untyped this.length;
	}

	inline function mk (data:ByteArrayImpl):ByteArray {
		return new ByteArray(data);
	}

	public function get( pos : Int ) : Int { 
		return untyped this[pos];
	}

	public function set( pos : Int, v : Int ) : Void { 
		untyped this[pos] = v;
	}

	public function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		this.blit(pos, src.raw(), srcpos, len);
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		untyped __global__.__hxcpp_memory_memset(this,pos,len,value);
	}

	public function sub( pos : Int, len : Int ) : ByteArray { 
		return mk(this.slice(pos,pos+len)));
	}

	public function compare( other : ByteArray ) : Int { 
		return this.memcmp(other.raw());
	}

	public function getDouble( pos : Int ) : Float { 
		return untyped __global__.__hxcpp_memory_get_double(this,pos);
	}

	public function getFloat( pos : Int ) : Float { 
		return untyped __global__.__hxcpp_memory_get_float(this,pos);
	}

	public function setDouble( pos : Int, v : Float ) : Void { 
		untyped __global__.__hxcpp_memory_set_double(this,pos,v);
	}

	public function setFloat( pos : Int, v : Float ) : Void { 
		untyped __global__.__hxcpp_memory_set_float(this,pos,v);
	}

	public function getUInt16( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8);
	}

	public function setUInt16( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
	}

	public function getInt32( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8) | (get(pos + 2) << 16) | (get(pos+3) << 24);
	}
	
	public function getInt64( pos : Int ) : haxe.Int64 { 
		return haxe.Int64.make(getInt32(pos+4),getInt32(pos));
	}
	
	public function setInt32( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
		set(pos + 2, v >> 16);
		set(pos + 3, v >>> 24);
	}
	
	public function setInt64( pos : Int, v : haxe.Int64 ) : Void { 
		setInt32(pos, v.low);
		setInt32(pos + 4, v.high);
	}

	public function getString( pos : Int, len : Int ) : String { 
		var result:String="";
		untyped __global__.__hxcpp_string_of_bytes(this,result,pos,len);
		return result;
	}

	public function toString() : String { 
		return getString(0,length);
	}

	public function fastGet( pos : Int ) : Int { 
		return untyped b.unsafeGet(pos);
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

// cs

typedef ByteArrayImpl = cs.NativeArray<cs.StdTypes.UInt8>;

abstract ByteArray(ByteArrayImpl) {
	public var length(get,null) : Int;

	public inline function new (impl:ByteArrayImpl) {
		this = impl;
	}

	inline function get_length ():Int {
		return this.Length;
	}

	inline function mk (data:ByteArrayImpl):ByteArray {
		return new ByteArray(data);
	}

	

	public function get( pos : Int ) : Int { 
		return b[pos];
	}

	public function set( pos : Int, v : Int ) : Void { 
		b[pos] = cast v;
	}

	public function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		cs.system.Array.Copy(src.raw(), srcpos, b, pos, len);
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		for( i in 0...len )
			set(pos++, value);
	}

	public function sub( pos : Int, len : Int ) : ByteArray { 
		var newarr = new cs.NativeArray(len);
		cs.system.Array.Copy(b, pos, newarr, 0, len);
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

	public function getDouble( pos : Int ) : Float { 
		return FPHelper.i64ToDouble(getInt32(pos),getInt32(pos+4));
	}

	public function getFloat( pos : Int ) : Float { 
		var b = new haxe.io.BytesInput(Bytes.ofData(new ByteArray(this)),pos,4);
		return b.readFloat();
	}

	public function setDouble( pos : Int, v : Float ) : Void { 
		var i = FPHelper.doubleToI64(v);
		setInt32(pos, i.low);
		setInt32(pos + 4, i.high);
	}

	public function setFloat( pos : Int, v : Float ) : Void { 
		setInt32(pos, FPHelper.floatToI32(v));
	}

	public function getUInt16( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8);
	}

	public function setUInt16( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
	}

	public function getInt32( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8) | (get(pos + 2) << 16) | (get(pos+3) << 24);
	}
	
	public function getInt64( pos : Int ) : haxe.Int64 { 
		return haxe.Int64.make(getInt32(pos+4),getInt32(pos));
	}
	
	public function setInt32( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
		set(pos + 2, v >> 16);
		set(pos + 3, v >>> 24);
	}
	
	public function setInt64( pos : Int, v : haxe.Int64 ) : Void { 
		setInt32(pos, v.low);
		setInt32(pos + 4, v.high);
	}

	public function getString( pos : Int, len : Int ) : String { 
		return cs.system.text.Encoding.UTF8.GetString(this, pos, len);
	}

	public function toString() : String { 
		return cs.system.text.Encoding.UTF8.GetString(this, 0, length);
	}

	public function fastGet( pos : Int ) : Int { 
		return b[pos];
	}

	public static function alloc( length : Int ) : ByteArray { 
		return mk(new cs.NativeArray(length));
	}

	public static function ofString( s : String ) : ByteArray { 
		var b = cs.system.text.Encoding.UTF8.GetBytes(s);
		return mk(b);
	}


}

// java

typedef ByteArrayImpl = java.NativeArray<java.StdTypes.Int8>;

abstract ByteArray(ByteArrayImpl) {
	public var length(get,null) : Int;

	inline function new (impl:ByteArrayImpl) {
		this = impl;
	}

	inline function get_length ():Int {
		return untyped b.length;
	}

	inline function mk (data:ByteArrayImpl):ByteArray {
		return new ByteArray(data);
	}

	public function get( pos : Int ) : Int { 
		return untyped b[pos] & 0xFF;
	}

	public function set( pos : Int, v : Int ) : Void { 
		b[pos] = cast v;
	}

	public function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		java.lang.System.arraycopy(src.raw(), srcpos, this, pos, len);
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		for( i in 0...len )
			set(pos++, value);
	}

	public function sub( pos : Int, len : Int ) : ByteArray { 
		var newarr = new java.NativeArray(len);
		java.lang.System.arraycopy(this, pos, newarr, 0, len);
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

	public function getDouble( pos : Int ) : Float { 
		return FPHelper.i64ToDouble(getInt32(pos),getInt32(pos+4));
	}

	public function getFloat( pos : Int ) : Float { 
		var b = new haxe.io.BytesInput(Bytes.ofData(new ByteArray(this)),pos,4);
		return b.readFloat();
	}

	public function setDouble( pos : Int, v : Float ) : Void { 
		var i = FPHelper.doubleToI64(v);
		setInt32(pos, i.low);
		setInt32(pos + 4, i.high);
	}

	public function setFloat( pos : Int, v : Float ) : Void { 
		setInt32(pos, FPHelper.floatToI32(v));
	}

	public function getUInt16( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8);
	}

	public function setUInt16( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
	}

	public function getInt32( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8) | (get(pos + 2) << 16) | (get(pos+3) << 24);
	}
	
	public function getInt64( pos : Int ) : haxe.Int64 { 
		return haxe.Int64.make(getInt32(pos+4),getInt32(pos));
	}
	
	public function setInt32( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
		set(pos + 2, v >> 16);
		set(pos + 3, v >>> 24);
	}
	
	public function setInt64( pos : Int, v : haxe.Int64 ) : Void { 
		setInt32(pos, v.low);
		setInt32(pos + 4, v.high);
	}

	public function getString( pos : Int, len : Int ) : String { 
		try
			return new String(this, pos, len, "UTF-8")
		catch (e:Dynamic) throw e;
	}

	public function toString() : String { 
		try
		{
			return new String(this, 0, length, "UTF-8");
		}
		catch (e:Dynamic) throw e;
	}

	public function fastGet( pos : Int ) : Int { 
		return untyped b[pos] & 0xFF;
	}

	public static function alloc( length : Int ) : ByteArray { 
		return mk(new java.NativeArray(length));
	}

	public static function ofString( s : String ) : ByteArray { 
		try
		{
			var b:BytesArrayImpl = untyped s.getBytes("UTF-8");
			return new ByteArray(b);
		}
		catch (e:Dynamic) throw e;
	}
}



// php


typedef ByteArrayImpl = php.BytesData;
abstract ByteArray(ByteArrayImpl) {
	public var length(get,null) : Int;

	inline function new (impl:ByteArrayImpl) {
		this = impl;
	}

	inline function raw ():ByteArrayImpl return this;

	inline function get_length ():Int {
		return this.length;
	}

	inline function mk (data:ByteArrayImpl):ByteArray {
		return new ByteArray(data);
	}

	public function get( pos : Int ) : Int { 
		return this.get(pos);
	}

	public function set( pos : Int, v : Int ) : Void { 
		this.set(pos, v);
	}

	public function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		this.blit(pos, src.raw(), srcpos, len);
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		for( i in 0...len )
			set(pos++, value);
	}

	public function sub( pos : Int, len : Int ) : ByteArray { 
		return mk(this.sub(pos, len));
	}

	public function compare( other : ByteArray ) : Int { 
		return this.compare(other.raw());
	}

	public function getDouble( pos : Int ) : Float { 
		return FPHelper.i64ToDouble(getInt32(pos),getInt32(pos+4));
	}

	public function getFloat( pos : Int ) : Float { 
		var b = new haxe.io.BytesInput(Bytes.fromData(new ByteArray(this)),pos,4);
		return b.readFloat();
	}

	public function setDouble( pos : Int, v : Float ) : Void { 
		var i = FPHelper.doubleToI64(v);
		setInt32(pos, i.low);
		setInt32(pos + 4, i.high);
	}

	public function setFloat( pos : Int, v : Float ) : Void { 
		setInt32(pos, FPHelper.floatToI32(v));
	}

	public function getUInt16( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8);
	}

	public function setUInt16( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
	}

	public function getInt32( pos : Int ) : Int { 
		var v = get(pos) | (get(pos + 1) << 8) | (get(pos + 2) << 16) | (get(pos+3) << 24);
		return if( v & 0x80000000 != 0 ) v | 0x80000000 else v;
	}
	
	public function getInt64( pos : Int ) : haxe.Int64 { 
		return haxe.Int64.make(getInt32(pos+4),getInt32(pos));
	}
	
	public function setInt32( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
		set(pos + 2, v >> 16);
		set(pos + 3, v >>> 24);
	}
	
	public function setInt64( pos : Int, v : haxe.Int64 ) : Void { 
		setInt32(pos, v.low);
		setInt32(pos + 4, v.high);
	}

	public function getString( pos : Int, len : Int ) : String { 
		return this.getString(pos, len);
	}

	public function toString() : String { 
		return this.toString();
	}

	public static function alloc( length : Int ) : ByteArray { 
		return mk(BytesData.alloc(length));
	}

	public static function ofString( s : String ) : ByteArray { 
		return mk(BytesData.ofString(s));
	}

	public function fastGet( pos : Int ) : Int { 
		return this.get(pos);
	}
}

// js


class ByteHelper {
	static function sub( impl:ByteArrayImpl, pos : Int, len : Int ) : js.html.ArrayBuffer {
		return impl.arr.buffer.slice(pos+b.byteOffset,pos+b.byteOffset+len);
	}
	public static function subByteArray( impl:ByteArrayImpl, pos : Int, len : Int ) : ByteArray {
		return mkByteArray(sub(impl, pos, len);
	}

	static inline function mkByteArray (buffer:js.html.ArrayBuffer):ByteArray {
		return ByteArray.fromBuffer(buffer);
	}

	public static inline function getLength (impl:ByteArrayImpl):Int {
		return impl.arr.byteLength;
	}

	public static inline function get( impl:ByteArrayImpl, pos : Int ) : Int { 
		return impl.arr[pos];
	}

	public static inline function set( impl:ByteArrayImpl, pos : Int, v : Int ) : Void { 
		impl.arr[pos] = v & 0xFF; // the &0xFF is necessary for js.html.compat support
	}

	public static inline function blit( impl:ByteArrayImpl, pos : Int, src : ByteArrayImpl, srcpos : Int, len : Int ) : Void { 
		if( srcpos == 0 && len == src.arr.byteLength )
			impl.arr.set(src.arr,pos);
		else
			impl.arr.set(src.arr.subarray(srcpos,srcpos+len),pos);
	}

	public static inline function fill( impl: ByteArrayImpl, pos : Int, len : Int, value : Int ):Void { 
		for( i in 0...len )
			set(impl, pos++, value);
	}

	inline static function initData(impl:ByteArrayImpl) : Void {
		if( impl.data == null ) impl.data = new js.html.DataView(impl.arr.buffer, impl.arr.byteOffset, impl.arr.byteLength);
	}

	public static function compare( b:ByteArrayImpl, other : ByteArrayImpl ) : Int { 
		var b1 = b.arr;
		var b2 = other.arr;
		var len = (getLength(b) < getLength(other)) ? getLength(b) : getLength(other);
		for( i in 0...len )
			if( b1[i] != b2[i] )
				return b1[i] - b2[i];
		return getLength(b) - getLength(other);
	}

	public static function getDouble( impl:ByteArrayImpl, pos : Int ) : Float { 
		initData(impl);
		return impl.data.getFloat64(pos, true);
	}

	public static function getFloat( impl:ByteArrayImpl, pos : Int ) : Float { 
		initData(impl);
		return impl.data.getFloat32(pos, true);
	}

	public static function setDouble( impl:ByteArrayImpl, pos : Int, v : Float ) : Void { 
		initData(impl);
		impl.data.setFloat64(pos, v, true);
	}

	public static function setFloat( impl:ByteArrayImpl, pos : Int, v : Float ) : Void { 
		initData(impl);
		impl.data.setFloat32( pos, v, true);
	}

	public static function getUInt16( impl:ByteArrayImpl, pos : Int ) : Int { 
		initData(impl);
		return getUint16(impl, pos, true);
	}

	public static function setUInt16( impl:ByteArrayImpl, pos : Int, v : Int ) : Void { 
		initData(impl);
		setUint16(impl, pos, v, true);
	}

	public static function getInt32( impl:ByteArrayImpl, pos : Int ) : Int { 
		initData(impl);
		return getInt32(impl, pos, true);
	}
	
	public static function getInt64( impl:ByteArrayImpl, pos : Int ) : haxe.Int64 { 
		return Int64.make(getInt32(impl, pos + 4),getInt32(impl, pos));
	}
	
	public static function setInt32( impl:ByteArrayImpl, pos : Int, v : Int ) : Void { 
		initData();
		impl.data.setInt32(pos, v, true);
	}
	
	public static function setInt64( impl:ByteArrayImpl, pos : Int, v : haxe.Int64 ) : Void { 
		setInt32(impl, pos, v.low);
		setInt32(impl, pos + 4, v.high);
	}

	public static function getString( impl:ByteArrayImpl, pos : Int, len : Int ) : String { 
		var s = "";
		var b = impl;
		var fcc = String.fromCharCode;
		var i = pos;
		var max = pos+len;
		// utf8-decode and utf16-encode
		while( i < max ) {
			var c = b[i++];
			if( c < 0x80 ) {
				if( c == 0 ) break;
				s += fcc(c);
			} else if( c < 0xE0 )
				s += fcc( ((c & 0x3F) << 6) | (b[i++] & 0x7F) );
			else if( c < 0xF0 ) {
				var c2 = b[i++];
				s += fcc( ((c & 0x1F) << 12) | ((c2 & 0x7F) << 6) | (b[i++] & 0x7F) );
			} else {
				var c2 = b[i++];
				var c3 = b[i++];
				var u = ((c & 0x0F) << 18) | ((c2 & 0x7F) << 12) | ((c3 & 0x7F) << 6) | (b[i++] & 0x7F);
				// surrogate pair
				s += fcc( (u >> 10) + 0xD7C0 );
				s += fcc( (u & 0x3FF) | 0xDC00 );
			}
		}
		return s;
	}

	public static function toString(impl:ByteArrayImpl) : String { 
		return getString(impl, 0, getLength(impl));
	}

	public static function ofString( s : String ) : js.html.ArrayBuffer { 
		var a = new Array();
		// utf16-decode and utf8-encode
		var i = 0;
		while( i < s.length ) {
			var c : Int = StringTools.fastCodeAt(s,i++);
			// surrogate pair
			if( 0xD800 <= c && c <= 0xDBFF )
			    c = (c - 0xD7C0 << 10) | (StringTools.fastCodeAt(s,i++) & 0x3FF);
			if( c <= 0x7F )
				a.push(c);
			else if( c <= 0x7FF ) {
				a.push( 0xC0 | (c >> 6) );
				a.push( 0x80 | (c & 63) );
			} else if( c <= 0xFFFF ) {
				a.push( 0xE0 | (c >> 12) );
				a.push( 0x80 | ((c >> 6) & 63) );
				a.push( 0x80 | (c & 63) );
			} else {
				a.push( 0xF0 | (c >> 18) );
				a.push( 0x80 | ((c >> 12) & 63) );
				a.push( 0x80 | ((c >> 6) & 63) );
				a.push( 0x80 | (c & 63) );
			}
		}
		return new js.html.Uint8Array(a).buffer;
	}

	public static function fastGet( impl:ByteArrayImpl, pos : Int ) : Int { 
		// this requires that we have wrapped it with haxe.io.Bytes beforehand
		return untyped impl.arr.bytes[pos];
	}

	public static function allocBuffer (length:Int) {
		return new js.html.ArrayBuffer(length);
	}
	
}

typedef ByteArrayImpl = {
	arr : js.html.Uint8Array,
	data : js.html.DataView,
}
abstract ByteArray(ByteArrayImpl) {
	public var length(get,null) : Int;

	inline function new (impl:ByteArrayImpl) {
		this = impl;
	}

	public static inline function fromBuffer (buffer:js.html.ArrayBuffer) {
		var arr = new js.html.Uint8Array(buffer);
		untyped {
			arr.bufferValue = data; // some impl does not return the same instance in .buffer
			buffer.bytes = this.arr;
		}
		var impl = {
			arr : arr,
			data : null
		}
		
		return new ByteArray(impl);
	}

	inline function raw ():ByteArrayImpl return this;

	inline function get_length ():Int {
		return ByteHelper.getLength(this);
	}

	public function get( pos : Int ) : Int { 
		return ByteHelper.get(this, pos);
	}

	public function set( pos : Int, v : Int ) : Void { 
		ByteHelper.set(this, pos, v);
	}

	public function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		return ByteHelper.blit(this, pos, src.raw(), srcpos, len);
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		ByteHelper.fill(pos, len, value);
	}

	public function sub( pos : Int, len : Int ) : ByteArray {
		return ByteHelper.subByteArray(this, pos, len);
	}

	public function compare( other : ByteArray ) : Int { 
		return ByteHelper.compare(this, other.raw());
	}

	public function getDouble( pos : Int ) : Float { 
		return ByteHelper.getDouble(this, pos);
	}

	public function getFloat( pos : Int ) : Float {
		return ByteHelper.getFloat(this, pos); 
	}

	public function setDouble( pos : Int, v : Float ) : Void {
		ByteHelper.setDouble(this, pos, v); 
	}

	public function setFloat( pos : Int, v : Float ) : Void {
		ByteHelper.setFloat(this, pos, v); 
	}

	public function getUInt16( pos : Int ) : Int { 
		return ByteHelper.getUInt16(this, pos);
	}

	public function setUInt16( pos : Int, v : Int ) : Void {
		ByteHelper.setUInt16(this, pos, v); 
	}

	public function getInt32( pos : Int ) : Int {
		return ByteHelper.getInt32(this, pos); 
	}
	
	public function getInt64( pos : Int ) : haxe.Int64 {
		return ByteHelper.getInt64(this, pos); 
	}
	
	public function setInt32( pos : Int, v : Int ) : Void {
		ByteHelper.setInt32(this, pos, v);
	}
	
	public function setInt64( pos : Int, v : haxe.Int64 ) : Void { 
		ByteHelper.setInt64(this, pos, v);
	}

	public function getString( pos : Int, len : Int ) : String { 
		return ByteHelper.getString(this, pos, len);
	}

	public function toString() : String { 
		return ByteHelper.toString(this);
	}

	public static function alloc( length : Int ) : ByteArray { 
		var buffer = ByteHelper.allocBuffer(length);
		return fromBuffer(buffer);
	}

	public static function ofString( s : String ) : ByteArray { 
		return fromBuffer(ByteHelper.ofString(s));
	}

	public function fastGet( pos : Int ) : Int { 
		return ByteHelper.fastGet(this, pos);
	}
}

// flash


typedef ByteArrayImpl = flash.utils.ByteArray;
abstract ByteArray(ByteArrayImpl) {
	public var length(get,null) : Int;

	inline function new (impl:ByteArrayImpl) {
		this = impl;
		this.endian = flash.utils.Endian.LITTLE_ENDIAN;
	}

	inline function get_length ():Int {
		return this.length;
	}

	inline function raw():flash.utils.ByteArray return this;

	inline function mk (data:ByteArrayImpl):ByteArray {
		return new ByteArray(data);
	}

	public function get( pos : Int ) : Int { 
		return this[pos];
	}

	public function set( pos : Int, v : Int ) : Void { 
		this[pos] = v;
	}

	public function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		this.position = pos;
		if( len > 0 ) this.writeBytes(src.raw().b,srcpos,len);
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		var v4 = value&0xFF;
		v4 |= v4<<8;
		v4 |= v4<<16;
		this.position = pos;
		for( i in 0...len>>2 )
			this.writeUnsignedInt(v4);
		pos += len&~3;
		for( i in 0...len&3 )
			set(pos++,value);
	}

	public function sub( pos : Int, len : Int ) : ByteArray { 
		this.position = pos;
		var b2 = new flash.utils.ByteArray();
		this.readBytes(b2,0,len);
		return mk(b2);
	}

	public function compare( other : ByteArray ) : Int { 
		var len = (length < other.length) ? length : other.length;
		var b1 = this;
		var b2 = other.raw();
		b1.position = 0;
		b2.position = 0;
		b1.endian = flash.utils.Endian.BIG_ENDIAN;
		b2.endian = flash.utils.Endian.BIG_ENDIAN;
		for( i in 0...len>>2 )
			if( b1.readUnsignedInt() != b2.readUnsignedInt() ) {
				b1.position -= 4;
				b2.position -= 4;
				var d = b1.readUnsignedInt() - b2.readUnsignedInt();
				b1.endian = flash.utils.Endian.LITTLE_ENDIAN;
				b2.endian = flash.utils.Endian.LITTLE_ENDIAN;
				return d;
			}
		for( i in 0...len & 3 )
			if( b1.readUnsignedByte() != b2.readUnsignedByte() ) {
				b1.endian = flash.utils.Endian.LITTLE_ENDIAN;
				b2.endian = flash.utils.Endian.LITTLE_ENDIAN;
				return b1[b1.position-1] - b2[b2.position-1];
			}
		b1.endian = flash.utils.Endian.LITTLE_ENDIAN;
		b2.endian = flash.utils.Endian.LITTLE_ENDIAN;
		return length - other.length;
	}

	public function getDouble( pos : Int ) : Float { 
		this.position = pos;
		return this.readDouble();
	}

	public function getFloat( pos : Int ) : Float { 
		this.position = pos;
		return this.readFloat();
	}

	public function setDouble( pos : Int, v : Float ) : Void { 
		this.position = pos;
		this.writeDouble(v);
	}

	public function setFloat( pos : Int, v : Float ) : Void { 
		this.position = pos;
		this.writeFloat(v);
	}

	public function getUInt16( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8);
	}

	public function setUInt16( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
	}

	public function getInt32( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8) | (get(pos + 2) << 16) | (get(pos+3) << 24);
	}
	
	public function getInt64( pos : Int ) : haxe.Int64 { 
		return haxe.Int64.make(getInt32(pos+4),getInt32(pos));
	}
	
	public function setInt32( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
		set(pos + 2, v >> 16);
		set(pos + 3, v >>> 24);
	}
	
	public function setInt64( pos : Int, v : haxe.Int64 ) : Void { 
		setInt32(pos, v.low);
		setInt32(pos + 4, v.high);
	}

	public function getString( pos : Int, len : Int ) : String { 
		this.position = pos;
		return this.readUTFBytes(len);
	}

	public function toString() : String { 
		this.position = 0;
		return this.readUTFBytes(length);
	}

	public static function alloc( length : Int ) : ByteArray { 
		var b = new flash.utils.ByteArray();
		b.length = length;
		return mk(b);
	}

	public static function ofString( s : String ) : ByteArray { 
		var b = new flash.utils.ByteArray();
		b.writeUTFBytes(s);
		return mk(b);
	}

	public function fastGet( pos : Int ) : Int { 
		return this[pos];
	}
}

// lua


typedef ByteArrayImpl = Array<Int>;

abstract ByteArray(ByteArrayImpl) {
	public var length(get,null) : Int;

	inline function new (impl:ByteArrayImpl) {
		this = impl;
	}

	inline function raw ():ByteArrayImpl return this;

	inline function get_length ():Int {
		return this.length;
	}

	inline function mk (data:ByteArrayImpl):ByteArray {
		return new ByteArray(data);
	}

	public function get( pos : Int ) : Int { 
		return this[pos];
	}

	public function set( pos : Int, v : Int ) : Void { 
		this[pos] = v & 0xFF;
	}

	public function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		var b1 = this;
		var b2 = src.raw();
		if( b1 == b2 && pos > srcpos ) {
			var i = len;
			while( i > 0 ) {
				i--;
				b1[i + pos] = b2[i + srcpos];
			}
			return;
		}
		for( i in 0...len )
			b1[i+pos] = b2[i+srcpos];
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		for( i in 0...len )
			set(pos++, value);
	}

	public function sub( pos : Int, len : Int ) : ByteArray { 
		return new ByteArray(this.slice(pos,pos+len));
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

	public function getDouble( pos : Int ) : Float { 
		return FPHelper.i64ToDouble(getInt32(pos),getInt32(pos+4));
	}

	public function getFloat( pos : Int ) : Float { 
		var b = new haxe.io.BytesInput(Bytes.fromData(this),pos,4);
		return b.readFloat();
	}

	public function setDouble( pos : Int, v : Float ) : Void { 
		var i = FPHelper.doubleToI64(v);
		setInt32(pos, i.low);
		setInt32(pos + 4, i.high);
	}

	public function setFloat( pos : Int, v : Float ) : Void { 
		setInt32(pos, FPHelper.floatToI32(v));
	}

	public function getUInt16( pos : Int ) : Int { 
		return get(pos) | (get(pos + 1) << 8);
	}

	public function setUInt16( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
	}

	public function getInt32( pos : Int ) : Int { 
		var v = get(pos) | (get(pos + 1) << 8) | (get(pos + 2) << 16) | (get(pos+3) << 24);
		return lua.Boot.clamp(if( v & 0x80000000 != 0 ) v | 0x80000000 else v);
	}
	
	public function getInt64( pos : Int ) : haxe.Int64 { 
		return haxe.Int64.make(getInt32(pos+4),getInt32(pos));
	}
	
	public function setInt32( pos : Int, v : Int ) : Void { 
		set(pos, v);
		set(pos + 1, v >> 8);
		set(pos + 2, v >> 16);
		set(pos + 3, v >>> 24);
	}
	
	public function setInt64( pos : Int, v : haxe.Int64 ) : Void { 
		setInt32(pos, v.low);
		setInt32(pos + 4, v.high);
	}

	public function getString( pos : Int, len : Int ) : String { 
		var begin = cast(Math.min(pos,this.length),Int);
		var end = cast(Math.min(pos+len,this.length),Int);
		return [for (i in begin...end) String.fromCharCode(this[i])].join("");
	}

	public function toString() : String { 
		return getString(0,length);
	}

	public static function alloc( length : Int ) : ByteArray { 
		var a = new Array();
		for( i in 0...length )
			a.push(0);
		return mk(a);
	}

	public static function ofString( s : String ) : ByteArray { 
		var bytes = [for (c in 0...s.length) StringTools.fastCodeAt(s,c)];
		return mk(bytes);
	}

	public function fastGet( pos : Int ) : Int { 
		return b[pos];
	}
}

// hl

typedef ByteArrayImpl = BytesDataImpl;

//@:forward(bytes)
abstract ByteArray(ByteArrayImpl) {
public var length(get,null) : Int;

	inline function new (impl:ByteArrayImpl) {
		this = impl;
	}

	inline function get_length ():Int {
		return this.length;	
	}

	inline function mk (data:ByteArrayImpl):ByteArray {
		return new ByteArray(data);
	}

	public function get( pos : Int ) : Int { 
		return this.bytes[pos];
	}

	public function set( pos : Int, v : Int ) : Void { 
		this.bytes[pos] = v;
	}

	public function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		this.bytes.blit(pos, src.raw().bytes, srcpos, len);
	}

	public function fill( pos : Int, len : Int, value : Int ):Void { 
		this.bytes.fill(pos, len, value);
	}

	public function sub( pos : Int, len : Int ) : ByteArray { 
		var impl = new BytesArrayImpl(b.sub(pos, len), len);
		return mk(impl);
	}

	public function compare( other : ByteArray ) : Int { 
		var len = length < other.length ? length : other.length;
		var r = this.bytes.compare(0, other.raw().bytes, 0, len);
		if( r == 0 )
			r = length - other.length;
		return r;
	}

	public function getDouble( pos : Int ) : Float { 
		 return this.bytes.getF64(pos);
	}

	public function getFloat( pos : Int ) : Float { 
		return this.bytes.getF32(pos);
	}

	public function setDouble( pos : Int, v : Float ) : Void { 
		this.bytes.setF64(pos, v);
	}

	public function setFloat( pos : Int, v : Float ) : Void { 
		this.bytes.setF32(pos, v);
	}

	public function getUInt16( pos : Int ) : Int { 
		this.bytes.getUI16(pos);
	}

	public function setUInt16( pos : Int, v : Int ) : Void { 
		this.bytes.setUI16(pos, v);
	}

	public function getInt32( pos : Int ) : Int { 
		this.bytes.getI32(pos);
	}
	
	public function getInt64( pos : Int ) : haxe.Int64 { 
		return haxe.Int64.make(this.bytes.getI32(pos+4), this.bytes.getI32(pos));
	}
	
	public function setInt32( pos : Int, v : Int ) : Void { 
		return this.bytes.setI32(pos, v);
	}
	
	public function setInt64( pos : Int, v : haxe.Int64 ) : Void { 
		setInt32(pos + 4, v.high);
		setInt32(pos, v.low);
	}

	public function getString( pos : Int, len : Int ) : String { 
		var b = new hl.types.Bytes(len + 1);
		b.blit(0, this.bytes, pos, len);
		b[len] = 0;
		return @:privateAccess String.fromUTF8(b);
	}

	public function toString() : String { 
		return getString(0,length);
	}

	public static function alloc( length : Int ) : ByteArray { 
		var b = new hl.types.Bytes(length);
		b.fill(0, length, 0);
		var impl = new BytesDataImpl(b, length);
		return mk(impl);
	}

	public static function ofString( s : String ) : ByteArray @:privateAccess { 
		var size = 0;
		var b = s.bytes.utf16ToUtf8(0, size);
		var impl = new BytesDataImpl(b, size);
		return mk(impl);
	}

	public function fastGet( pos : Int ) : Int { 
		return this.bytes[pos];
	}



}

*/