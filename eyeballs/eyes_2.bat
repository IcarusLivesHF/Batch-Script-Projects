@echo off & setlocal enableDelayedExpansion

if "%~1" neq "_" if not "%~1" == "" goto :%~1
call :Set_Font "mxplus ibm ega 8x8" 1 nomax %1 || exit
for %%i in ("stdlib 400 320" "radish" "math" "gfx") do call lib\%%~i


set "maxPupilOffset=10"

set "eye=10"
for /l %%i in (1,1,%eye%) do (
	set /a "pupilSize[%%i]=(!random! %% (7 - 4 + 1)) + 4"
	set /a   "eyeSize=(!random! %% (20 - 10 + 1)) + 10"
	set /a "eyeY[%%i]=(!random! %% (hei - eyeSize - eyeSize + 1)) + eyeSize",^
		   "eyeX[%%i]=(!random! %% (wid - eyeSize - eyeSize + 1)) + eyeSize"

	%@fillCircle% !eyeSize! 15
	set "eyes=!eyes!%\e%[!eyeY[%%i]!;!eyeX[%%i]!H!$fillCircle!"
	
	%@fillCircle% !pupilSize[%%i]! 16
	set "pupil[%%i]=!$fillCircle!"
)

( %radish% "%~nx0" game ) & exit
:game
( %while% if exist "radish_ready" %end.while% ) & del /f /q "radish_ready"



(for /l %%# in () do (
	%@mouse_and_keys%
	
	for /l %%i in (1,1,%eye%) do (
		set /a "x=mouseX -  eyeX[%%i], y=mouseY - eyeY[%%i], %atan2(x,y)%", "theta=$atan2 / 100",^
			   "pupilOffsetX=maxPupilOffset * !cos:x=theta!/10000 + eyeX[%%i] - pupilSize[%%i]",^
			   "pupilOffsetY=maxPupilOffset * !sin:x=theta!/10000 + eyeY[%%i]"
		set "pupils=!pupils!%\e%[!pupilOffsetY!;!pupilOffsetX!H!pupil[%%i]!"
	)
	echo %\e%[2J%\e%[H%eyes%!pupils!
	set "pupils="
))2>nul



:Set_Font FontName FontSize max/nomax dummy
if "%4"=="" (
	for /f "tokens=1,2 delims=x" %%a in ("%~2") do if "%%b"=="" (set /a "FontSize=%~2*65536") else set /a "FontSize=%%a+%%b*65536"
	reg add "HKCU\Console\%~nx0" /v FontSize /t reg_dword /d !FontSize! /f
	reg add "HKCU\Console\%~nx0" /v FaceName /t reg_sz /d "%~1" /f
	set "m=" & if /I "%~3"=="max" set "m=/max"
	start "%~nx0" !m! "%ComSpec%" /c "%~f0" _ 
	exit /b 1
) else ( >nul reg delete "HKCU\Console\%~nx0" /f )
goto:eof
