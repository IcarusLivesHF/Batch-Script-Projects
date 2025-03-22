@echo off & setlocal enableDelayedExpansion

call :Set_Font "mxplus ibm ega 8x8" 1 nomax %1 || exit

call :init

call :constructStars

for /l %%# in () do (

	for /l %%i in (1,1,%stars%) do (
	
		set /a "tz[%%i]-=speed[%%i]"
		
		if !tz[%%i]! lss 1 (
			set /a "x=-wid, y=wid, tx[%%i]=%rnd(x,y)%",^
				   "x=-hei, y=hei, ty[%%i]=%rnd(x,y)%",^
				                  "tz[%%i]=wid",^
				   "x=10, y=40, speed[%%i]=%rnd(x,y)%",^
				   "color[%%i]=!random! %% 14"
		)
		
		set /a "sx[%%i]=(wid/2) + range * tx[%%i] / tz[%%i]",^
		       "sy[%%i]=(hei/2) + range * ty[%%i] / tz[%%i]",^
			   "r=15 + -15 * tz[%%i] / wid"
		
		if !sx[%%i]! gtr 0 if !sx[%%i]! lss %wid% if !sy[%%i]! gtr 0 if !sy[%%i]! lss %hei% for %%r in (!r!) do (
			set "field=!field!%\e%[48;5;!color[%%i]!m%\e%[!sy[%%i]!;!sx[%%i]!H!circle[%%r]!"
		)
		
	)

	echo %\e%[2J!field!%\e%[m
	set "field="
)



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



:init
rem Empty environment, but keep some essentials
for /f "tokens=1 delims==" %%a in ('set') do (
	set "pre=true"
	for %%b in (cd Path ComSpec SystemRoot temp windir) do (
		if /i "%%a" equ "%%b" set "pre="
	)
	if defined pre set "%%~a="
)
set "pre="

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%

set /a "wid=600, hei=300"
mode %wid%,%hei%


set "rnd(x,y)=(((^!random^! * 32768 + ^!random^!) %% (y - x + 1)) + x)"


rem %@fillCircle% radius color <rtn> !$fillCircle!
set @fillCircle=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1,2" %%1 in ("^!args^!") do (%\n%
	if "%%~2" neq "" ( set "$fillCircle=%\e%[48;5;%%~2m" ) else ( set "$fillCircle=%\e%[48;5;15m" )%\n%
	set /a "$rr=%%~1 * %%~1", "hr=%%~1 - 1"%\n%
	for /l %%y in (-%%~1,1,%%~1) do (%\n%
		set "$sx=0"%\n%
		for /l %%x in (-%%~1,1,%%~1) do (%\n%
			set /a "$xxyy=%%x*%%x+%%y*%%y"%\n%
			if ^^!$xxyy^^! lss ^^!$rr^^! set /a "$sx+=1"%\n%
		)%\n%
		if ^^!$sx^^! gtr 0 (%\n%
			set /a "shift=lx / 2 - $sx / 2"%\n%
			if ^^!shift^^! leq -1 (%\n%
				set "shift=%\e%[^!shift:-=^!D"%\n%
				set "shift=^!shift:1=^!"%\n%
			) else if ^^!shift^^! geq 1 (%\n%
				set "shift=%\e%[^!shift^!C"%\n%
				set "shift=^!shift:1=^!"%\n%
			) else (%\n%
				set "shift="%\n%
			)%\n%
			set "$fillCircle=^!$fillCircle^!^!shift^!%\e%[^!$sx^!X%\e%[B"%\n%
			set /a "lx=$sx"%\n%
		)%\n%
	)%\n%
	set "$fillCircle=%\e%[^!hr^!A^!$fillCircle^!%\e%[0m"%\n%
)) else set args=
goto :eof



:constructStars
set "stars=20"

set "range=200"

set /a "x=10, y=40, speed=%rnd(x,y)%"

for /l %%i in (1,1,%stars%) do (
	set /a "x=-wid, y=wid, tx[%%i]=%rnd(x,y)%"
	set /a "x=-hei, y=hei, ty[%%i]=%rnd(x,y)%"
	set /a "x=0,    y=wid, tz[%%i]=%rnd(x,y)%"
	set /a "x=10, y=40, speed[%%i]=%rnd(x,y)%"
	set /a "color[%%i]=!random! %% 14"
)




for /l %%i in (1,1,15) do (
	%@fillCircle% %%i
	set "circle[%%i]=!$fillCircle:%\e%[48;5;15m=!"
)
goto :eof
