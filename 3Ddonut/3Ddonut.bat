@echo off & setlocal enableDelayedExpansion

rem Empty environment, but keep some essentials
for /f "tokens=1 delims==" %%a in ('set') do (
	set "pre=true"
	for %%b in (cd Path ComSpec SystemRoot temp windir) do (
		if /i "%%a" equ "%%b" set "pre="
	)
	if defined pre set "%%~a="
)
set "pre="

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%
echo %\e%[2J%\e%[H%\e%[?25l

set /a "wid=100"
set /a "hei=100"
mode %wid%,%hei%

set /a "PI=31416, HALF_PI=PI / 2, TAU=TWO_PI=2*PI, PI32=PI+HALF_PI, QUARTER_PI=PI / 4"
set "radians=x * pi / 180"
set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "sin=(a=(        x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!)"
set "cos=(a=(15708 - x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!)"
set "_sin="








set "r0=300"
set "r1=180"
set /a "ax=wid / 2"
set /a "ay=hei / 2"

set /a "step=%radians:x=40%"
set /a "step2=%radians:x=15%"
for /l %%p in (0,%step2%,%tau%) do set /a "ct=!cos:x=%%p!", "st=!sin:x=%%p!" & set "pre_a=!pre_a!"!ct! !st!" "
for /l %%i in (0,%step%,%tau%)  do set /a "ct=!cos:x=%%i!", "st=!sin:x=%%i!" & set "pre_b=!pre_b!"!ct! !st!" "

set "map=O."




                               for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=((((10%%a-1000)*60+(10%%b-1000))*60+(10%%c-1000))*100)+(10%%d-1000)"
for /l %%# in (1,1,10000) do ( for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=((((10%%a-1000)*60+(10%%b-1000))*60+(10%%c-1000))*100)+(10%%d-1000), dt=t2 - t1"
    
    set /a "radx=dt * 90", "rady=dt * 90", "radz=dt * 30",^
           "crx=!cos:x=radx!", "srx=!sin:x=radx!",^
           "cry=!cos:x=rady!", "sry=!sin:x=rady!",^
           "crz=!cos:x=radz!", "srz=!sin:x=radz!"
    
    set "$donut="
    
    for %%P in (%pre_a%) do for /f "tokens=1,2" %%p in ("%%~P") do (
	for %%P in (%pre_b%) do for /f "tokens=1,2" %%a in ("%%~P") do (
	
		set /a "lr= r0 + (r1 * %%a)/10000",^
			   "bx=(lr * %%p)/10000",^
			   "by=(lr * %%q)/10000",^
			   "bz=(r1 * %%b)/10000",^
			   "ny=(by * crx - bz * srx)/10000", "nz=( by * srx + bz * crx)/10000",^
			   "nx=(bx * cry + nz * sry)/10000", "nz=(-bx * sry + nz * cry)/10000",^
			   "df=10000 / (1000 - nz)",^
			   "cx=((nx * crz - ny * srz)/10000) * df / 100 + ax",^
			   "cy=((nx * srz + ny * crz)/10000) * df / 100 + ay",^
			   "$map=(-nz>>31)&1"
			   
		if !nz! gtr 0 ( set "char=O" ) else ( set "char=." )
		for %%m in (!$map!) do (
			set "$donut=!$donut!%\e%[!cy!;!cx!H!char!"
		)
    ))
    
    echo=%\e%[2J%\e%[H!$donut!
    set "$donut="
)
