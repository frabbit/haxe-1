
#if macro
import haxe.macro.Context;
import haxe.macro.Type;
import haxe.macro.Expr;
import haxe.macro.TypeTools;
#end

class Macros {

	#if macro


	static var reduceOf:Type->Type = @:privateAccess Context.load("reduce_of", 1);
	static var normalizeOf:Type->Type = @:privateAccess Context.load("normalize_of", 1);

	#end

}
