package unit;


using unit.MyTypeConstructor.ArrayT;
using unit.MyTypeConstructor.EitherT;

enum Either<L,R> {
	Left(l:L);
	Right(r:R);
}

interface Functor<F> {
  public function fmap<A,B>(x:F<A>, f:A->B):F<B>;
}


class EitherFunctor<L> implements Functor<Either<L, In>> 
{
     public function new () {}
     public function fmap<A,B>(x:Either<L, A>, f:A->B):Either<L, B> {
         return switch (x) {
            case Right(r): Right(f(r));
            case Left(l): Left(l);
         }
     }
}


class EitherLeftFunctor<R> implements Functor<Either<In, R>> 
{
     public function new () {}
     public function fmap<A,B>(x:Either<A, R>, f:A->B):Either<B, R> {
         return switch (x) {
            case Right(r): Right(r);
            case Left(l): Left(f(l));
         }
     }
}


class ReversedEitherFunctor<R> implements Functor<ReversedEither<R, In>> 
{
     public function new () {}
     public function fmap<A,B>(x:ReversedEither<R, A>, f:A->B):ReversedEither<R, B> {
         return switch (x.toEither()) {
            case Right(r): new ReversedEither(Right(r));
            case Left(l): new ReversedEither(Left(f(l)));
         }
     }
}


 
class ArrayFunctor implements Functor<Array<In>> {
  public function new () {}
  public inline function fmap<S,T>(a:Array<S>, f:S->T):Array<T> {
    return a.map(f);
  }
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


class ArrayTFunctor<M> implements Functor<ArrayT<M,In>> 
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

class EitherTFunctor<M,L> implements Functor<EitherT<M,L,In>> 
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


typedef ReversedEitherAlias<B,A> = Either<A,B>;

abstract ReversedEither<R,L>(Either<L,R>) 
{
  public function new (x:Either<L,R>) this = x;

  public function toEither ():Either<L,R> {
    return this;
  }
}
