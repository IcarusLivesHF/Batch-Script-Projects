@echo off & setlocal enableDelayedExpansion

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set "sin=(a=((x*31416/180)%%62832)+(((x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) / 10000"
set "cos=(a=((15708-x*31416/180)%%62832)+(((15708-x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) / 10000"

set /a "wid=hei=50"
mode %wid%,%hei%

for /l %%i in () do (
	
	set /a "angle=(angle + 15) %% 360"
	
	for /l %%j in (0,6,360) do (
	
		REM rotate on y
        set /a "px=20 * !cos:x=%%j! * !cos:x=angle! - 2 * !sin:x=angle! + wid / 2"
		set /a "py=20 * !sin:x=%%j! + hei / 2"
        
        set "scrn=!scrn!%\e%[!py!;!px!HO"
    )
	
	echo %\e%[2J!scrn!
	set "scrn="
)
