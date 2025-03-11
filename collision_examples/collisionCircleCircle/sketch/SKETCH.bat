@echo off & setlocal enableDelayedExpansion
if "%~1" neq "" goto :%~1

call lib\stdlib 60 60 /multithread
call lib\gfx
call lib\collision
call lib\cmdwiz


set /a "c2x=20,c2y=20,c2r=10"

set /a "c1x=10,c1y=10,c1r=6"
%@circle% !c1x! !c1y! !c1r!
set "scrn=!$circle!"

(%@multithread% main controller %temp%/signal.txt "%0") & exit

:main
for /l %%# in () do (
	
	%@getMouse_multithread%
	%@circle% !c2x! !c2y! !c2r!
	
	if !lmb! equ 1 set /a "c2x=mx", "c2y=my", "%CircleCircle%"
	if !collision! equ 1 ( title COLLISION ) else ( title NO COLLISION )
	
	echo %\e%[2J%\e%[H!scrn!%\e%[!c1y!;!c1x!H!$circle!
)

:controller
%@controller_cmdwiz%