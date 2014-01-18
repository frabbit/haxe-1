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

	public function testTypeConstructorWithTwoTypeParameters () {
		
		var e = Left(1);
		var x = passTwo(e);
		t(e.match(Left(1)));

	}

	static function passFour <M,A,B,C,D> (m:M<A,B,C,D>):M<A,B,C,D> {
		return m;
	}

	public function testTypeConstructorWithMoreThanTwoTypeParameters () {
		var e:FourTypeParameters<Int, String, Float, Array<Int>> = {
			a : 1,
			b : "a",
			c : 1.1,
			d : [1]
		}
		
		var x = passFour(e);
		t(x == e);
	}

	public function testArrows () 
	{
		
		function arr <A,B>(f:A->B) return new FunctionArrow(f);
		var a = arr(function (x) return "foo"+Std.string(x));
		var r = a.dot(arr(function (y) return y+2));
		t(r.run(1) == "foo3");
	}

	static function withArrow <Arr:(Arrow<Arr,In,In>)> (a:Arr<Int,String>):Int->String
	{
		return a.dot(a.create(function (y) return y+2))
			.dot(a.create(function (y) return y+2)).run;
	}

	public function testTypeConstructorWithTwoParametersAndConstraint () 
	{
		function arr <A,B>(f:A->B) return new FunctionArrow(f);
		var a = arr(function (x) return "foo"+Std.string(x));
		var r = withArrow(a);

		t(r(1) == "foo5");
	}

	public function testUnification () {
		var x1 : FourTypeParameters<Int, String, Float, Array<Int>> = null;
		var x2 : Of<Of<Of<Of<FourTypeParameters<In, In, In, In>, Int>, String>, Float>, Array<Int>> = null;
		var x3 : Of<Of<Of<FourTypeParameters<Int, In, In, In>, String>, Float>, Array<Int>> = null;
		var x4 : Of<Of<Of<FourTypeParameters<In, String, In, In>, Int>, Float>, Array<Int>> = null;
		var x5 : Of<Of<Of<FourTypeParameters<In, In, Float, In>, Int>, String>, Array<Int>> = null;
		var x6 : Of<Of<Of<FourTypeParameters<In, In, In, Array<Int>>, Int>, String>, Float> = null;
		var x7 : Of<Of<FourTypeParameters<In, In, Float, Array<Int>>, Int>, String> = null;
		var x8 : Of<Of<FourTypeParameters<In, String, In, Array<Int>>, Int>, Float> = null;
		var x9 : Of<Of<FourTypeParameters<Int, In, In, Array<Int>>, String>, Float> = null;

		var a1 = [x1,x2,x3,x4,x5,x6,x7,x8,x9];
		var a2 = [x2,x3,x4,x5,x6,x7,x8,x9];

		/*
		this doesn't work currently, i guess we have to check this in unify types
		because we first check type_eq which does no follow (i guess there is a reason why) and after following (pattern matching)
		we don't check if the followed types are equal. Where is the best place to add this check, i guess it's type_eq? but does it 
		have side effects?
		
		var a3 = a1.concat(a2);
		var a3:Array<FourTypeParameters<Int, String, Float, Array<Int>>> = a2;
		*/

		x1 = x2; x1 = x3; x1 = x4; x1 = x5; x1 = x6; x1 = x7; x1 = x8; x1 = x9;
		x2 = x1; x2 = x3; x2 = x4; x2 = x5; x2 = x6; x2 = x7; x2 = x8; x2 = x9; 
		x3 = x1; x3 = x2; x3 = x4; x3 = x5; x3 = x6; x3 = x7; x3 = x8; x3 = x9;
		x4 = x1; x4 = x2; x4 = x3; x4 = x5; x4 = x6; x4 = x7; x4 = x8; x4 = x9;
		x5 = x1; x5 = x2; x5 = x3; x5 = x4; x5 = x6; x5 = x7; x5 = x8; x5 = x9;
		x6 = x1; x6 = x2; x6 = x3; x6 = x4; x6 = x5; x6 = x7; x6 = x8; x6 = x9;
		x7 = x1; x7 = x2; x7 = x3; x7 = x4; x7 = x5; x7 = x6; x7 = x8; x7 = x9;
		x8 = x1; x8 = x2; x8 = x3; x8 = x4; x8 = x5; x8 = x6; x8 = x7; x8 = x9;
		x9 = x1; x9 = x2; x9 = x3; x9 = x4; x9 = x5; x9 = x6; x9 = x7; x9 = x8;
		

	}

}

typedef FourTypeParameters<A,B,C,D> = {
	var a:A;
	var b:B;
	var c:C;
	var d:D;
}