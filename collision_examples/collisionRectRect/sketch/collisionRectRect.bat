@echo off & setlocal enableDelayedExpansion

if "%~1" neq "" goto :%~1

call lib\stdlib 60 60 /multithread
call lib\math radians
call lib\gfx
call lib\cmdwiz
call lib\collision

set /a "r2x=30,r2y=30,r2w=r2h=4"
rem rectangle
set /a "r1x=10,r1y=50,r1w=r1h=6"
%@rect% !r1x! !r1y! !r1w! !r1h!
set "scrn=!$rect!"

(%@multithread% main controller %temp%/signal.txt "%0") & exit

:main
for /l %%# in () do (
	
	%@getMouse_multithread%
	%@rect% !r2x! !r2y! !r2w! !r2h!
	
	if !lmb! equ 1 set /a "r2x=mx", "r2y=my", "%RectRect%"

	if !COLLISION! equ 1 ( title COLLISION ) else title NO COLLISION

	echo %\e%[2J%\e%[H!scrn!!$rect!%\e%[2;10HCOLLISION:!COLLISION!

)

:controller
%@controller_cmdwiz%