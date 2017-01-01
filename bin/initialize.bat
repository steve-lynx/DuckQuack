@ECHO OFF
set BASEPATH=%~dp0
set GEM_HOME=lib/gems
set GEM_PATH=lib/gems

cd %BASEPATH%
cd ..

ECHO "=========================================================================="
ECHO Preparing bundler in %CD%\\%GEM_PATH%
ECHO "=========================================================================="

java -jar %BASEPATH%jruby-complete.jar -S gem install -i %GEM_HOME% --no-rdoc --no-ri bundler

ECHO done...
