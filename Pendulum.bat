@echo off & setlocal enableDelayedExpansion

call :init

set /a "angle=pi / 4",^
       "angleA=0, angleV=0",^
	   "gravity=16",^
	   "mass=4",^
	   "origin.x=wid / 2",^
	   "origin.y=0",^
	   "length=75",^
	   "inc=PI / (mass * 2)"

for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=((((10%%a-1000)*60+(10%%b-1000))*60+(10%%c-1000))*100)+(10%%d-1000)"

for /l %%# in () do (
	
	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=((((10%%a-1000)*60+(10%%b-1000))*60+(10%%c-1000))*100)+(10%%d-1000)"
	set /a "dt=t2 - t1"
	
	if !dt! gtr 1 (
		set /a "t1=t2"

		set /a "angleA=100 * (-1 * gravity * mass * !sin:x=angle!) / length",^
			   "angleV+=angleA",^
			   "angle+=angleV",^
			   "bob.x=length * !sin:x=angle! + origin.x",^
			   "bob.y=length * !cos:x=angle! + origin.y",^
			   "angleV=angleV * 99000 / 100000" & rem DAMPENING
		
		%@line% !origin.x! !origin.y! !bob.x! !bob.y!
		set "scrn=!scrn!!$line!"
		
		for /l %%i in (0,%inc%,%tau%) do (
			set /a "cx=mass * !cos:x=%%i! + bob.x",^
				   "cy=mass * !sin:x=%%i! + bob.y + 2"
			set "scrn=!scrn!%\e%[48;5;15m%\e%[!cy!;!cx!H "
		)
		
		echo=%\e%[2J%\e%[H!scrn!%\e%[0m
		set "scrn="
	)
)

:init
set /a "wid=width=100", "hei=height=100 - 1"
mode %wid%,%hei%

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%

set /a "PI=(35500000/113+5)/10, HALF_PI=(35500000/113/2+5)/10, TAU=TWO_PI=2*PI, PI32=PI+HALF_PI"
set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "sin=(a=(x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!) / 10000"
set "cos=(a=(15708 - x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!) / 10000"

rem get \n
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)

:_line
rem line x0 y0 x1 y1 color
set @line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	if "%%~5" equ "" ( set "hue=15" ) else ( set "hue=%%~5")%\n%
	set "$line=%\e%[48;5;^!hue^!m"%\n%
	set /a "xa=%%~1", "ya=%%~2", "xb=%%~3", "yb=%%~4", "dx=%%~3 - %%~1", "dy=%%~4 - %%~2"%\n%
	if ^^!dy^^! lss 0 ( set /a "dy=-dy", "stepy=-1" ) else ( set "stepy=1" )%\n%
	if ^^!dx^^! lss 0 ( set /a "dx=-dx", "stepx=-1" ) else ( set "stepx=1" )%\n%
	set /a "dx<<=1", "dy<<=1"%\n%
	if ^^!dx^^! gtr ^^!dy^^! (%\n%
		set /a "fraction=dy - (dx >> 1)"%\n%
		for /l %%x in (^^!xa^^!,^^!stepx^^!,^^!xb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "ya+=stepy", "fraction-=dx"%\n%
			set /a "fraction+=dy"%\n%
			set "$line=^!$line^!%\e%[^!ya^!;%%xH "%\n%
		)%\n%
	) else (%\n%
		set /a "fraction=dx - (dy >> 1)"%\n%
		for /l %%y in (^^!ya^^!,^^!stepy^^!,^^!yb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "xa+=stepx", "fraction-=dy"%\n%
			set /a "fraction+=dx"%\n%
			set "$line=^!$line^!%\e%[%%y;^!xa^!H "%\n%
		)%\n%
	)%\n%
	set "$line=^!$line^!%\e%[0m"%\n%
)) else set args=
goto :eof
