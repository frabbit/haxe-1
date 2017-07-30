package typing;
import Log;
import haxe.ds.Either;
import haxe.ds.Option;
import types.Tup2;


interface Mappable<M,T> {
  public function map <B>(f:T->B):M<B>;
}

interface Filterable<M, T> {
  public function filter (f:T->Bool):M<T>;
}


class TypeConstraints {
	private static function constraint
	 <M:(Filterable<M,_>, Mappable<M,_>, { var length(default, null):Int;}), T> (m:M<Int>):M<Int>
 	{
 		return m.map(function (x) return x+1).filter(function (x) return x > 2);
	}

}
