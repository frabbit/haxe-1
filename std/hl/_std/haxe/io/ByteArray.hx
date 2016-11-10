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

typedef ByteArrayImpl = haxe.io.BytesData;

//@:forward(bytes)
abstract ByteArray(ByteArrayImpl) {
public var length(get,never) : Int;

	inline function new (impl:ByteArrayImpl) {
		this = impl;
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
		var impl = new ByteArrayImpl(this.bytes.sub(pos, len), len);
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
		return this.bytes.getUI16(pos);
	}

	public function setUInt16( pos : Int, v : Int ) : Void { 
		this.bytes.setUI16(pos, v);
	}

	public function getInt32( pos : Int ) : Int { 
		return this.bytes.getI32(pos);
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
		var impl = new ByteArrayImpl(b, length);
		return mk(impl);
	}

	public static function ofString( s : String ) : ByteArray @:privateAccess { 
		var size = 0;
		var b = s.bytes.utf16ToUtf8(0, size);
		var impl = new ByteArrayImpl(b, size);
		return mk(impl);
	}

	public function fastGet( pos : Int ) : Int { 
		return this.bytes[pos];
	}



}

