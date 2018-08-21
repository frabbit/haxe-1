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


		var c:HKApply<Array<_>, Int> = (null:Array<Int>);
    	var c:HKApply<HKApply<Either<_,_>, Int>, Int> = (null:Either<Int, Int>);

    	var c:HKApply<Either<Int,_>, Int> = (null:Either<Int, Int>);

    	var c:Array<HKApply<Either<_,_>, Int>> = (null:Array<Either<Int, _>>);


		var d:HKApply<HKApply<HKMono, String>, Int> = (null:String->Int);

		var a:Void -> HKApply<Array<_>, Int> = (null:Void->Array<Int>);

		var a:Void->Array<Int> = (null:Void -> HKApply<Array<_>, Int>);


		var a:HKApply<HKApply<Either<_,_>, Int>, String> = (null:Either<Int, String>);

		var a:Void -> HKApply<HKApply<Either<_,_>, Int>, String> = (null:Void->Either<Int, String>);


		var a:HKApply<HKApply<HKApply<CThree<_,_, _>, Int>, String>, Bool> = (null:CThree<Int, String, Bool>);
		var a:HKApply<HKApply<HKApply<AThree<_,_, _>, Int>, String>, Bool> = (null:AThree<Int, String, Bool>);
		var a:HKApply<HKApply<HKApply<EThree<_,_, _>, Int>, String>, Bool> = (null:EThree<Int, String, Bool>);
		var a:HKApply<HKApply<HKApply<_ -> _ -> _, Int>, String>, Bool> = (null:Int->String->Bool);

		// reversed

		var a:CThree<Int, String, Bool> = (null:HKApply<HKApply<HKApply<CThree<_,_, _>, Int>, String>, Bool>);
		var a:AThree<Int, String, Bool> = (null:HKApply<HKApply<HKApply<AThree<_,_, _>, Int>, String>, Bool>);
		var a:EThree<Int, String, Bool> = (null:HKApply<HKApply<HKApply<EThree<_,_, _>, Int>, String>, Bool>);
		var a:Int->String->Bool = (null:HKApply<HKApply<HKApply<_ -> _ -> _, Int>, String>, Bool>);

		// Mono
		var a:HKApply<HKApply<HKApply<HKMono, Int>, String>, Bool> = (null:CThree<Int, String, Bool>);
		var a:HKApply<HKApply<HKApply<HKMono, Int>, String>, Bool> = (null:AThree<Int, String, Bool>);
		var a:HKApply<HKApply<HKApply<HKMono, Int>, String>, Bool> = (null:EThree<Int, String, Bool>);
		var a:HKApply<HKApply<HKApply<HKMono, Int>, String>, Bool> = (null:Int->String->Bool);

		var a:CThree<Int, String, Bool> = (null:HKApply<HKApply<HKApply<HKMono, Int>, String>, Bool>);

		var a:AThree<Int, String, Bool> = (null:HKApply<HKApply<HKApply<HKMono, Int>, String>, Bool>);
		var a:EThree<Int, String, Bool> = (null:HKApply<HKApply<HKApply<HKMono, Int>, String>, Bool>);
		var a:Int->String->Bool = (null:HKApply<HKApply<HKApply<HKMono, Int>, String>, Bool>);

		var a:HKMono = (null:HKApply<HKApply<HKApply<CThree<_,_, _>, Int>, String>, Bool>);
		var a:HKMono = (null:HKApply<HKApply<HKApply<AThree<_,_, _>, Int>, String>, Bool>);
		var a:HKMono = (null:HKApply<HKApply<HKApply<EThree<_,_, _>, Int>, String>, Bool>);
		var a:HKMono = (null:HKApply<HKApply<HKApply<_ -> _ -> _, Int>, String>, Bool>);

		var a:Void->Int = (null:HKApply<Void -> _, Int>);
		var a:HKApply<Void -> _, Int> = (null:Void->Int);

		var a:HKApply<Void -> _, Int> = (null:Void->HKMono);
		var a:Void->Int = (null:HKApply<Void -> _, HKMono>);

		var a:Int->Void = (null:HKApply<_ -> Void, Int>);
		var a:HKApply<_ -> Void, Int> = (null:Int->Void);


		var a:HKApply<HKMono, Int> = (null:HKMono);

		var a:HKMono = (null:HKApply<HKMono, Int>);

		var a:HKApply<_->Void, Int> = (null:HKMono);

		var a:HKMono = (null:HKApply<_->Void, Int>);

		var a:HKApply<_->Void, Int> = (null:HKApply<HKMono, Int>);

		var a:HKApply<HKMono, Int> = (null:HKApply<_->Void, Int>);

		var a:HKApply<_->Void, _> = (null:HKApply<HKMono, _>);

		var a:HKApply<HKMono, _> = (null:HKApply<_->Void, _>);

		var a:HKApply<_->Void, _> = (null:HKMono);

		var a:HKMono = (null:HKApply<_->Void, _>);

		var a:HKApply<HKApply<HKMono, Int>, String> = (null:HKApply<HKMono, String>);

		var a:HKMono = (null:HKApply<HKMono, Int>);

		var a:HKApply<HKApply<_ -> _ -> Void, Int>, String> = (null:HKApply<HKApply<HKMono, Int>, String>);

		var a:Array<Array<Int>> = (null:HKApply<Array<_>, HKApply<Array<_>, Int>>);

		var a:Array<Array<Array<Int>>> = (null:HKApply<Array<_>, HKApply<Array<_>, HKApply<Array<_>, Int>>>);

		var a:Array<Array<Array<Array<Int>>>> = (null:HKApply<Array<_>, HKApply<Array<_>, HKApply<Array<_>, HKApply<Array<_>, Int>>>>);

		var a:Array<Array<Array<Array<Array<Array<Int>>>>>> = (null:HKApply<Array<_>, HKApply<Array<_>, HKApply<Array<_>, HKApply<Array<_>, HKApply<Array<_>, HKApply<Array<_>, Int>>>>>>);

		var a:Array<Array<_>> = (null:HKApply<Array<_>, HKMono>);

		var a:HKApply<Array<_>, HKMono> = (null:Array<Array<_>>);

		var a:Int->(Int -> _) = (null:HKApply<Int -> _, HKMono>);
		var a:HKApply<Int -> _, HKMono> = (null:Int->(Int -> _));

		//var a:(Int -> Void)->Void = (null:HKApply<_ -> Void, HKMono>);
		var a:HKApply<_ -> Void, HKMono> = (null:(Int -> Void)->Void);

		//var a:(Int -> Void)->Void = (null:HKApply<HKMono, _ -> Void>);

		//var a:HKApply<HKMono, Int -> Void> = (null:(Int -> Void)->Void);

		var a:HKApply<Array<_>, String> = (null:HKApply<Array<_>, String>);

	}

	static function typeParameters <TP1, TP2, TP3> () {
		var a:TP1<Int> = (null:HKApply<TP1, Int>);

	}

	static function foo <TP1:TP1<_>>(a:TP1, b:TP1) {

	}

	static function typeParameters1  () {
		function foo <A,T>(a:A<T>) {

		}
		foo([1]);
	}


	static function typeParameters3  () {
		function foo <A,B,T>(a:A<B<T>>) {

		}
		foo([[1]]);
	}
	static function typeParameters4  () {
		function foo <A,B,C,T>(a:A<B<C<T>>>) {

		}

		foo([[[1]]]);

	}

	static function typeParameters5  () {
		function foo <A,B,C,D,T>(a:A<B<C<D<T>>>>) {

		}
		foo([[[[1]]]]);
	}

	static function typeParameters6  () {
		function foo <A,B,C,D,E,T>(a:A<B<C<D<E<T>>>>>) {

		}
		foo([[[[[1]]]]]);
	}


	static function typeParameters7  () {
		function foo <A,B,C,D,E,F,T>(a:A<B<C<D<E<F<T>>>>>>) {

		}
		Log.enable(true);
		foo([[[[[[1]]]]]]);

	}

	static function typeParameters10  () {
		function foo <A,B,C,D,E,F,G,H,I,J>(a:A<B<C<D<E<F<G<H<I<J>>>>>>>>>) {

		}
		Log.enable(true);
		foo([[[[[[[[[1]]]]]]]]]);

	}





	static function typeParameters2  () {
		function foo <T>(a:HKApply<T, Int>, a:HKApply<T, Int>) {
		}

		foo( (null:Array<Int>), (null:Array<Int>) );

		foo( (null:HKMono<Int>), (null:Array<Int>) );

		foo( (null:Array<Int>), (null:HKMono<Int>) );

		foo( (null:HKMono<Int>), (null:HKMono<Int>) );

		foo( (null:HKMono<HKMono>), (null:HKMono<Int>) );

		foo.bind( (null:Array<Int>));
		foo.bind( (null:HKMono<Int>));

	}

}

typedef Of4<M,A,B,C,D> = M<A,B,C,D>;