@echo off & setlocal enableDelayedExpansion

call lib\stdlib 50 50
call lib\math
call lib\gfx

for /l %%i in (1,1,12) do (
	set /a "cx=21 * !cos:x=(360 * %%i / 12 - 90)! + wid/2"
	set /a "cy=21 * !sin:x=(360 * %%i / 12 - 90)! + hei/2"
	set "numbers=!numbers!%\e%[!cy!;!cx!H%%i"
)

for /l %%# in () do (
	
	for /f "tokens=1-3 delims=:.," %%a in ("!time!") do (
	
		set "hr=%%a" & set "mn=%%b" & set "sc=%%c"
		for %%i in (hr mn sc) do if "!%%i:~0,1!" equ "0" set "%%i=!%%i:~1,1!"
		
		set /a "hrx=10 * !cos:x=(360 * (hr %% 12) / 12 - 90)! + wid / 2",^
		       "hry=10 * !sin:x=(360 * (hr %% 12) / 12 - 90)! + hei / 2",^
		       "mnx=15 * !cos:x=(360 * mn / 60 - 90)! + wid / 2",^
		       "mny=15 * !sin:x=(360 * mn / 60 - 90)! + hei / 2",^
			   "scx=20 * !cos:x=(360 * sc / 60 - 90)! + wid / 2",^
		       "scy=20 * !sin:x=(360 * sc / 60 - 90)! + hei / 2"
	)
	
	%@circle% wid/2 hei/2 23 23
	set "scrn=!scrn!!$circle!"
	%@line% wid/2 hei/2 !hrx! !hry! 9
	set "scrn=!scrn!!$line!"
	%@line% wid/2 hei/2 !mnx! !mny! 10
	set "scrn=!scrn!!$line!"
	%@line% wid/2 hei/2 !scx! !scy! 12
	set "scrn=!scrn!!$line!"
	
	echo %\h%!scrn!%numbers%
	set "scrn="
)