package unit;
import haxe.ds.Option;
import unit.hkt.MyTypeConstructor2;
import unit.hkt.Helpers.Lazy;
class TestTypeConstructor2 extends Test {
	public function test()
	{
		var optionAp = new OptionAsApplicative();
		var optionOptionAp = Applicatives.compose(optionAp, optionAp);
		var lazy1 = Lazy.mk(function () return 1);
		var opt = optionOptionAp.pure( Lazy.mk(() -> 1));
		var opt2 = optionAp.pure(Lazy.mk(() -> 1));
		$type(opt);
		t(opt.match(Some(Some(1))));
		//var isEq = (:Option<Option<Int>>).match(Some(Some(1)));
		//t(false);
	}
}