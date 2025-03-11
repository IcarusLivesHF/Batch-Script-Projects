@echo off & setlocal enableDelayedExpansion
if "%~1" neq "" goto :%~1

call lib\stdlib 60 60 /multithread
call lib\gfx
call lib\collision
call lib\cmdwiz

set cx=10
set cy=10
set r=4

set tx1=10
set ty1=50
set tx2=50
set ty2=10
%@line% !tx1! !ty1! !tx2! !ty2!

(%@multithread% main controller %temp%/signal.txt "%0") & exit

:main
for /l %%# in () do (
	
	%@getMouse_multithread%
	
	%@circle% !cx! !cy! !r!
	
	if !lmb! equ 1 set /a "cx=mx", "cy=my", "x1=tx1,y1=ty1,x2=tx2,y2=ty2", "%LineCircle%"
	if !collision! equ 1 ( title COLLISION ) else ( title NO COLLISION )
	
	echo %\e%[2J%\e%[H%$line%%\e%[!cy!;!cx!H!$circle!%\e%[!cly!;!clx!H%\e%[38;5;10mX
)

:controller
%@controller_cmdwiz%