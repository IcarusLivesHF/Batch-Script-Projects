@echo off & setlocal enableDelayedExpansion

if "%~1" neq "" goto :%~1
del /f /q signal.txt

set /a "wid=hei=90"
mode %wid%,%hei%

call :macro

set /a "box.x=wid/2,box.y=hei/2,box.s=15,angle=0"

("%0" Controller >"signal.txt" | "%0" main <"signal.txt") & exit

:main
title T - QUIT
for /l %%# in () do (
	
	if defined key set "lastKey=!key!"
	set "key=" & set /p "key="
	
	       if /i "!key!" == "q" ( set /a "aR+=2"
	) else if /i "!key!" == "a" ( set /a "aR-=2"
	) else if /i "!key!" == "w" ( set /a "bR+=2"
	) else if /i "!key!" == "s" ( set /a "bR-=2"
	) else if /i "!key!" == "e" ( set /a "cR+=2"
	) else if /i "!key!" == "d" ( set /a "cR-=2"
	) else if /i "!key!" == "r" ( set /a "box.s+=1"
	) else if /i "!key!" == "f" ( if !box.s! gtr 3 set /a "box.s-=1"
	) else if /i "!key!" == "t" ( echo=.>"abort.txt" & exit )
	
	set /a "anglex=(anglex + aR) %% 360",^
	       "angley=(angley + bR) %% 360",^
	       "anglez=(anglez + cR) %% 360"
	
	%@box% box.x box.y box.s angleX angleY angleZ
	
	rem echo !$box!
	echo %\e%[2J!$box!%\e%[3;3H[Q,A] Angle X:!anglex!;	aR:!aR!%\e%[4;3H[W,S] Angle Y:!angley!;	bR:!bR!%\e%[5;3H[E,D] Angle Z:!anglez!;	cR:!cR!%\e%[6;3H[R,F] Size: !box.s!
)
exit

:Controller
For /l %%C in () do (
	if exist "abort.txt" (
		del /f /q "abort.txt"
		exit
	)
	for /f "delims=" %%A in ('choice /c:qawsedrft /n') do echo=%%~A
)
exit


:macro
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)

(for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a") & echo=!\e![?25l

set "sin=(a=((x*31416/180)%%62832)+(((x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) "
set "cos=(a=((15708-x*31416/180)%%62832)+(((15708-x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) "


rem %@line% x0 y0 x1 y1 color <rtn> $line
set @line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	if "%%~5" neq "" ( set "$line=%\e%[48;5;%%~5m" ) else set "$line=%\e%[48;5;15m"%\n%
	set /a "$x0=%%~1, $y0=%%~2, $x1=%%~3, $y1=%%~4, dx=(((%%~3-%%~1)>>31|1)*(%%~3-%%~1)), dy=-($dy=(((%%~4-%%~2)>>31|1)*(%%~4-%%~2))), err=dx+dy, dist=dx, sx=sy=-1"%\n%
	if ^^!dx^^! lss ^^!$dy^^! set dist=^^!$dy^^!%\n%
	if ^^!$x0^^! lss ^^!$x1^^! set sx=1%\n%
	if ^^!$y0^^! lss ^^!$y1^^! set sy=1%\n%
	for /l %%i in (0,1,^^!dist^^!) do (%\n%
		set "$line=^!$line^!%\e%[^!$y0^!;^!$x0^!H "%\n%
		set /a "e2=2 * err"%\n%
		if ^^!e2^^! geq ^^!dy^^! set /a "err+=dy, $x0+=sx"%\n%
		if ^^!e2^^! leq ^^!dx^^! set /a "err+=dx, $y0+=sy"%\n%
	)%\n%
	set "$line=^!$line^!%\e%[0m"%\n%
)) else set args=


:_box
rem predefine points of %@box%
set "points=0" & for %%i in ("-1 -1 -1" " 1 -1 -1" " 1  1 -1" "-1  1 -1" "-1 -1  1" " 1 -1  1" " 1  1  1" "-1  1  1") do (
	for /f "tokens=1-3" %%x in ("%%~i") do set /a "x!points!=%%~x, y!points!=%%~y, z!points!=%%~z"
	set /a "points+=1"
)
set "points="
rem in=>x y z ; out=>$a $b
set "boxFormula(x,y,z)=rx= x *  coa/10000 +  z *  sia/10000, rz= x * -sia/10000 +  z *  coa/10000, ry= y *  cob/10000 + rz * -sib/10000, $a=rx *  coc/10000 + ry * -sic/10000, $b=rx *  sic/10000 + ry *  coc/10000"
set @box=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-6" %%A in ("^!args^!") do (%\n%
	set "$box="%\n%
	set /a "coa=^!cos:x=%%~D^!, sia=^!sin:x=%%~D^!, cob=^!cos:x=%%~E^!, sib=^!sin:x=%%~E^!, coc=^!cos:x=%%~F^!, sic=^!sin:x=%%~F^!"%\n%
	for /l %%i in (0,1,7) do set /a "x=x%%i * %%~C, y=y%%i * %%~C, z=z%%i * %%~C", "%boxFormula(x,y,z)%", "px[%%i]=$a + %%~A, py[%%i]=$b + %%~B"%\n%
	for /l %%i in (0,1,3) do ( set /a "i1=%%i, i2=(%%i + 1) %% 4, j1=i1 + 1, i3=%%i+4, i4=((%%i + 1) %% 4) + 4, j2=j1 + 5, i5=%%i + 4, j3=j2 + 5"%\n%
		for /f "tokens=1-6" %%1 in ("^!i1^! ^!i2^! ^!i3^! ^!i4^! ^!i5^!") do (%\n%
			^!@line^! ^^!px[%%1]^^! ^^!py[%%1]^^! ^^!px[%%2]^^! ^^!py[%%2]^^! ^^!j1^^!%\n%
			set "$box=^!$box^!^!$line^!"%\n%
			^!@line^! ^^!px[%%3]^^! ^^!py[%%3]^^! ^^!px[%%4]^^! ^^!py[%%4]^^! ^^!j2^^!%\n%
			set "$box=^!$box^!^!$line^!"%\n%
			^!@line^! ^^!px[%%1]^^! ^^!py[%%1]^^! ^^!px[%%5]^^! ^^!py[%%5]^^! ^^!j3^^!%\n%
			set "$box=^!$box^!^!$line^!"%\n%
		)%\n%
	)%\n%
)) else set args=
set "boxFormula(x,y,z)="
goto :eof