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

#if !nodejs
import js.html.compat.Uint8Array;
import js.html.compat.DataView;
#end

import haxe.io.ByteArray.ByteHelper;

@:coreApi
class Bytes {

	public var length(default,null) : Int;
	var b : js.html.Uint8Array;
	var data : js.html.DataView;

	function new(data:BytesData) {
		this.length = data.byteLength;
		this.b = new js.html.Uint8Array(data);
		untyped {
			b.bufferValue = data; // some impl does not return the same instance in .buffer
			data.hxBytes = this;
			data.bytes = this.b;
		}
	}

	public inline function get( pos : Int ) : Int {
		return ByteHelper.get(this, pos);
	}

	public inline function set( pos : Int, v : Int ) : Void {
		ByteHelper.set(this, pos, v);
	}

	public inline function blit( pos : Int, src : Bytes, srcpos : Int, len : Int ) : Void {
		if( pos < 0 || srcpos < 0 || len < 0 || pos + len > length || srcpos + len > src.length ) throw Error.OutsideBounds;
		ByteHelper.blit(this, pos, src, srcpos, len);
	}

	public inline function fill( pos : Int, len : Int, value : Int ) : Void {
		ByteHelper.fill(this, pos, len, value);
	}

	public inline function sub( pos : Int, len : Int ) : Bytes {
		if( pos < 0 || len < 0 || pos + len > length ) throw Error.OutsideBounds;
		return Bytes.ofData(ByteHelper.sub(this, pos, len));
	}

	public inline function compare( other : Bytes ) : Int {
		return ByteHelper.compare(this, other);
	}

	public inline function getDouble( pos : Int ) : Float {
		return ByteHelper.getDouble(this, pos);
	}

	public inline function getFloat( pos : Int ) : Float {
		return ByteHelper.getFloat(this, pos);
	}

	public inline function setDouble( pos : Int, v : Float ) : Void {
		ByteHelper.setDouble(this, pos, v);
	}

	public inline function setFloat( pos : Int, v : Float ) : Void {
		ByteHelper.setFloat(this, pos, v);
	}

	public inline function getUInt16( pos : Int ) : Int {
		return ByteHelper.getUInt16(this, pos);
	}

	public inline function setUInt16( pos : Int, v : Int ) : Void {
		ByteHelper.setUInt16(this, pos, v);
	}

	public inline function getInt32( pos : Int ) : Int {
		return ByteHelper.getInt32(this, pos);
	}

	public inline function setInt32( pos : Int, v : Int ) : Void {
		ByteHelper.setInt32(this, pos, v);
	}

	public inline function getInt64( pos : Int ) : haxe.Int64 {
		return ByteHelper.getInt64(this, pos);
	}

	public inline function setInt64( pos : Int, v : haxe.Int64 ) : Void {
		ByteHelper.setInt64(this, pos, v);
	}

	public function getString( pos : Int, len : Int ) : String {
		if( pos < 0 || len < 0 || pos + len > length ) throw Error.OutsideBounds;
		return ByteHelper.getString(this, pos, len);
	}

	@:deprecated("readString is deprecated, use getString instead")
	@:noCompletion
	public inline function readString(pos:Int, len:Int):String {
		return getString(pos, len);
	}

	public inline function toString() : String {
		return ByteHelper.getString(this, 0, length);
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
		return untyped b.bufferValue;
	}

	public static inline function alloc( length : Int ) : Bytes {
		return new Bytes(ByteHelper.allocBuffer(length));
	}

	public static inline function ofString( s : String ) : Bytes {
		var buffer = ByteHelper.ofString(s);
		return new Bytes(buffer);
	}

	public static function ofData( b : BytesData ) : Bytes {
		var hb = untyped b.hxBytes;
		if( hb != null ) return hb;
		return new Bytes(b);
	}

	public inline static function fastGet( b : BytesData, pos : Int ) : Int {
		return ByteHelper.fastGet(b, pos);
	}

}
