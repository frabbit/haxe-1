package unit;

using unit.MyTypeConstructor;

class TestTypeConstructor extends Test {
	public function testMonadTransformers() 
	{
		var func = new ArrayTFunctor(new ArrayTFunctor(new EitherMonad()));
		var e = Right([[1]]);

		var r = e.arrayT().arrayT().fmap(function (x) return x+1, func).runT().runT();

		
		var rx : Either<String, Array<Array<Int>>> = r;
		t(r.match(Right([[2]])));

		var r = e.fmap(function (x) return 1, new EitherMonad());

		t(r.match(Right(1)));		

		var r = e.arrayT().fmap(function (x) return [1], new ArrayTFunctor(new EitherMonad())).runT();

		t(r.match(Right([[1]])));

		var r = e.arrayT().arrayT().fmap(function (x) return x+1, new ArrayTFunctor(new ArrayTFunctor(new EitherMonad()))).runT().runT();

		t(r.match(Right([[2]])));

		var r = e.arrayT().arrayT().fmap(function (x) return x+1, func).runT().runT();

		t(r.match(Right([[2]])));

		

		var e2 = Right([[Right(1)]]);

		

		var r = e2.arrayT().arrayT().eitherT().fmap(function (x) return x+1, new EitherTFunctor(new ArrayTFunctor(new ArrayTFunctor(new EitherMonad())))).runT().runT().runT();

		
		
		t(r.match(Right([[Right(2)]])));


 	}

 	public function testLeftInType() 
 	{
 		var x : Of<Either<In, Int>, String> = Left("hello");

 		//$type(x.fmap);

 		var r = x.fmap(function (x) return x+" world", new EitherLeftMonad());

 		t(r.match(Left("hello world")));

 		var r = x.flatMap(function (x) return Left(x+" world"), new EitherLeftMonad());

 		t(r.match(Left("hello world")));
 	}

 	public function testReversedTypedef() 
 	{
 		var x : Of<ReversedEitherAlias<Int, In>, String> = Left("hello");
 		
 		var r = x.fmap(function (x) return x+" world", new EitherLeftMonad());

 		t(r.match(Left("hello world")));

 		var r = x.flatMap(function (x) return Left(x+" world"), new EitherLeftMonad());

		t(r.match(Left("hello world")));

 	}

 	public function testStructure() 
 	{
 		// explicit left lifted Of type

 		var z:Of<Tup2<In,Int>, String> = { _1 : "hey", _2 : 20};

 		var r = z.fmap(function (x) return x + " foo", new Tup2LeftFunctor());

 		t(r._1 == "hey foo" && r._2 == 20);

 		// explicit right lifted Of type

 		var z:Of<Tup2<String,In>, Int> = { _1 : "hey", _2 : 20};

 		var r = z.fmap(function (x) return x + 20, new Tup2RightFunctor());

 		t(r._1 == "hey" && r._2 == 40);


 		// implicit Of type: always the right type parameter is lifted

 		var z:Tup2<String,Int> = { _1 : "hey", _2 : 20};

 		var r = z.fmap(function (x) return x + 20, new Tup2RightFunctor());

 		t(r._1 == "hey" && r._2 == 40);


 	}

 	public function testReversedAbstract() 
 	{

 		var x : ReversedEither<Int, String> = new ReversedEither(Left("hello"));

 		var r = x.fmap(function (x) return x+" world", new ReversedEitherMonad());

 		t(r.toEither().match(Left("hello world")));
 	}


 	public function testOopMappable() {
 		
 		function mapMappable <M,A,B>(m:Mappable<M,A>, f:A->B):M<B> {
 			return m.map(f);
 		}

 		var x = new MyArray([1]);
 		
 		var r = mapMappable(x, function (y) return y+1);





 		t(r.a[0] == 2);



 		var l = new List();
 		l.add(1);
 		var x = new MyList(l);


 		var r = mapMappable(x, function (y) return y+1);

 		



 		t(r.a.first() == 2);

 	}

 	public function testOopFlatMappable() {
 		
 		function flatMapMappable <M,A,B>(m:FlatMappable<M,A>, f:A->M<B>):M<B> {
 			return m.flatMap(f);
 		}

 		var x = new MyArray([1]);
 		
 		var r = flatMapMappable(x, function (y) return new MyArray([y+1]));

 		t(r.a[0] == 2);

 		var l = new List();
 		l.add(1);
 		var x = new MyList(l);

 		var r = flatMapMappable(x, function (y) return new MyList({ var l = new List(); l.add(y+1); l;}));

 		t(r.a.first() == 2);


 	}
 	static function mapMappable <M,A,B>(m:MappableTD<M,A>, f:A->B):M<B> {
		return m.map(f);
	}

	public function testOopMappableWithTypedef() {

 		var x = [1];
 		
 		var r = mapMappable(x, function (y) return y+1);

 		t(r[0] == 2);



 		var x = new List();
 		x.add(1);
 		

 		var r = mapMappable(x, function (y) return y+1);


 		t(r.first() == 2);

 	}

 	


 	
 	/*
 	 next target, after reducing an of type which can't be reduced, 
 	 apply the In type on each constraint and type field access on the reduced constraints.
 	 this would allow this, which is much more useful:
	
 	static function test1 <M:Filterable<M,In>,A,B>(m:M<A>, f:A->Bool):M<A> {
 		return m.filter(f).filter(f);
 	}
 	*/

 	public function testOopFilterableWithTypedef() {


 		function genericFilter <M,A,B>(m:Filterable<M,A>, f:A->Bool):M<A> {
 			return m.filter(f);
 		}

 		var x = [1,2,3,4];
 		
 		var r = genericFilter(x, function (y) return y > 2);

 		t(r.length == 2);
 		t(r[0] == 3);
		t(r[1] == 4);

 		var x = new List();
 		x.add(1);
 		x.add(2);
 		x.add(3);
 		x.add(4);
 		
 		var r = genericFilter(x, function (y) return y > 2);


 		t(r.length == 2);
 		t(r.first() == 3);
 		t(r.last() == 4);

 	}

 	

 // 	private static function foo <M,Z:(Filterable<M,Int>, MappableTD<M,Int>)> (m:Z):Z {
	// 	return m.map(function (x) return x+1).filter(function (x) return x > 2);
	// }

 // 	public function testOopFilterMapWithTypedef() {
 		
 		

 // 		var x = [1,2,3];
 		
 // 		var r = foo(x);

 // 		t(r.length == 2);
 // 		t(r[0] == 3);
	// 	t(r[0] == 4);

 // 		var x = new List();
 // 		x.add(1);
 // 		x.add(2);
 // 		x.add(3);
 		
 // 		var r = foo(x);


 // 		t(r.length == 2);
 // 		t(r.first() == 3);
 // 		t(r.last() == 4);

 // 	} 	


}