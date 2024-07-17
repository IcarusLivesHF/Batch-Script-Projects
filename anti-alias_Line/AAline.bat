@echo off & setlocal enableDelayedExpansion
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"
chcp 65001>nul

set /a "wid=80,hei=50"
mode %wid%,%hei%
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)

set "sqrt=( M=(N),j=M/(11264)+40, j=(M/j+j)>>1, j=(M/j+j)>>1, j=(M/j+j)>>1, j=(M/j+j)>>1, j=(M/j+j)>>1, j+=(M-j*j)>>31 )"

rem %@AAline% x0 x1 y0 y1 <rtn> !$AAline!
set @AAline=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set "$AAline="%\n%
	set /a "$dx=(((%%~3-%%~1)>>31|1)*(%%~3-%%~1))","$dy=(((%%~4-%%~2)>>31|1)*(%%~4-%%~2))","$x0=%%~1,$y0=%%~2,$x1=%%~3,$y1=%%~4"%\n%
	set /a "$err=$dx-$dy", "dxdy=$dx+$dy","dist=^!sqrt:n=(%%~3-%%~1)*(%%~3-%%~1) + (%%~4-%%~2)*(%%~4-%%~2)^!"%\n%
	if %%~1 lss %%~3 ( set $sx=1 ) else ( set $sx=-1 )%\n%
	if %%~2 lss %%~4 ( set $sy=1 ) else ( set $sy=-1 )%\n%
	if ^^!dxdy^^! equ 0 ( set $ed=1 ) else ( set /a "$ed=dist" )%\n%
	for /l %%i in (1,1,^^!dist^^!) do (%\n%
		set /a "$shade=255 - (255 * ((($err-$dx+$dy)>>31|1)*($err-$dx+$dy)) / $ed^)", "e2=$err, x2=^!$x0^!", "$2e2=2 * e2"%\n%
		set "$AAline=^!$AAline^!%\e%[48;2;^!$shade^!;^!$shade^!;^!$shade^!m%\e%[^!$y0^!;^!$x0^!H "%\n%
		if ^^!$2e2^^! geq -^^!$dx^^! (%\n%
			set /a "e2dy=e2 + $dy"%\n%
			if ^^!e2dy^^! lss ^^!$ed^^! if ^^!$x0^^! neq ^^!$x1^^! (%\n%
				set /a "$shade=255 - (255 * (((e2+$dy)>>31|1)*(e2+$dy)) / $ed)", "$y0sy=$y0 + $sy"%\n%
				set "$AAline=^!$AAline^!%\e%[48;2;^!$shade^!;^!$shade^!;^!$shade^!m%\e%[^!$y0sy^!;^!$x0^!H "%\n%
			)%\n%
			set /a "$err-=$dy, $x0+=$sx"%\n%
		)%\n%
		if ^^!$2e2^^! leq ^^!$dy^^! if ^^!$y0^^! neq ^^!$y1^^! (%\n%
			set /a "dxe2=$dx - e2"%\n%
			if ^^!dxe2^^! lss ^^!$ed^^! (%\n%
				set /a "$shade=255 - (255 * ((($dx-e2)>>31|1)*($dx-e2)) / $ed)", "x2sx=x2 + $sx"%\n%
				set "$AAline=^!$AAline^!%\e%[48;2;^!$shade^!;^!$shade^!;^!$shade^!m%\e%[^!$y0^!;^!x2sx^!H "%\n%
			)%\n%
			set /a "$err+=$dx, $y0+=$sy"%\n%
		)%\n%
	)%\n%
	set "$AAline=^!$AAline^!%\e%[0m"%\n%
)) else set args=

set x0=1
set y0=20
set x1=40
set y1=22
set e=3
set f=2
set g=1
set h=3


for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100"

for /l %%# in () do (

	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, dt=t2-t1"

	if !dt! gtr 5 (
		set /a "t1=t2", "x0+=e,y0+=f,x1+=g,y1+=h"
		
		if !x0! leq 1  set /a x0=1, e*=-1
		if !x0! geq 80 set /a x0=80,e*=-1
		if !y0! leq 1  set /a y0=1, f*=-1
		if !y0! geq 50 set /a y0=50,f*=-1
		if !x1! leq 1  set /a x1=1, g*=-1
		if !x1! geq 80 set /a x1=80,g*=-1
		if !y1! leq 1  set /a y1=1, h*=-1
		if !y1! geq 50 set /a y1=50,h*=-1

		%@AAline% !x0! !y0! !x1! !y1!

		echo %\e%[2J!$aaline!
	)
	title !dt!
)
pause
exit