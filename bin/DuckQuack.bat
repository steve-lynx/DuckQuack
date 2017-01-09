@ECHO OFF
set BASEPATH=%~dp0
cd %BASEPATH%
cd ..
java -Dfile.encoding=UTF8 -jar %BASEPATH%/jruby-complete.jar -S ../app/duck_quack.rb %1 %2 %3 %4 %5 %6 %7 %8 
