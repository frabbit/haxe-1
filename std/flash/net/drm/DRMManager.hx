package flash.net.drm;

extern class DRMManager extends flash.events.EventDispatcher {
	function new() : Void;
	function authenticate(serverURL : String, domain : String, username : String, password : String) : Void;
	function loadPreviewVoucher(contentData : DRMContentData) : Void;
	function loadVoucher(contentData : DRMContentData, setting : String) : Void;
	function resetDRMVouchers() : Void;
	function returnVoucher(inServerURL : String, immediateCommit : Bool, licenseID : String, policyID : String) : Void;
	function setAuthenticationToken(serverUrl : String, domain : String, token : flash.utils.ByteArray) : Void;
	function storeVoucher(voucher : flash.utils.ByteArray) : Void;
	static var isSupported(default,null) : Bool;
	static var networkIdleTimeout : Float;
	static function getDRMManager() : DRMManager;
}
