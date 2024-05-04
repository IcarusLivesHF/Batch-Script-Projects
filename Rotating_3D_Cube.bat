@echo off & setlocal enableDelayedExpansion

for /f "tokens=1 delims==" %%a in ('set') do (
	set "unload=true"
	for %%b in ( cd Path ComSpec SystemRoot temp windir ) do if /i "%%a"=="%%b" set "unload=false"
	if "!unload!"=="true" set "%%a="
)

call :macro

set "points=-1" & for %%i in ( "-1 -1 -1" " 1 -1 -1" " 1  1 -1" "-1  1 -1" "-1 -1  1" " 1 -1  1" " 1  1  1" "-1  1  1") do (
	set /a "points+=1"
	for /f "tokens=1-3" %%x in ("%%~i") do (
		set /a "x[!points!]=%%~x, y[!points!]=%%~y, z[!points!]=%%~z"
	)
)

set /a "boxSize=15", "rotationSpeed=10", "wid=hei=90"
mode %wid%,%hei%

for /l %%# in () do (
	
	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do (
		set /a "t1=((((1%%a-1000)*60+(1%%b-1000))*60+(1%%c-1000))*100)+(1%%d-1000)"
	)
	if defined t2 set /a "deltaTime=(t1 - t2)","$TT+=deltaTime","timer100cs+=deltaTime","$sec=$TT / 100 %% 60","$min=$TT / 100 / 60 %% 60"
	set /a "t2=t1", "global.frameCount=(global.frameCount + 1) %% 0x7FFFFFFF", "fpsFrames+=1"

	if !timer100cs! GEQ 100 (
		set /a "timer100cs-=100,fps=fpsFrames,fpsFrames=0"
		if !timer100cs! GEQ 100 set /a timer100cs=0
	)
	if "!$sec:~1!" equ "" set "$sec=0!$sec!"
	
	title Time: !$min!:!$sec! FPS:!fps! deltaTime:!deltaTime!
	
	set /a "angle+=rotationSpeed"
	
	for /l %%i in (0,1,7) do ( set /a ^
		       "px[%%i]=0", "py[%%i]=0",^
		       "x=x[%%i] * boxSize, y=y[%%i] * boxSize, z=z[%%i] * boxSize",^
		       "%rotY%", "x=ryx, y=ryy, z=ryz",^
		       "%rotX%", "x=rxx, y=rxy, z=rxz",^
		       "%rotZ%", "%projection:?=Z%",^
		       "px+=wid/2", "py+=hei/2",^
		       "px[%%i]+=px", "py[%%i]+=py"
	)

	for /l %%i in (0,1,3) do (
		set /a "i1=%%i", "i2=(%%i + 1) %% 4", "j=i1 + 1"
		for /f "tokens=1,2" %%1 in ("!i1! !i2!") do %line% !px[%%1]! !py[%%1]! !px[%%2]! !py[%%2]! !j!
		set "box=!box!!$line!"
		
		set /a "i1=%%i+4", "i2=((%%i + 1) %% 4) + 4", "j+=5"
		for /f "tokens=1,2" %%1 in ("!i1! !i2!") do %line% !px[%%1]! !py[%%1]! !px[%%2]! !py[%%2]! !j!
		set "box=!box!!$line!"
		
		set /a "i1=%%i", "i2=%%i + 4", "j+=5"
		for /f "tokens=1,2" %%1 in ("!i1! !i2!") do %line% !px[%%1]! !py[%%1]! !px[%%2]! !py[%%2]! !j!
		set "box=!box!!$line!"
	)

	echo %esc%[2J!box!
	set "box="
)

:macro

set "sin=(a=((x*31416/180)%%62832)+(((x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) / 10000"
set "cos=(a=((15708-x*31416/180)%%62832)+(((15708-x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) / 10000"
set "rotZ=  rZx=x*^!cos:x=angle^! + y*-^!sin:x=angle^! + z*0,     rZy=x*^!sin:x=angle^! + y*^!cos:x=angle^! + z*0,     rZz=x*0 + y*0 + z*1"
set "rotX=  rXx=x*1 + y*0 + z*0,     rXy=x*0 + y*^!cos:x=angle^! + z*-^!sin:x=angle^!,     rXz=x*0 + y*^!sin:x=angle^! + z*^!cos:x=angle^!"
set "rotY=  rYx=x*^!cos:x=angle^! + y*0 + z*^!sin:x=angle^!,     rYy=x*0 + y*1 + z*0,     rYz=x*-^!sin:x=angle^! + y*0 + z*^!cos:x=angle^!"
set "projection=  px=r?x*1 + r?y*0 + r?z*0,     py=r?x*0 + r?y*1 + r?z*0"

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)

for /f %%a in ('echo prompt $E^| cmd') do set "esc=%%a"
<nul set /p "=%esc%[?25l"

set line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	if "%%~5" equ "" ( set "hue=15" ) else ( set "hue=%%~5")%\n%
	set "$line=%esc%[48;5;^!hue^!m"%\n%
	set /a "xa=%%~1", "ya=%%~2", "xb=%%~3", "yb=%%~4", "dx=%%~3 - %%~1", "dy=%%~4 - %%~2"%\n%
	if ^^!dy^^! lss 0 ( set /a "dy=-dy", "stepy=-1" ) else ( set "stepy=1" )%\n%
	if ^^!dx^^! lss 0 ( set /a "dx=-dx", "stepx=-1" ) else ( set "stepx=1" )%\n%
	set /a "dx<<=1", "dy<<=1"%\n%
	if ^^!dx^^! gtr ^^!dy^^! (%\n%
		set /a "fraction=dy - (dx >> 1)"%\n%
		for /l %%x in (^^!xa^^!,^^!stepx^^!,^^!xb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "ya+=stepy", "fraction-=dx"%\n%
			set /a "fraction+=dy"%\n%
			set "$line=^!$line^!%esc%[^!ya^!;%%xH "%\n%
		)%\n%
	) else (%\n%
		set /a "fraction=dx - (dy >> 1)"%\n%
		for /l %%y in (^^!ya^^!,^^!stepy^^!,^^!yb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "xa+=stepx", "fraction-=dy"%\n%
			set /a "fraction+=dx"%\n%
			set "$line=^!$line^!%esc%[%%y;^!xa^!H "%\n%
		)%\n%
	)%\n%
	set "$line=^!$line^!%esc%[0m"%\n%
)) else set args=
goto :eof
