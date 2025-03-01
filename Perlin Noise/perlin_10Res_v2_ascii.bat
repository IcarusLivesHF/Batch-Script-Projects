@echo off & setlocal enabledelayedexpansion

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%

set /a "wid=hei=100"
mode %wid%,%hei%

set "@map=(c + (d - c) * (v - a) / (b - a))"
set "@rndSgn_A=(^!random^! %% 2 * 2 - 1)"
set "@rndSgn_B=(^!random^! %% 3 - 1)"
set "@lerp=((b - a) * (c - 1)) / 99 + a"
set "@smoothStep=((3*10000*x*x) - (2*x*x*x))/10000000"

set @perlin=for %%# in (1, 1, 2) do if %%#==2 ( for /f "tokens=1-6" %%A in ("^!args^!") do (%\n%
	set /a "x=%%A * 17 + 11, wx=(%@smoothStep%)",^
		   "x=%%B * 17 + 11, wy=(%@smoothStep%)"%\n%
	for /f "tokens=1-4" %%a in ("^![%%C][%%D]^! ^![%%E][%%D]^!") do (%\n%
		set /a "a=(((%%A-%%C)*%%a)+((%%B-%%D)*%%b))",^
			   "b=(((%%A-%%E)*%%c)+((%%B-%%D)*%%d))",^
			   "c=wx", "nx=%@lerp%"%\n%
	)%\n%
	for /f "tokens=1-4" %%a in ("^![%%C][%%F]^! ^![%%E][%%F]^!") do (%\n%
		set /A "a=(((%%A-%%C)*%%a)+((%%B-%%F)*%%b))",^
		       "b=(((%%A-%%E)*%%c)+((%%B-%%F)*%%d))",^
			   "c=wx", "ny=%@lerp%"%\n%
	)%\n%
    set /a "a=nx","b=ny", "c=wy", "$perlin=(%@lerp% + 127 - 0)"%\n%
	if ^^!$perlin^^! lss 0   set "$perlin=0"%\n%
	if ^^!$perlin^^! gtr 255 set "$perlin=255"%\n%
	set /a "v=$perlin, a=0, b=255, c=0, d=100, $perlin=%@map%"%\n%
)) else set args=


set /a "res=10","gw=10","gh=10",^
       "gw*=res","gh*=res",^
	   "ey=gh-res","ex=gw-res"

for /l %%y in (1,%res%,%gh%) do (
    for /l %%x in (1,%res%,%gw%) do (
		set /a "dx=%@rndSgn_A%, dy=%@rndSgn_A%"
        set "[%%x][%%y]=!dx! !dy!"
    )
)

set "chars= .:-=+*$#@"
for /l %%Y in (1,%res%,%ey%) do (
	<nul set /p "=%\e%7"
    for /l %%X in (1,%res%,%ex%) do (
        set /a "i=%%X+res","j=%%Y+res"
        for /l %%y in (1,1,%res%) do (
            for /l %%x in (1,1,%res%) do (
			
			
                %@perlin% %%x %%y %%X %%Y !i! !j!
				
				
				set /a "x=$perlin, m=(((x-99)>>31)&1) + (((x-88)>>31)&1) + (((x-77)>>31)&1) + (((x-66)>>31)&1) + (((x-55)>>31)&1) + (((x-44)>>31)&1) + (((x-33)>>31)&1)+ (((x-22)>>31)&1) + (((x-11)>>31)&1)"
				
				for %%m in (!m!) do <nul set /p "=%\e%[38;5;15m!chars:~%%m,1!"
				REM for %%m in (!m!) do <nul set /p "=%\e%[38;5;15m%%m"

            )
            <nul set /p "=%\e%[%res%D%\e%[B"
        )
        <nul set /p "=%\e%[%res%C%\e%[%res%A"
    )
    <nul set /p "=%\e%8%\e%[%res%B"
)

pause
exit

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