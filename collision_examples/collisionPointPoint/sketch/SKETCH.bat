@echo off & setlocal enableDelayedExpansion
if "%~1" neq "" goto :%~1

call lib\stdlib 60 60 /multithread
call lib\gfx
call lib\collision
call lib\cmdwiz

set x1=10
set y1=30
set x2=50
set y2=10

(%@multithread% main controller %temp%/signal.txt "%0") & exit

:main
for /l %%# in () do (
	
	%@getMouse_multithread%
	
	if !lmb! equ 1 set /a "x2=mx", "y2=my", "1/(%PointPoint%)" && ( title COLLISION ) || ( title NO COLLISION )
	
	echo %\e%[2J%\e%[!y1!;!x1!HO%\e%[!y2!;!x2!HX
)

:controller
%@controller_cmdwiz%