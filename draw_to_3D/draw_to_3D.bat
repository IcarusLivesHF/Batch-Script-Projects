@echo off & setlocal enableDelayedExpansion

if "%~1" neq "" goto :%~1

call :init
call lib\radish


( %radish% "%~nx0" radish_wait ) & exit
:radish_wait
( %while% if exist "radish_ready" %endwhile% ) & del /f /q "radish_ready"


title Press ENTER or ESC to watch your drawing animate
set "Z_level=0"
:draw_mode
	rem @radish <no arguments> <rtn> !mouseX! !mouseY! !L_click! !R_click! !B_click! !scrollUp! !scrollDown! !keysPressed!
	%@radish%
	
	set "show=0"
	if not defined draw set /a "show+=1"
	if "!draw!" neq "0" set /a "show+=1"
	if !show! neq 0 <nul set /p "=%ZBUTTONS%%\e%[3;20H!Z_level!%\e%[!mouseY!;!mouseX!H@"
	
	if !L_click! equ 1 (
		set "draw=1"
		if not defined [!mouseX!][!mouseY!] (
			set "pre=!pre!"!mouseX! !mouseY! !Z_level!" "
			set "[!mouseX!][!mouseY!]=1"
		)
	) else set "draw=0"
	
	

	set /a "a=1, b=1, c=18, d=5,  $ZI=((~(mouseY-b)>>31)&1) & ((~(d-mouseY)>>31)&1) & ((~(mouseX-a)>>31)&1) & ((~(c-mouseX)>>31)&1) & L_click",^
	       "     b=6,       d=11, $ZJ=((~(mouseY-b)>>31)&1) & ((~(d-mouseY)>>31)&1) & ((~(mouseX-a)>>31)&1) & ((~(c-mouseX)>>31)&1) & L_click"
	if "!$ZI!" equ "1" if !Z_level! lss %wid% set /a "Z_level+=1"
	if "!$ZJ!" equ "1" if !Z_level! gtr 0     set /a "Z_level-=1"
	
	
	
	
	rem ENTER or ESC to watch animation
	%asyncKeys:?=13% goto :exitDraw_mode
	%asyncKeys:?=27% goto :exitDraw_mode

goto :draw_mode
:exitDraw_mode
for /f "tokens=1 delims==" %%i in ('set [') do set "%%~i="





set /a "step=%radians:x=5%"
(
	for /l %%z in (1,1,10000) do (
		set /a "radx+=step, rady+=step, radz+=step",^
		       "%@rotateX%, %@rotateY%, %@rotateZ%"
			   
		for %%p in (%pre%)  do (
			for /f "tokens=1-3" %%x in ("%%~p") do (
				set /a "x=%%x-center_x, y=%%y-center_y, z=%%z, %@ortho%, $x+=center_x, $y+=center_y"
			)
			set "draw=!draw!%\e%[!$y!;!$x!H "
		)
		echo %\e%[2J%\e%[48;5;15m!draw!%\e%[m
		set "draw="
	)
)
exit











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




rem create characters \n and \e
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%

( for /l %%i in (0,1,80) do set "$s=!$s!!$s!  " ) & set "$q=!$s: =q!"



set /a "wid=width=100", "hei=height=100"
set /a "center_x=wid / 2"
set /a "center_y=hei / 2"
mode %wid%,%hei%





set "while=for /l %%i in (1 1 16)do if defined do.while"
set "while=set do.while=1&!while! !while! !while! !while! !while! "
set "endWhile=set "do.while=""




set @rect=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-2" %%1 in ("^!args^!") do (%\n%
	set /a "$w=%%~1-2", "$h=%%~2-2"%\n%
	for /f "tokens=1,2" %%A in ("^!$w^! ^!$h^!") do (%\n%
		set "$rect=^!$q:~0,%%~B^!"%\n%
		set "$rect=%\e%(0%\e%7l^!$q:~0,%%~A^!k%\e%8%\e%[B^!$rect:q=%\e%7x%\e%[%%~ACx%\e%8%\e%[B^!m^!$q:~0,%%~A^!j%\e%(B%\e%[0m"%\n%
	)%\n%
	set "$w=" ^& set "$h="%\n%
)) else set args=



set /a "PI=31416, TAU=2*PI"
set "radians=x * pi / 180"
set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "sin=(a=(        x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "cos=(a=(15708 - x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), %_SIN%)"
set "_sin="

rem set /a "radx=, %@rotateX%"
set "@rotateX=( cx=^!cos:x=radx^!, sx=^!sin:x=radx^! )"
rem set /a "rady=, %@rotateY%"
set "@rotateY=( cy=^!cos:x=rady^!, sy=^!sin:x=rady^! )"
rem set /a "radz=, %@rotateZ%"
set "@rotateZ=( cz=^!cos:x=radz^!, sz=^!sin:x=radz^! )"

set "@ortho=(rx=(x*cx+z*sx)/10000,rz=(x*-sx+z*cx)/10000,ry=(y*cy+rz*-sy)/10000,$x=(rx*cz+ry*-sz)/10000,$y=(rx*sz+ry*cz)/10000)"




%@rect% 18 5
set "buttonFrame=%$rect%"
set "ZBUTTONS=%\e%[1;1H%buttonFrame%%\e%[3;2HIncrease Z Level%\e%[6;1H%buttonFrame%%\e%[8;2HDecrease Z Level"
set "@rect="
goto :eof