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
