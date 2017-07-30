package typing;
import Log;
import haxe.ds.Either;
import haxe.ds.Option;
import types.Tup2;

private typedef Mappable<M:Mappable<M,_>,T> = {
  public function map <B>(f:T->B):M<B>;
}

private typedef Filterable<M:Filterable<M,_>, T> = {
  public function filter (f:T->Bool):M<T>;
}

private typedef Container<M:Container<M,_>,T> = {
	> Mappable<M,T>,
	> Filterable<M,T>,
}

class TypeTypedef2 {
	static function main () {

		Log.enable(true);
		var a:Mappable<Array<_>,Int> = [1];
		Log.enable(false);

		//test();

	}


	private static function withContainer <M:Mappable<M,_>> (m:Mappable<M, Int>):Mappable<M,Int>
 	{
 		return m.map(function (x) return x+1);
	}



	private static function withContainer2 <M:Container<M,_>> (m:Container<M, Int>):Container<M,Int>
 	{
 		return m.map(function (x) return x+1).filter(function (x) return x > 2);
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
