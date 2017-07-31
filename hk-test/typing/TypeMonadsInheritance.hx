package typing;
import types.inheritance.Monad;

import haxe.ds.Option;

private class Array1<T> implements Monad<Array1<_>, T> {
	var a:Array<T>;
	public function new (a:Array<T>) {
		this.a = a;
	}
	public function map <B>(f:T->B):Array1<B> {
		return new Array1(a.map(f));
	}
	public function flatMap <B>(f:T->Array1<B>):Array1<B> {
		var res = [];
		for (x in a.map(f)) {
			for (y in x.a) {
				res.push(y);
			}
		}
		return new Array1(res);
	}
	public function pure<T>(x:T):Array1<T> {
		return new Array1([x]);
	}
}

private class Option1<T> implements Monad<Option1<_>, T> {
	var a:Option<T>;
	public function new (a:Option<T>) {
		this.a = a;
	}
	public function map <B>(f:T->B):Option1<B> {
		return switch a {
			case Some(x): new Option1(Some(f(x)));
			case None: new Option1(None);
		}

	}
	public function flatMap <B>(f:T->Option1<B>):Option1<B> {
		return switch a {
			case Some(x): f(x);
			case None: new Option1(None);
		}

	}
	public function pure<T>(x:T):Option1<T> {
		return new Option1(Some(x));
	}
}
class TypeMonadsInheritance {

	@:generic static inline function withMonad <M:Monad<M,_>,T,A,B>(x:M<T>, f:T->A, f2:A->M<B>):M<B> {
		return x.map(f).flatMap(f2);
	}

	public static function main () {
		var a = new Array1([1,2,3]);
		var b = new Option1(Some(1));

		withMonad(a, _ -> true, _ -> new Array1(["foo"]));
		withMonad(b, _ -> true, _ -> new Option1(Some("foo")));

	}
}