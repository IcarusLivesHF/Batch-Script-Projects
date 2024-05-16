@echo off & setlocal enableDelayedExpansion

Rem NO LIBRARY REQUIRED

if /i "%controller%" equ "enabled" if "%~1" neq "" goto :%~1

REM INITIALIZE -----------------------------------------------------------------------------
call :macros

mode 100,100
set "controller=enabled"
set "controls=WSADZX"



REM CHANGE ME
2>nul set /a "sides=%~1" || set /a "sides=5"
REM -------------

set /a "size=18"
set /a "x=50", "y=50"
set /a "angle=360 / sides"
set /a "rotationSpeed=10"
set /a "depth=10"
set /a "P_ANGLE=0"

rem Û
REM ----------------------------------------------------------------------------------------
if /i "%controller%" equ "enabled" (
	if exist "%temp%\%~n0_signal.txt" del "%temp%\%~n0_signal.txt"
	"%~F0" Controller %controls% >"%temp%\%~n0_signal.txt" | "%~F0" GAME_ENGINE <"%temp%\%~n0_signal.txt"
)
:GAME_ENGINE
	for /l %%# in () do (		set /a "frame+=1"
	
		rem User Controller
			if /i "%controller%" equ "enabled" set "com=" & set /p "com="
			
				   if /i "!com!" equ "D" ( set /a "rotationSpeed+=5"
			) else if /i "!com!" equ "A" ( set /a "rotationSpeed-=5"
			) else if /i "!com!" equ "W" ( if !depth! lss 25 set /a "depth+=2", "x-=1", "y-=1"
			) else if /i "!com!" equ "S" ( if !depth! gtr 5 set /a "depth-=2", "x+=1", "y+=1"
			) else if /i "!com!" equ "Z" ( if !size! gtr 10 set /a "size-=3"
			) else if /i "!com!" equ "X"   if !size! lss 24 set /a "size+=3"

			set /a "angle0+=rotationSpeed"
			
			for %%i in (1 2) do ( for /l %%c in (1,1,%sides%) do (
					set /a "b=%%c - 1" & for %%b in (!b!) do set /a "angle%%c=!angle%%b! + angle"
					set /a "xoff=x", "yoff=y"
					if %%i equ 1 (
						set /a "x%%i_%%c=size * !cos(x):x=angle%%c! + xoff"
						set /a "y%%i_%%c=size * !sin(x):x=angle%%c! + yoff"
					) else (
						set /a "x%%i_%%c=size * !cos(x):x=angle%%c! + (xoff + depth)"
						set /a "y%%i_%%c=size * !sin(x):x=angle%%c! + (yoff + depth)"
					)
				)
				set /a "c=sides + 1" & set /a "x%%i_!c!=x%%i_1", "y%%i_!c!=y%%i_1"
			)
			
			for %%i in (1 2) do for /l %%c in (1,1,%sides%) do (
				set /a "d=%%c + 1"
				for %%b in (!d!) do (
					%line% !x%%i_%%c! !y%%i_%%c! !x%%i_%%b! !y%%i_%%b! %%c
					set /a "connect_%%i_%%b_X=!x%%i_%%c!"
					set /a "connect_%%i_%%b_Y=!y%%i_%%c!"
				)
			)
			
			for /l %%c in (1,1,%sides%) do ( set /a "d=%%c + 1"
				for %%b in (!d!) do (
					%line% !connect_1_%%b_X! !connect_1_%%b_Y! !connect_2_%%b_X! !connect_2_%%b_Y! %%c
				)
			)
		
		
		rem display everything using VT100 2J sequence to clear the screen first.
		set "stats1=%esc%[9;5HA - Decrease rotation speed       Z - Zoom out     W - Increase Depth"
		set "stats2=%esc%[11;5HD - Increase rotation speed       X - Zoom in      S - Decrease depth"
		set "stats3=%esc%[13;5H Rotation Speed = !rotationSpeed!%esc%[14;5H Zoom - !size!"
		set "stats4=%esc%[5;5HSides = !sides!;  Point at every !angle! Degrees;  Depth = !depth!"
		set "statsBuffer=!stats1!!stats2!!stats3!!stats4!"
		echo %esc%[2J!screen!%esc%[0m!statsBuffer!
		set "screen="
	)
exit

:Controller
	if /i "%controller%" equ "enabled" (
		for /l %%# in () do for /f "tokens=*" %%a in ('choice /c:%~2 /n') do <nul set /p ".=%%a"
	)


:macros
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)
( for /f %%a in ('echo prompt $E^| cmd') do set "esc=%%a" ) & <nul set /p "=!esc![?25l"

rem line x0 y0 x1 y1 color
set line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	if "%%~5" equ "" ( set "hue=30" ) else ( set "hue=%%~5")%\n%
	set "$line=%esc%[38;5;^!hue^!m"%\n%
	set /a "xa=%%~1", "ya=%%~2", "xb=%%~3", "yb=%%~4", "dx=%%~3 - %%~1", "dy=%%~4 - %%~2"%\n%
	if ^^!dy^^! lss 0 ( set /a "dy=-dy", "stepy=-1" ) else ( set "stepy=1" )%\n%
	if ^^!dx^^! lss 0 ( set /a "dx=-dx", "stepx=-1" ) else ( set "stepx=1" )%\n%
	set /a "dx<<=1", "dy<<=1"%\n%
	if ^^!dx^^! gtr ^^!dy^^! (%\n%
		set /a "fraction=dy - (dx >> 1)"%\n%
		for /l %%x in (^^!xa^^!,^^!stepx^^!,^^!xb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "ya+=stepy", "fraction-=dx"%\n%
			set /a "fraction+=dy"%\n%
			set "$line=^!$line^!%esc%[^!ya^!;%%xHÛ"%\n%
		)%\n%
	) else (%\n%
		set /a "fraction=dx - (dy >> 1)"%\n%
		for /l %%y in (^^!ya^^!,^^!stepy^^!,^^!yb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "xa+=stepx", "fraction-=dy"%\n%
			set /a "fraction+=dx"%\n%
			set "$line=^!$line^!%esc%[%%y;^!xa^!HÛ"%\n%
		)%\n%
	)%\n%
	set "screen=^!screen^!^!$line^!"%\n%
)) else set args=

    set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
    set "SIN(x)=(a=(x * 31416 / 180)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%) / 10000"
    set "COS(x)=(a=(15708 - x * 31416 / 180)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%) / 10000"
goto :eof
