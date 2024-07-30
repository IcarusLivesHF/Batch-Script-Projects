@echo off & setlocal enableDelayedExpansion

set /a "wid=100,hei=70"
mode %wid%,%hei%

call :macros

set /a top.x=wid / 2, top.y=20, pyramid.hei=33, pyramid.wid=19
for /l %%i in (0,1,3) do set /a "angle=90 * %%i",^
								"cx[%%i]=pyramid.wid * !cos:x=angle!/10000 + top.x",^
								"cy[%%i]=(pyramid.wid / 2 - pyramid.wid / 4) * !sin:x=angle!/10000 + top.y + pyramid.hei"

for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=((((10%%a-1000)*60+(10%%b-1000))*60+(10%%c-1000))*100)+(10%%d-1000)"
for /l %%# in (1,1,1000) do (

	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, dt=t2-t1"
	
	title %%#
	if !dt! gtr 5 (
		
		set /a "t1=t2","frames+=6"
	
		for /l %%i in (0,1,3) do ( set /a "angle=(90 * %%i + frames)",^
										  "cx[%%i]=pyramid.wid * !cos:x=angle!/10000 + top.x",^
										  "cy[%%i]=(pyramid.wid / 2 - pyramid.wid / 4) * !sin:x=angle!/10000 + top.y + pyramid.hei",^
										  "next=(%%i + 1) %% 4"
										  
			%@aaline% !top.x! !top.y! !cx[%%i]! !cy[%%i]!
			set "scrn=!scrn!%\e%[!cy[%%i]!;!cx[%%i]!H!$aaline!"
			
			for %%n in (!next!) do %@aaline% !cx[%%i]! !cy[%%i]! !cx[%%n]! !cy[%%n]!
			set "scrn=!scrn!%\e%[!cy[%%i]!;!cx[%%i]!H!$aaline!"
		)
		
		echo=%\e%[2J%\e%[H!scrn!
		set "scrn="
	)
)
rem ------------------------------------------------------------------------------------------------------------------------------------
:macros
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set "sin=(a=((x*31416/180)%%62832)+(((x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000)"
set "cos=(a=((15708-x*31416/180)%%62832)+(((15708-x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000)"

rem %@AAline% x0 x1 y0 y1 <rtn> !$AAline!
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
