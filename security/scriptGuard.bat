@echo off

call :scriptGuard

echo Made by Icarus Lives
echo File cannot be modified after first run
pause
exit

:scriptGuard
	set "hFile=%temp%\%~n0hash.txt"
	copy "%~nx0" "copy.txt">nul
	for /f "skip=1 tokens=*" %%i in ('certutil -hashfile copy.txt sha256') do if not defined hash set "hash=%%i"
	if not exist "%hFile%" (echo=%hash%>"%hFile%") else for /f "usebackq delims=" %%i in ("%hFile%") do (
		if "%%~i" neq "%hash%" start /b "" cmd /c del "%~nx0" & exit
	)
	(del /f /q "copy.txt") & set "hFile=" & set "hash="
goto :eof