package types;
import types.Functor;
interface Monad<M> extends Functor<M> {
   public function flatMap<A,B>(x:M<A>, f:A->M<B>):M<B>;
}