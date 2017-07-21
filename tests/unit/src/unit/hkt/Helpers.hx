package unit.hkt;

#if macro
import haxe.macro.Type;
import haxe.macro.Expr;
#end


abstract Lazy<T>(Void->T) {

	function new (f:Void->T) {
		this = f;
	}

	public inline function get ():T return toT();

	@:to inline function toT ():T return this();



	//@:from static inline function fromAny <T>(f:T):Lazy<T> {
	//	return mk(() -> f);
	//}


	/*
	@:from macro static function fromExpr (e:haxe.macro.Expr) {
		var t = haxe.macro.Context.follow(haxe.macro.Context.typeof(e));

		//var expectedType = haxe.macro.Context.getExpectedType();
		//trace(expectedType);
		var ct = haxe.macro.TypeTools.toComplexType(t);
		var ct = TPath({pack : ["unit","hkt"], sub: "Lazy", name: "Helpers", params : [TPType(ct)] });
		trace(ct);
		return macro (unit.hkt.Helpers.Lazy.mk(function () return $e):$ct);
	}
	*/



	public static function mk <T>(f:Void->T):Lazy<T> {
		var v:Null<T> = null;
		var set = false;
		return new Lazy(  () -> {
			if (!set) {
				v = f();
				set = true;
			}
			return (v:T);
		});
	}
}
