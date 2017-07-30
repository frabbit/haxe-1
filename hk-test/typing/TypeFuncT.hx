package typing;

import Log;
import types.FuncT;

class TypeFuncT {

	public static function withExplicit () {
		var a:Array<Int->String> = null;
		var a:FuncT<Array<_>, Int, String> = FuncT.funcT(a);

		var a:Int->(Bool->String) = null;
		var a:Array<Int->(Bool->String)> = [a];

		var a:FuncT<Array<_>, Int, Bool->String> = FuncT.funcT(a);
		var a:FuncT<FuncT<Array<_>, Int, _>, Bool, String> = FuncT.funcT(a);
		var a:FuncT<Array<_>, Int, Bool->String> = FuncT.runT(a);
		var a:Array<Int->(Bool->String)> = FuncT.runT(a);

	}

	public static function withMono () {
		var a:Array<Int->HKMono> = null;
		var a:FuncT<Array<_>, Int, HKMono> = FuncT.funcT(a);

		var a:Int->(Bool->HKMono) = null;
		var a:Array<Int->(Bool->HKMono)> = [a];

		var a:FuncT<Array<_>, Int, Bool->HKMono> = FuncT.funcT(a);
		var a:FuncT<FuncT<Array<_>, Int, _>, Bool, HKMono> = FuncT.funcT(a);
		var a:FuncT<Array<_>, Int, Bool->HKMono> = FuncT.runT(a);
		var a:Array<Int->(Bool->HKMono)> = FuncT.runT(a);

	}
}

