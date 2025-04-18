@echo off & setlocal enableDelayedExpansion

call :Set_Font "mxplus ibm ega 8x8" 1 nomax %1 || exit

call :init 400 400

set "n=2"
set "d=39"
set "rr=250"

(
	for /l %%i in (1,1,360) do (
		
		if defined px (
			set /a "lx=px"
			set /a "ly=py"
		)
		set /a "k=%%i * d"
		set /a "r=rr * !sin:x=n*k!/10000"
		set /a "px=r * !cos:x=k!/10000 + center_x"
		set /a "py=r * !sin:x=k!/10000 + center_y"
		
		set /a "t=rr * !sin:x=n*%%i!/10000"
		set /a "tx=t * !cos:x=%%i!/10000 + center_x"
		set /a "ty=t * !sin:x=%%i!/10000 + center_y"
		
		set /a "h=%%i * 10, s=10000, l=5000, %@hsl.rgb%"
		
		%@line% !px! !py! !lx! !ly!
		<nul set /p "=%\e%[48;2;!r!;!g!;!b!m!$line!%\e%[48;5;21m%\e%[!ty!;!tx!H %\e%[m"
	)

)
pause>nul
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

set /a "wid=%1, hei=%2"
set /a "center_x=wid / 2"
set /a "center_y=hei / 2"
mode %wid%,%hei%

set "sin=(a=((x*31416/180)%%62832)+(((x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) "
set "cos=(a=((15708-x*31416/180)%%62832)+(((15708-x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) "
	


rem %@line% x0 y0 x1 y1 color <rtn> $line
set @line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set "$line="%\n%
	set /a "$xa=%%~1", "$ya=%%~2", "$xb=%%~3", "$yb=%%~4", "$dx=%%~3 - %%~1", "$dy=%%~4 - %%~2", "$sx=$sy=1"%\n%
	if ^^!$dy^^! lss 0 set /a "$dy=-$dy", "$sy=-1"%\n%
	if ^^!$dx^^! lss 0 set /a "$dx=-$dx", "$sx=-1"%\n%
	set /a "$dx<<=1", "$dy<<=1"%\n%
	if ^^!$dx^^! gtr ^^!$dy^^! (%\n%
		set /a "$e=$dy - ($dx >> 1)"%\n%
		for /l %%x in (^^!$xa^^!,^^!$sx^^!,^^!$xb^^!) do (%\n%
			if ^^!$e^^! geq 0 set /a "$ya+=$sy", "$e-=$dx"%\n%
			set /a "$e+=$dy"%\n%
			if %%x gtr 0 if %%x lss %wid% if ^^!$ya^^! gtr 0 if ^^!$ya^^! lss %hei% set "$line=^!$line^!%\e%[^!$ya^!;%%xH "%\n%
		)%\n%
	) else (%\n%
		set /a "$e=$dx - ($dy >> 1)"%\n%
		for /l %%y in (^^!$ya^^!,^^!$sy^^!,^^!$yb^^!) do (%\n%
			if ^^!$e^^! geq 0 set /a "$xa+=$sx", "$e-=$dy"%\n%
			set /a "$e+=$dx"%\n%
			if ^^!$xa^^! gtr 0 if ^^!$xa^^! lss %wid% if %%y gtr 0 if %%y lss %hei% set "$line=^!$line^!%\e%[%%y;^!$xa^!H "%\n%
		)%\n%
	)%\n%
	set "$line=^!$line^!%\e%[0m"%\n%
)) else set args=


rem set /a "h=0-3600, s=0-10000, l=0-10000, %@hsl.rgb%" <rtn> !r! !g! !b!
set "HSL(n)=k=(n*100+(h %% 3600)/3) %% 1200, u=k-300, q=900-k, u=q-((q-u)&((u-q)>>31)), u=100-((100-u)&((u-100)>>31)), max=u-((u+100)&((u+100)>>31))"
set "@HSL.RGB=(%HSL(n):n=0%", "r=(l-(s*((10000-l)-(((10000-l)-l)&((l-(10000-l))>>31)))/10000)*max/100)*255/10000","%HSL(n):n=8%", "g=(l-(s*((10000-l)-(((10000-l)-l)&((l-(10000-l))>>31)))/10000)*max/100)*255/10000", "%HSL(n):n=4%", "b=(l-(s*((10000-l)-(((10000-l)-l)&((l-(10000-l))>>31)))/10000)*max/100)*255/10000)"
set "hsl(n)="
goto :eof
