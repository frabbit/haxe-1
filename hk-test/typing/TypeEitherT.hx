package typing;

import Log;
import haxe.ds.Either;
import types.EitherT;

class TypeEitherT {

	public static function withExplicit () {
		var a:Array<Either<Int,String>> = null;
		var a:EitherT<Array<_>, Int, String> = EitherT.eitherT(a);

		var a:Either<Int,Either<Bool,String>> = null;
		var a:Array<Either<Int,Either<Bool,String>>> = [a];

		var a:EitherT<Array<_>, Int, Either<Bool,String>> = EitherT.eitherT(a);
		var a:EitherT<EitherT<Array<_>, Int, _>, Bool, String> = EitherT.eitherT(a);
		var a:EitherT<Array<_>, Int, Either<Bool,String>> = EitherT.runT(a);
		var a:Array<Either<Int,Either<Bool,String>>> = EitherT.runT(a);
	}

	public static function withMono () {
		var a:Array<Either<Int,HKMono>> = null;
		var a:EitherT<Array<_>, Int, HKMono> = EitherT.eitherT(a);

		var a:Either<Int, Either<Bool,HKMono>> = null;
		var a:Array<Either<Int, Either<Bool,HKMono>>> = [a];

		var a:EitherT<Array<_>, Int, Either<Bool,HKMono>> = EitherT.eitherT(a);
		var a:EitherT<EitherT<Array<_>, Int, _>, Bool, HKMono> = EitherT.eitherT(a);
		var a:EitherT<Array<_>, Int, Either<Bool,HKMono>> = EitherT.runT(a);
		var a:Array<Either<Int, Either<Bool, HKMono>>> = EitherT.runT(a);

	}
}