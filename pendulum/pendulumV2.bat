@echo off & setlocal enableDelayedExpansion

call :init

set /a "angle=pi / 4",^
       "angleA=0, angleV=0",^
	   "gravity=16",^
	   "mass=4",^
	   "origin.x=wid / 2",^
	   "origin.y=0",^
	   "length=75",^
	   "inc=PI / (mass * 2)"
	   
call :drawSphere 8 4 3 0 40 -100
set "sphere=%\e%[3A%\e%[5D!sphere!"

for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=((((10%%a-1000)*60+(10%%b-1000))*60+(10%%c-1000))*100)+(10%%d-1000)"

for /l %%# in () do (
	
	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=((((10%%a-1000)*60+(10%%b-1000))*60+(10%%c-1000))*100)+(10%%d-1000)"
	set /a "dt=t2 - t1"
	
	REM if !dt! gtr 1 (
		set /a "t1=t2"

		set /a "angleA=100 * (-1 * gravity * mass * !sin:x=angle!) / length",^
			   "angleV+=angleA",^
			   "angle+=angleV",^
			   "bob.x=length * !sin:x=angle! + origin.x",^
			   "bob.y=length * !cos:x=angle! + origin.y",^
			   "angleV=angleV * 99900 / 100000"
		
		%@aaline% !origin.x! !origin.y! !bob.x! !bob.y!
		set "scrn=!scrn!!$aaline!%\e%[48;5;15m%\e%[!bob.y!;!bob.x!H!sphere!"
		
		echo=%\e%[2J%\e%[H!scrn!%\e%[0m
		set "scrn="
	REM )
)

:init
set /a "wid=width=120", "hei=height=100 - 1"
mode %wid%,%hei%

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%

set /a "PI=(35500000/113+5)/10, HALF_PI=(35500000/113/2+5)/10, TAU=TWO_PI=2*PI, PI32=PI+HALF_PI"
set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "sin=(a=(x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!) / 10000"
set "cos=(a=(15708 - x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!) / 10000"

rem get \n
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)

:_line
rem line x0 y0 x1 y1 color
set @line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	if "%%~5" equ "" ( set "hue=15" ) else ( set "hue=%%~5")%\n%
	set "$line=%\e%[48;5;^!hue^!m"%\n%
	set /a "xa=%%~1", "ya=%%~2", "xb=%%~3", "yb=%%~4", "dx=%%~3 - %%~1", "dy=%%~4 - %%~2"%\n%
	if ^^!dy^^! lss 0 ( set /a "dy=-dy", "stepy=-1" ) else ( set "stepy=1" )%\n%
	if ^^!dx^^! lss 0 ( set /a "dx=-dx", "stepx=-1" ) else ( set "stepx=1" )%\n%
	set /a "dx<<=1", "dy<<=1"%\n%
	if ^^!dx^^! gtr ^^!dy^^! (%\n%
		set /a "fraction=dy - (dx >> 1)"%\n%
		for /l %%x in (^^!xa^^!,^^!stepx^^!,^^!xb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "ya+=stepy", "fraction-=dx"%\n%
			set /a "fraction+=dy"%\n%
			set "$line=^!$line^!%\e%[^!ya^!;%%xH "%\n%
		)%\n%
	) else (%\n%
		set /a "fraction=dx - (dy >> 1)"%\n%
		for /l %%y in (^^!ya^^!,^^!stepy^^!,^^!yb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "xa+=stepx", "fraction-=dy"%\n%
			set /a "fraction+=dx"%\n%
			set "$line=^!$line^!%\e%[%%y;^!xa^!H "%\n%
		)%\n%
	)%\n%
	set "$line=^!$line^!%\e%[0m"%\n%
)) else set args=

set @AAline=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set "$AAline="%\n%
	set /a "$dx=(((%%~3-%%~1)>>31|1)*(%%~3-%%~1))","$dy=(((%%~4-%%~2)>>31|1)*(%%~4-%%~2))", "$x0=%%~1,$y0=%%~2,$x1=%%~3,$y1=%%~4", "$err=$dx-$dy", "dxdy=$dx+$dy","dist=$dx"%\n%
	if ^^!$dx^^! lss ^^!$dy^^! ( set /a "dist=$dy" )%\n%
	if %%~1 lss %%~3 ( set $sx=1 ) else ( set $sx=-1 )%\n%
	if %%~2 lss %%~4 ( set $sy=1 ) else ( set $sy=-1 )%\n%
	if ^^!dxdy^^! equ 0 ( set $ed=1 ) else ( set /a "$ed=dist" )%\n%
	for /l %%i in (1,1,^^!dist^^!) do (%\n%
		set /a "$shade=255 - (255 * ((($err-$dx+$dy)>>31|1)*($err-$dx+$dy)) / $ed)", "e2=$err, x2=$x0", "$2e2=2 * e2", "color=232 + (255 - 232) * $shade / 255"%\n%
		set "$AAline=^!$AAline^!%\e%[48;5;^!color^!m%\e%[^!$y0^!;^!$x0^!H "%\n%
		if ^^!$2e2^^! geq -^^!$dx^^! (%\n%
			set /a "e2dy=e2 + $dy"%\n%
			if ^^!e2dy^^! lss ^^!$ed^^! if ^^!$x0^^! neq ^^!$x1^^! (%\n%
				set /a "$shade=255 - (255 * (((e2+$dy)>>31|1)*(e2+$dy)) / $ed)", "$y0sy=$y0 + $sy", "color=232 + (255 - 232) * $shade / 255"%\n%
				set "$AAline=^!$AAline^!%\e%[48;5;^!color^!m%\e%[^!$y0sy^!;^!$x0^!H "%\n%
			)%\n%
			set /a "$err-=$dy, $x0+=$sx"%\n%
		)%\n%
		if ^^!$2e2^^! leq ^^!$dy^^! if ^^!$y0^^! neq ^^!$y1^^! (%\n%
			set /a "dxe2=$dx - e2"%\n%
			if ^^!dxe2^^! lss ^^!$ed^^! (%\n%
				set /a "$shade=255 - (255 * ((($dx-e2)>>31|1)*($dx-e2)) / $ed)", "x2sx=x2 + $sx", "color=232 + (255 - 232) * $shade / 255"%\n%
				set "$AAline=^!$AAline^!%\e%[48;5;^!color^!m%\e%[^!$y0^!;^!x2sx^!H "%\n%
			)%\n%
			set /a "$err+=$dx, $y0+=$sy"%\n%
		)%\n%
	)%\n%
	set "$AAline=^!$AAline^!%\e%[0m"%\n%
)) else set args=
goto :eof

:drawSphere r(MAX=18) k ambient light0 light1 light2
set "sqrt(N)=( M=(N),j=M/(11264)+40, j=(M/j+j)>>1, j=(M/j+j)>>1, j=(M/j+j)>>1, j=(M/j+j)>>1, j=(M/j+j)>>1, j+=(M-j*j)>>31 )"

set /a "R=%1", "twiceR=R*2", "sqrdR=R*R*100*100", "k=%3", "ambient=%2","r1=%1+1"
set "emptyCell="
set "sphere="
for /l %%j in (-%R%, 1, %R%) do (
	set /a "y=100*%%j"
	set "sphere=!sphere!%\e%7"
	for /l %%i in (-%twiceR%, 1, %twiceR%) do (
		set /a "x=100*%%i",  "pythag= x*x + y*y"
		if !pythag! lss !sqrdR! (
			set /a "vec[0]=x","vec[1]=y","vec[2]=%sqrt(N):N=(sqrdR-pythag)%"
			set /a "$len=%sqrt(N):N=(vec[0]*vec[0]+vec[1]*vec[1]+vec[2]*vec[2])%",^
			       "vec[0]*=100", "vec[1]*=100", "vec[2]*=100",^
				   "vec[0]/=$len", "vec[1]/=$len", "vec[2]/=$len"
			set /a "d=%~4*vec[0]+%~5*vec[1]+%6*vec[2]",^
				   "dot_out=((((((d-0)>>31)&1)*-d)|((~(((d-0)>>31)&1)&1)*0))) / 100"

			set "b=1"
			if !k! leq 4 (
				if !k! equ 1 (
					set /a b=dot_out
				) else (
					for /l %%? in (1,1,!k!) do set /a "b*=dot_out"
					set /A "d=(k-1)*2"
					for %%D in (!d!) do set b=!b:~0,-%%D!
				)
			 ) else (
				for /l %%? in (1,1,4) do set /a "b*=dot_out"
				set /A "b=b/100*dot_out, d=(k-1)*2-2"
				if !k! geq 6 for /l %%? in (6,1,!k!) do set /A b=b/100*dot_out, d=d-2
				for %%D in (!d!) do set b=!b:~0,-%%D!
			 )
			
			%= invert color, clamp, and then map value to 232-255 for shortest bytes possible =%
			set /a "intensity=(255 - ( (leq=((0-((100-b)*255 / 100))>>31)+1)*0  +  (geq=((((100-b)*255 / 100)-255)>>31)+1)*255  +  ^!(leq+geq)*((100-b)*255 / 100) )) ",^
			       "intensity=232 + (255 - 232) * (intensity - 0) / (255 - 0)"
			
			if defined eC set /a "eC-=r1" & set "sphere=!sphere!%\e%[!eC!C"
			set "eC="
			if !intensity! equ !lastIntensity! (
				set "sphere=!sphere! "
			) else (
				set "sphere=!sphere!%\e%[48;5;!intensity!m "
			)
			set /a "lastIntensity=intensity"
			set "emptyCell="
		) else (
			if not defined emptyCell (
				set "sphere=!sphere!%\e%[0m"
				set "emptyCell=true"
				set /a "eC+=1"
			) else (
				if %%i lss 0 set /a "eC+=1"
			)
		)
	)
	set "sphere=!sphere!%\e%8%\e%[B"
	set "eC="
)
set "sphere=!sphere:~11!%\e%[0m"
set "sphere=!sphere:%\e%[0C=!"
set "emptyCell="
goto :EOF