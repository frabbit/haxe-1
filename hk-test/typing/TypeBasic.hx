package typing;
import Log;
import haxe.ds.Either;
import haxe.ds.Option;
import types.Tup2;

private class CThree<A,B,C> {}
private abstract AThree<A,B,C>(CThree<A,B,C>) {}
enum EThree<A,B,C> {}

class TypeBasic {
	static function main () {

		var c:HKOf<Array<_>, Int> = (null:Array<Int>);
    	var c:HKOf<HKOf<Either<_,_>, Int>, Int> = (null:Either<Int, Int>);

    	var c:HKOf<Either<Int,_>, Int> = (null:Either<Int, Int>);

    	var c:Array<HKOf<Either<_,_>, Int>> = (null:Array<Either<Int, _>>);


		var d:HKOf<HKOf<HKMono, Int>, String> = (null:Int->String);

		var a:Void -> HKOf<Array<_>, Int> = (null:Void->Array<Int>);

		var a:Void->Array<Int> = (null:Void -> HKOf<Array<_>, Int>);


		var a:HKOf<HKOf<Either<_,_>, Int>, String> = (null:Either<Int, String>);

		var a:Void -> HKOf<HKOf<Either<_,_>, Int>, String> = (null:Void->Either<Int, String>);


		var a:HKOf<HKOf<HKOf<CThree<_,_, _>, Int>, String>, Bool> = (null:CThree<Int, String, Bool>);
		var a:HKOf<HKOf<HKOf<AThree<_,_, _>, Int>, String>, Bool> = (null:AThree<Int, String, Bool>);
		var a:HKOf<HKOf<HKOf<EThree<_,_, _>, Int>, String>, Bool> = (null:EThree<Int, String, Bool>);
		var a:HKOf<HKOf<HKOf<_ -> _ -> _, Int>, String>, Bool> = (null:Int->String->Bool);

		// reversed

		var a:CThree<Int, String, Bool> = (null:HKOf<HKOf<HKOf<CThree<_,_, _>, Int>, String>, Bool>);
		var a:AThree<Int, String, Bool> = (null:HKOf<HKOf<HKOf<AThree<_,_, _>, Int>, String>, Bool>);
		var a:EThree<Int, String, Bool> = (null:HKOf<HKOf<HKOf<EThree<_,_, _>, Int>, String>, Bool>);
		var a:Int->String->Bool = (null:HKOf<HKOf<HKOf<_ -> _ -> _, Int>, String>, Bool>);

		// Mono
		var a:HKOf<HKOf<HKOf<HKMono, Int>, String>, Bool> = (null:CThree<Int, String, Bool>);
		var a:HKOf<HKOf<HKOf<HKMono, Int>, String>, Bool> = (null:AThree<Int, String, Bool>);
		var a:HKOf<HKOf<HKOf<HKMono, Int>, String>, Bool> = (null:EThree<Int, String, Bool>);
		var a:HKOf<HKOf<HKOf<HKMono, Int>, String>, Bool> = (null:Int->String->Bool);

		var a:CThree<Int, String, Bool> = (null:HKOf<HKOf<HKOf<HKMono, Int>, String>, Bool>);

		var a:AThree<Int, String, Bool> = (null:HKOf<HKOf<HKOf<HKMono, Int>, String>, Bool>);
		var a:EThree<Int, String, Bool> = (null:HKOf<HKOf<HKOf<HKMono, Int>, String>, Bool>);
		var a:Int->String->Bool = (null:HKOf<HKOf<HKOf<HKMono, Int>, String>, Bool>);

		var a:HKMono = (null:HKOf<HKOf<HKOf<CThree<_,_, _>, Int>, String>, Bool>);
		var a:HKMono = (null:HKOf<HKOf<HKOf<AThree<_,_, _>, Int>, String>, Bool>);
		var a:HKMono = (null:HKOf<HKOf<HKOf<EThree<_,_, _>, Int>, String>, Bool>);
		var a:HKMono = (null:HKOf<HKOf<HKOf<_ -> _ -> _, Int>, String>, Bool>);

		var a:Void->Int = (null:HKOf<Void -> _, Int>);
		var a:HKOf<Void -> _, Int> = (null:Void->Int);

		var a:HKOf<Void -> _, Int> = (null:Void->HKMono);
		var a:Void->Int = (null:HKOf<Void -> _, HKMono>);

		var a:Int->Void = (null:HKOf<_ -> Void, Int>);
		var a:HKOf<_ -> Void, Int> = (null:Int->Void);

		//var z:HKOf<Int, Int, Int>;

		var a:HKOf<HKMono, Int> = (null:HKMono);

		var a:HKMono = (null:HKOf<HKMono, Int>);

		var a:HKOf<_->Void, Int> = (null:HKMono);

		var a:HKMono = (null:HKOf<_->Void, Int>);

		var a:HKOf<_->Void, Int> = (null:HKOf<HKMono, Int>);

		var a:HKOf<HKMono, Int> = (null:HKOf<_->Void, Int>);

		var a:HKOf<_->Void, _> = (null:HKOf<HKMono, _>);

		var a:HKOf<HKMono, _> = (null:HKOf<_->Void, _>);


		var a:HKOf<_->Void, _> = (null:HKMono);

		var a:HKMono = (null:HKOf<_->Void, _>);


		var a:HKOf<HKOf<HKMono, Int>, String> = (null:HKOf<HKMono, String>);

		var a:HKMono = (null:HKOf<HKMono, Int>);

		var a:HKOf<HKOf<_ -> _ -> Void, Int>, String> = (null:HKOf<HKOf<HKMono, Int>, String>);


		var a:Array<Array<Int>> = (null:HKOf<HKOf<HKMono, HKMono>, Int>);
		var a:Array<Array<Array<Int>>> = (null:HKOf<HKOf<HKOf<HKMono, HKMono>, HKMono>, Int>);


		var a:Array<Array<Array<Array<Int>>>> = (null:HKOf<HKOf<HKOf<HKOf<HKMono, HKMono>, HKMono>, HKMono>, Int>);

		var a:Array<Array<Array<Array<Array<Array<Int>>>>>> = (null:HKOf<HKOf<HKOf<HKOf<HKOf<HKOf<HKMono, HKMono>, HKMono>, HKMono>,HKMono>, HKMono>, Int>);

		var a:Array<Array<_>> = (null:HKOf<Array<_>, HKMono>);

		var a:HKOf<Array<_>, HKMono> = (null:Array<Array<_>>);

		var a:Int->(Int -> _) = (null:HKOf<Int -> _, HKMono>);
		var a:HKOf<Int -> _, HKMono> = (null:Int->(Int -> _));

		//var a:(Int -> Void)->Void = (null:HKOf<_ -> Void, HKMono>);
		var a:HKOf<_ -> Void, HKMono> = (null:(Int -> Void)->Void);

		//var a:(Int -> Void)->Void = (null:HKOf<HKMono, _ -> Void>);

		var a:HKOf<HKMono, Int -> Void> = (null:(Int -> Void)->Void);

		//var a:HKOf<HKOf<Array<_>, Int>, String> = (null:HKOf<Array<_>, Int>);

		var a:HKMono = (null:HKOf<HKOf<HKOf<HKMono, Int>, String>, Bool>);



		Log.enable(true);
		Log.enable(false);

	}

	static function typeParameters <TP1, TP2, TP3> () {
		var a:TP1<Int> = (null:HKOf<TP1, Int>);

	}

	static function foo <TP1:TP1<_>>(a:TP1, b:TP1) {

	}

	static function typeParameters1  () {
		function foo <A,T>(a:A<T>) {

		}
		//Log.enable(true);
		foo([1]);
		//Log.enable(false);
	}


	static function typeParameters3  () {
		function foo <A,B,T>(a:A<B<T>>) {

		}
		//Log.enable(true);
		foo([[1]]);
		//Log.enable(false);
	}
	static function typeParameters4  () {
		function foo <A,B,C,T>(a:A<B<C<T>>>) {

		}

		foo([[[1]]]);

	}

	static function typeParameters5  () {
		function foo <A,B,C,D,T>(a:A<B<C<D<T>>>>) {

		}
		//Log.enable(true);
		foo([[[[1]]]]);
		//Log.enable(false);
	}

	static function typeParameters6  () {
		function foo <A,B,C,D,E,T>(a:A<B<C<D<E<T>>>>>) {

		}
		//Log.enable(true);
		foo([[[[[1]]]]]);
		//Log.enable(false);
	}
/*

	static function typeParameters7  () {
		function foo <A,B,C,D,E,F,T>(a:A<B<C<D<E<F<T>>>>>>) {

		}
		Log.enable(true);
		foo([[[[[[1]]]]]]);

	}

	*/


	/*
	static function typeParameters2  () {
		function foo <T>(a:HKOf<T, Int>, a:HKOf<T, Int>) {

		}

		foo( (null:Array<Int>), (null:Array<Int>) );

		foo( (null:HKMono<Int>), (null:Array<Int>) );

		foo( (null:Array<Int>), (null:HKMono<Int>) );

		foo( (null:HKMono<Int>), (null:HKMono<Int>) );

		foo( (null:HKMono<HKMono>), (null:HKMono<Int>) );

		$type(foo);
		$type( foo.bind( (null:Array<Int>)));
		$type( foo.bind( (null:HKMono<Int>)));

		//var a:TP2 = (null:HKOf<HKMono, Int>);
		//var a:TP1 = (null:HKOf<Array<_>, Int>);
		//var a:TP1 = (null:HKOf<Option<_>, Int>);

		//var a:TP1 = [1];

	}
	*/
}

typedef Of4<M,A,B,C,D> = M<A,B,C,D>;