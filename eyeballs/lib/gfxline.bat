set "lineMODE=1"
if /i "%~1" equ "DDA"       set /a "lineMODE+=1"
if /i "%~1" equ "Bresenham" set /a "lineMODE-=2"

REM USAGE IS %@LINE%

if !lineMODE! gtr 0 ( goto :_line.dda ) else ( goto :_line.Bresenham )

:_line.DDA
rem %@line% x0 y0 x1 y1 color <rtn> $line
set @line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	if "%%~5" neq "" ( set "$line=%\e%[48;5;%%~5m" ) else set "$line=%\e%[48;5;15m"%\n%
	set /a "$x0=%%~1,$y0=%%~2,$x1=%%~3,$y1=%%~4, dx=(((%%~3-%%~1)>>31|1)*(%%~3-%%~1)), dy=-($dy=(((%%~4-%%~2)>>31|1)*(%%~4-%%~2))), err=dx+dy, dist=dx, sx=-1, sy=-1"%\n%
	if ^^!dx^^! lss ^^!$dy^^! ( set dist=^^!$dy^^! )%\n%
	if ^^!$x0^^! lss ^^!$x1^^! ( set sx=1 )%\n%
	if ^^!$y0^^! lss ^^!$y1^^! ( set sy=1 )%\n%
	for /l %%i in (0,1,^^!dist^^!) do (%\n%
		set "$line=^!$line^!%\e%[^!$y0^!;^!$x0^!H "%\n%
		set /a "e2=err<<1"%\n%
		if ^^!e2^^! geq ^^!dy^^! ( set /a "err+=dy, $x0+=sx" )%\n%
		if ^^!e2^^! leq ^^!dx^^! ( set /a "err+=dx, $y0+=sy" )%\n%
	)%\n%
	set "$line=^!$line^!%\e%[0m"%\n%
)) else set args=
goto :end

:_line.Bresenham
rem %@line% x0 y0 x1 y1 color <rtn> $line
set @line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	if "%%~5" equ "" ( set "$line=%\e%[48;5;15m" ) else ( set "$line=%\e%[48;5;%%~5m")%\n%
	set /a "xa=%%~1", "ya=%%~2", "xb=%%~3", "yb=%%~4", "dx=%%~3 - %%~1", "dy=%%~4 - %%~2", "sx=sy=1"%\n%
	if ^^!dy^^! lss 0 set /a "dy=-dy", "sy=-1"%\n%
	if ^^!dx^^! lss 0 set /a "dx=-dx", "sx=-1"%\n%
	set /a "dx<<=1", "dy<<=1"%\n%
	if ^^!dx^^! gtr ^^!dy^^! (%\n%
		set /a "err=dy - (dx >> 1)"%\n%
		for /l %%x in (^^!xa^^!,^^!sx^^!,^^!xb^^!) do (%\n%
			if ^^!err^^! geq 0 set /a "ya+=sy", "err-=dx"%\n%
			set /a "err+=dy"%\n%
			set "$line=^!$line^!%\e%[^!ya^!;%%xH "%\n%
		)%\n%
	) else (%\n%
		set /a "err=dx - (dy >> 1)"%\n%
		for /l %%y in (^^!ya^^!,^^!sy^^!,^^!yb^^!) do (%\n%
			if ^^!err^^! geq 0 set /a "xa+=sx", "err-=dy"%\n%
			set /a "err+=dx"%\n%
			set "$line=^!$line^!%\e%[%%y;^!xa^!H "%\n%
		)%\n%
	)%\n%
	set "$line=^!$line^!%\e%[0m"%\n%
)) else set args=
goto :end

:end
set "lineMode="