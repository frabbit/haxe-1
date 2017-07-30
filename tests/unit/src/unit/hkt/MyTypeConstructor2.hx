package unit.hkt;

using unit.hkt.Helpers;
using unit.hkt.MyTypeConstructor2.Lists;
using unit.hkt.MyTypeConstructor2.Function3s;
using unit.hkt.MyTypeConstructor2.Function4s;
import haxe.ds.Option;

enum Unit {
	unit;
}


private enum ListData<T> {
	Nil;
	Cons(e:T, tail:List<T>);
}

abstract List<T>(ListData<T>) from ListData<T> {
	inline function new (ld:ListData<T>) this = ld;
	public static inline function nil<T>():List<T> return new List(Nil);
	public static inline function cons<T>(a:T, list:List<T>):List<T> return new List(Cons(a, list));
}

class Lists {
	public static inline function nil<T>():List<T> return List.nil();
	public static inline function cons<T>(a:T, list:List<T>):List<T> return List.cons(a, list);



	public static function map <A,B>(a:List<A>, f:A->B):List<B> return switch a {
		case Nil: nil();
		case Cons(e, tail): cons(f(e), map(tail, f));
	}

	public static function flatten <A>(a:List<List<A>>):List<A> return switch a {
		case Nil: nil();
		case Cons(e, tail): concat(e, flatten(tail));
	}

	public static function flatMap <A,B>(a:List<A>, f:A->List<B>):List<B> {
		return flatten(map(a, f));
	}

	public static function concat <A>(a:List<A>, b:List<A>) return switch a {
		case Nil: b;
		case Cons(e, tail): cons(e, concat(a, b));
	}

	public static function foldRight <A,B>(a:List<A>, acc:B, f:A->B->B):B {
		return switch a {
			case Nil: acc;
			case Cons(e, tail): f(e, foldRight(tail, acc, f));
		}
	}
	public static function foldLeft <A,B>(a:List<A>, acc:B, f:B->A->B):B {
		return switch a {
			case Nil: acc;
			case Cons(e, tail): foldLeft(tail, f(acc,e), f);
		}
	}
}

class Function3s {
	public static function curried <A,B,C,D>(f:A->B->C->D):A->(B->(C->D))
	{
		return a -> b -> c -> f(a,b,c);
	}
}
class Function4s {
	public static function curried <A,B,C,D,E>(f:A->B->C->D->E):A->(B->(C->(D->E)))
	{
		return a -> b -> c -> d -> f(a,b,c,d);
	}
}

interface Monoid<T> {
	public function zero ():T;
	public function plus (a:T, b:T):T;


	public function foldMap<S>(a:Array<S>, f : S -> T):T;
}

class Monoids {
	public static function foldMapDefault<S, T>(m:Monoid<T>, a:Array<S>, f : S -> T):T
	{
		var res = m.zero();
		for (x in a) {
			res = m.plus(res, f(x));
		}
		return res;
	}
}

class OptionAsFunctor<A> implements Functor<Option<_>> {
	public function map<A, B>(o:Option<A>, f:A->B):Option<B> {
		return switch o {
			case Some(v): Some(f(v));
			case None: None;
		}
	}
}


class EndoMonoid<A> implements Monoid<A->A> {
	var monoidA:Monoid<A>;
	public function new (monoidA:Monoid<A>) {
		this.monoidA = monoidA;
	}
	public function zero ():A->A return function (a) return a;
	public function plus (a:A->A, b:A->A):A->A return function (x:A) return monoidA.plus(a(x), b(x));

	public function foldMap<S>(a:Array<S>, f : S -> (A->A) ) :(A->A) {
		return Monoids.foldMapDefault(this, a, f);
	}
}

class BoolOrAsMonoid implements Monoid<Bool> {
	public function zero () return false;
	public function plus (a:Bool, b:Bool) return a || b;

	public function foldMap<S>(a:Array<S>, f : S -> Bool):Bool {
		return Monoids.foldMapDefault(this, a, f);
	}
}

class BoolAndAsMonoid implements Monoid<Bool> {
	public function zero () return true;
	public function plus (a:Bool, b:Bool) return a && b;

	public function foldMap<S>(a:Array<S>, f : S -> Bool):Bool {
		return Monoids.foldMapDefault(this, a, f);
	}
}

class OptionAsFoldable implements Foldable<Option<_>> {

	public function foldRight <A,B>(as:Option<A>, z:B, f:A->B->B):B {
		return switch as {
			case Some(v): f(v, z);
			case None: z;
		}
	}

	public function foldLeft <A,B>(as:Option<A>, z:B, f:B->A->B):B {
		return switch as {
			case Some(v): f(z, v);
			case None: z;
		}
	}

	public function foldMap <A,B>(as:Option<A>, f:A->B, mb:Monoid<B>):B {
		return switch as {
			case Some(v): f(v);
			case None: mb.zero();
		}
	}

	public function concat <A> (as:Option<A>, m:Monoid<A>):A return Foldables.defaultConcat(this, as, m);
}

class Foldables {
	public static function defaultConcat <A,F> (f:Foldable<F>, as:F<A>, m:Monoid<A>):A return f.foldLeft(as, m.zero(), m.plus);
}

interface Functor<F> {
	public function map<A,B>(f:F<A>, b:A->B):F<B>;
}

interface Foldable<F> {
	function foldRight <A,B>(as:F<A>, z:B, f:A->B->B):B;
	function foldLeft <A,B>(as:F<A>, z:B, f:B->A->B):B;
	function foldMap <A,B>(as:F<A>, f:A->B, mb:Monoid<B>):B;
	function concat <A> (as:F<A>, m:Monoid<A>):A;
}



interface Applicative<F> extends Functor<F> {
	function map2<A,B,C>(fa:F<A>, fb:F<B>, f:A->B->C):F<C>;

	function pure<A>(a:Lazy<A>):F<A>;

	function traverse<A,B>(as:List<A>, f:A->F<B>):F<List<B>>;
	// derived
	function apply<A, B>(fab:F<A->B>, fa:F<A>):F<B>;
}




class OptionAsApplicative<A> extends OptionAsFunctor<A> implements Applicative<Option<_>> {
	public function new () {}


	public function pure<A>(a:Lazy<A>):Option<A> {
		var x:A = a.get();
		return haxe.ds.Option.Some(x);
	}

	public function map2<A,B,C>(fa:Option<A>, fb:Option<B>, f:A->B->C):Option<C> {
		return switch [fa, fb] {
			case [Some(a), Some(b)]: Some(f(a,b));
			case _ : None;
		}
	}

	public function traverse<A,B>(as:List<A>, f:A->Option<B>):Option<List<B>> {
		return null; //Applicatives.defaultTraverse(this, as, f);
	}
	// derived
	public function apply<A, B>(fab:Option<A->B>, fa:Option<A>):Option<B> {
		return null; //Applicatives.defaultApply(this, fab, fa);
	}

}

class ApplicativeComposition<F, G> implements Applicative<F<G<_>>> {
	var appF:Applicative<F>;
	var appG:Applicative<G>;

	public function new (appF:Applicative<F>, appG:Applicative<G>) {
		this.appF = appF;
		this.appG = appG;
	}

	public function map2<A,B,C>(fa:F<G<A>>, fb:F<G<B>>, f:A->B->C):F<G<C>> {
		return appF.map2( fa, fb, (ga, gb) -> appG.map2(ga, gb, (a, b) -> f(a,b) ) );
	}

	public function map<A,B>(f:F<G<A>>, b:A->B):F<G<B>> {

		return null; // Applicatives.defaultMap(this,f,b);
	}



	public function pure<A>(a:Lazy<A>):F<G<A>> return appF.pure(Lazy.mk(() -> appG.pure(a)));

	public function traverse<A,B>(as:List<A>, f:A->F<G<B>>):F<G<List<B>>> {
		return null; //return Applicatives.defaultTraverse(this,as,f);
	}
	//derived
	public function apply<A, B>(fab:F<G<A->B>>, fa:F<G<A>>):F<G<B>> return null; //Applicatives.defaultApply(this, fab, fa);

}


class Applicatives {

	//defaultTraverse.B -> list : unit.hkt.List<defaultTraverse.B> -> unit.hkt.List<defaultTraverse.B>
	//defaultTraverse.B -> unit.hkt.Unit -> unit.hkt.List<defaultTraverse.B>

	public static function defaultTraverse<F,A,B>(ap:Applicative<F>, as:List<A>, f:A->F<B>):F<List<B>> {
		var init = ap.pure(Lazy.mk(() -> List.nil() ));
		return Lists.foldRight(as,
			init,
			(a:A, fbs) -> ap.map2( f(a), fbs, List.cons )
		);
	}


	public static function defaultMap<F, A, B>(ap:Applicative<F>, fa:F<A>, f:A->B):F<B> {

		return ap.map2(fa, ap.pure(Lazy.mk(() -> unit)), function (a, _) return f(a));
	}


	public static function defaultApply<F, A, B>(ap:Applicative<F>, fab:F<A->B>, fa:F<A>):F<B> {
		return ap.map2(fab, fa, function (ab:A->B, a:A ) return ab(a));
	}
	public static function map3<F, A, B,C,D>(ap:Applicative<F>, fa:F<A>, fb:F<B>, fc:F<C>, f:A->B->C->D):F<D> {

		var s0 = ap.pure(Lazy.mk(() -> f.curried()));
		var s1 = defaultApply(ap, s0, fa);

		var s2 = defaultApply(ap, s1, fb);
		return defaultApply(ap, s2, fc);
	}
	public static function map4<F, A, B,C,D,E>(ap:Applicative<F>, fa:F<A>, fb:F<B>, fc:F<C>, fd:F<D>, f:A->B->C->D->E):F<E> {

		var s0 = ap.pure(Lazy.mk(() -> f.curried()));

		var s1 = defaultApply(ap, s0, fa);
		var s2 = defaultApply(ap, s1, fb);
		var s3 = defaultApply(ap, s2, fc);
		return defaultApply(ap, s3, fd);
	}



	public static function compose <F, G>(F:Applicative<F>, G:Applicative<G> ):Applicative<F<G<_>>>
	{
		return new ApplicativeComposition(F, G);
	}



}
/*

class ApplicativeComposition3<F, G, H> implements Applicative<F<G<H<_>>>> {
	var appF:Applicative<F>;
	var appG:Applicative<G>;
	var appH:Applicative<H>;

	public function new (appF:Applicative<F>, appG:Applicative<G>, appH:Applicative<H>) {
		this.appF = appF;
		this.appG = appG;
		this.appH = appH;
	}



	public function map2<A,B,C>(fa:F<G<H<A>>>, fb:F<G<H<B>>>, f:A->B->C):F<G<H<C>>> {
		return appF.map2( fa, fb,
			(ga, gb) -> appG.map2(ga, gb,
				(ha, hb) -> appH.map2(ha, hb,
					 (a, b) -> f(a,b)
				)
			)
		);
	}

	public function map<A,B>(f:F<G<H<A>>>, b:A->B):F<G<H<B>>> {
		return Applicatives.defaultMap(
			this,
			f,
			b
		);
	}

	public function pure<A>(a:Lazy<A>):F<G<H<A>>> return appF.pure(Lazy.mk(() -> appG.pure(Lazy.mk(() -> appH.pure(a)))));

	public function traverse<A,B>(as:List<A>, f:A->F<G<H<B>>>):F<G<H<List<B>>>> {
		return Applicatives.defaultTraverse(
			this,
			as,
			f
		);
	}
	//derived
	public function apply<A, B>(fab:F<G<H<A->B>>>, fa:F<G<H<A>>>):F<G<H<B>>> return Applicatives.defaultApply(this, fab, fa);

}

*/
