:_calendar.click
rem %@calendar.click% calendar.x calendar.y /l1,/l2,/r1,/r2
set @calendar.click=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1" %%1 in ("^!args^!") do (%\n%
	for %%i in (^^!date.button.list^^!) do for /f "tokens=1-3 delims=-" %%a in ("%%~i") do (%\n%
		set /a "cb.x=(%%b * 4) + %~1 - 3", "cb.x0=(%%b * 4) + %~1 - 1 - 3","cb.x1=(%%b * 4) + %~1 + 1 - 3","cb.y=%%c + (%~2 + 1)"%\n%
		if ^^!mx^^! geq ^^!cb.x0^^! if ^^!mx^^! leq ^^!cb.x1^^! if ^^!my^^! equ ^^!cb.y^^! (%\n%
			if "%%~1" equ "" (%\n%
				set "$calendar.click=%%~a"%\n%
			) else if /i "%%~1" equ "/L1" (%\n%
				if "^!lmb^!" equ "1" set "$calendar.click=%%~a"%\n%
			) else if /i "%%~1" equ "/L2" (%\n%
				if "^!dlb^!" equ "1" set "$calendar.click=%%~a"%\n%
			) else if /i "%%~1" equ "/R1" (%\n%
				if "^!rmb^!" equ "1" set "$calendar.click=%%~a"%\n%
			) else if /i "%%~1" equ "/R2" (%\n%
				if "^!drb^!" equ "1" set "$calendar.click=%%~a"%\n%
			)%\n%
		)%\n%
	)%\n%
	for %%i in (cb.x cb.x0 cb.x1 cb.y) do set "%%~i="%\n%
)) else set args=

rem define a few buffers
for /l %%i in (0,1,5) do set "barBuffer=!barBuffer!!barBuffer! "

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

set /a "barVal=15 * date.percent.mapped / date.daysInMonth", "onethird=date.daysInMonth / 3", "twoThird=onethird * 2"
if !date.percent.mapped! lss !onethird! (
	set "hue=46"
) else if !date.percent.mapped! gtr !oneThird! if !date.percent.mapped! lss !twoThird! (
	set "hue=226"
) else if !date.percent.mapped! gtr !twoThird! (
	set "hue=196"
)

if /i "!date.day!" equ "Sun" (
	set "back=%\e%[D"
)

rem build calendar into sprite
set /a "i=date.offset", "date.offset*=4", "date.monthLoop=date.daysInMonth - date.daysLeft"
set "$calendar==%\e%7%\e%[38;5;15;48;5;16m%\e%[4m%\e%7Days left: !date.daysleft!%\e%8%\e%[14C%\e%(0x%\e%(B Pick a date:%\e%[0m%\e%8%\e%[B%\e%7 S  %dayColor[1]% M  %dayColor[2]% T  %dayColor[3]% W  %dayColor[4]% T  %dayColor[5]% F  %\e%[0m S  %\e%8%\e%[B"
set "$calendar!$calendar!%\e%[%date.offset%C%\e%[38;5;16;48;5;15m%back%"

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

set /a "bx=%~1 - 1","by=%~2 - 1"
set "$calendar=%\e%[%~2;%~1H!$calendar!%\e%[0m%\e%8%\e%[8B[%\e%7%\e%[48;5;!hue!m!barBuffer:~0,%barVal%!%\e%[0m%\e%8%\e%[15C][%\e%[38;5;!hue!m!date.date!%\e%[0m/!date.daysinmonth!:%\e%[38;5;!hue!m!date.percent!%\e%[0m%%]"
set "$calendar=!$calendar!%\e%[!by!;!bx!H%\e%(0%\e%7lqqqqqqqqqqqqqqqqqqqqqqqqqqqqk%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[B%\e%7tqqqqqqqqqqqqqqqqqqqqqqqqqqqqu%\e%8%\e%[B%\e%7x%\e%[28Cx%\e%8%\e%[Bmqqqqqqqqqqqqqqqqqqqqqqqqqqqqj%\e%(B%\e%[0m"
set "date.date=!date.date.name!"
for %%i in (i r g b name hex found date.offset date.date.name date.monthLoop weekDays barval onethird twoThird hue) do set "%%~i="
for /f "tokens=1 delims==" %%i in ('set dayColor') do set "%%~i="
for /f "tokens=1 delims==" %%i in ('set dayDay') do set "%%~i="
goto :eof