@echo off & setlocal enableDelayedExpansion

call :init

rem wrap numbers around the clock
for /l %%i in (1,1,12) do (
	set /a "cx=21 * !cos:x=(360 * %%i / 12 - 90)! + wid/2"
	set /a "cy=21 * !sin:x=(360 * %%i / 12 - 90)! + hei/2"
	set "numbers=!numbers!%\e%[!cy!;!cx!H%%i"
)

rem build the frame of the clock now so we don't have to build it every loop
%@circle% wid/2 hei/2 23 23
set "$clockFrame=!$circle!"


for /l %%# in ( infinite ) do (

	for /f "tokens=1-4 delims=:.," %%a in ("!time!") do (

		set "hr=%%a" & set "mn=%%b" & set "sc=%%c" & set "cs=%%d"

		for %%i in (hr mn sc cs) do if "!%%i:~0,1!" equ "0" set "%%i=!%%i:~1,1!"

		set /a "hrang=(360 * (hr %% 12) / 12 - 90)",^
		       "mnang=(360 * mn / 60 - 90)",^
		       "scang=(360 * (sc * 100 + cs) / 6000 - 90)",^
		       "csang=(360 * cs / 100 - 90)"
	)

	rem hour hand /w radius 10, only recomputed when the hour changes
	if !hr! neq !lastHr! (
		set "hands="
		for /l %%r in (1,1,10) do (
			set /a "xa=%%r * !cos:x=hrang! + wid/2", "ya=%%r * !sin:x=hrang! + hei/2"
			set "hands=!hands!%\e%[!ya!;!xa!H "
		)
		set "$hourHand=%\e%[48;5;9m!hands!%\e%[0m"
		set "lastHr=!hr!"
	)

	rem minute hand /w radius 15, only recomputed when the minute changes
	if !mn! neq !lastMn! (
		set "hands="
		for /l %%r in (1,1,15) do (
			set /a "xa=%%r * !cos:x=mnang! + wid/2", "ya=%%r * !sin:x=mnang! + hei/2"
			set "hands=!hands!%\e%[!ya!;!xa!H "
		)
		set "$minuteHand=%\e%[48;5;10m!hands!%\e%[0m"
		set "lastMn=!mn!"
	)

	rem second hand /w radius 20, smoothed via centiseconds
	set "hands="
	for /l %%r in (1,1,20) do (
		set /a "xa=%%r * !cos:x=scang! + wid/2", "ya=%%r * !sin:x=scang! + hei/2"
		set "hands=!hands!%\e%[!ya!;!xa!H "
	)
	set "$secondHand=%\e%[48;5;12m!hands!%\e%[0m"

	rem centisecond hand /w short radius 6, spins once per second
	set "hands="
	for /l %%r in (1,1,6) do (
		set /a "xa=%%r * !cos:x=csang! + wid/2", "ya=%%r * !sin:x=csang! + hei/2"
		set "hands=!hands!%\e%[!ya!;!xa!H "
	)
	set "$csHand=%\e%[48;5;11m!hands!%\e%[0m"

	set "scrn=!$hourHand!!$minuteHand!!$secondHand!!$csHand!"

	echo %\e%[2J%\e%[H!$clockFrame!!scrn!%numbers%
	set "scrn="
)








:init
rem set the code page to use utf-8 characters
chcp 65001>nul

rem set dimensions
set /a "wid=hei=50"
mode %wid%,%hei%

rem harvest \n and \e characters
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%

rem sin/cos taylor series in degress
set "sin=(a=((x*31416/180)%%62832)+(((x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) / 10000"
set "cos=(a=((15708-x*31416/180)%%62832)+(((15708-x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) / 10000"

rem @circle macro returns $circl
:_circle
rem %circle% x y ch cw <rtn> $circle
set @circle=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set "$circle=%\e%[48;5;15m"%\n%
	for /l %%a in (0,3,360) do (%\n%
		set /a "xa=%%~3 * ^!cos:x=%%a^! + %%~1", "ya=%%~4 * ^!sin:x=%%a^! + %%~2"%\n%
		set "$circle=^!$circle^!%\e%[^!ya^!;^!xa^!H "%\n%
	)%\n%
	set "$circle=^!$circle^!%\e%[0m"%\n%
)) else set args=

rem number sprites 3x4
set "[1]=[C [2D[B  [2D[B▓ [2D[B▓ [3A"
set "[2]=  [2D[B[C [2D[B [C[2D[B  [3A"
set "[3]=   [3D[B[2C [3D[B[C  [3D[B   [3A"
set "[4]= ▓ [3D[B ▓ [3D[B   [3D[B[2C [3A"
set "[5]=  [2D[B [C[2D[B[C [2D[B  [3A"
set "[6]= [2C[3D[B   [3D[B [C [3D[B   [3A"
set "[7]=   [3D[B[2C [3D[B▓▓ [3D[B▓▓ [3A"
set "[8]=   [3D[B   [3D[B [C [3D[B   [3A"
set "[9]=   [3D[B [C [3D[B   [3D[B[2C [3A"
set "[0]=   [3D[B [C [3D[B [C [3D[B   [3A"
set "[]=[C"
set "[.]=[3C[C[3D[B[C [C[3D[B[3C[3D[B[C [C[3A"

goto :eof
