package types.inheritance;

import types.inheritance.Category;
import types.Tup2;

interface Category<Cat:Category<Cat, _, _>, A, B>
{
  public function create<A,B> (f:A->B):Cat<A,B>;

  public function run (a:A):B;

  public function dot <C>(f:Cat<C, A>):Cat<C, B>;

  public function next <C>(f:Cat<B, C>):Cat<A, C>;


}