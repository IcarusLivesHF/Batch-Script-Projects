@echo off & setlocal enableDelayedExpansion

call :Set_Font "lucida console" 1 nomax %1 || exit

call :init

set /a "step=%radians:x=5%"
(
	for /l %%z in (1,1,10000) do (
		set /a "radx+=step, rady+=step, radz+=step, %@3Dangles%"
		for %%p in (%pre%)  do (
			for /f "tokens=1-4 delims= " %%w in ("%%~p") do (
				set /a "x=%%x, y=%%y, z=%%z, %@ortho%, $x+=center_x, $y+=center_y"
				set "spiral=!spiral!%\e%[48;2;%%wm%\e%[!$y!;!$x!H "
			)
			
		)
		echo %\e%[2J!spiral!%\e%[m
		set "spiral="
	)
)
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



:init
rem Empty environment, but keep some essentials
for /f "tokens=1 delims==" %%a in ('set') do (
	set "pre=true"
	for %%b in (cd Path ComSpec SystemRoot temp windir) do (
		if /i "%%a" equ "%%b" set "pre="
	)
	if defined pre set "%%~a="
)
set "pre="

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%

set /a "wid=600, hei=400"
set /a "center_x=wid / 2"
set /a "center_y=hei / 2"
mode %wid%,%hei%

set "HSL(n)=k=(n*100+(h %% 3600)/3) %% 1200, u=k-300, q=900-k, u=q-((q-u)&((u-q)>>31)), u=100-((100-u)&((u-100)>>31)), max=u-((u+100)&((u+100)>>31))"
set "@HSL.RGB=(%HSL(n):n=0%", "r=(l-(s*((10000-l)-(((10000-l)-l)&((l-(10000-l))>>31)))/10000)*max/100)*255/10000","%HSL(n):n=8%", "g=(l-(s*((10000-l)-(((10000-l)-l)&((l-(10000-l))>>31)))/10000)*max/100)*255/10000", "%HSL(n):n=4%", "b=(l-(s*((10000-l)-(((10000-l)-l)&((l-(10000-l))>>31)))/10000)*max/100)*255/10000)"
set "hsl(n)="

set /a "PI=31416, TAU=2*PI"
	
set "radians=x * pi / 180"

set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "sin=(a=(        x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%) / 100"
set "cos=(a=(15708 - x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"

set /a "heartSize=10", "heartHei=13", "heartWid=16", "step=%radians:x=2%"

for /l %%a in (0,%step%,%tau%) do (
	set /a "gotPow=1", "normalize=1" & for /l %%b in (1,1,3) do set /a "gotPow*=!sin:x=%%a!", "normalize*=100"
	set /a "x=( heartSize * heartWid * gotPow / normalize)"
	set /a "y=(-heartSize * (heartHei * !cos:x=%%a! - 5 * !cos:x=2*%%a! - 2 * !cos:x=3*%%a! - !cos:x=4*%%a!) / 10000)"
	set /a "h=(10000*%%a/tau) %% 3600, s=10000, l=5000, %@hsl.rgb%"
	set "pre=!pre!"!r!;!g!;!b! !x! !y! 0" "
)

set "sin=(a=(        x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_sin="

rem set /a "radx=, rady=, radz=, %@3Dangles%"
set "@3Dangles=( cx=^!cos:x=radx^!, sx=^!sin:x=radx^!, cy=^!cos:x=rady^!, sy=^!sin:x=rady^!, cz=^!cos:x=radz^!, sz=^!sin:x=radz^!)

set "@ortho=(rx=(x*cx+z*sx)/10000,rz=(x*-sx+z*cx)/10000,ry=(y*cy+rz*-sy)/10000,$x=(rx*cz+ry*-sz)/10000,$y=(rx*sz+ry*cz)/10000)"



goto :eof
