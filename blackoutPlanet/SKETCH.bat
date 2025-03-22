@echo off & setlocal enableDelayedExpansion

call :Set_Font "lucida console" 1 nomax %1 || exit

call :init

set /a "ball.x=575", "ball.y=hei / 4", "ball.r=10, ball.r=ball.r * ball.r * 2550"
rem big shiny star
set "lastSum="
set "reset=0"
title PLEASE WAIT, SCRIPT WILL RESTART ITSELF
if not exist shinyStar.txt (
	(
		for /l %%y in (1,2,%hei%) do (
			set /a "dy=%%y - ball.y, by=dy*dy"
			for /l %%x in (1,2,%wid%) do (
				set /a "dx=%%x - ball.x, bx=dx*dx, sum=ball.r / (bx + by + 1)"
				
				set "append=  " 
				if !sum! gtr 2 (
					if !sum! neq !lastSum! (
						set "append=%\e%[48;2;!sum!;!sum!;!sum!m  "
					)
					set /a lastSum=sum
				)
				set "line=!line!%\e%7!append!%\e%8!append!"
			)
			echo=!line!
			set "line="
		)
	)>shinyStar.txt
	set /a "reset+=1"
) else type shinyStar.txt

rem star(s)
if not exist littleStars.txt (
	set "c[0]=15"
	set "c[1]=222"
	set "c[2]=117"
	(
		for /l %%i in (1,1,200) do (
			set /a "x=0, y=wid, i=%rnd(x,y)%"
			set /a "x=0, y=hei, j=%rnd(x,y)%"
			set /a "color=!random! %% 3"
			for %%c in (!color!) do <nul set /p "=%\e%[48;5;!c[%%c]!m%\e%[!j!;!i!H %\e%[m"
		)
	)>littleStars.txt
	set /a "reset+=1"
) else type littleStars.txt

rem back side of planet
if not exist backSideOfPlanet.txt (
	(
		%@fillCircle% 100 16
		<nul set /p "=%\e%[150;400H%\e%[48;2;2;2;2m!$fillCircle:%\e%[48;5;16m=!"
	)>backSideOfPlanet.txt
	set /a "reset+=1"
) else type backSideOfPlanet.txt

if !reset! gtr 0 (
	start /b "" cmd /c "%~nx0" & exit
)
pause>nul
exit /b

:init
for /f "tokens=1 delims==" %%a in ('set') do (
	set "unload=true"
	for %%b in ( Path ComSpec SystemRoot ) do if /i "%%a"=="%%b" set "unload=false"
	if "!unload!"=="true" set "%%a="
)
set "unload="

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)

set "rnd(x,y)=(((^!random^! * 32768 + ^!random^!) %% (y - x + 1)) + x)"


rem this is a special version of fillCircle
rem because of lucida console font size 1 is a 1:2 ratio, I had to double the cells on the X
rem %@fillCircle% radius color <rtn> !$fillCircle!
set @fillCircle=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1,2" %%1 in ("^!args^!") do (%\n%
	if "%%~2" neq "" ( set "$fillCircle=%\e%[48;5;%%~2m" ) else ( set "$fillCircle=%\e%[48;5;15m" )%\n%
	set /a "$rr=%%~1 * %%~1", "hr=%%~1 - 1"%\n%
	for /l %%y in (-%%~1,1,%%~1) do (%\n%
		set "$sx=0"%\n%
		for /l %%x in (-%%~1,1,%%~1) do (%\n%
			set /a "$xxyy=%%x*%%x+%%y*%%y"%\n%
			if ^^!$xxyy^^! lss ^^!$rr^^! set /a "$sx+=2"%\n%
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

set /a "wid=800,hei=600"
mode %wid%,300
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
