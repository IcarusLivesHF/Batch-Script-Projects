@echo off & setlocal enableDelayedExpansion

REM call :Set_Font "lucida console" 2 nomax %1 || exit
call :Set_Font "mxplus ibm ega 8x8" 1 nomax %1 || exit

set /a "hei=300, wid=300"
mode %wid%,%hei%

call :init
call :macros

for %%i in ("148 150 5 196" "153 150 5 46" "150 155 5 12") do (
	%@fillCircle% %%~i
	set "cent=!cent!!$fillCircle!"
)

for %%i in (. 196 202 226 46 21 54 90) do set /a "i+=1" & set "b!i!=%%i"
for /l %%i in (1,1,%i%) do set /a "angle%%i=360 / %%i"
set /a "x=wid / 2, y=hei / 2"

(
	set "@fillCircle="
	set "@circle="
	
	for /l %%# in () do (
		for /l %%i in (1,1,%i%) do (
			set /a "angle%%i+=1",^
				   "x%%i=wid / 3 * !cos:x=(i + 1) * angle%%i!/10000 * !sin:x=angle%%i!/10000 + wid / 2",^
				   "y%%i=hei / 2 * !cos:x=(i + 1) * angle%%i!/10000 * !cos:x=angle%%i!/10000 + hei / 2"
			
			%@circle% !x%%i! !y%%i! 2 !b%%i!
			set "screen=!screen!%\e%[!y%%i!;!x%%i!H!$circle!"
			set "trail=!trail!%\e%[48;5;!b%%i!m%\e%[!y%%i!;!x%%i!H "
		)
		
		echo=%\e%[2J%\e%[H!cent!!screen!!trail!%\e%[0m
		set "screen="
		set "trail=!trail:~-3500!"
	)
)
:init
set "sin=(a=((x*31416/180)%%62832)+(((x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) "
set "cos=(a=((15708-x*31416/180)%%62832)+(((15708-x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) "

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"
echo %\e%[?25l
goto :eof

:macros
:_while
REM maximum number of iterations: 16*16*16*16*16 = 1,048,576
rem %while% ( condition %end.while% )
Set "While=For /l %%i in (1 1 16)Do If Defined Do.While"
Set "While=Set Do.While=1&!While! !While! !While! !While! !While! "
Set "End.While=Set "Do.While=""

:_circle
rem %@circle% cx cy cr COLOR <rtn> !$circle!
set @circle=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	if "%%~4" equ "" ( set "$circle=%\e%[48;5;15m" ) else ( set "$circle=%\e%[48;5;%%~4m" )%\n%
	set /a "$d=3 - 2 * %%~3, x=0, y=%%~3"%\n%
	^!While^! (%\n%
		set /a "a=%%~1 + x, b=%%~2 + y, c=%%~1 - x, d=%%~2 - y, e=%%~1 - y, f=%%~1 + y, g=%%~2 + x, h=%%~2 - x"%\n%
		set "$circle=^!$circle^!%\e%[^!b^!;^!a^!H %\e%[^!b^!;^!c^!H %\e%[^!d^!;^!a^!H %\e%[^!d^!;^!c^!H %\e%[^!g^!;^!f^!H %\e%[^!g^!;^!e^!H %\e%[^!h^!;^!f^!H %\e%[^!h^!;^!e^!H "%\n%
		if ^^!$d^^! leq 0 ( set /a "$d=$d + 4 * x + 6"%\n%
		) else set /a "y-=1", "$d=$d + 4 * (x - y) + 10"%\n%
		if ^^!x^^! GEQ ^^!y^^! ^!End.while^!%\n%
		set /a "x+=1"%\n%
	)%\n%
	set "$circle=^!$circle^!%\e%[0m"%\n%
)) else set args=

:_fillCircle v2
rem %@fillCircle% cx cy cr COLOR <rtn> !$fillCircle!
set @fillCircle=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	if "%%~4" neq "" ( set "$fillCircle=%\e%[48;5;%%~4m" ) else ( set "$fillCircle=%\e%[48;5;15m" )%\n%
	set /a "rr=%%~3 * %%~3"%\n%
	for /l %%y in (-%%~3,1,%%~3) do for /l %%x in (-%%~3,1,%%~3) do (%\n%
		set /a "xxyy=%%x*%%x+%%y*%%y"%\n%
		if ^^!xxyy^^! leq ^^!rr^^! (%\n%
			set /a "cx=%%~1 + %%x, cy=%%~2 + %%y"%\n%
			set "$fillCircle=^!$fillCircle^!%\e%[^!cy^!;^!cx^!H "%\n%
		)%\n%
	)%\n%
	set "$fillCircle=^!$fillCircle^!%\e%[0m"%\n%
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