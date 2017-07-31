package types.inheritance;

import types.inheritance.Category;
import types.Tup2;

interface Arrow<Arr,A,B> extends Category<Arr, A, B>
{

  public function first  <C>():Arr<Tup2<A,C>, Tup2<B,C>>;
  public function second <C>():Arr<Tup2<C,A>, Tup2<C,B>>;

  public function split <A1,B1>(g:Arr<A1, B1>):Arr<Tup2<A,A1>, Tup2<B,B1>>;

}