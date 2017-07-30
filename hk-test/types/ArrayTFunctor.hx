package types;

using types.ArrayT;
import types.Functor;

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

    var x:M<Array<B>> = functorM.fmap(v.runT(), g);
	  return x.arrayT();
  }

}
