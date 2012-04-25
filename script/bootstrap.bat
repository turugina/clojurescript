@echo off

rem set PREFERRED_DOWNLOADER[_OPTS] below if you have one that
rem    %PREFERRED_DOWNLOADER% %PREFERRED_DOWNLOADER_OPTS% http://example.com/foo/bar.zip
rem will download http://example.vom/foo/bar.zip and save it into bar.zip
rem
rem or this script will automatically detect if wget.exe or curl.exe is in your PATH.

set PREFERRED_DOWNLOADER=wget
set PREFERRED_DOWNLOADER_OPTS=



goto reqcheck
:reqcheck_done

set CLOJURE_VERSION=1.3.0

if exist lib goto mkdir_lib_done
mkdir lib
if ERRORLEVEL 1 goto mkdir_lib_error
goto mkdir_lib_done
:mkdir_lib_error
echo Failed to create lib dir
exit 1
:mkdir_lib_done


if "%PREFERRED_DOWNLOADER%" == "" (
goto detect_downloader
) else (
goto set_preferred_downloader
)

:download_clojure
echo "Fetching Clojure..."
echo %DOWNLOADER%
echo %DOWNLOADER_OPTS%
%DOWNLOADER% %DOWNLOADER_OPTS% http://repo1.maven.org/maven2/org/clojure/clojure/%CLOJURE_VERSION%/clojure-%CLOJURE_VERSION%.zip
if not exist clojure-%CLOJURE_VERSION%.zip (
echo Failed to get clojure-%CLOJURE_VERSION%.zip
exit 2
)
jar -xf clojure-%CLOJURE_VERSION%.zip
echo "Copying clojure-%CLOJURE_VERSION%/clojure-%CLOJURE_VERSION%.jar to lib/clojure.jar..."
copy clojure-%CLOJURE_VERSION%\clojure-%CLOJURE_VERSION%.jar lib\clojure.jar
echo "Cleaning up Clojure directory..."
rmdir /s /q clojure-%CLOJURE_VERSION%
echo "Cleaning up Clojure archive..."
del clojure-%CLOJURE_VERSION%.zip

rem for now, we've got a power of Clojure :)

rem TODO: move to bootstrap.clj
echo "Fetching Google Closure library..."
mkdir closure\library
cd closure\library
%DOWNLOADER% %DOWNLOADER_OPTS% http://closure-library.googlecode.com/files/closure-library-20110323-r790.zip
jar -xf closure-library-20110323-r790.zip
echo "Cleaning up Google Closure library archive..."
del closure-library-20110323-r790.zip
cd ..

echo "Fetching Google Closure compiler..."
mkdir compiler
cd compiler
%DOWNLOADER% %DOWNLOADER_OPTS% http://closure-compiler.googlecode.com/files/compiler-latest.zip
jar -xf compiler-latest.zip
echo "Cleaning up Google Closure compiler archive..."
del compiler-latest.zip
cd ..\..
echo "Building lib/goog.jar..."
echo "jar cf ./lib/goog.jar -C closure/library/closure/ goog"
jar cf .\lib\goog.jar -C closure\library\closure goog

echo "Fetching Rhino..."
%DOWNLOADER% %DOWNLOADER_OPTS% http://ftp.mozilla.org/pub/mozilla.org/js/rhino1_7R3.zip
jar -xf rhino1_7R3.zip
echo "Copying rhino1_7R3/js.jar to lib/js.jar..."
copy rhino1_7R3\js.jar lib\js.jar
echo "Cleaning up Rhino directory..."
rmdir /s /q rhino1_7R3
echo "Cleaning up Rhino archive..."
del rhino1_7R3.zip

echo "Copying closure/compiler/compiler.jar to lib/compiler.jar"
copy closure\compiler\compiler.jar lib

echo "[Bootstrap Completed]"

:detect_downloader
:detect_wget
echo Checking if you have wget...
wget.exe --version > NUL 2>&1
if ERRORLEVEL 1 goto detect_curl
set DOWNLOADER=wget.exe
set DOWNLOADER_OPTS=-q
goto download_clojure

:detect_curl
echo Checking if you have curl...
curl.exe --version > NUL 2>&1
if ERRORLEVEL 1 goto compile_downloader
set DOWNLOADER=curl.exe
set DOWNLOADER_OPTS=-O -s
goto download_clojure

:compile_downloader
javac --version > NUL 2>&1
if ERRORLEVEL 1 goto no_javac
cd script\src
javac downloader.java
cd ..\..
set PROXY_PROPERTIES=
rem set proxy properties if needed
rem PROXY_PROPERTIES=-Dhttp.proxyHost=proxy.example.com -Dhttp.proxyPort=8080
set DOWNLOADER=java %PROXY_PROPERTIES% -cp %~dp0\script\src downloader
set DOWNLOADER_OPTS=
goto download_clojure

:no_javac
echo no download command nor java compiler be found.
exit 1

:set_preferred_downloader
set DOWNLOADER=%PREFERRED_DOWNLOADER%
set DOWNLOADER_OPTS=%PREFERRED_DOWNLOADER_OPTS%
goto download_clojure

:reqcheck
java -version > NUL 2>&1
if ERRORLEVEL 1 goto no_java
goto ok_java
:no_java
echo no 'java' command in your PATH.
exit 1
:ok_java

jar > NUL 2>&1
if ERRORLEVEL 2 goto no_jar
goto ok_jar
:no_jar
echo no 'jar' command in your PATH.
exit 1
:ok_jar

goto reqcheck_done
