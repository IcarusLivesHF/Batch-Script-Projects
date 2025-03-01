@echo off & setlocal enabledelayedexpansion

if "%~1" neq "_" if "%1" neq "" goto:%1

rem use a font you have -v
call :Set_Font "lucida console" 2 nomax %1 || exit

call :init




rem HEY USER! LOOK HERE ---------------------------------------------------------------------------------
rem           \world,heat,grayscale,fire,night,radiation,rainbow,infrared,sunset,aurora,galaxy,magic
call mapvalues\world


rem vector range
rem 1   -> 0.01
rem 10  -> 0.10
rem 100 -> 1.00
rem provide an integer between 0 - 200;  please experiment with this value
set "vectorRange=100"

rem provide an integer between 0 - 127;  please experiment with this value
set "landLevel=64"

rem provide how wide by how tall you want the grid to be
set "fieldX=20"
set "fieldY=20"

rem -----------------------------------------------------------------------------------------------------





rem generate Vector Field  20*20 * resolution(10)
call :generateVectorField %fieldX% %fieldY%


rem main                                       start X new threads    'perlinStrip'    LOC    landLevel
for /l %%Y in (%start%,%resolution%,%endy%) do start /b "" cmd /c %0   perlinStrip     %%Y   %landLevel%

pause>nul
exit

:perlinStrip
set /a "$y=%~2 - start"
<nul set /p "=%\e%[!$y!;1H"

set /a "dx=0, dy=$y"

for /l %%X in (%start%,%resolution%,%endx%) do (
	
	set /a "i=%%X+resolution","j=%~2+resolution"
	
	for /l %%y in (1,1,%resolution%) do (
		for /l %%x in (1,1,%resolution%) do (
			
			
			
			rem  x*resolution y*resolution X/resolution Y/resolution X+resolution Y+resolution landLevel
			%@perlin% %%x %%y %%X %~2 !i! !j! %~3
			
			
			
			rem $MAP = 0 - 25    the formula for this is a summation of every bool (255,-10,0)
			rem when bool(@lss) = 1 then $map+=1 else $map+=0
			set /a "x=$perlin, $MAP=%@switchMap%"
			
			rem define the R G B values based on the $map position in %map%
			for %%m in (!$MAP!) do for %%C in ("!map:~%%m,1!") do (
				set /a "!$RGB[%%~C]!"
			)
			
			
			
			<nul set /p "=%\e%[!dy!;!dx!H%\e%[48;2;!r!;!g!;!b!m%\e%[2X"
			set /a "dx+=2"
		)
		set /a "dx-=resolution*2, dy+=1"
		<nul set /p "=%\e%[!dy!;!dx!H"
	)
	set /a "dx+=resolution*2, dy-=resolution"
	<nul set /p "=%\e%[!dy!;!dx!H"
)
goto :eof










:init
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%

set /a "wid=400, hei=200"
mode %wid%,%hei%

rem map for switchMap to map R G B values from the called mapvalues\MAP
set "map=PONMLKJIHGFEDBCA9876543210"



rem some dependencies
set "@rnd(x,y)=(((^!random^! * 32768 + ^!random^!) %% (y - x + 1)) + x)"
set "@constrain=(l=x-lo, t=x-(l&(l>>31)), h=hi-t, t+=(h&(h>>31)))" & rem constrain X between lo and hi
set "@lerp=((b - a) * (c - 1)) / 99 + a"                           & rem lerp a to b by c(0-100)
set "@smoothStep=((3*10000*x*x) - (2*x*x*x))/10000000"
set "@lss=(((x-y)>>31)&1)"

rem switchMap is a summation of booleans; each time a boolean is true, it equals 1, so it will add 1, otherwise it is 0
set "@switchMap=%@lss:y=255% + %@lss:y=240% + %@lss:y=230% + %@lss:y=220% + %@lss:y=210% + %@lss:y=200% + %@lss:y=190% + %@lss:y=180% + %@lss:y=170% + %@lss:y=160% + %@lss:y=150% + %@lss:y=140% + %@lss:y=130% + %@lss:y=120% + %@lss:y=110% + %@lss:y=100% + %@lss:y=90% + %@lss:y=80% + %@lss:y=70% + %@lss:y=60% + %@lss:y=50% + %@lss:y=40% + %@lss:y=30% + %@lss:y=20% + %@lss:y=10%"
set "@lss="


REM https://en.wikipedia.org/wiki/Perlin_noise
REM https://rtouti.github.io/graphics/perlin-noise-algorithm
REM %@perlin% x*resolution y*resolution X/resolution Y/resolution X+resolution Y+resolution landLevel <rtn> !$perlin! approximate range: (-127 to 127 + %%~7)
set @perlin=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-7" %%A in ("^!args^!") do (%\n%
	rem * 17 + 11 is hardcoded because it is where I found the best resolutionults forcing wx,wy to be between 0-100%\n%
	set /a "x=%%A * 17 + 11, wx=%@smoothStep%",^
		   "x=%%B * 17 + 11, wy=%@smoothStep%",^
		   "ac=%%A - %%C, bd=%%B - %%D, ae=%%A - %%E, bf=%%B - %%F"%\n%
	for /f "tokens=1-8" %%1 in ("^![%%C][%%D]^! ^![%%E][%%D]^! ^![%%C][%%F]^! ^![%%E][%%F]^!") do (%\n%
		set /a "a=(ac * %%1 + bd * %%2) /10000",^
		       "b=(ae * %%3 + bd * %%4) /10000",^
			   "c=wx", "nx=%@lerp%",^
			   "a=(ac * %%5 + bf * %%6) /10000",^
			   "b=(ae * %%7 + bf * %%8) /10000",^
			   "c=wx", "ny=%@lerp%"%\n%
	)%\n%
    set /a "lo=0, hi=127, x=%%~G, a=nx, b=ny, c=wy, x=%@lerp% + %@constrain%, hi=255, $perlin=%@constrain%"%\n%
)) else set args=
goto :eof

:generateVectorField
rem initialize vectors across the window * by resolution
set "resolution=10" & rem [CONSTANT] : This system is built to work with this resolution. Other sizes probably won't look right.

set  "gridShift=4" & rem Personally, I find that the first few values are kind of plain, so we just shift them out.
rem constrain the vector range to between -20000 and 20000 which gets transformed into -2.00 to 2.00 
set /a "lo=100, hi=20000, x=vectorRange * 100, vectorRange=%@constrain%",^
       "start=resolution * gridShift + 1",^
       "w=(%~1 + gridShift + 1) * resolution",^
	   "h=(%~2 + gridShift + 1) * resolution",^
	   "endy=h - resolution",^
       "endx=w - resolution"
	   
for /l %%y in (%start%,%resolution%,%h%) do (
	for /l %%x in (%start%,%resolution%,%w%) do (
		set /a "x=-vectorRange, y=vectorRange, dx=%@rnd(x,y)%, dy=%@rnd(x,y)%"
		set "[%%x][%%y]=!dx! !dy!"
	)
)
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