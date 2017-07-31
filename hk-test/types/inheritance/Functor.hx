package types.inheritance;
interface Functor<M, A> {
	public function map <B>(f:A->B):M<B>;
}