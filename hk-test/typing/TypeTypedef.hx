package typing;
import Log;
import haxe.ds.Either;
import haxe.ds.Option;
import types.Tup2;

private typedef Of<M,A,B> = M<A,B>;



private typedef Mappable<M,T> = {
  public function map <B>(f:T->B):M<B>;
}

private typedef Filterable<M, T> = {
  public function filter (f:T->Bool):M<T>;
}


class TypeTypedef {
	static function main () {

		Log.enable(true);
		var a:Mappable<Array<_>,Int> = [1];
		Log.enable(false);

		test();

	}


	private static function constraint <M:(Filterable<M,Int>, Mappable<M,Int>)> (m:M<Int>):M<Int>
 	{
 		return m.map(function (x) return x+1).filter(function (x) return x > 2);
	}

	public static function test () {
		var a = [1,2,3];
		var r = constraint(a);
		var r = typeConstructorWithConstraints(a);
	}

	private static function typeConstructorWithConstraints<M:(Filterable<M,Int>, Mappable<M,Int>)> (m:M<Int>):M<Int>
 	{
 		return m.map(function (x) return x+1).filter(function (x) return x > 2);
	}



}
