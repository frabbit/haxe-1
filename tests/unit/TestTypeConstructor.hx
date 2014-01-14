package unit;

using unit.MyTypeConstructor;

class TestTypeConstructor extends Test {
	public function testMonadTransformers() 
	{
		var func = new ArrayTFunctor(new ArrayTFunctor(new EitherFunctor()));
		var e = Right([[1]]);

		var r = e.arrayT().arrayT().fmap(function (x) return x+1, func).runT().runT();

		
		var rx : Either<String, Array<Array<Int>>> = r;
		t(r.match(Right([[2]])));

		var r = e.fmap(function (x) return 1, new EitherFunctor());

		t(r.match(Right(1)));		

		var r = e.arrayT().fmap(function (x) return [1], new ArrayTFunctor(new EitherFunctor())).runT();

		t(r.match(Right([[1]])));

		var r = e.arrayT().arrayT().fmap(function (x) return x+1, new ArrayTFunctor(new ArrayTFunctor(new EitherFunctor()))).runT().runT();

		t(r.match(Right([[2]])));

		var r = e.arrayT().arrayT().fmap(function (x) return x+1, func).runT().runT();

		t(r.match(Right([[2]])));

		

		var e2 = Right([[Right(1)]]);

		

		var r = e2.arrayT().arrayT().eitherT().fmap(function (x) return x+1, new EitherTFunctor(new ArrayTFunctor(new ArrayTFunctor(new EitherFunctor())))).runT().runT().runT();

		
		
		t(r.match(Right([[Right(2)]])));


 	}

 	public function testLeftInType() 
 	{
 		var x : Of<Either<In, Int>, String> = Left("hello");

 		//$type(x.fmap);

 		var r = x.fmap(function (x) return x+" world", new EitherLeftFunctor());

 		t(r.match(Left("hello world")));
 	}

 	public function testReversedTypedef() 
 	{
 		// the rule that the mostleft In type is used to determine the lifted Of type doesn't actually apply for typedefs because they are nothing else than an alias
 		var x : Of<ReversedEitherAlias<Int, In>, String> = Left("hello");
 		

 		x.fmap.bind(function (x) return x+" world")(new EitherLeftFunctor());

 		var r = x.fmap(function (x) return x+" world", new EitherLeftFunctor());

 		//t(r.match(Left("hello")));
 	}

 	public function testStructure() 
 	{
 		// the rule that the mostleft In type is used to determine the lifted Of type doesn't actually apply for typedefs because they are nothing else than an alias
 		var x : Of<ReversedEitherAlias<Int, In>, String> = Left("hello");
 		// Of<Either<In, Int>, String>

 		//$type(x.fmap.bind(function (x) return x+" world"))(new EitherLeftFunctor());

 		var r = x.fmap(function (x) return x+" world", new EitherLeftFunctor());

 		//t(r.match(Left("hello")));
 	}

 	public function testReversedAbstract() {
 		var x : ReversedEither<Int, String> = new ReversedEither(Left("hello"));

 		var r = x.fmap(function (x) return x+" world", new ReversedEitherFunctor());

 		t(r.toEither().match(Left("hello world")));
 	}

 	
}