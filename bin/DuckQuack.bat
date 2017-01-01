@ECHO OFF
set BASEPATH=%~dp0
set GEM_HOME=lib/gems
set GEM_PATH=lib/gems
cd %BASEPATH%
cd ..
java -Dfile.encoding=UTF8 -jar %BASEPATH%/jruby-complete.jar -S ../config/boot.rb %1 %2 %3 %4 %5 %6 %7 %8 
