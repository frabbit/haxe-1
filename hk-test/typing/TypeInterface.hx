package typing;


private interface Mappable<M,T> {
  public function map <B>(f:T->B):M<B>;
}

private interface BuildFrom<M> {
  public function buildFrom <T>(a:Array<T>):M<T>;
}

private class Array1<T> implements Mappable<Array1<_>, T> implements BuildFrom<Array1<_>> {
	var a:Array<T>;
	public function new (a:Array<T>) {
		this.a = a;
	}

	public function map <B>(f:T->B):Array1<B> {
		return new Array1(a.map(f));
	}

	public function buildFrom <T>(a:Array<T>):Array1<T> {
		return new Array1(a.copy());
	}
	public var length (get, never):Int;
	function get_length () return a.length;
}

class TypeInterface {
	static function main () {

	}

	private static function withBuildFrom <M:BuildFrom<M>, T> (m:M<T>):M<Int>
 	{
		 m.buildFrom(["foo"]);
 		return m.buildFrom([1]);
	}

	private static function withMappable <M:Mappable<M,_>> (m:M<Int>):M<String>
 	{
		//return null;
 		return m.map(function (x) return x+1).map(function (x:Int) return "foo"+x);
	}


	public static function test () {

		var a = new Array1([1,2,3]);
		//Log.enable(true);
		var a = withMappable(a);
		//Log.enable(false);
		var a = withBuildFrom(a);
		//trace(r.length);
		//$type(r);
	}




}
