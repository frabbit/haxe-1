package typing;


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


interface Functor<F> {
	public function map<A,B>(f:F<A>, b:A->B):F<B>;
}

interface Applicative<F> extends Functor<F> {
	function map2<A,B,C>(fa:F<A>, fb:F<B>, f:A->B->C):F<C>;

	function pure<A>(a:A):F<A>;

	function traverse<A,B>(as:List<A>, f:A->F<B>):F<List<B>>;
	// derived
	function apply<A, B>(fab:F<A->B>, fa:F<A>):F<B>;
}

//typedef Compose<F, G, A> = F<G<A>>;

abstract Compose<F, G, A>(F<G<A>>) {
	function new (f) this = f;

	function unwrap ():F<G<A>> return this;
}



class ApplicativeComposition<F, G> implements Applicative<Compose<F, G, _>> {
	var appF:Applicative<F>;
	var appG:Applicative<G>;

	public function new (appF:Applicative<F>, appG:Applicative<G>) {
		this.appF = appF;
		this.appG = appG;
	}


	public function map2<A,B,C>(fa:Compose<F,G,A>, fb:Compose<F,G,B>, f:A->B->C):Compose<F,G,C> {
		return null;
	}



	public function map<A,B>(f:Compose<F,G,A>, b:A->B):Compose<F, G, B> {
		return null;
	}




	public function pure<A>(a:A):Compose<F,G,A> return null;


	public function traverse<A,B>(as:List<A>, f:A->Compose<F,G,B>):Compose<F,G,List<B>> {
		return null;
	}

	//derived
	public function apply<A, B>(fab:Compose<F,G,A->B>, fa:Compose<F,G,A>):Compose<F,G,B> return null; //Applicatives.defaultApply(this, fab, fa);

}
/*
Apply(f, b)

Apply(F, G)

Apply(Apply(F, G), B)

Apply(Apply(F, G), Apply(F, G))

Apply(F, Apply(G, Apply(F, G)))

Apply(Apply)

Apply(F, Apply(G, B))

Apply(F, Apply(G, B)) = Apply(Apply(F, G), B))

Apply(F, Apply(G, B))

Apply(Apply(Apply(F), A), B) => F<A, B>


Apply(Apply(F, Apply(G, _)), B)

Apply(, b)
Apply(f, Apply(g, b))
F<G<B>>
*/
/*
F

F<C>

Apply(F, C)





Apply<(F, G<_>)

Apply<(F, G<_>)

Apply(F, Apply(G, C))

Apply(F<G<_>>, C)

F<G<_>>

Apply()

*/