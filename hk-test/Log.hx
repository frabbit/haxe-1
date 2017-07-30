
class Log {
	#if macro
	static var enableLog:Bool->Void = @:privateAccess haxe.macro.Context.load("enable_type_log", 1);
	#end

	#if macro
	public static function enable (b:Bool) {
		enableLog(b);
		return macro null;
	}
	#else
	macro public static function enable (b:Bool) {
		enableLog(true);
		return macro null;
	}
	#end

}
