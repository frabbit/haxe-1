package typing;

import haxe.ds.Either;
import Log;

using types.ArrayT;

class TypeArrayTUsing {

	public static function main () {

    var a = Right([1]);

    var a:ArrayT<Either<String, _>, Int> = a.arrayT();
    var a:Either<String, Array<Array<Int>>> = a.runT();

    var a = Right([[1]]);

    var a:ArrayT<Either<String, _>, Array<Int>> = a.arrayT();
    var a:ArrayT<ArrayT<Either<String, _>, _>, Int> = a.arrayT();
    var a:ArrayT<Either<String, _>, Array<Int>> = a.runT();
    var a:Either<String, Array<Array<Int>>> = a.runT();

	}
}

