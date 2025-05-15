@echo off & setlocal enableDelayedExpansion
call :Set_Font "mxplus ibm ega 8x8" 1 nomax %1 || exit

call :init

for /l %%i in (1,1,4) do (
	set /a "cx[%%i]=(!random! %% ((wid - (10 * 2))) + 10)"
	set /a "cy[%%i]=(!random! %% ((hei - (10 * 2))) + 10)"
	set /a "ci[%%i]=(!random! %% 2 * 2 - 1) * (!random! %% 3 + 2)"
	set /a "cj[%%i]=(!random! %% 2 * 2 - 1) * (!random! %% 3 + 2)"
)

set /a "centerX=wid / 2"
set /a "centerY=hei / 2"

for /l %%# in () do (

	for /l %%i in (1,1,4) do (
		set /a "cx[%%i]+=ci[%%i]",^
		       "cy[%%i]+=cj[%%i]",^
		       "mx[%%i]=wid - cx[%%i]",^
			   "my[%%i]=hei - cy[%%i]"
		if !cx[%%i]! lss 1         set /a "cx[%%i]=1,      ci[%%i]*=-1"
		if !cx[%%i]! gtr %centerX% set /a "cx[%%i]=centerX,ci[%%i]*=-1"
		if !cy[%%i]! lss 1         set /a "cy[%%i]=1,      cj[%%i]*=-1"
		if !cy[%%i]! gtr %centerY% set /a "cy[%%i]=centerY,cj[%%i]*=-1"
	)

	%@bezier% !cx[1]!  !cy[1]! !cx[2]!  !cy[2]! !cx[3]!  !cy[3]! !cx[4]!  !cy[4]! 21
	set "scrn=!$bezier!"
	%@bezier% !mx[1]!  !cy[1]! !mx[2]!  !cy[2]! !mx[3]!  !cy[3]! !mx[4]!  !cy[4]! 46
	set "scrn=!scrn!!$bezier!"
	%@bezier% !cx[1]!  !my[1]! !cx[2]!  !my[2]! !cx[3]!  !my[3]! !cx[4]!  !my[4]! 226
	set "scrn=!scrn!!$bezier!"
	%@bezier% !mx[1]!  !my[1]! !mx[2]!  !my[2]! !mx[3]!  !my[3]! !mx[4]!  !my[4]! 196
	set "scrn=!scrn!!$bezier!"
	echo %\e%[2J!scrn!
)


:init
for /f "tokens=1 delims==" %%a in ('set') do (
	set "unload=true"
	for %%b in ( path ComSpec SystemRoot ) do if /i "%%a"=="%%b" set "unload=false"
	if "!unload!"=="true" set "%%a="
)
set "unload="

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set /a "wid=hei=400"
mode %wid%,%hei%



rem %@bezier% x1 y1 x2 y2 x3 y3 x4 y4 color <rtn> $bezier
set @bezier=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-9" %%1 in ("^!args^!") do (%\n%
    if "%%~9" equ "" ( set "$bezier=%\e%[48;5;15m" ) else ( set "$bezier=%\e%[48;5;%%~9m" )%\n%
    set /a "steps=30", "dt=1000 / steps", "t=0",^
           "C3x=-%%~1 + 3*%%~3 - 3*%%~5 + %%~7", "C2x=3*(%%~1 - 2*%%~3 + %%~5)", "C1x=3*(%%~3 - %%~1)", "C0x=%%~1",^
           "C3y=-%%~2 + 3*%%~4 - 3*%%~6 + %%~8", "C2y=3*(%%~2 - 2*%%~4 + %%~6)", "C1y=3*(%%~4 - %%~2)", "C0y=%%~2"%\n%
	for /l %%i in (0,1,^^!steps^^!) do (%\n%
		set /a "t2 = t * t / 1000",^
			   "t3 = t2 * t / 1000",^
			   "vx = ((C3x*t3 + C2x*t2 + C1x*t + C0x) / 1000) + %%~1",^
			   "vy = ((C3y*t3 + C2y*t2 + C1y*t + C0y) / 1000) + %%~2",^
			   "t += dt"%\n%
		set "$bezier=^!$bezier^!%\e%[^!vy^!;^!vx^!H%\e%[2X%\e%[B  "%\n%
	)%\n%
	set "$bezier=^!$bezier^!%\e%[0m"%\n%
)) else set args=

goto :eof

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