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

typedef ByteArrayImpl = flash.utils.ByteArray;
abstract ByteArray(ByteArrayImpl) {
	public var length(get,never) : Int;

	inline function new (impl:ByteArrayImpl) {
		this = impl;
		this.endian = flash.utils.Endian.LITTLE_ENDIAN;
	}

	inline function get_length ():Int {
		return this.length;
	}

	public inline function getData ():BytesData {
		return this;
	}
	
	inline function raw () return this;

	public static inline function ofData (data:BytesData) {
		return mk(data);
	}

	static inline function mk (data:ByteArrayImpl):ByteArray {
		return new ByteArray(data);
	}

	public inline function get( pos : Int ) : Int { 
		return this[pos];
	}

	public inline function set( pos : Int, v : Int ) : Void { 
		this[pos] = v;
	}

	public function blit( pos : Int, src : ByteArray, srcpos : Int, len : Int ) : Void { 
		this.position = pos;
		if( len > 0 ) this.writeBytes(src.raw(),srcpos,len);
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
		this.position = pos;
		return this.readUTFBytes(len);
	}

	public inline function toString() : String { 
		this.position = 0;
		return this.readUTFBytes(length);
	}

	public inline static function alloc( length : Int ) : ByteArray { 
		var b = new flash.utils.ByteArray();
		b.length = length;
		return mk(b);
	}

	public inline static function ofString( s : String ) : ByteArray { 
		var b = new flash.utils.ByteArray();
		b.writeUTFBytes(s);
		return mk(b);
	}
}
