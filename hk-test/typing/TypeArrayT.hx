package typing;

import types.ArrayT;
import haxe.ds.Either;
import Log;

class TypeArrayT {

	public static function withExplicit () {

        var a:Either<String, Array<Int>>  = null;

        var a:ArrayT<Either<String, _>, Int> = ArrayT.arrayT(a);
        var a:Either<String, Array<Int>> = ArrayT.runT(a);

        var a:Either<String, Array<Array<Int>>>  = null;

        var a:ArrayT<Either<String, _>, Array<Int>> = ArrayT.arrayT(a);
        var a:ArrayT<ArrayT<Either<String, _>, _>, Int> = ArrayT.arrayT(a);
        var a:ArrayT<Either<String, _>, Array<Int>> = ArrayT.runT(a);
        var a:Either<String, Array<Array<Int>>> = ArrayT.runT(a);

	}

    public static function withMono () {
        var a:Either<HKMono, Array<Int>>  = null;
        var a:ArrayT<Either<HKMono, _>, Int> = ArrayT.arrayT(a);
        var a:Either<HKMono, Array<Int>> = ArrayT.runT(a);

        var a:Either<HKMono, Array<Array<Int>>>  = null;

        var a:ArrayT<Either<HKMono, _>, Array<Int>> = ArrayT.arrayT(a);
        var a:ArrayT<ArrayT<Either<HKMono, _>, _>, Int> = ArrayT.arrayT(a);
        var a:ArrayT<Either<HKMono, _>, Array<Int>> = ArrayT.runT(a);
        var a:Either<HKMono, Array<Array<Int>>> = ArrayT.runT(a);
    }
}

