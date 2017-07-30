package types;

abstract FuncT<M,L,A>(M<L -> A>)
{

  public function new (x:M<L -> A>) {
    this = x;
  }

  public function unwrap ():M<L -> A> {
    return this;
  }

  public static function runT <M1,L,A1>(a:FuncT<M1,L,A1>):M1<L -> A1>
  {
    return a.unwrap();
  }
  public static function funcT <M,L,A>(a:M<L -> A>):FuncT<M,L,A>
  {
    return new FuncT(a);
  }

}