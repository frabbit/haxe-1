package typing;

import types.Monad;
import types.Functor;

import haxe.ds.Option;


class ArrayMonad implements Monad<Array<_>> {

	public function new () {
	}

	public inline function fmap <T,B>(a:Array<T>,f:T->B):Array<B> {
		return a.map(f);
	}
	public inline function flatMap <T,B>(a:Array<T>,f:T->Array<B>):Array<B> {
		var res:Array<B> = [];
		for (x in a.map(f)) {
			for (y in x) {
				res.push(y);
			}
		}
		return res;
	}
	public function pure<T>(x:T):Array<T> {
		return [x];
	}
}

class OptionMonad implements Monad<Option<_>> {

	public function new () {}

	public inline function fmap <T,B>(a:Option<T>, f:T->B):Option<B> {
		return switch a {
			case Some(x): Some(f(x));
			case None: None;
		}

	}
	public inline function flatMap <T,B>(a:Option<T>, f:T->Option<B>):Option<B> {
		return switch a {
			case Some(x): f(x);
			case None: None;
		}

	}
	public function pure<T>(x:T):Option<T> {
		return Some(x);
	}
}

class TypeMonads {

	static inline function withMonad <M,T,A,B>(x:M<T>, f:T->A, f2:A->M<B>, m:Monad<M>):M<B> {
		var x = m.fmap(x,f);
		return m.flatMap(x,f2);
	}

	public static function main () {
		var a = [1,2,3];
		var b = Some(1);
		var arrayMonad = new ArrayMonad();
		var optionMonad = new OptionMonad();

		//Log.enable(true);
		withMonad(a, _ -> true, _ -> ["foo"], arrayMonad);
		//Log.enable(false);
		withMonad(b, _ -> true, _ -> Some("foo"), optionMonad);

	}
}