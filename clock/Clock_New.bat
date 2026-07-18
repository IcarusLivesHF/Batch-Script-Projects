@echo off & setlocal enableDelayedExpansion

call :init

rem wrap numbers around the clock
for /l %%i in (1,1,12) do (
	set /a "cx=21 * !cos:x=(360 * %%i / 12 - 90)!/10000 + wid/2",^
	       "cy=21 * !sin:x=(360 * %%i / 12 - 90)!/10000 + hei/2"
	set "numbers=!numbers!%\e%[!cy!;!cx!H%%i"
)

rem build the frame of the clock now so we don't have to build it every loop
for /l %%a in (0,1,360) do (
	set /a "xa=23 * !cos:x=%%a!/10000 + wid/2",^
		   "ya=23 * !sin:x=%%a!/10000 + hei/2"
	set "$circle=!$circle!%\e%[!ya!;!xa!H "
)
set "$circle=%\e%[48;5;15m!$circle!%\e%[0m"
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

	if !hr! neq !lastHr! (set "lastHr=!hr!" & (%@clockHand% hrang 10) & set "$hourHand=%\e%[48;5;9m!hands!")
	if !mn! neq !lastMn! (set "lastMn=!mn!" & (%@clockHand% mnang 15) & set "$minuteHand=%\e%[48;5;10m!hands!")
	                                          (%@clockHand% scang 20) & set "$secondHand=%\e%[48;5;12m!hands!"
	                                          (%@clockHand% csang 6)  & set "$csHand=%\e%[48;5;11m!hands!"

	set "scrn=!$hourHand!!$minuteHand!!$secondHand!!$csHand!%\e%[0m"

	echo %\e%[2J%\e%[H!$clockFrame!!scrn!%numbers%!build_ssd!%\e%[0m
	set "scrn="
)








:init
rem set the code page to use utf-8 characters
chcp 65001>nul

rem set dimensions
set /a "wid=49,hei=50"
mode %wid%,%hei%

rem harvest \n and \e characters
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%
echo %\e%[2J%\e%[H%\e%[?25l

rem sin/cos taylor series in degress
set "sin=(a=((x*31416/180)%%62832)+(((x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000)"
set "cos=(a=((15708-x*31416/180)%%62832)+(((15708-x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000)"

set @clockHand=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-2" %%1 in ("^!args^!") do (%\n%
	set "hands="%\n%
	set /a "cr=^!cos:x=%%~1^!",^
	       "sr=^!sin:x=%%~1^!"%\n%
	for /l %%r in (1,1,%%~2) do (%\n%
		set /a "xa=%%r * cr/10000 + wid/2",^
		       "ya=%%r * sr/10000 + hei/2"%\n%
		set "hands=^!hands^!%\e%[^!ya^!;^!xa^!H "%\n%
	)%\n%
)) else set args=
goto :eof
