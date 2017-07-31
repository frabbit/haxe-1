package types.inheritance;
interface Monad<M, A> extends Functor<M,A> {
	public function flatMap <B>(f:A->M<B>):M<B>;
	public function pure<T>():M<T>;
}