@echo off & setlocal enableDelayedExpansion
if "%~1" neq "" goto :%~1

call lib\stdlib 60 60 /multithread
call lib\gfx
call lib\collision
call lib\cmdwiz

set x1=10
set y1=30

set /a "cx=10,cy=10,r=6"
%@circle% !cx! !cy! !r!

(%@multithread% main controller %temp%/signal.txt "%0") & exit

:main
for /l %%# in () do (
	
	%@getMouse_multithread%
	
	if !lmb! equ 1 set /a "x1=mx", "y1=my", "%PointCircle%"
	if !collision! equ 1 ( title COLLISION ) else ( title NO COLLISION )
	
	echo %\e%[2J%\e%[h%$circle%%\e%[!y1!;!x1!HX
)

:controller
%@controller_cmdwiz%