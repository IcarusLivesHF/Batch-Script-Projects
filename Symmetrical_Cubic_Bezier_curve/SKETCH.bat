@echo off & setlocal enableDelayedExpansion

call :init

for /l %%i in (1,1,4) do (
	set /a "cx[%%i]=!random! %% ((wid - (10 * 2)) + 1) + 10"
	set /a "cy[%%i]=!random! %% ((hei - (10 * 2)) + 1) + 10"
	set /a "ci[%%i]=(!random! %% 2 * 2 - 1) * (!random! %% 3 + 2)"
	set /a "cj[%%i]=(!random! %% 2 * 2 - 1) * (!random! %% 3 + 2)"
)
set /a "centerX=wid / 2"

for /l %%# in () do (
	for /l %%i in (1,1,4) do (
		set /a "cx[%%i]+=ci[%%i]","cy[%%i]+=cj[%%i]","mx[%%i]=wid - cx[%%i]"
		if !cx[%%i]! lss 1         set /a "cx[%%i]=1,  ci[%%i]*=-1"
		if !cx[%%i]! gtr %centerX% set /a "cx[%%i]=centerX,ci[%%i]*=-1"
		if !cy[%%i]! lss 1         set /a "cy[%%i]=1,  cj[%%i]*=-1"
		if !cy[%%i]! gtr %hei%     set /a "cy[%%i]=hei,cj[%%i]*=-1"
	)

	for /l %%i in (1,1,4) do set /a "mx[%%i]=wid - cx[%%i]"

	%@bezier% !cx[1]!  !cy[1]! !cx[2]!  !cy[2]! !cx[3]!  !cy[3]! !cx[4]!  !cy[4]! 10
	set "scrn=!$bezier!"
	%@bezier% !mx[1]!  !cy[1]! !mx[2]!  !cy[2]! !mx[3]!  !cy[3]! !mx[4]!  !cy[4]! 12
	set "scrn=!scrn!!$bezier!"
	echo %\e%[2J!scrn!
)


:init
for /f "tokens=1 delims==" %%a in ('set') do (
	set "unload=true"
	for %%b in ( path ComSpec SystemRoot ) do if /i "%%a"=="%%b" set "unload=false"
	if "!unload!"=="true" set "%%a="
)
set "unload="

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set /a "wid=hei=80"
mode %wid%,%hei%




rem %@bezier% x1 y1 x2 y2 x3 y3 x4 y4 color <rtn> $bezier
set @bezier=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-9" %%1 in ("^!args^!") do (%\n%
	if "%%~9" equ "" ( set "hue=15" ) else ( set "hue=%%~9")%\n%
    set "$bezier=%\e%[48;5;^!hue^!m"%\n%
    for /l %%. in (1,1,50) do (%\n%
        set /a "_=%%.<<1,N=((%%~1+_*(%%~3-%%~1)*10)/1000+%%~1),O=((%%~3+_*(%%~5-%%~3)*10)/1000+%%~3),P=((%%~2+_*(%%~4-%%~2)*10)/1000+%%~2),Q=((N+_*(O-N)*10)/1000+N),S=((%%~4+_*(%%~6-%%~4)*10)/1000+%%~4),T=((P+_*(S-P)*10)/1000+P),vx=(Q+_*(((O+_*(((%%~5+_*(%%~7-%%~5)*10)/1000+%%~5)-O)*10)/1000+O)-Q)*10)/1000+Q,vy=(T+_*(((S+_*(((%%~6+_*(%%~8-%%~6)*10)/1000+%%~6)-S)*10)/1000+S)-T)*10)/1000+T"%\n%
        set "$bezier=^!$bezier^!%\e%[^!vy^!;^!vx^!H "%\n%
    )%\n%
	set "$bezier=^!$bezier^!%\e%[0m"%\n%
)) else set args=

goto :eof