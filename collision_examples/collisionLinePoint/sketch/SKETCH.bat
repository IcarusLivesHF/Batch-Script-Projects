@echo off & setlocal enableDelayedExpansion
if "%~1" neq "" goto :%~1

call lib\stdlib 60 60 /multithread
call lib\gfx
call lib\collision
call lib\cmdwiz

set "LinePoint=a=x1-x2, b=y1-y2, c=px-x1, d=py-y1, e=px-x2, f=py-y2,COLLISION=((~((!sqrt(n):n=a*a + b*b!)-((!sqrt(n):n=c*c + d*d!)+(!sqrt(n):n=e*e + f*f!)))>>31)&1)"

set /a "px=10,py=10"
set /a "x1=10,y1=30,x2=50,y2=10"
%@line% !x1! !y1! !x2! !y2!

(%@multithread% main controller %temp%/signal.txt "%0") & exit

:main
for /l %%# in () do (
	
	%@getMouse_multithread%
	
	if !lmb! equ 1 set /a "px=mx", "py=my", "%LinePoint%"
	if !collision! equ 1 ( title COLLISION ) else ( title NO COLLISION )
	
	echo %\e%[2J%\e%[H!$line!%\e%[!py!;!px!HX%\e%[3;10H!px! !py!
)

:controller
%@controller_cmdwiz%