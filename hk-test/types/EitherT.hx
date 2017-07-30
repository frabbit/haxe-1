package types;

import haxe.ds.Either;

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