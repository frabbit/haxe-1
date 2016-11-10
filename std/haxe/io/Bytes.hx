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


class Bytes {

	public var length(default,null) : Int;
	var b : ByteArray;

	function new(b) {
		this.b = b;
		this.length = b.length;
	}

	public inline function get( pos : Int ) : Int {
		return b.get(pos);
	}

	public inline function set( pos : Int, v : Int ) : Void {
		b.set(pos, v);
	}

	public inline function blit( pos : Int, src : Bytes, srcpos : Int, len : Int ) : Void {
		#if neko
		try b.blit(pos, src.b, srcpos, len) catch (e:Dynamic) throw Error.OutsideBounds;
		#else
		if( pos < 0 || srcpos < 0 || len < 0 || pos + len > length || srcpos + len > src.length ) throw Error.OutsideBounds;
		b.blit(pos, src.b, srcpos, len);
		#end
	}

	public inline function fill( pos : Int, len : Int, value : Int ) {
		b.fill(pos, len, value);
	}

	public inline function sub( pos : Int, len : Int ) : Bytes {
		#if neko
		return try new Bytes(b.sub(pos, len)) catch (e:Dynamic) throw Error.OutsideBounds;
		#else
		if( pos < 0 || len < 0 || pos + len > length ) throw Error.OutsideBounds;
		return new Bytes(b.sub(pos, len));
		#end
	}

	public inline function compare( other : Bytes ) : Int {
		return b.compare(other.b);
	}


	/**
		Returns the IEEE double precision value at given position (in low endian encoding).
		Result is unspecified if reading outside of the bounds
	**/
	
	public inline function getDouble( pos : Int ) : Float {
		if( pos < 0 || pos + 8 > length ) throw Error.OutsideBounds;
		return b.getDouble(pos);
	}

	/**
		Returns the IEEE single precision value at given position (in low endian encoding).
		Result is unspecified if reading outside of the bounds
	**/
	public inline function getFloat( pos : Int ) : Float {
		if( pos < 0 || pos + 4 > length ) throw Error.OutsideBounds;
		return b.getFloat(pos);
	}

	/**
		Store the IEEE double precision value at given position in low endian encoding.
		Result is unspecified if writing outside of the bounds.
	**/

	public inline function setDouble( pos : Int, v : Float ) : Void {
		if( pos < 0 || pos + 8 > length ) throw Error.OutsideBounds;
		b.setDouble(pos, v);
	}

	/**
		Store the IEEE single precision value at given position in low endian encoding.
		Result is unspecified if writing outside of the bounds.
	**/
	
	public inline function setFloat( pos : Int, v : Float ) : Void {
		if( pos < 0 || pos + 4 > length ) throw Error.OutsideBounds;
		b.setFloat(pos, v);
	}

	/**
		Returns the 16 bit unsigned integer at given position (in low endian encoding).
	**/
	public inline function getUInt16( pos : Int ) : Int {
		return b.getUInt16(pos);
	}

	/**
		Store the 16 bit unsigned integer at given position (in low endian encoding).
	**/
	public inline function setUInt16( pos : Int, v : Int ) : Void {
		b.setUInt16(pos, v);
	}

	/**
		Returns the 32 bit integer at given position (in low endian encoding).
	**/
	public inline function getInt32( pos : Int ) : Int {
		return b.getInt32(pos);
	}

	/**
		Returns the 64 bit integer at given position (in low endian encoding).
	**/
	public inline function getInt64( pos : Int ) : haxe.Int64 {
		return b.getInt64(pos);
	}

	/**
		Store the 32 bit integer at given position (in low endian encoding).
	**/
	public inline function setInt32( pos : Int, v : Int ) : Void {
		b.setInt32(pos, v);
	}

	/**
		Store the 64 bit integer at given position (in low endian encoding).
	**/
	public inline function setInt64( pos : Int, v : haxe.Int64 ) : Void {
		return b.setInt64(pos, v);
	}

	public inline function getString( pos : Int, len : Int ) : String {
		#if neko
		return try b.getString(pos, len) catch( e : Dynamic ) throw Error.OutsideBounds;
		#else
		if( pos < 0 || len < 0 || pos + len > length ) throw Error.OutsideBounds;
		return b.getString(pos, len);
		#end
	}

	@:deprecated("readString is deprecated, use getString instead")
	@:noCompletion
	public inline function readString(pos:Int, len:Int):String {
		return getString(pos, len);
	}

	public function toString() : String {
		return b.toString();
	}

	public function toHex() : String {
		var s = new StringBuf();
		var chars = [];
		var str = "0123456789abcdef";
		for( i in 0...str.length )
			chars.push(str.charCodeAt(i));
		for( i in 0...length ) {
			var c = get(i);
			s.addChar(chars[c >> 4]);
			s.addChar(chars[c & 15]);
		}
		return s.toString();
	}

	public inline function getData() : BytesData {
		return b.getData();
	}

	public static function alloc( length : Int ) : Bytes {
		return new Bytes(ByteArray.alloc(length));
	}

	@:pure
	public static function ofString( s : String ) : Bytes {
		return new Bytes(ByteArray.ofString(s));
	}

	public static function ofData( b : BytesData ) {
		return new Bytes(ByteArray.ofData(b));
	}

	/**
		Read the most efficiently possible the n-th byte of the data.
		Behavior when reading outside of the available data is unspecified.
	**/
	public inline static function fastGet( b : BytesData, pos : Int ) : Int {
		return ByteArray.ofData(b).fastGet(pos);
	}

}
