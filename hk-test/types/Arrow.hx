package types;

Void -> types.inheritance.FuncArrow<types.Tup2<types.inheritance.FuncArrow.A, C>, types.Tup2<types.inheritance.FuncArrow.B, C>>

should be

Void -> -Of<-Of<types.inheritance.FuncArrow<_, _>,types.Tup2<types.inheritance.FuncArrow.A, C>>,types.Tup2<types.inheritance.FuncArrow.B, C>>