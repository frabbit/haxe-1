package typing;
import Log;
import haxe.ds.Either;
import haxe.ds.Option;
import types.Tup2;

private interface Mappable<M:Mappable<M,_>,T> {
  public function map <B>(f:T->B):M<B>;
}


private class Array1<T> implements Mappable<Array1<_>, T> {
	var a:Array<T>;
	public function new (a:Array<T>) {
		this.a = a;
	}

	public function map <B>(f:T->B):Array1<B> {
		return new Array1(a.map(f));
	}

}

class TypeInterface {
	static function main () {



	}


	private static function withContainer <M:Mappable<M,_>> (m:Mappable<M, Int>):Mappable<M,String>
 	{
 		return m.map(function (x) return x+1).map(function (x) return "foo"+x);
	}

/*
	public static function test () {
		var a = [1,2,3];
		var r = withContainer(a);
		//trace(r.length);
		$type(r);
	}
*/



}
