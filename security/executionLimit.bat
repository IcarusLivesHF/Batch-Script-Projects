@echo off & setlocal enableDelayedExpansion

call :executionLimit 11

echo Made by Icarus Lives
echo You have access to this file %$m% more times
pause
exit

:executionLimit
	set "cFile=%temp%\%~n0count.txt"
	if not exist "%cFile%" echo %~1 > "%cFile%"
	for /f "usebackq delims=" %%i in ("%cFile%") do set /a "$m=%%i - 1"
	if %$m% equ 0 start /b "" cmd /c del "%~nx0" & exit
	echo %$m% > "%cFile%"
goto :eof