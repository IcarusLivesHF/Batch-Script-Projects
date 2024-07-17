@echo off & setlocal enableDelayedExpansion

call :set_font "lucida console" 2 nomax %1 || exit

call :macros
chcp 65001>nul

set /a "wid=250,hei=150"
mode !wid!,!hei!
set /a "rez=6"
set /a "cols=1 + wid / rez", "rows=1 + hei / rez - 1"

for /l %%i in (0,1,%cols%) do for /l %%j in (0,1,%rows%) do (
	set /a "x=%%i * rez", "y=%%j * rez"
	
	REM set /a "1/(!random! %% 2)" && ( 
		REM set "field[%%i][%%j]=0"
		REM set "dots=!dots!%\e%[!y!;!x!H█"
	REM ) || (
		REM set "field[%%i][%%j]=1"
	REM )
	set /a "r=!random! %% 100"
	if !r! lss 50 (
		set "field[%%i][%%j]=1"
		set "dots=!dots!%\e%[!y!;!x!H█"
	) else (
		set "field[%%i][%%j]=0"
	)
)2>nul

for /l %%i in (0,1,%cols%) do (
    for /l %%j in (0,1,%rows%) do (
		set /a "ti=%%i + 1,tj=%%j + 1"
        set /a "a=field[%%i][%%j]",^
               "b=field[!ti!][%%j]",^
               "c=field[!ti!][!tj!]",^
               "d=field[%%i][!tj!]",^
			   "state=a*8+b*4+c*2+d*1",^
               "$a1=%%i * rez + rez / 2", "$a2=%%j * rez",^
               "$b1=%%i * rez + rez",     "$b2=%%j * rez + rez / 2",^
               "$c1=%%i * rez + rez / 2", "$c2=%%j * rez + rez",^
               "$d1=%%i * rez",           "$d2=%%j * rez + rez / 2"

               if !state! equ 1 (  %@line% !$c1! !$c2! !$d1! !$d2!
        ) else if !state! equ 2 (  %@line% !$b1! !$b2! !$c1! !$c2!
        ) else if !state! equ 3 (  %@line% !$b1! !$b2! !$d1! !$d2!
        ) else if !state! equ 4 (  %@line% !$a1! !$a2! !$b1! !$b2!
        ) else if !state! equ 5 (  %@line% !$a1! !$a2! !$d1! !$d2! & %@line% !$b1! !$b2! !$c1! !$c2!
        ) else if !state! equ 6 (  %@line% !$a1! !$a2! !$c1! !$c2!
        ) else if !state! equ 7 (  %@line% !$a1! !$a2! !$d1! !$d2!
        ) else if !state! equ 8 (  %@line% !$a1! !$a2! !$d1! !$d2!
        ) else if !state! equ 9 (  %@line% !$a1! !$a2! !$c1! !$c2!
        ) else if !state! equ 10 ( %@line% !$a1! !$a2! !$b1! !$b2! & %@line% !$c1! !$c2! !$d1! !$d2!
        ) else if !state! equ 11 ( %@line% !$a1! !$a2! !$b1! !$b2!
        ) else if !state! equ 12 ( %@line% !$b1! !$b2! !$d1! !$d2!
        ) else if !state! equ 13 ( %@line% !$b1! !$b2! !$c1! !$c2!
        ) else if !state! equ 14 ( %@line% !$c1! !$c2! !$d1! !$d2!
        )
    )
)

<nul set /p "=!dots!"
pause >nul & exit


:macros
( for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" ) & <nul set /p "=!\e![?25l"

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)
set "sqrt=( M=(N),j=M/(11264)+40, j=(M/j+j)>>1, j=(M/j+j)>>1, j=(M/j+j)>>1, j=(M/j+j)>>1, j=(M/j+j)>>1, j+=(M-j*j)>>31 )"

rem %@line% x0 y0 x1 y1 color <rtn> $line
set @line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set "$line=%\e%[48;5;15m"%\n%
	set /a "$x0=%%~1,$y0=%%~2,$x1=%%~3,$y1=%%~4, dx=(((%%~3-%%~1)>>31|1)*(%%~3-%%~1)), dy=-(((%%~4-%%~2)>>31|1)*(%%~4-%%~2)), $dy=(((%%~4-%%~2)>>31|1)*(%%~4-%%~2))", "err=dx+dy", "dist=((((($dy-dx)>>31)&1)*dx)|((~((($dy-dx)>>31)&1)&1)*$dy))"%\n%
	if ^^!$x0^^! lss ^^!$x1^^! ( set sx=1 ) else ( set sx=-1 )%\n%
	if ^^!$y0^^! lss ^^!$y1^^! ( set sy=1 ) else ( set sy=-1 )%\n%
	for /l %%i in (0,1,^^!dist^^!) do (%\n%
		set "$line=^!$line^!%\e%[^!$y0^!;^!$x0^!H "%\n%
		set /a "e2=2 * err"%\n%
		if ^^!e2^^! geq ^^!dy^^! ( set /a "err+=dy, $x0+=sx" )%\n%
		if ^^!e2^^! leq ^^!dx^^! ( set /a "err+=dx, $y0+=sy" )%\n%
	)%\n%
	set "$line=^!$line^!%\e%[0m"%\n%
	^<nul set /p "=^!$line^!"%\n%
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