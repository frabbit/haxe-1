package unit;

import haxe.ds.Option;
using unit.MyTypeConstructor.ArrayT;
using unit.MyTypeConstructor.EitherT;


enum Either<L,R> {
  Left(l:L);
  Right(r:R);
}


abstract ArrayT<M, A>(M<Array<A>>)
{
  public function new (x:M<Array<A>>) {
    this = x;
  }
  public function unwrap ():M<Array<A>> {
    return this;
  }

  public static function runT <M1,A1>(a:ArrayT<M1,A1>):M1<Array<A1>>
  {
    return a.unwrap();
  }
  public static function arrayT <M1,A1>(a:M1<Array<A1>>):ArrayT<M1,A1>
  {
    return new ArrayT(a);
  }
}


abstract EitherT<M,L,A>(M<Either<L,A>>)
{

  public function new (x:M<Either<L,A>>) {
    this = x;
  }

  public function unwrap ():M<Either<L,A>> {
    return this;
  }

  public static function runT <M1,L,A1>(a:EitherT<M1,L,A1>):M1<Either<L,A1>>
  {
    return a.unwrap();
  }
  public static function eitherT <M,L,A>(a:M<Either<L, A>>):EitherT<M,L,A>
  {
    return new EitherT(a);
  }

}



interface Functor<F> {
  public function fmap<A,B>(x:F<A>, f:A->B):F<B>;
}

interface Monad<M> extends Functor<M> {
   public function flatMap<A,B>(x:M<A>, f:A->M<B>):M<B>;
}



class EitherMonad<L> implements Monad<Either<L, _>>
{
     public function new () {}
     public function fmap<A,B>(x:Either<L, A>, f:A->B):Either<L, B> {
         return switch (x) {
            case Right(r): Right(f(r));
            case Left(l): Left(l);
         }
     }
     public function flatMap<A,B>(x:Either<L, A>, f:A->Either<L,B>):Either<L, B> {
         return switch (x) {
            case Right(r): f(r);
            case Left(l): Left(l);
         }
     }
}




class ReversedEitherMonad<R> implements Monad<ReversedEither<R, _>>
{
     public function new () {}
     public function fmap<A,B>(x:ReversedEither<R, A>, f:A->B):ReversedEither<R, B> {
         return switch (x.toEither()) {
            case Right(r): new ReversedEither(Right(r));
            case Left(l): new ReversedEither(Left(f(l)));
         }
     }
     public function flatMap<A,B>(x:ReversedEither<R, A>, f:A->ReversedEither<R,B>):ReversedEither<R, B> {
         return switch (x.toEither()) {
            case Right(r): new ReversedEither(Right(r));
            case Left(l): f(l);
         }
     }
}




class ArrayMonad implements Monad<Array<_>> {
  public function new () {}
  public inline function fmap<S,T>(a:Array<S>, f:S->T):Array<T> {
    return a.map(f);
  }
  public inline function flatMap<S,T>(a:Array<S>, f:S->Array<T>):Array<T> {
    return [for (x in a) for (y in f(x)) y];
  }
}
class OptionMonad implements Monad<Option<_>> {
  public function new () {}
  public inline function fmap<S,T>(a:Option<S>, f:S->T):Option<T> {
    return switch a {
      case Some(a): Some(f(a));
      case None: None;
    }
  }
  public inline function flatMap<S,T>(a:Option<S>, f:S->Option<T>):Option<T> {
    return switch a {
      case Some(a): f(a);
      case None: None;
    }
  }
}




typedef ReversedEitherAlias<B,A> = Either<A,B>;

abstract ReversedEither<R,L>(Either<L,R>)
{
  public function new (x:Either<L,R>) this = x;

  public function toEither ():Either<L,R> {
    return this;
  }
}



class ArrayTFunctor<M> implements Functor<ArrayT<M,_>>
{
  var functorM:Functor<M>;

  public function new (functorM:Functor<M>)
  {
    this.functorM = functorM;
  }

  public function fmap<A,B>(v:ArrayT<M, A>,f:A->B):ArrayT<M, B>
  {
    function g (a:Array<A>) return a.map(f);

    return functorM.fmap(v.runT(), g).arrayT();
  }

}

class EitherTFunctor<M,L> implements Functor<EitherT<M,L,_>>
{
  var functorM:Functor<M>;

  public function new (functorM:Functor<M>)
  {
    this.functorM = functorM;
  }

  public function fmap<A,B>(v:EitherT<M,L,A>,f:A->B):EitherT<M,L,B>
  {
    function g (a:Either<L,A>)
      return switch (a) {
        case Left(x): Left(x);
        case Right(x): Right(f(x));
      }

    return functorM.fmap(v.runT(), g).eitherT();
  }

}


class FunctorSyntax {
  public static function fmap<M, S, T>(x:M<S>, f:S->T, m:Functor<M>):M<T>
  {
    return m.fmap(x, f);
  }
}
class MonadSyntax {
  public static function flatMap<M, S, T>(x:M<S>, f:S->M<T>, m:Monad<M>):M<T>
  {
    return m.flatMap(x, f);
  }
}



class Tup2<A,B> {
  public var _1 : A;
  public var _2 : B;

  public function new (_1:A, _2:B) {
    this._1 = _1;
    this._2 = _2;
  }
}

class Tup2RightFunctor<T> implements Functor<Tup2<T, _>> {
  public function new () {}
  public inline function fmap<A,B>(a:Tup2<T, A>, f:A->B):Tup2<T, B>
  {
    return new Tup2(
      a._1,
      f(a._2)
    );
  }
}


interface Mappable<M,T> {
  public function map <B>(f:T->B):M<B>;
}

typedef MappableTD<M,T> = {
  public function map <B>(f:T->B):M<B>;
}



interface FlatMappable<M,T> extends Mappable<M,T> {
  public function flatMap <B>(f:T->M<B>):M<B>;
}


class MyArray<T> implements FlatMappable<MyArray<_>, T> {
  public var a:Array<T>;
  public function new (a:Array<T>) {
    this.a = a;
  }
  public function map <B>(f:T->B):MyArray<B> {
    return new MyArray(this.a.map(f));
  }
  public function flatMap <B>(f:T->MyArray<B>):MyArray<B> {
    return new MyArray([for (x in a) for (y in f(x).a) y]);
  }
}


class MyList<T> implements FlatMappable<MyList<_>, T> {
  public var a:List<T>;
  public function new (a:List<T>) {
    this.a = a;
  }

  public function map <B>(f:T->B):MyList<B> {
    return new MyList(this.a.map(f));
  }

  public function flatMap <B>(f:T->MyList<B>):MyList<B> {
    var r = new List();
    for (x in a) for (y in f(x).a) r.add(y);
    return new MyList(r);
  }
}

typedef Filterable<M, T> = {
  public function filter (f:T->Bool):M<T>;
}


typedef BetterFilterable<M:BetterFilterable<M,_>, T> = {
  public function filter (f:T->Bool):M<T>;
}


interface Category<Cat:Category<Cat, _, _>, A, B>
{
  public function create<A,B> (f:A->B):Cat<A,B>;

  public function run (a:A):B;

  public function dot <C>(f:Cat<C, A>):Cat<C, B>;

  public function next <C>(f:Cat<B, C>):Cat<A, C>;


}

interface Arrow<Arr:Arrow<Arr, _, _>,A,B> extends Category<Arr, A, B>
{

  public function first  <C>():Arr<Tup2<A,C>, Tup2<B,C>>;
  public function second <C>():Arr<Tup2<C,A>, Tup2<C,B>>;

  public function split <A1,B1>(g:Arr<A1, B1>):Arr<Tup2<A,A1>, Tup2<B,B1>>;

}

class FunctionArrow<A,B> implements Arrow<FunctionArrow<_,_>, A, B>
{
  var a : A->B;

  public function new (a:A->B) {
    this.a = a;
  }

  public function create<A,B> (f:A->B):FunctionArrow<A,B> {
    return new FunctionArrow(f);
  }

  public function run (a:A):B
  {
    return this.a(a);
  }

  public function first  <C>():FunctionArrow<Tup2<A,C>,Tup2<B,C>> {
    return create(function (t:Tup2<A,C>) return new Tup2(this.a(t._1), t._2));

  }
  public function second <C>():FunctionArrow<Tup2<C,A>, Tup2<C,B>> {
    return create(function (t:Tup2<C,A>) return new Tup2(t._1, this.a(t._2)));
  }

  public function split <A1,B1>(g:FunctionArrow<A1, B1>):FunctionArrow<Tup2<A,A1>, Tup2<B,B1>> {
    return first().next(g.second());
  }

  public function dot <C>(f:FunctionArrow<C, A>):FunctionArrow<C, B> {
    return create(function (c:C) return a(f.a(c)));
  }

  public function next <C>(f:FunctionArrow<B, C>):FunctionArrow<A, C> {
    return create(function (c:A) return f.a(a(c)));
  }
}





private enum Node<Id> {
	CNode<X>(id:Id<X>);
}

private enum Node2<Id> {
	CNode2(id:Id);
}

private enum Node3<Id,X> {
	CNode3(id:Id<X>);
}

class UnifyTests {

  public static function getId2 <Y:Y<_>>(a:Node2<Y>) {
    return switch a {
			case CNode2(id): null;
		}
  }
  public static function getId3 <Y, X>(a:Node3<Y, X>):Y<X> {
    return switch a {
			case CNode3(id): id;
		}
  }
	public static function getId <Y>(a:Node<Y>) {

		return switch a {
			case CNode(id): null;
		}
	}
  static function test () {

		var n = CNode([1]);
		getId(n);
    //var n = CNode2(1);
		//getId2(n);
    var n = CNode3([1]);
		getId3(n);

	}
}

