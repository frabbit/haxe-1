package types.typedefs;

typedef Mappable<M:Mappable<M,_>,T> = {
  public function map <B>(f:T->B):M<B>;
}