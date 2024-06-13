@echo off & setlocal enableDelayedExpansion

rem this script work on 1x2 char ratio. it duoble the width.
call :Set_Font "Lucida Console" 2 nomax %1 || exit

rem For Fast PC you can increase number of point or radius
set /a "point=15, rad=80, wid=(rad*2+rad*2),hei=rad*2"

mode %wid%,%hei%
chcp 65001
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

rem you can try different type of point
%= *Φ•○♥øo█♦ =%
rem set "ball=%\e%[D███%\e%[A%\e%[3D/█\%\e%[2B%\e%[3D\█/"
set "ball=██"

set "sin=(a=((x*31416/180)%%62832)+(((x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000)"
set "cos=(a=((15708-x*31416/180)%%62832)+(((15708-x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000)"

rem Hide cursor
echo %\e%[?25l

rem precompute
set /a step=360/point
for /l %%i in (0,%step%,360) do (
	set /a "ci=!cos:x=%%i!, si=!sin:x=%%i!"
	set "PRE=!PRE!"!ci! !si!" "	
)

rem Step 4: Empty env
(
  for /F "Tokens=1 delims==" %%v in ('set') do set "%%v="
  set "ball=%ball%"
  set "sin=%sin%
  set "cos=%cos%

  for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=((((10%%a-1000)*60+(10%%b-1000))*60+(10%%c-1000))*100)+(10%%d-1000)"

for /l %%# in (1,1,10000) do (

		for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=((((10%%a-1000)*60+(10%%b-1000))*60+(10%%c-1000))*100)+(10%%d-1000)"
		set /a "dt=(t2 - t1)*10000/%%#, FPS=1000000/dt"
		title dt=!dt! FPS=!FPS!

		set /a "dt=t2 - t1, angle=dt/3 %% 360" & set "dt=" & set "t2=" & set "FPS=" & rem step 5 keep env empty
		
		rem Repeated factors
		set /a "ca=!cos:x=angle!, sa=!sin:x=angle!"	

		rem step 5
		for %%s in (%PRE%) do for /f "tokens=1,2" %%a in (%%s) do (

			for %%t in (%PRE%) do for /f "tokens=1,2" %%u in (%%t) do (
				
				REM Repeated factors and Rotate around the X axis and Y
				set /a 	new_z=-%rad% * %%v/10000 * sa/10000 + (%rad% * %%u/10000 * %%a/10000 * sa/10000 + %rad% * %%u/10000 * %%b/10000 * ca/10000^) * ca/10000, ^
					cx=(%rad% * %%v/10000 * ca/10000 + (%rad% * %%u/10000 * %%a/10000 * sa/10000 + %rad% * %%u/10000 * %%b/10000 * ca/10000^) * sa/10000^) *2 + %wid% / 2, ^
					cy=%rad% * %%u/10000 * %%a/10000 * ca/10000 - %rad% * %%u/10000 * %%b/10000 * sa/10000 + %hei% / 2
				
				if !new_z! lss 0 (
					set "circle=!circle!%\e%[!cy!;!cx!H%Ball%%\e%[0m"
				) else set "circle=!circle!%\e%[!cy!;!cx!H♦"

			)
		)
		echo=%\e%[2J!circle!
		set "circle="

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
