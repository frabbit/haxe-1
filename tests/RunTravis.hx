import sys.*;
import sys.io.*;

/**
	Will be run by TravisCI.
	See ".travis.yml" at project root for TravisCI settings.
*/
class RunTravis {
	/**
		Run a command using `Sys.command()`.
		If the command exits with non-zero code, exit the whole script with the same code.

		If `useRetry` is `true`, the command will be re-run if it exits with non-zero code (3 trials).
		It is useful for running network-dependent commands.
	*/
	static function runCommand(cmd:String, args:Array<String>, useRetry:Bool = false):Void {
		var trials = useRetry ? 3 : 1;
		var exitCode:Int = 1;

		while (trials-->0) {
			Sys.println('Command: $cmd $args');
			exitCode = Sys.command(cmd, args);
			Sys.println('Command exited with $exitCode: $cmd $args');

			if (exitCode == 0) {
				return;
			} else if (trials > 0) {
				Sys.println('Command will be re-run...');
			}
		}

		Sys.exit(exitCode);
	}

	static function setupFlashPlayerDebugger():Void {
		Sys.putEnv("DISPLAY", ":99.0");
		runCommand("sh", ["-e", "/etc/init.d/xvfb", "start"]);
		Sys.putEnv("AUDIODEV", "null");
		runCommand("sudo", ["apt-get", "install", "-qq", "libgd2-xpm", "ia32-libs", "ia32-libs-multiarch", "-y"], true);
		runCommand("wget", ["-nv", "http://fpdownload.macromedia.com/pub/flashplayer/updaters/11/flashplayer_11_sa_debug.i386.tar.gz"], true);
		runCommand("tar", ["-xf", "flashplayer_11_sa_debug.i386.tar.gz", "-C", Sys.getEnv("HOME")]);
		File.saveContent(Sys.getEnv("HOME") + "/mm.cfg", "ErrorReportingEnable=1\nTraceOutputFileEnable=1");
		runCommand(Sys.getEnv("HOME") + "/flashplayerdebugger", ["-v"]);
	}

	static function runFlash(swf:String):Void {
		Sys.command(Sys.getEnv("HOME") + "/flashplayerdebugger", [swf, "&"]);

		//wait a little until flashlog.txt is created
		var flashlogPath = Sys.getEnv("HOME") + "/.macromedia/Flash_Player/Logs/flashlog.txt";
		for (t in 0...5) {
			runCommand("sleep", ["2"]);
			if (FileSystem.exists(flashlogPath))
				break;
		}
		if (!FileSystem.exists(flashlogPath)) {
			Sys.println('$flashlogPath not found.');
			Sys.exit(1);
		}

		//read flashlog.txt continously
		var traceProcess = new Process("tail", ["-f", "-v", flashlogPath]);
		var line = "";
		while (true) {
			try {
				line = traceProcess.stdout.readLine();
				Sys.println(line);
				if (line.indexOf("SUCCESS: ") >= 0) {
					Sys.exit(line.indexOf("SUCCESS: true") >= 0 ? 0 : 1);
				}
			} catch (e:haxe.io.Eof) {}
		}
		Sys.exit(1);
	}

	static function main():Void {
		var cwd = Sys.getCwd();
		var unitDir = cwd + "unit/";
		var optDir = cwd + "optimization/";

		Sys.setCwd(unitDir);
		switch (Sys.getEnv("TARGET")) {
			case "macro", null:
				runCommand("haxe", ["compile-macro.hxml"]);


				//generate documentation
				runCommand("haxelib", ["git", "hxparse", "https://github.com/Simn/hxparse", "development", "src"], true);
				runCommand("haxelib", ["git", "hxtemplo", "https://github.com/Simn/hxtemplo", "master", "src"], true);
				runCommand("haxelib", ["git", "hxargs", "https://github.com/Simn/hxargs.git"], true);
				runCommand("haxelib", ["git", "markdown", "https://github.com/dpeek/haxe-markdown.git", "master", "src"], true);

				runCommand("haxelib", ["git", "hxcpp", "https://github.com/HaxeFoundation/hxcpp.git"], true);
				runCommand("haxelib", ["git", "hxjava", "https://github.com/HaxeFoundation/hxjava.git"], true);
				runCommand("haxelib", ["git", "hxcs", "https://github.com/HaxeFoundation/hxcs.git"], true);

				runCommand("haxelib", ["git", "dox", "https://github.com/dpeek/dox.git"], true);
				Sys.setCwd(Sys.getEnv("HOME") + "/haxelib/dox/git/");
				runCommand("haxe", ["run.hxml"]);
				runCommand("haxe", ["gen.hxml"]);
				runCommand("haxelib", ["run", "dox", "-o", "bin/api.zip", "-i", "bin/xml"]);
			case "neko":
				runCommand("haxe", ["compile-neko.hxml"]);
				runCommand("neko", ["unit.n"]);
			case "php":
				runCommand("sudo", ["apt-get", "install", "php5", "-y"], true);
				runCommand("haxe", ["compile-php.hxml"]);
				runCommand("php", ["php/index.php"]);
			case "cpp":
				//hxcpp dependencies
				runCommand("sudo", ["apt-get", "install", "gcc-multilib", "g++-multilib", "-y"], true);

				//install and build hxcpp
				runCommand("haxelib", ["git", "hxcpp", "https://github.com/HaxeFoundation/hxcpp.git"], true);
				Sys.setCwd(Sys.getEnv("HOME") + "/haxelib/hxcpp/git/project/");
				runCommand("neko", ["build.n"]);
				Sys.setCwd(unitDir);

				runCommand("haxe", ["compile-cpp.hxml"]);
				runCommand("./cpp/Test-debug", []);

				runCommand("rm", ["-rf", "cpp"]);

				runCommand("haxe", ["compile-cpp.hxml", "-D", "HXCPP_M64"]);
				runCommand("./cpp/Test-debug", []);
			case "js":
				runCommand("haxe", ["compile-js.hxml"]);
				runCommand("node", ["-e", "var unit = require('./unit.js').unit; unit.Test.main(); process.exit(unit.Test.success ? 0 : 1);"]);

				if (Sys.getEnv("TRAVIS_SECURE_ENV_VARS") == "true") {
					//https://saucelabs.com/opensource/travis
					runCommand("npm", ["install", "wd"], true);
					runCommand("curl", ["https://gist.github.com/santiycr/5139565/raw/sauce_connect_setup.sh", "-L", "|", "bash"], true);
					runCommand("haxelib", ["git", "nodejs", "https://github.com/dionjwa/nodejs-std.git", "master", "src"], true);
					runCommand("haxe", ["compile-saucelabs-runner.hxml"]);
					runCommand("nekotools", ["server", "&"]);
					runCommand("node", ["RunSauceLabs.js"]);
				}

				Sys.println("Test optimization:");
				Sys.setCwd(optDir);
				runCommand("haxe", ["run.hxml"]);
			case "java":
				runCommand("haxelib", ["git", "hxjava", "https://github.com/HaxeFoundation/hxjava.git"], true);
				runCommand("haxe", ["compile-java.hxml"]);
				runCommand("java", ["-jar", "java/Test-Debug.jar"]);
			case "cs":
				runCommand("sudo", ["apt-get", "install", "mono-devel", "mono-mcs", "-y"], true);
				runCommand("haxelib", ["git", "hxcs", "https://github.com/HaxeFoundation/hxcs.git"], true);

				runCommand("haxe", ["compile-cs.hxml"]);
				runCommand("mono", ["cs/bin/Test-Debug.exe"]);

				runCommand("haxe", ["compile-cs-unsafe.hxml"]);
				runCommand("mono", ["cs_unsafe/bin/Test-Debug.exe"]);
			case "flash9":
				setupFlashPlayerDebugger();
				runCommand("haxe", ["compile-flash9.hxml", "-D", "fdb"]);
				runFlash("unit9.swf");
			case "flash8":
				setupFlashPlayerDebugger();
				runCommand("haxe", ["compile-flash8.hxml", "-D", "fdb"]);
				runFlash("unit8.swf");
			case "as3":
				setupFlashPlayerDebugger();

				//setup flex sdk
				runCommand("wget", ["http://mirror.cc.columbia.edu/pub/software/apache/flex/4.12.0/binaries/apache-flex-sdk-4.12.0-bin.tar.gz"], true);
				runCommand("tar", ["-xf", "apache-flex-sdk-4.12.0-bin.tar.gz", "-C", Sys.getEnv("HOME")]);
				var flexsdkPath = Sys.getEnv("HOME") + "/apache-flex-sdk-4.12.0-bin";
				Sys.putEnv("PATH", Sys.getEnv("PATH") + ":" + flexsdkPath + "/bin");
				var playerglobalswcFolder = flexsdkPath + "/player";
				FileSystem.createDirectory(playerglobalswcFolder + "/11.1");
				runCommand("wget", ["-nv", "http://download.macromedia.com/get/flashplayer/updaters/11/playerglobal11_1.swc", "-O", playerglobalswcFolder + "/11.1/playerglobal.swc"], true);
				File.saveContent(flexsdkPath + "/env.properties", 'env.PLAYERGLOBAL_HOME=$playerglobalswcFolder');
				runCommand("mxmlc", ["--version"]);

				runCommand("haxe", ["compile-as3.hxml", "-D", "fdb"]);
				runFlash("unit9_as3.swf");
			case target:
				throw "unknown target: " + target;
		}
	}
}
