@echo off & setlocal enableDelayedExpansion

if /i "%controller%" equ "enabled" if "%~1" neq "" goto :%~1

set "revisionRequired=3.29.8"
set "(=(set "\=?" & ren "%~nx0" -t.bat & ren "?.bat" "%~nx0""
set ")=ren "%~nx0" "^^!\^^!.bat" & ren -t.bat "%~nx0")" & set "self=%~nx0"
set "failedLibrary=ren -t.bat "%~nx0" &echo Library not found & timeout /t 3 & exit"
(%(:?=Library% && (call :revision)||(%failedLibrary%))2>nul
	call :stdlib /w:50 /h:50 /fs:8
	call :misc
%)%  && (cls&goto :setup)

:setup
set "controller=enabled"
set "controls=WASDEQ"

rem --------------------------------------------------------------------------------------------------------
rem set variables here
rem --------------------------------------------------------------------------------------------------------


if /i "%controller%" equ "enabled" (
	if exist "%temp%\%~n0_signal.txt" del "%temp%\%~n0_signal.txt"
	"%~F0" Controller %controls% >"%temp%\%~n0_signal.txt" | "%~F0" GAME_ENGINE <"%temp%\%~n0_signal.txt"
)
:GAME_ENGINE
	%loop% (
		if /i "%controller%" equ "enabled" set "com=" & set /p "com="
		
		rem --------------------------------------------------------------------------------------------------------
		rem main engine
		rem --------------------------------------------------------------------------------------------------------
	)
	pause
exit

:Controller
	if /i "%controller%" equ "enabled" (
		for /l %%# in () do for /f "tokens=*" %%a in ('choice /c:%~2 /n') do <nul set /p ".=%%a"
	)
