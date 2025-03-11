@echo off & setlocal enableDelayedExpansion

if "%~1" neq "" goto :%~1

call lib\stdlib 60 60 /multithread
call lib\math radians
call lib\gfx
call lib\cmdwiz
call lib\collision

REM set "CircleRect=g=cx,h=cy,a=cx-rx,b=rx+rw,c=cy-ry,d=ry+rh,e=(((b - cx) >> 31) & 1),f=(((d - cy) >> 31) & 1),g=cx-((((a >> 31) & 1) * rx) + ((1 - ((a >> 31) & 1)) * (1 - e) * cx) + e * b),h=cy-((((c >> 31) & 1) * ry) + ((1 - ((c >> 31) & 1)) * (1 - f) * cy) + f * d),COLLISION=((~(r-!sqrt(n):n=g*g + h*h)!)>>31)&1)"
set "CircleRect=tx=cx, ty=cy,a=cx - rx,b=cy - ry,c=rx+rw,d=ry+rh,e=(((c) - cx) >> 31) & 1,f=(((d) - cy) >> 31) & 1,g=cx-((((a >> 31) & 1) * rx) + ((1 - ((a >> 31) & 1)) * (1 - e) * cx) + e * c),h=cy-((((b >> 31) & 1) * ry) + ((1 - ((b >> 31) & 1)) * (1 - f) * cy) + f * d),COLLISION=((~(r-!sqrt(n):n=g*g + h*h!)>>31)&1)"

REM set "CircleRect=tx=cx, ty=cy, tx=((((cx - rx) >> 31) & 1) * rx) + ((1 - (((cx - rx) >> 31) & 1)) * (1 - ((((rx+rw) - cx) >> 31) & 1)) * cx) + (((((rx+rw) - cx) >> 31) & 1) * (rx+rw)), ty=((((cy - ry) >> 31) & 1) * ry) + ((1 - (((cy - ry) >> 31) & 1)) * (1 - ((((ry+rh) - cy) >> 31) & 1)) * cy) + (((((ry+rh) - cy) >> 31) & 1) * (ry+rh)), COLLISION=((~(r-!sqrt(n):n=((cx - tx)*(cx - tx)) + ((cy - ty)*(cy - ty))!)>>31)&1)"


rem circle
set /a "cx=10","cy=10","r=6"

rem rectangle
set /a "rx=ry=rw=rh=20"
%@rect% !rx! !ry! !rw! !rh!

(%@multithread% main controller %temp%/signal.txt "%0") & exit

:main
for /l %%# in () do (
	
	%@getMouse_multithread%
	%@circle% !cx! !cy! !r!
	
	if !lmb! equ 1 set /a "cx=mx", "cy=my", "%CircleRect%"
	if !collision! equ 1 ( title COLLISION ) else ( title NO COLLISION )
	
	rem draw the stuff
	echo %\e%[2J%\e%[H!$circle!!$rect!

)

:controller
%@controller_cmdwiz%