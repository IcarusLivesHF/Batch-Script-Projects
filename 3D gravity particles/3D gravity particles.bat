@echo off & setlocal enableDelayedExpansion

call :Set_Font "lucida console" 2 nomax %1 || exit

call :init

call :constructStars

for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100"
for /l %%# in () do (

	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, dt=t2-t1"

	if !dt! gtr 5 (

		set /a "t1=t2"
		for /l %%i in (1,1,%stars%) do (
		
			set /a "tz[%%i]+=speed[%%i]",^
				   "ay[%%i]+=1 * tm[%%i], vy[%%i]+=ay[%%i], ay[%%i]=0, ty[%%i]+=vy[%%i]",^
				   "sx=100 * tx[%%i] / tz[%%i] + center_x",^
				   "sy=100 * ty[%%i] / tz[%%i] + center_y",^
				   "r=maxSpeed + -maxSpeed * tz[%%i] / wid"
			
			if !ty[%%i]! geq %hei% set /a "vy[%%i]*=-1"
			
			
			if !tz[%%i]! gtr %wid% (
				set /a "x=-wid, y=wid, tx[%%i]=%rnd(x,y)%",^
					   "x=-hei, y=hei, ty[%%i]=%rnd(x,y)%",^
									  "tz[%%i]=0",^
					   "x=10, y=40, speed[%%i]=%rnd(x,y)%",^
					   "color[%%i]=!random! %% 14 + 1"
			)
			
			if !sx! gtr 0 if !sx! lss %wid% if !sy! gtr 0 if !sy! lss %hei% for %%r in (!r!) do (
				set "field=!field!%\e%[48;5;!color[%%i]!m%\e%[!sy!;!sx!H!circle[%%r]!"
			)
			
		)

		echo %\e%[2J!field!%\e%[m
		set "field="
	)
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
set /a "center_x=wid / 2"
set /a "center_y=hei / 2"
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

set /a "x=10, y=40, speed=%rnd(x,y)%"

for /l %%i in (1,1,%stars%) do (
	set /a "x=-wid, y=wid, tx[%%i]=%rnd(x,y)%"
	set /a "x=-hei, y=hei, ty[%%i]=%rnd(x,y)%"
	set /a "x=0,    y=wid, tz[%%i]=%rnd(x,y)%"
	set /a "x=1,    y=10,  tm[%%i]=%rnd(x,y)%"
	set /a "x=10, y=20, speed[%%i]=%rnd(x,y)%"
	set /a "color[%%i]=!random! %% 14 + 1"
)


set "maxSpeed=25"
for /l %%i in (1,1,%maxSpeed%) do (
	%@fillCircle% %%i
	set "circle[%%i]=!$fillCircle:%\e%[48;5;15m=!"
)

goto :eof
