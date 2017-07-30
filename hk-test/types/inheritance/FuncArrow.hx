package types.inheritance;

import types.inheritance.Arrow;
import types.Tup2;

class FuncArrow<A,B> implements Arrow<FuncArrow<_,_>, A, B>
{
  var a : A->B;

  public function new (a:A->B) {
    this.a = a;
  }

  public function create<A,B> (f:A->B):FuncArrow<A,B> {
    return new FuncArrow(f);
  }

  public function run (a:A):B
  {
    return this.a(a);
  }

  public function first  <C>():FuncArrow<Tup2<A,C>,Tup2<B,C>> {
    return create(function (t:Tup2<A,C>) return new Tup2(this.a(t._1), t._2));

  }
  public function second <C>():FuncArrow<Tup2<C,A>, Tup2<C,B>> {
    return create(function (t:Tup2<C,A>) return new Tup2(t._1, this.a(t._2)));
  }

  public function split <A1,B1>(g:FuncArrow<A1, B1>):FuncArrow<Tup2<A,A1>, Tup2<B,B1>> {
    return first().next(g.second());
  }

  public function dot <C>(f:FuncArrow<C, A>):FuncArrow<C, B> {
    return create(function (c:C) return a(f.a(c)));
  }

  public function next <C>(f:FuncArrow<B, C>):FuncArrow<A, C> {
    return create(function (c:A) return f.a(a(c)));
  }
}