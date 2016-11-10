test-neko:
	cd ../tests/unit && haxe-bytes-refactoring compile-neko.hxml
	cd ../tests/unit && neko bin/unit.n

test-js:
	cd ../tests/unit && haxe-bytes-refactoring compile-js.hxml 
	cd ../tests/unit && node bin/unit.js 

test-python:
	cd ../tests/unit && haxe-bytes-refactoring compile-python.hxml
	cd ../tests/unit && python3 bin/unit.py 

test-java:
	cd ../tests/unit && haxe-bytes-refactoring compile-java.hxml
	cd ../tests/unit && java -jar bin/java/TestMain-Debug.jar

test-cs:
	cd ../tests/unit && haxe-bytes-refactoring compile-cs.hxml
	cd ../tests/unit && bin/cs/bin/TestMain-Debug.exe 

test-cpp:
	cd ../tests/unit && haxe-bytes-refactoring compile-cpp.hxml
	cd ../tests/unit && bin/cpp/TestMain-debug 

test-lua:
	cd ../tests/unit && haxe-bytes-refactoring compile-lua.hxml
	cd ../tests/unit && lua bin/unit.lua 

test-swf:
	cd ../tests/unit && haxe-bytes-refactoring compile-flash9.hxml
	cd ../tests/unit && flashplayerdebugger bin/unit9.swf 

test-php:
	cd ../tests/unit && haxe-bytes-refactoring compile-php.hxml
	cd ../tests/unit && php bin/php/index.php 

test-hl:
	cd ../tests/unit && haxe-bytes-refactoring compile-hl.hxml
	cd ../tests/unit && hl bin/unit.hl 

check-cpp:
	haxe-bytes-refactoring -main Check -cpp bin/cpp -debug -dce no
	bin/cpp/Check-debug

check-neko:
	haxe-bytes-refactoring -main Check -neko bin/check.n -debug -dce no
	neko bin/check.n

check-java:
	haxe-bytes-refactoring -main Check -java bin/java -debug -dce no
	java -jar bin/java/Check-Debug.jar

check-cs:
	haxe-bytes-refactoring -main Check -cs bin/cs -debug -dce no
	bin/cs/bin/Check-Debug.exe

check-lua:
	haxe-bytes-refactoring -main Check -lua bin/check.lua
	luajit bin/check.lua

check-python:
	haxe-bytes-refactoring -main Check -python bin/check.py -debug  -dce no
	python3 bin/check.py

check-php:
	haxe-bytes-refactoring -main Check -php bin/php -debug -dce no
	php bin/php/index.php

check-js:
	haxe-bytes-refactoring -main Check -js bin/check.js -debug -D nodejs -dce no
	node bin/check.js

check-swf:
	haxe-bytes-refactoring -main Check -swf bin/check.swf -debug -dce no
	flashplayerdebugger bin/check.swf

check-hl:
	haxe-bytes-refactoring -main Check -hl bin/check.hl -debug -dce no
	hl bin/check.hl