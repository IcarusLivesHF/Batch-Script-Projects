setlocal enableDelayedExpansion
rem define a few buffers
for /l %%i in (0,1,5) do set "barBuffer=!barBuffer!!barBuffer! "

if "%~3" neq "" ( set "color=%~3" ) else set "color=12"

rem init calendar details set date
set "totalDaysInMonth.list="01 January 31" "02 February 28" "03 March 31" "04 April 30" "05 May 31" "06 June 30" "07 July 31" "08 August 31" "09 September 30" "10 October 31" "11 November 30" "12 December 31""
set "weekDays=Sun Mon Tue Wed Thu Fri Sat"

for %%a in (Mon.5DE23C Tue.30C5FF Wed.FBF719 Thu.FF793B Fri.FA3BF0) do (
	set /a "dayColors+=1"
	for /f "tokens=1,2 delims=." %%1 in ("%%a") do (
		set "dayDay[!dayColors!]=%%~1"
		set "hex=%%~2"
		set /a "r=0x!hex:~0,2!","g=0x!hex:~2,2!","b=0x!hex:~4,2!"
		set "dayColor[!dayColors!]=%\e%[48;2;!r!;!g!;!b!m%\e%[38;5;16m"
	)
)

set "date.day=%date:~0,3%"
for /f "tokens=1-3 delims=/" %%0 in ("%date:~4%") do (
	set "date.month=%%0"
	set "date.date.name=%%1"
	set "date.date=%%1"
	set "date.year=%%2"
)

if "%date.date.name:~0,1%" equ "0" (
	set "date.date=%date.date.name:~1%"
)

for %%i in (%weekDays%) do (
	if /i "%date.day%" neq "%%~i" (
		if !found! neq 1 (
			set /a "date.offset+=1"
		)
	) else set /a "found+=1"
)

for %%i in (%totalDaysInMonth.list%) do (
	for /f "tokens=1-3" %%0 in ("%%~i") do (
		if /i "%date.month%" equ "%%~0" (
			set /a "date.daysInMonth=%%~2",^
			       "date.daysLeft=%%~2 - date.date",^
				   "date.percent=date.date * 100 / %%~2",^
				   "date.percent.mapped=(date.date * 100 / %%~2) * %%~2 / 100"
			set "date.month.name=%%~1"
		)
	)
)

set /a "barVal=15 * date.percent.mapped / date.daysInMonth",^
	   "percent=100 * date.percent.mapped/date.daysInMonth",^
	   "t1=(2*date.daysInMonth)/3",^
	   "t2=date.daysInMonth/3",^
	   "m1=-((((t1-date.percent.mapped)>>31)&1) & 1)",^
	   "m2=-((((t2-date.percent.mapped)>>31)&1) & 1) & ~m1",^
	   "m3=~(m1 | m2)",^
	   "hue=(m1 & 46) | (m2 & 226) | (m3 & 196)"


if /i "!date.day!" equ "Sun" (
	set "back=%\e%[D"
)

rem build calendar into sprite
set /a "i=date.offset", "date.offset*=4", "date.monthLoop=date.daysInMonth - date.daysLeft"
set "$calendar=%\e%7%\e%[38;5;15;48;5;%color%m%\e%[4m%\e%7 Days left: !date.daysleft!%\e%8%\e%[14C%\e%(0x%\e%(B Next 30 days%\e%[0m%\e%8%\e%[B%\e%7 S  %dayColor[1]% M  %dayColor[2]% T  %dayColor[3]% W  %dayColor[4]% T  %dayColor[5]% F  %\e%[0m S  %\e%8%\e%[B"
set "$calendar=!$calendar!%\e%[%date.offset%C%\e%[38;5;16;48;5;15m%back%"

set /a "j=1"
for /l %%i in (%date.date%,1,%date.daysInMonth%) do (
	if %%i lss 10 (set "name=0%%i") else (set "name=%%i")
	set "$calendar=!$calendar! !name!%\e%(0x%\e%(B"
	set /a "i+=1"
	set "date.button.list=!date.button.list!"!name!-!i!-!j!" "
	if !i! gtr 6 (
		set /a "i*=4", "j+=1"
		set "$calendar=!$calendar!%\e%[!i!D%\e%[B"
		set "i=0"
	)
)
for /l %%i in (1,1,%date.monthLoop%) do (
	if %%i lss 10 (set "name=0%%i") else (set "name=%%i")
	set "$calendar=!$calendar! !name!%\e%(0x%\e%(B"
	set /a "i+=1"
	set "date.button.list=!date.button.list!"!name!-!i!-!j!" "
	if !i! gtr 6 (
		set /a "i*=4","j+=1"
		set "$calendar=!$calendar!%\e%[!i!D%\e%[B"
		set "i=0"
	)
)

if "%~2" neq "" (
	set /a "bx=%~1","by=%~2", "bi=%~1 - 1","bj=%~2 - 1"
) else set /a "bx=2","by=2", "bi=1","bj=1"

set "$calendar=%\e%[%by%;%bx%H!$calendar!%\e%[0m%\e%8%\e%[8B%\e%[48;5;%color%m[%\e%7%\e%[48;5;!hue!m!barBuffer:~0,%barVal%!%\e%[0m%\e%8%\e%[15C%\e%[48;5;%color%m][%\e%[48;5;%color%m!date.date!%\e%[0m%\e%[48;5;%color%m/!date.daysinmonth!:%\e%[48;5;%color%;38;5;!hue!m!date.percent!%\e%[48;5;%color%m%\e%[0m%\e%[48;5;%color%m%%%\e%[0m%\e%[48;5;%color%m]%\e%[0m"
set "$calendar=!$calendar!%\e%[%bj%;%bi%H%\e%[48;5;%color%m%\e%(0%\e%7lqqqqqqqqqqqqqqqqqqqqqqqqqqqqk%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7tqqqqqqqqqqqqqqqqqqqqqqqqqqqqu%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[Bmqqqqqqqqqqqqqqqqqqqqqqqqqqqqj%\e%(B%\e%[0m"
set "date.date=!date.date.name!"
for %%i in (bx by i r g b name hex found date.offset date.date.name date.monthLoop weekDays barval onethird twoThird hue) do set "%%~i="
for /f "tokens=1 delims==" %%i in ('set dayColor') do set "%%~i="
for /f "tokens=1 delims==" %%i in ('set dayDay') do set "%%~i="



endlocal & set "$calendar=%$calendar%" & set "date.button.list=%date.button.list%"

:_calendar.click
rem %@calendar.click% l,r
set @calendar.click=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1" %%1 in ("^!args^!") do (%\n%
	for %%i in (%date.button.list%) do for /f "tokens=1-3 delims=-" %%a in ("%%~i") do (%\n%
		set /a "x0=(%%b * 4) + %~1 - 4",^
		       "x1=(%%b * 4) + %~1 + 4",^
			   "y=%%c + %~2"%\n%
		if ^^!mouseX^^! geq ^^!x0^^! if ^^!mouseX^^! leq ^^!x1^^! if ^^!mouseY^^! equ ^^!y^^! (%\n%
			       if /i "%%~1" equ "L" ( if "^!l_click^!" equ "1" set "$calendar.click=%%~a"%\n%
			) else if /i "%%~1" equ "R" ( if "^!r_click^!" equ "1" set "$calendar.click=%%~a"%\n%
			) else set "$calendar.click=%%~a"%\n%
		)%\n%
	)%\n%
	for %%i in (x0 x1 y) do set "%%~i="%\n%
)) else set args=


goto :eof