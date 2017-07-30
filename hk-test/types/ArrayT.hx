package types;

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