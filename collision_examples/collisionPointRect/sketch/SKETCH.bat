@echo off & setlocal enableDelayedExpansion
if "%~1" neq "" goto :%~1

call lib\stdlib 60 60 /multithread
call lib\gfx
call lib\collision
call lib\cmdwiz

set /a "px=10,py=10"
set /a "rx=ry=rw=rh=20"
%@rect% !rx! !ry! !rw! !rh!

(%@multithread% main controller %temp%/signal.txt "%0") & exit

:main
for /l %%# in () do (
	
	%@getMouse_multithread%
	
	if !lmb! equ 1 set /a "px=mx", "py=my", "%PointRect%"
	if !collision! equ 1 ( title COLLISION ) else ( title NO COLLISION )
	
	echo %\e%[2J%\e%[H!$rect!%\e%[!py!;!px!HX
)

:controller
%@controller_cmdwiz%