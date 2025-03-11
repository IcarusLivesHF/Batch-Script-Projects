@echo off & setlocal enableDelayedExpansion

if "%~1" neq "" goto :%~1

call lib\stdlib 60 60 /multithread
call lib\math radians
call lib\gfx
call lib\cmdwiz
call lib\collision

set "LineLine=a=x4-x3,b=y4-y3,c=x1-x3,d=y1-y3,e=x2-x1,f=y2-y1,uA=10 * (a*d - b*c) / (b*e - a*f), uB=10 * (e*d - f*c) / (b*e - a*f), COLLISION=((~(uA-0)>>31)&1) & ((~(10-uA)>>31)&1) & ((~(uB-0)>>31)&1) & ((~(10-uB)>>31)&1)"
set "LineLine=a=x4-x3,b=y4-y3,c=x1-x3,d=y1-y3,e=x2-x1,f=y2-y1,g=b*e-a*f, uA=10 * (a*d - b*c) / g, uB=10 * (e*d - f*c) / g, COLLISION=((~(uA-0)>>31)&1) & ((~(10-uA)>>31)&1) & ((~(uB-0)>>31)&1) & ((~(10-uB)>>31)&1)"


rem set up 2 lines
set /a "x1=10, y1=10, x2=0, y2=0",^
       "x3=10, y3=30, x4=50,y4=10"
%@line% !x3! !y3! !x4! !y4!
set "scrn=!$line!"

(%@multithread% main controller %temp%/signal.txt "%0") & exit

:main
for /l %%# in () do (
	
	%@getMouse_multithread%
	%@line_fast% !x1! !y1! !x2! !y2!
	
	if !lmb! equ 1 set /a "x1=mx", "y1=my", "%LineLine%"

	if !COLLISION! equ 1 ( title COLLISION ) else title NO COLLISION

	echo %\e%[2J%\e%[H!scrn!!$line!

)

:controller
%@controller_cmdwiz%