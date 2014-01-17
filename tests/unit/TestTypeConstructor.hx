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


	public function testMappable() {
		
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

	

	public function testFlatMappable() {

		function flatMapFlatMappable <M,A,B>(m:FlatMappable<M,A>, f:A->M<B>):M<B> {
			return m.flatMap(f);
		}

		var x = new MyArray([1]);
		
		var r = flatMapFlatMappable(x, function (y) return new MyArray([y+1]));

		t(r.a[0] == 2);

		var l = new List();
		l.add(1);
		var x = new MyList(l);

		var r = flatMapFlatMappable(x, function (y) return new MyList({ var l = new List(); l.add(y+1); l;}));

		t(r.a.first() == 2);


	}
	
	
	
	

	public function testMappableWithTypedef() {

		function mapMappable <M,A,B>(m:MappableTD<M,A>, f:A->B):M<B> {
			return m.map(f);
		}
		
		
		#if !as3	
		/*
		 !!!!!!!!!!!!!
		 TODO
		 This fails on as3 because the call to map inside of mapMappable actually calls map on dynamic nand not the haxe defined function. 
		 A runtime wrapper for filter and map is missing.
		*/
		var x = [1];
		
		var r = mapMappable(x, function (y) return y+1);

		t(r[0] == 2);

		#end
		
		var x = new List();
		x.add(1);
		
		var r = mapMappable(x, function (y) return y+1);

		t(r.first() == 2);

	}
	



	public function testFilterableWithTypedef() {
		
		function filterFilterable <M,A,B>(m:Filterable<M,A>, f:A->Bool):M<A> {
			// you can currently not apply filter again, this is a limitation which could be solved with constraints described at the bottom
			return m.filter(f);
		}
		
		#if !as3	
		/*
		 !!!!!!!!!!!!!
		 TODO
		 This fails on as3 because the call to filter inside of filterFilterable actually calls filter on dynamic and not the haxe defined function. 
		 A runtime wrapper for filter and map is missing.
		*/

		var x = [1,2,3,4];
				
		var r = filterFilterable(x, function (y) return y > 2);
		t(r.length == 2);
		t(r[0] == 3);
		t(r[1] == 4);
		
		#end

		var x = new List();
		x.add(1);
		x.add(2);
		x.add(3);
		x.add(4);

		var r = filterFilterable(x, function (y) return y > 2);

		t(r.length == 2);
		t(r.first() == 3);
		t(r.last() == 4);
	}


 	private static function typeConstructorWithConstraints <M:(Filterable<M,In>, MappableTD<M,In>, { var length(default, null):Int;}), T> (m:M<Int>):M<Int> 
 	{
 		return m.map(function (x) return x+1).filter(function (x) return x > 2);
	}

	public function testTypeConstructorWithConstraints () {
		
		#if !as3
		var a = [1,2,3];
		var r = typeConstructorWithConstraints(a);
		t(r.length == 2);
		t(r[0] == 3);
		t(r[1] == 4);
		#end

		var a = new List(); a.add(1); a.add(2); a.add(3);
		var r = typeConstructorWithConstraints(a);
		t(r.length == 2);
		t(r.first() == 3);
		t(r.last() == 4);
	}
	
	public function testTypeConstructorClassConstraints () 
	{
		#if !as3
		var x : BetterFilterable<Array<In>, Int> = [1,2,3,4];

		var r = x.filter(function (x) return x < 3).filter(function (x) return x > 1);

		

		t(r.length == 1);
		t(r[0] == 2);
		#end
		
		var x : BetterFilterable<List<In>, Int> = { var l = new List(); l.add(1); l.add(2); l.add(3); l.add(4); l; }


		var r = x.filter(function (x) return x < 3).filter(function (x) return x > 1);


		

		t(r.length == 1);
		t(r.first() == 2);

	}

	static function passTwo <M,A,B> (m:M<A,B>):M<A,B> {
		return m;
	}

	public function testTypeConstructorWithTwoParameters () {
		
		var e = Left(1);
		var x = passTwo(e);
		t(e.match(Left(1)));


		
	}
	

}