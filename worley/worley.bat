@echo off & setlocal enableDelayedExpansion

if "%~1" neq "_" if "%1" neq "" goto :thread

call :Set_Font "lucida console" 4 nomax %1 || exit

call :init 200 100

set /a "grid_cols=5, grid_rows=5"

set "density=10"
set /a "points=(density * wid * hei / (grid_cols * grid_rows)) / 100"

rem WATER daytime
rem set "wR=44"
rem set "wG=169"
rem set "wB=225"
rem set "i=117"
rem set "j=183"
rem set "k=310"

rem WATER nighttime
set "wR=32"
set "wG=55"
set "wB=68"
set "i=400"
set "j=240"
set "k=193"

set /a "chunk_width= wid / grid_cols",^
       "chunk_height=hei / grid_rows"
	   
for /l %%i in (1,1,%points%) do (

	set /a "p[%%i]_x=!random! %% wid, p[%%i]_y=!random! %% hei",^
	       "cx=p[%%i]_x / chunk_width, cy=p[%%i]_y / chunk_height"
		   
    for /f "tokens=1,2" %%a in ("!cx! !cy!") do (
		set "chunk_%%a_%%b=!chunk_%%a_%%b! %%i"
	)
	
)



for /l %%a in (1,1,%hei%) do start /b "" cmd /c %0 %%a

pause>nul
exit

:thread
(
	for /l %%x in (1,1,%wid%) do (

		set "distances="
		set /a "lo=100000",^
			   "pcx=(%%x - 1) / chunk_width",^
			   "pcy=(%1  - 1) / chunk_height"

		for %%i in (-1 0 1) do for %%j in (-1 0 1) do (
			set /a "cx=pcx + %%i, cy=pcy + %%j"
			for /f "tokens=1,2" %%a in ("!cx! !cy!") do (
				for %%q in (!chunk_%%a_%%b!) do (
					set /a "x=%%x - p[%%q]_x",^
						   "y=%1  - p[%%q]_y",^
						   "d=x*x + y*y"
					if !d! lss !lo! set /a "lo=d"
				)
			)
		)
		
		set /a "noise=100 * !sqrt:n=lo!", ^
			   "x=noise / i",^
			   "y=noise / j",^
			   "z=noise / k",^
			   "r=wR + x * x",^
			   "g=wG + y * y",^
			   "b=wB + z * z"

		<nul set /p "=%\e%[%1;%%xH%\e%[48;2;!r!;!g!;!b!m "
	)
)
exit 0



:init
for /f "tokens=1 delims==" %%a in ('set') do (
	set "pre=true" & for %%b in (cd Path ComSpec SystemRoot temp) do if /i "%%a" equ "%%b" set "pre="
	if defined pre set "%%~a="
)
set "pre="

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%

set /a "wid=%1, hei=%2"

mode %wid%,%hei%

set "sqrt=( M=(N),q=M/(11264)+40, q=(M/q+q)>>1, q=(M/q+q)>>1, q=(M/q+q)>>1, q=(M/q+q)>>1, q=(M/q+q)>>1, q+=(M-q*q)>>31 )"

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