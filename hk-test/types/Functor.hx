package types;

interface Functor<F> {
  public function fmap<A,B>(x:F<A>, f:A->B):F<B>;
}