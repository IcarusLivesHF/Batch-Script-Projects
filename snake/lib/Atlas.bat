rem Atlas is where all dependencies are for all other libraries




rem Empty environment, but keep some essentials
for /f "tokens=1 delims==" %%a in ('set') do (
	set "pre=true"
	for %%b in (cd Path ComSpec SystemRoot temp windir) do (
		if /i "%%a" equ "%%b" set "pre="
	)
	if defined pre set "%%~a="
)
set "pre="




rem create characters \n and \e
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%





rem 2147483647   or   0x7FFFFFFF
set /a "@32bitlimit=(1<<31)-1"





rem define a few buffers for other libraries
( for /l %%i in (0,1,80) do set "$s=!$s!!$s!  " ) & set "$q=!$s: =q!"





rem grab the default wid,hei
for /f "skip=2 tokens=2" %%a in ('mode') do (
		   if not defined hei ( set /a "hei=height=%%a"
	) else if not defined wid   set /a "wid=width=%%a"
)
REM if specified, define wid,hei
if "%~2" neq "" (
	set /a "wid=width=%~1", "hei=height=%~2 - 1"
	mode %~1,%~2
) 2>nul





:_while 
rem %while% ( condition %end.while% )
REM maximum number of iterations: 16*16*16*16*16 = 1,048,576
set "while=for /l %%i in (1 1 16)do if defined do.while"
set "while=set do.while=1&!while! !while! !while! !while! !while! "
set "endWhile=set "do.while=""






rem hide cursor, cls, set cursor to 0,0
echo %\e%[2J%\e%[H%\e%[?25l
exit /b