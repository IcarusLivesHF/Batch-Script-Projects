@echo off & setlocal enableDelayedExpansion

if "%~1" neq "_" if not "%~1" == "" goto :%~1
call :Set_Font "mxplus ibm ega 8x8" 1 nomax %1 || exit
for %%i in ("stdlib 400 320" "radish" "math" "gfx") do call lib\%%~i

set "eyeSize=20"
set "pupilSize=7"
set "maxPupilOffset=10"

set /a "eyeY=hei / 2"
set "eyeOffset=30"
set /a "leftEyeX=wid / 2 - eyeOffset"
set /a "rightEyeX=wid / 2 + eyeOffset"

%@fillCircle% !eyeSize! 15
set "eyes=%\e%[!eyeY!;!leftEyeX!H%$fillCircle%%\e%[!eyeY!;!rightEyeX!H%$fillCircle%"

%@fillCircle% !pupilSize! 16
set "pupil=%$fillCircle%"

( %radish% "%~nx0" game ) & exit
:game
( %while% if exist "radish_ready" %end.while% ) & del /f /q "radish_ready"



(for /l %%# in () do (
	%@mouse_and_keys%

	set /a "x=mouseX -  leftEyeX, y=mouseY - eyeY, %atan2(x,y)%", "theta1=$atan2 / 100",^
	       "pupilOffsetX1=maxPupilOffset * !cos:x=theta1!/10000 + leftEyeX - pupilSize",^
	       "pupilOffsetY1=maxPupilOffset * !sin:x=theta1!/10000 + eyeY",^
		   "x=mouseX - rightEyeX, y=mouseY - eyeY, %atan2(x,y)%", "theta2=$atan2 / 100",^
	       "pupilOffsetX2=maxPupilOffset * !cos:x=theta2!/10000 + rightEyeX - pupilSize",^
	       "pupilOffsetY2=maxPupilOffset * !sin:x=theta2!/10000 + eyeY"
	set "pupils=%\e%[!pupilOffsetY1!;!pupilOffsetX1!H!pupil!%\e%[!pupilOffsetY2!;!pupilOffsetX2!H!pupil!"
	
	echo %\e%[2J%\e%[H%eyes%!pupils!
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
