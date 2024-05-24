for /f "tokens=1 delims==" %%a in ('set') do (
	set "unload=true"
	for %%b in (cd Path ComSpec SystemRoot temp windir) do if /i "%%a"=="%%b" set "unload=false"
	if "!unload!"=="true" set "%%a="
)
set "unload="

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%
set "\c=%\e%[2J"                                       %= \c =%
set "\h=%\e%[2J%\e%[H"                                 %= \h =%
<nul set /p "=%\e%[?25l"     & rem hide cursor

set "@32bitlimit=0x7FFFFFFF" & rem 2147483647 or (1 << 31) - 1 or 0x7FFFFFFF

:_@getDim
rem %@getDim% - get current dimensions of window
set  @getDim=(%\n%
	set "wid=" ^& set "hei=" ^& set "width=" ^& set "height="%\n%
	for /f "skip=2 tokens=2" %%a in ('mode') do if not defined hei (set /a "hei=height=%%a") else if not defined wid set /a "wid=width=%%a"%\n%
)

%@getDim%
if "%~2" neq "" (
	set /a "wid=width=%~1", "hei=height=%~2"
	mode %~1,%~2
) 2>nul


if /i "%~3" equ "/multithread" (
	call :multithread_macros
)
exit /b

:multithread_macros

:_@multithread
rem %@multithread% main controller "path" "%~f0" <- last argument *must* be %~f0
set @multithread=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	"%%~4" %%~2 ^>"%%~3" ^| "%%~4" %%~1 ^<"%%~3"%\n%
)) else set args=

:_@fetchkey
rem %@fetchkey% VAR - <rtn> var & lastVar
set @fetchKey=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1" %%1 in ("^!args^!") do (%\n%
	if defined %%~1 set "last%%~1=^!%%~1^!"%\n%
	set "%%~1=" ^& set /p "%%~1="%\n%
)) else set args=

:_abort
rem %@abort
set "@abort=echo=.>"%temp%\abort.txt" & exit"

goto :eof

Features:
	%~1 = width
	%~2 = height
	%~3 = if defined "/multithread"
	
	Clears environment of unnecessary variables
	Hides cursor
	Sets size of window and provides definitions in variables, see below
	
	Macros:
		@getDim
		
		if /multithread
			@multithread
			@fetchkey
	
	Values:
		@32bitlimit
		wid/width
		hei/height
		\e = esc
		\c = clear screen
		\h = clear\goto 0,0
		\n = newLine