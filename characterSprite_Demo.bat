@echo off & setlocal enableDelayedExpansion & set "(=(set "\=?" & ren "%~nx0" -t.bat & ren "?.bat" "%~nx0"" & set ")=ren "%~nx0" "^^!\^^!.bat" & ren -t.bat "%~nx0")" & set "self=%~nx0" & set "failedLibrary=ren -t.bat "%~nx0" &echo Library not found & timeout /t 3 & exit"

set "revisionRequired=3.30.1"
(%(:?=Library% && (call :revision)||(%failedLibrary%))2>nul
	call :stdlib /w:150 /h:50 /fs:8
	call :characterSprites
%)%  && (cls&goto :setup)
:setup

for %%a in (0 1 2 3 4 5 6 7 8 9) do (
	set /a "r=!random! %% 255","g=!random! %% 255","b=!random! %% 255"
	<nul set /p "=%\e%%\rgb%!chr[%%a]! "
)
for /l %%a in (1,1,9) do echo.
for %%a in (. _ -a -b -c -d -e -f -g) do (
	set /a "r=!random! %% 255","g=!random! %% 255","b=!random! %% 255"
	<nul set /p "=%\e%%\rgb%!chr[%%a]! "
)
for /l %%a in (1,1,9) do echo.
for %%a in (-h -i -j -k -l -m -n -o -p) do (
	set /a "r=!random! %% 255","g=!random! %% 255","b=!random! %% 255"
	<nul set /p "=%\e%%\rgb%!chr[%%a]! "
)
for /l %%a in (1,1,9) do echo.
for %%a in (-q -r -s -t -u -v -w -x -y -z) do (
	set /a "r=!random! %% 255","g=!random! %% 255","b=!random! %% 255"
	<nul set /p "=%\e%%\rgb%!chr[%%a]! "
)

pause & exit /b
