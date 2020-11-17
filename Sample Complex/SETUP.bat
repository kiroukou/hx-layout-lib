@echo off

SET NEKO_VER=neko-2.3.0-win


set CWD=%~dp0
SET CWD=%CWD:~0,-1%
SET HAXE_OUTPUT=%CWD%\.haxe
SET HASHLINK_OUTPUT=%CWD%\.hashlink
SET HAXELIB_OUTPUT=%CWD%\.haxelib

ECHO ### CHECKS..
if exist "%HAXE_OUTPUT%" rd /q /s "%HAXE_OUTPUT%"
if exist "%HAXELIB_OUTPUT%" rd /q /s "%HAXELIB_OUTPUT%"
if exist "%HASHLINK_OUTPUT%" rd /q /s "%HASHLINK_OUTPUT%"

ECHO ### Downloading and Installing Haxe
START /WAIT powershell.exe -NoProfile -NonInteractive -Command "Invoke-WebRequest https://github.com/HaxeFoundation/haxe/releases/download/4.1.4/haxe-4.1.4-win.zip -OutFile haxe.zip"

START /WAIT powershell.exe -NoProfile -Command "Expand-Archive -FORCE '%CWD%\haxe.zip'"
for /f %%a in ('dir /b "%CWD%\haxe\haxe_*"') do set TMP_PATH=%%~a
MOVE "%CWD%\haxe\%TMP_PATH%" "%HAXE_OUTPUT%"  || goto :fail



cd %CWD%

ECHO ### Downloading and Installing Neko
START /WAIT powershell.exe -NoProfile -NonInteractive -Command "Invoke-WebRequest https://github.com/HaxeFoundation/neko/releases/download/v2-3-0/%NEKO_VER%.zip -OutFile neko.zip
START /WAIT powershell.exe -NoProfile -Command "Expand-Archive -FORCE '%CWD%\neko.zip'"
START /WAIT powershell.exe -NoProfile -Command "Expand-Archive -FORCE '%CWD%\neko.zip'"
XCOPY /s/e/y "%CWD%\neko\%NEKO_VER%" "%HAXE_OUTPUT%"  || goto :fail


cd %CWD%

ECHO ### Downloading and Installing Hashlink
START /WAIT powershell.exe -NoProfile -NonInteractive -Command "Invoke-WebRequest https://github.com/HaxeFoundation/hashlink/releases/download/1.11/hl-1.11.0-win.zip -OutFile hashlink.zip"
START /WAIT powershell.exe -NoProfile -Command "Expand-Archive -FORCE '%CWD%\hashlink.zip'"
for /f %%a in ('dir /b "%CWD%\hashlink\hl*"') do set TMP_PATH=%%~a
MOVE "%CWD%\hashlink\%TMP_PATH%" "%HASHLINK_OUTPUT%"  || goto :fail


:clean

ECHO ### CLEANING
if exist "%CWD%\haxe" rd /q /s "%CWD%\haxe" || goto :fail
if exist "%CWD%\hashlink" rd /q /s "%CWD%\hashlink"  || goto :fail
if exist "%CWD%\neko" rd /q /s "%CWD%\neko"  || goto :fail

DEL "%CWD%\haxe.zip"  || goto :fail
DEL "%CWD%\hashlink.zip"  || goto :fail
DEL "%CWD%\neko.zip"  || goto :fail

ECHO ### Dev environement setup

"%HAXE_OUTPUT%\haxelib.exe" newrepo
"%HAXE_OUTPUT%\haxelib.exe" --always install "%CWD%\build.hxml"

goto :end

:fail
echo "Error during installation, contact thomas@evilempirestudio.com for some help"
PAUSE

:end 
