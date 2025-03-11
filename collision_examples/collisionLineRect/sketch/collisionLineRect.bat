@echo off & setlocal enableDelayedExpansion

if "%~1" neq "" goto :%~1

call lib\stdlib 60 60 /multithread
call lib\math radians
call lib\gfx
call lib\cmdwiz
call lib\collision

REM set "LineRect=x1=x1,y1=y1,x2=x2,y2=y2, x3=rx, y3=ry, x4=rx, y4=ry+rh, ^!lineLine^!, left=COLLISION, x3=rx+rw,y3=ry, x4=rx+rw,y4=ry+rh, ^!lineLine^!, right=COLLISION, x3=rx, y3=ry, x4=rx+rw,y4=ry, ^!lineLine^!, top=COLLISION, x3=rx,y3=ry+rh,x4=rx+rw,y4=ry+rh, ^!lineLine^!, bottom=COLLISION, COLLISION=left | right | top | bottom"
set "LineRect=x1=x1,y1=y1,x2=x2,y2=y2, COLLISION=(x3=rx, y3=ry, x4=rx, y4=ry+rh, ^!lineLine^!) | (x3=rx+rw,y3=ry, x4=rx+rw,y4=ry+rh, ^!lineLine^!) | (x3=rx, y3=ry, x4=rx+rw,y4=ry, ^!lineLine^!) | (x3=rx,y3=ry+rh,x4=rx+rw,y4=ry+rh, ^!lineLine^!)"

rem set up 2 lines
set /a "x1=10, y1=10, x2=0, y2=0"
	   
rem rectangle
set /a "rx=ry=rw=rh=20"
%@rect% !rx! !ry! !rw! !rh!

(%@multithread% main controller %temp%/signal.txt "%0") & exit

:main
for /l %%# in () do (
	
	%@getMouse_multithread%
	%@line% !x1! !y1! !x2! !y2!
	if !lmb! equ 1 set /a "x1=mx", "y1=my", "%LineRect%"

	if !COLLISION! equ 1 ( title COLLISION ) else title NO COLLISION
	
	rem draw the stuff
	echo %\e%[2J%\e%[H!$rect!!$line!%\e%[2;10Hleft:!left! right:!right! top:!top! bottom:!bottom! COLLISION:!COLLISION!

)

:controller
%@controller_cmdwiz%