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
		t(optionOptionAp.map2(Some(Some(1)), Some(Some(1)), (a,b) -> a+b).match(Some(Some(2))));
		//var isEq = (:Option<Option<Int>>).match(Some(Some(1)));
		//t(false);
	}
}