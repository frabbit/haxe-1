package typing;

import haxe.ds.Option;
import haxe.ds.Either;


class Test {

	public function foo <T,M,A> (x:T<M<A>> ) {
		return null;
	}

	public function useFoo <M,A>() {
		var x:Array<M<A>> = null;
		foo(x);
	}
}

class Test2 {

	public function foo <T,M,A> (x:T<M<A>> -> A ) {
		return null;
	}

	public function useFoo <M,A>() {
		var x:Array<M<A>> -> A = null;
		//Log.enable(true);
		foo(x);
		//Log.enable(false);
	}
}


class Test3<T> {

	public function foo <M,A> (x:T<M<A>> -> A ) {
		return null;
	}

	public static function useFoo <M,A>() {
		var t: Test3<Array<_>> = null;
		var x:Array<M<A>> -> A = null;
		t.foo(x);
	}
}


class Test4<T> {

	dynamic public function foo <M,A> (x:T<M<A>> ):A { return null; }

	public static function useFoo <M,A>() {
		var t: Test4<Array<_>> = null;
		var x:Array<M<A>> -> A = null;
		t.foo = x;
	}
}

private interface X<T> {
	function foo <M,A>(x:T<M<A>>):A;
}

private class XImpl implements X<Array<_>> {
	public function foo <M,A>(x:Array<M<A>>):A { return null; }
}

private interface X1<T,O> {
	function foo <M,A>(x:T<M<O<A>>>):A;
}

private class X1Impl implements X1<Array<_>, Option<_>> {
	public function foo <M,A>(x:Array<M<Option<A>>>):A { return null; }
}


private interface X2<T,F,G> {
	function foo <A>(x:T<F<A>, G<A>>):A;
}

private class X2Impl implements X2<Either<_,_>, Array<_>, Option<_>> {
	public function foo <A>(x:Either<Array<A>, Option<A>>):A { return null; }
}

private interface X3<T,O,M> {
	function foo <A,B,C>(x:T<B<M<A>>, C<O<A>>>):A;
}

private class X3Impl implements X3<Either<_,_>, Array<_>, Option<_>> {
	public function foo <A,B,C>(x:Either<B<Option<A>>, C<Array<A>>>):A { return null; }
}
