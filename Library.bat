(call :buildSketch) & (exit) & rem Double click the library to build a new sketch.
:revision DON'T CALL
	set "revision=4.0.1"
	set "libraryError=False"
	for /f "tokens=4-5 delims=. " %%i in ('ver') do set "winVERSION=%%i.%%j"
	if %revision:.=% neq %revisionRequired:.=% (
		echo.&echo  This %revision% of Library.bat is not supported in this script.
		echo  %revisionRequired% of Library.bat required to run this script.
		set "libraryError=True"
	)
	if "%winversion%" neq "10.0" (
		echo %~n0 is not supported on this version of Windows: %winVERSION%"
		set "libraryError=True"
	)
	if "%libraryError%" equ "True" (
		ren "%~nx0" "Library.bat"
		ren "-t.bat" "%self%"
		del /f /q "-t.bat"
		timeout /t 3 & exit
	)
goto :eof
:StdLib /w:N /h:N /fs:N /title:"foobar" /rgb:"foo":"bar" /debug /extlib /3rdparty /multi /sprite /math /misc /shape /ac /turtle /cursor /cr:N /gfx /util
title Powered by: Windows Batch Library - Revision: %Revision%
echo Loading Windows Batch Library - Revision: %Revision%...
chcp 437>nul
set "defaultFontSize=12"
set "defaultFont=Terminal"
set "debug=False"
set "pixel=Û" & set ".=Û"
(for /f %%a in ('echo prompt $E^| cmd') do set "esc=%%a" ) || ( set "esc=" )
set "\e=%esc%["
set "\p=echo %esc%["
set  "\rgb=%esc%[38;2;^!r^!;^!g^!;^!b^!m"
set "\fcol=%esc%[48;2;^!r^!;^!g^!;^!b^!m"
set "cls=%esc%[2J" & set "\c=%esc%[2J"
set "L.32bit=2147483647"
rem newLine
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)
rem multiline Comment     %rem[%    %]rem%
Set "rem[=rem/||(" & set "]rem=)"
<nul set /p "=%esc%[?25l"

for %%a in (%*) do (
	set /a "totalArguemnts+=1"
	set "fullArgument=%%a"
	for /f "tokens=1-3 delims=:" %%i in ("!fullArgument:~1!") do (
		set "argumentCommand[!totalArguemnts!]=%%~i"
		set "argumentArgument[!totalArguemnts!][1]=%%~j"
		set "argumentArgument[!totalArguemnts!][2]=%%~k"
	)
)
for /l %%i in (1,1,%totalArguemnts%) do (

	REM -----------------------------------------------------------------------------------------------------------------------------W
		   if /i "!argumentCommand[%%i]!" equ "w" (
			set /a "wid=width=!argumentArgument[%%i][1]!"
			
	REM -----------------------------------------------------------------------------------------------------------------------------H
	) else if /i "!argumentCommand[%%i]!" equ "h" (
			set /a "hei=height=!argumentArgument[%%i][1]!"
			
	REM -----------------------------------------------------------------------------------------------------------------------------FS
	) else if /i "!argumentCommand[%%i]!" equ "fs" (
			set /a "defaultFontSize=!argumentArgument[%%i][1]!"
			
	REM -----------------------------------------------------------------------------------------------------------------------------TITLE t
	) else if /i "!argumentCommand[%%i]:~0,1!" equ "t" (
			title !argumentArgument[%%i][1]!
			
	REM -----------------------------------------------------------------------------------------------------------------------------RGB
	) else if /i "!argumentCommand[%%i]!" equ "rgb" (
			set "backgroundColor=!argumentArgument[%%i][1]!"
			set "textColor=!argumentArgument[%%i][2]!"
			if "!textColor:;=!" neq "!textColor!" (
				set "defaultStyle=2" 
			) else (
				set "defaultStyle=5"
			)
			<nul set /p "=%esc%[48;!defaultStyle!;!backgroundColor!m%esc%[38;!defaultStyle!;!textColor!m"
			
	REM -----------------------------------------------------------------------------------------------------------------------------DEBUG d
	) else if /i "!argumentCommand[%%i]:~0,1!" equ "d" (
			set "debug=True"
			
	REM -----------------------------------------------------------------------------------------------------------------------------EXTLIB e
	) else if /i "!argumentCommand[%%i]:~0,1!" equ "e" (
			rem Backspace
			for /f %%a in ('"prompt $H&for %%b in (1) do rem"') do set "BS=%%a"
			rem BEL (sound)
			for /f %%i in ('forfiles /m "%~nx0" /c "cmd /c echo 0x07"') do set "BEL=%%i"
			rem Carriage Return
			for /f %%A in ('copy /z "%~dpf0" nul') do set "CR=%%A"
			rem Tab 0x09
			for /f "delims=" %%T in ('forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo(0x09"') do set "TAB=%%T"
			rem Heart
			for /f %%i in ('forfiles /m "%~nx0" /c "cmd /c echo 0x03"') do set "<3=%%i"
			for %%i in (
				"pointer[R].10" "pointer[L].11" "pointer[U].1E" "pointer[D].1F"
				"pixel[0].DB" "pixel[1].B0" "pixel[2].B1" "pixel[3].B2"
				"face[0].01" "face[1].02" "musicNote.0E"
				"border[vert].B3" "border[hori].C4" "border[X].C5"
				"border[hori.N].C1" "border[hori.S].C2" "border[vert.E].C3" "border[vert.W].B4"
				"corner[SE].D9" "corner[NE].BF" "corner[SW].C0" "corner[NW].DA"
			) do (
				for /f "tokens=1,2 delims=." %%a in ("%%~i") do (
					for /f %%i in ('forfiles /m "%~nx0" /c "cmd /c echo 0x%%~b"') do set "%%~a=%%~i"
				)
			)
			
	REM -----------------------------------------------------------------------------------------------------------------------------3RDPARTY
	) else if /i "!argumentCommand[%%i]:~0,3!" equ "3rd" (
			if not exist "%temp%/batch" (
				Powershell.exe -command "(New-Object System.Net.WebClient).DownloadFile('https://download1478.mediafire.com/5991igjkrecgKaXyNCmBNY5bKGGfDrgJHdxz9p8dJpBN8c2FMylYGjY9GH0WPesKh1JjZ6gvCHu4Wz8XpjYFF2CarOg/etz48ptpp0l2lkp/batch.zip','batch.zip')" && (
					move /y batch.zip "%temp%"
					pushd "%temp%"
					tar -xf batch.zip
					popd
				) || ( goto :eof )
				goto :eof
			)
			rem returns (mouseXpos mouseYpos CONSTANTLY no keypress needed) click keysPressed
			set "curl=%temp%/batch/curl.exe"
			set "import_getInput.dll=set /a "rasterx=8,rastery=8" & ("%temp%/batch/inject.exe" "%temp%/batch/getInput.dll")"
			set "adjustDLLmouse=set /a "mouseY=mouseYpos+1","mouseX=mouseXpos+1""
			set "NirCmd="%temp%/batch/NirCmd.exe""
			set "curl="%temp%/batch/curl.exe""
			set "wget="%temp%/batch/wget.exe""
			set "getMouseXY=for /f "tokens=1-3" %%W in ('"%temp%\Mouse.exe"') do set /a "mouseC=%%W,mouseX=%%X,mouseY=%%Y""
			set "clearMouse=set "mouseX=" ^& set "mouseY=" ^& set "mouseC=""

	REM -----------------------------------------------------------------------------------------------------------------------------MULTI
	) else if /i "!argumentCommand[%%i]!" equ "multi" (
			set "controller=True"
			set "fetchDataFromController=if "^^!controller^^!" equ "True" set "com=" & set /p "com=""

	REM -----------------------------------------------------------------------------------------------------------------------------SPRITE s
	) else if /i "!argumentCommand[%%i]:~0,1!" equ "s" (
			call :sprites

	REM -----------------------------------------------------------------------------------------------------------------------------MATH
	) else if /i "!argumentCommand[%%i]!" equ "math" (
			set /a "PI=(35500000/113+5)/10, HALF_PI=(35500000/113/2+5)/10, TWO_PI=2*PI, PI32=PI+HALF_PI, neg_PI=PI * -1, neg_HALF_PI=HALF_PI *-1"
			REM set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
			REM set "sin=(a=(x * 31416 / 180)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!) / 10000"
			REM set "cos=(a=(15708 - x * 31416 / 180)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!) / 10000"
			set "sin=(a=((x*31416/180)%%62832)+(((x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) / 10000"
			set "cos=(a=((15708-x*31416/180)%%62832)+(((15708-x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) / 10000"
			set "sinr=(a=(x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!) / 10000"
			set "cosr=(a=(15708 - x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!) / 10000"
			set "Sqrt(N)=( x=(N)/(11*1024)+40, x=((N)/x+x)/2, x=((N)/x+x)/2, x=((N)/x+x)/2, x=((N)/x+x)/2, x=((N)/x+x)/2 )"
			set "Sign=1 / (x & 1)"
			set "Abs=(((x)>>31|1)*(x))"
			set "dist(x2,x1,y2,y1)=( @=x2-x1, $=y2-y1, ?=(((@>>31|1)*@-(($>>31|1)*$))>>31)+1, ?*(2*(@>>31|1)*@-($>>31|1)*$-((@>>31|1)*@-($>>31|1)*$)) + ^^^!?*((@>>31|1)*@-($>>31|1)*$-((@>>31|1)*@-($>>31|1)*$*2)) )"
			set "avg=(x&y)+(x^y)/2"
			set "map=(c)+((d)-(c))*((v)-(a))/((b)-(a))"
			set "lerp=?=(a+c*(b-a)*10)/1000+a"
			set "swap=t=x, x=y, y=t"
			set "swap=x^=y, y^=x, x^=y"
			set "getState=a*8+b*4+c*2+d*1"
			set "max=(((((y-x)>>31)&1)*x)|((~(((y-x)>>31)&1)&1)*y))"
			set "min=(((((x-y)>>31)&1)*x)|((~(((x-y)>>31)&1)&1)*y))"
			set "percentOf=p=x*y/100"
			
	REM -----------------------------------------------------------------------------------------------------------------------------MISC
	) else if /i "!argumentCommand[%%i]!" equ "misc" (
			set "gravity=_G_=1, ?.acceleration+=_G_, ?.velocity+=?.acceleration, ?.acceleration*=0, ?+=?.velocity"
			set "chance=1/((((^!random^!%%100)-x)>>31)&1)"
			set "every=1/(((~(0-(frameCount%%x))>>31)&1)&((~((frameCount%%x)-0)>>31)&1))"
			set "smoothStep=(3*100 - 2 * x) * x/100 * x/100"
			set "bitColor=C=((r)*6/256)*36+((g)*6/256)*6+((b)*6/256)+16"
			set "ifOdd=1/(x&1)"
			set "ifEven=1/(1+x&1)"
			set "RCX=1/((((x-wid)>>31)&1)^(((0-x)>>31)&1))"
			set "RCY=1/((((x-hei)>>31)&1)^(((0-x)>>31)&1))"
			set "edgeCase=1/(((x-0)>>31)&1)|((~(x-wid)>>31)&1)|(((y-0)>>31)&1)|((~(y-=hei)>>31)&1)"
			set "rndBetween=(^!random^! %% (x*2+1) + -x)"
			set "fib=?=c=a+b, a=b, b=c"
			set "rndRGB=r=^!random^! %% 255, g=^!random^! %% 255, b=^!random^! %% 255"
			set "mouseBound=1/(((~(mouseY-ma)>>31)&1)&((~(mb-mouseY)>>31)&1)&((~(mouseX-mc)>>31)&1)&((~(md-mouseX)>>31)&1))"
			
	REM -----------------------------------------------------------------------------------------------------------------------------SHAPE sh
	) else if /i "!argumentCommand[%%i]:~0,2!" equ "sh" (
			set "SQ(x)=x*x"
			set "CUBE(x)=x*x*x"
			set "pmSQ(x)=x+x+x+x"
			set "pmREC(l,w)=l+w+l+w"
			set "pmTRI(a,b,c)=a+b+c"
			set "areaREC(l,w)=l*w"
			set "areaTRI(b,h)=(b*h)/2"
			set "areaTRA(b1,b2,h)=(b1*b2)*h/2"
			set "volBOX(l,w,h)=l*w*h"
			
	REM -----------------------------------------------------------------------------------------------------------------------------AC
	) else if /i "!argumentCommand[%%i]!" equ "ac" (
			set "LSS(x,y)=(((x-y)>>31)&1)"
			set "LEQ(x,y)=((~(y-x)>>31)&1)"
			set "GTR(x,y)=(((y-x)>>31)&1)"
			set "GEQ(x,y)=((~(x-y)>>31)&1)"
			set "EQU(x,y)=(((~(y-x)>>31)&1)&((~(x-y)>>31)&1))"
			set "NEQ(x,y)=((((x-y)>>31)&1)|(((y-x)>>31)&1))"
			set "AND(b1,b2)=(b1&b2)"
			set "OR(b1,b2)=(b1|b2)"
			set "XOR(b1,b2)=(b1^b2)"
			set "TERN(bool,v1,v2)=((bool*v1)|((~bool&1)*v2))"  &REM ?:
			
	REM -----------------------------------------------------------------------------------------------------------------------------TURTLE
	) else if /i "!argumentCommand[%%i]!" equ "turtle" (
			set /a "DFX=%~1", "DFY=%~2", "DFA=%~3"
			set "forward=DFX+=(?+1)*^!cos:x=DFA^!, DFY+=(?+1)*^!sin:x=DFA^!"
			set "turnLeft=DFA-=?"
			set "turnRight=DFA+=?"
			set "TF_push=sX=DFX, sY=DFY, sA=DFA"
			set "TF_pop=DFX=sX, DFY=sY, DFA=sA"
			set "draw=?=^!?^!%esc%[^!DFY^!;^!DFX^!H%pixel%"
			set "home=DFX=0, DFY=0, DFA=0"
			set "cent=DFX=wid/2, DFY=hei/2"
			set "penDown=for /l %%a in (1,1,#) do set /a "^!forward:?=1^!" ^& set "turtleGraphics=%esc%[^!DFY^!;^!DFX^!H%pixel%""
			
	REM -----------------------------------------------------------------------------------------------------------------------------CURSOR c
	) else if /i "!argumentCommand[%%i]!" equ "cursor" (
			set ">=<nul set /p ="
			set "push=%esc%7"
			set "pop=%esc%8"
			set "cursor[U]=%esc%[?A"
			set "cursor[D]=%esc%[?B"
			set "cursor[L]=%esc%[?D"
			set "cursor[R]=%esc%[?C"
			set "colorText=%esc%[38;^!style^!;?m"
			set "colorBack=%esc%[48;^!style^!;?m"
			set "cac=%esc%[1J"
			set "cbc=%esc%[0J"
			set "underLine=%esc%[4m"
			set "capIt=%esc%[0m"
			set "moveXY=%esc%[^!y^!;^!x^!H"
			set "home=%esc%[H"
			set "setDefaultColor=<nul set /p "=%esc%[48;%defaultStyle%;%backgroundColor%m%esc%[38;%defaultStyle%;%textColor%m""
			call :setStyle
			
	REM -----------------------------------------------------------------------------------------------------------------------------GFX
	) else if /i "!argumentCommand[%%i]!" equ "gfx" (
			call :graphicsFunctions
			
	REM -----------------------------------------------------------------------------------------------------------------------------UTIL
	) else if /i "!argumentCommand[%%i]!" equ "util" (
			call :utilityFunctions
			
	REM -----------------------------------------------------------------------------------------------------------------------------CR
	) else if /i "!argumentCommand[%%i]!" equ "8x8" (
			call :characterSprites_8x8
			
	REM -----------------------------------------------------------------------------------------------------------------------------CR
	) else if /i "!argumentCommand[%%i]!" equ "cr" (
			set /a "range=!argumentArgument[%%i][1]!"
			set "totalColorsInRange=0"
			for /l %%a in (0,!range!,255) do set /a "totalColorsInRange+=1" & set "color[!totalColorsInRange!]=%esc%[38;2;255;%%a;0m"
			for /l %%a in (255,-!range!,0) do set /a "totalColorsInRange+=1" & set "color[!totalColorsInRange!]=%esc%[38;2;%%a;255;0m"
			for /l %%a in (0,!range!,255) do set /a "totalColorsInRange+=1" & set "color[!totalColorsInRange!]=%esc%[38;2;0;255;%%am"
			for /l %%a in (255,-!range!,0) do set /a "totalColorsInRange+=1" & set "color[!totalColorsInRange!]=%esc%[38;2;0;%%a;255m"
			for /l %%a in (0,!range!,255) do set /a "totalColorsInRange+=1" & set "color[!totalColorsInRange!]=%esc%[38;2;%%a;0;255m"
			for /l %%a in (255,-!range!,0) do set /a "totalColorsInRange+=1" & set "color[!totalColorsInRange!]=%esc%[38;2;255;0;%%am"
			set /a "range=255 / !argumentArgument[%%i][1]!"
	)
	
	set "argumentCommand[%%i]="
	set "argumentArgument[%%i][1]="
	set "argumentArgument[%%i][2]="
)


if "%debug%" neq "False" (
	@echo on
	call :setfont 16 Consolas
	mode 180,100
) else (
	if not defined wid set /a "wid=width=hei=height"
	if not defined hei set /a "hei=height=wid=width"
	call :setfont %defaultFontSize% %defaultFont%
	mode !wid!,!hei!
)
goto :eof

:___________________________________________________________________________________________
:graphicsFunctions

set "frames=frameCount=(frameCount + 1) %% L.32bit"
set "loop=for /l %%# in () do "
set "framedLoop=%loop% ( set /a "%frames%""
set "throttle=for /l %%# in (1,x,1000000) do rem"

:_point DON'T CALL
rem %point% x y <rtn> _scrn_
set point=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-2" %%1 in ("^!args^!") do (%\n%
	set "_scrn_=^!_scrn_^!!esc![%%2;%%1H%pixel%!esc![0m"%\n%
)) else set args=

:_plot DON'T CALL
rem %plot% x y 0-255 CHAR <rtn> _scrn_
set plot=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set "_scrn_=^!_scrn_^!!esc![%%2;%%1H!esc![38;5;%%3m%%~4!esc![0m"%\n%
)) else set args=

:_RGBpoint DON'T CALL
rem %RGBpoint% x y 0-255 0-255 0-255 CHAR
set rgbpoint=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	set "_scrn_=^!_scrn_^!!esc![%%2;%%1H!esc![38;2;%%3;%%4;%%5m%pixel%!esc![0m"%\n%
)) else set args=

:_translate DON'T CALL
rem %translate% x Xoffset y Yoffset
set translate=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set /a "%%~1+=%%~2, %%3+=%%~4"%\n%
)) else set args=

:_BVector DON'T CALL
rem x y theta(0-360) magnitude(rec.=4 max) <rtn> %~1[]./BV[].
set BVector=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-3" %%1 in ("^!args^!") do (%\n%
	set /a "%%~1.x=^!random^! %% wid + 1"%\n%
	set /a "%%~1.y=^!random^! %% hei + 1"%\n%
	set /a "%%~1.td=^!random^! %% 360"%\n%
	set /a "%%~1.tr=^!random^! %% 62832"%\n%
	set /a "%%~1.m=^!random^! %% 2 + 2"%\n%
	set /a "%%~1.i=^!random^! %% 4 + -1"%\n%
	set /a "%%~1.j=^!random^! %% 4 + -1"%\n%
	if "^!%%~1.i^!" equ "0" if "^!%%~1.j^!" equ "0" (%\n%
		set /a "%%~1.i=1"%\n%
	)%\n%
	set /a "bvr=^!random^! %% 255","bvg=^!random^! %% 255","bvb=^!random^! %% 255"%\n%
	set "%%~1.rgb=38;2;^!bvr^!;^!bvg^!;^!bvb^!m"%\n%
	set "%%~1.fcol=48;2;^!bvr^!;^!bvg^!;^!bvb^!m"%\n%
	for %%a in (bvr bvg bvb) do set "%%a="%\n%
	if "%%~2" neq "" (%\n%
		set /a "%%~1.vd=%%~2"%\n%
		set /a "%%~1.vr=%%~1.vd / 2"%\n%
		set /a "%%~1.vmw=wid - %%~1.vr - 2"%\n%
		set /a "%%~1.vmh=hei - %%~1.vr - 3"%\n%
		set /a "%%~1.x=^!random^! %% (wid - %%~1.vr) + %%~1.vr"%\n%
		set /a "%%~1.y=^!random^! %% (hei - %%~1.vr) + %%~1.vr"%\n%
	)%\n%
	if "%%~3" neq "" set "%%~1.ch=%%~3"%\n%
)) else set args=

:_lerpRGB DON'T CALL
rem %lerpRGB% rgb1 rgb2 1-100 <rtn> $r $g $b
set lerpRGB=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-3" %%1 in ("^!args^!") do (%\n%
	set /a "a=r[%%~1], b=r[%%~2], c=%%~3, $r=^!lerp^!"%\n%
	set /a "a=g[%%~1], b=g[%%~2], c=%%~3, $g=^!lerp^!"%\n%
	set /a "a=b[%%~1], b=b[%%~2], c=%%~3, $b=^!lerp^!"%\n%
)) else set args=

:_getDistance DON'T CALL
rem %getDistance% x2 x1 y2 y1 <rtnVar>
set getDistance=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	set /a "%%5=( ?=((((((%%1 - %%2))>>31|1)*((%%1 - %%2)))-((((%%3 - %%4))>>31|1)*((%%3 - %%4))))>>31)+1, ?*(2*((((%%1 - %%2))>>31|1)*((%%1 - %%2)))-((((%%3 - %%4))>>31|1)*((%%3 - %%4)))-(((((%%1 - %%2))>>31|1)*((%%1 - %%2)))-((((%%3 - %%4))>>31|1)*((%%3 - %%4))))) + ^^^!?*(((((%%1 - %%2))>>31|1)*((%%1 - %%2)))-((((%%3 - %%4))>>31|1)*((%%3 - %%4)))-(((((%%1 - %%2))>>31|1)*((%%1 - %%2)))-((((%%3 - %%4))>>31|1)*((%%3 - %%4)))*2)) )"%\n%
)) else set args=

:_exp DON'T CALL
rem %exp% num pow <rtnVar>
for /l %%a in (1,1,1095) do set "pb=!pb!x*"
set exp=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-3" %%1 in ("^!args^!") do (%\n%
	set /a "x=%%~1","$p=%%~2*2-1"%\n%
	for %%a in (^^!$p^^!) do set /a "%%~3=^!pb:~0,%%a^!"%\n%
)) else set args=

:_circle DON'T CALL
rem %circle% x y ch cw <rtn> $circle
set circle=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set "$circle="%\n%
	for /l %%a in (0,3,360) do (%\n%
		set /a "xa=%%~3 * ^!cos:x=%%a^! + %%~1", "ya=%%~4 * ^!sin:x=%%a^! + %%~2"%\n%
		set "$circle=^!$circle^!%esc%[^!ya^!;^!xa^!H%pixel%"%\n%
	)%\n%
	set "$circle=^!$circle^!%esc%[0m"%\n%
)) else set args=

:_rect DON'T CALL
rem %rect% x r length <rtn> $rect
set rect=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set "$rect="%\n%
	set /a "$x=%%~1", "$y=%%~2", "rectw=%%~3", "recth=%%~4"%\n%
	for /l %%b in (1,1,^^!rectw^^!) do ( set /a "$x+=2 * ^!cos:x=0^!", "$y+=2 * ^!sin:x=0^!"%\n%
		set "$rect=^!$rect^!^!esc^![^!$y^!;^!$x^!H%pixel%"%\n%
	)%\n%
	for /l %%b in (1,1,^^!recth^^!) do ( set /a "$x+=2 * ^!cos:x=90^!", "$y+=2 * ^!sin:x=90^!"%\n%
		set "$rect=^!$rect^!^!esc^![^!$y^!;^!$x^!H%pixel%"%\n%
	)%\n%
	for /l %%b in (1,1,^^!rectw^^!) do ( set /a "$x+=2 * ^!cos:x=180^!", "$y+=2 * ^!sin:x=180^!"%\n%
		set "$rect=^!$rect^!^!esc^![^!$y^!;^!$x^!H%pixel%"%\n%
	)%\n%
	for /l %%b in (1,1,^^!recth^^!) do ( set /a "$x+=2 * ^!cos:x=270^!", "$y+=2 * ^!sin:x=270^!"%\n%
		set "$rect=^!$rect^!^!esc^![^!$y^!;^!$x^!H%pixel%"%\n%
	)%\n%
	set "$rect=^!$rect^!%esc%[0m"%\n%
)) else set args=

:_line DON'T CALL
rem line x0 y0 x1 y1 color
set line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	if "%%~5" equ "" ( set "hue=15" ) else ( set "hue=%%~5")%\n%
	set "$line=%esc%[38;5;^!hue^!m"%\n%
	set /a "xa=%%~1", "ya=%%~2", "xb=%%~3", "yb=%%~4", "dx=%%~3 - %%~1", "dy=%%~4 - %%~2"%\n%
	if ^^!dy^^! lss 0 ( set /a "dy=-dy", "stepy=-1" ) else ( set "stepy=1" )%\n%
	if ^^!dx^^! lss 0 ( set /a "dx=-dx", "stepx=-1" ) else ( set "stepx=1" )%\n%
	set /a "dx<<=1", "dy<<=1"%\n%
	if ^^!dx^^! gtr ^^!dy^^! (%\n%
		set /a "fraction=dy - (dx >> 1)"%\n%
		for /l %%x in (^^!xa^^!,^^!stepx^^!,^^!xb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "ya+=stepy", "fraction-=dx"%\n%
			set /a "fraction+=dy"%\n%
			set "$line=^!$line^!%esc%[^!ya^!;%%xHU"%\n%
		)%\n%
	) else (%\n%
		set /a "fraction=dx - (dy >> 1)"%\n%
		for /l %%y in (^^!ya^^!,^^!stepy^^!,^^!yb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "xa+=stepx", "fraction-=dy"%\n%
			set /a "fraction+=dx"%\n%
			set "$line=^!$line^!%esc%[%%y;^!xa^!HU"%\n%
		)%\n%
	)%\n%
)) else set args=

:_bezier DON'T CALL
rem %bezier% x1 y1 x2 y2 x3 y3 x4 y4 length
set bezier=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-9" %%1 in ("^!args^!") do (%\n%
	set "$bezier=" ^& set "c=0"%\n%
	set /a "px[0]=%%~1","py[0]=%%~2", "px[1]=%%~3","py[1]=%%~4", "px[2]=%%~5","py[2]=%%~6", "px[3]=%%~7","py[3]=%%~8"%\n%
	for /l %%# in (1,1,%%~9) do (%\n%
		set /a "vx[1]=(px[0]+c*(px[1]-px[0])*10)/1000+px[0]","vy[1]=(py[0]+c*(py[1]-py[0])*10)/1000+py[0]","vx[2]=(px[1]+c*(px[2]-px[1])*10)/1000+px[1]","vy[2]=(py[1]+c*(py[2]-py[1])*10)/1000+py[1]","vx[3]=(px[2]+c*(px[3]-px[2])*10)/1000+px[2]","vy[3]=(py[2]+c*(py[3]-py[2])*10)/1000+py[2]","vx[4]=(vx[1]+c*(vx[2]-vx[1])*10)/1000+vx[1]","vy[4]=(vy[1]+c*(vy[2]-vy[1])*10)/1000+vy[1]","vx[5]=(vx[2]+c*(vx[3]-vx[2])*10)/1000+vx[2]","vy[5]=(vy[2]+c*(vy[3]-vy[2])*10)/1000+vy[2]","vx[6]=(vx[4]+c*(vx[5]-vx[4])*10)/1000+vx[4]","vy[6]=(vy[4]+c*(vy[5]-vy[4])*10)/1000+vy[4]","c+=1"%\n%
		set "$bezier=^!$bezier^!%esc%[^!vy[6]^!;^!vx[6]^!H%pixel%"%\n%
	)%\n%
)) else set args=

:_RGBezier DON'T CALL
rem %bezier% x1 y1 x2 y2 x3 y3 x4 y4 length
set RGBezier=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-9" %%1 in ("^!args^!") do (%\n%
	set "$bezier=" ^& set "c=0"%\n%
	set /a "px[0]=%%~1","py[0]=%%~2", "px[1]=%%~3","py[1]=%%~4", "px[2]=%%~5","py[2]=%%~6", "px[3]=%%~7","py[3]=%%~8"%\n%
	for /l %%m in (1,1,%%~9) do (%\n%
		set /a "vx[1]=(px[0]+c*(px[1]-px[0])*10)/1000+px[0]","vy[1]=(py[0]+c*(py[1]-py[0])*10)/1000+py[0]","vx[2]=(px[1]+c*(px[2]-px[1])*10)/1000+px[1]","vy[2]=(py[1]+c*(py[2]-py[1])*10)/1000+py[1]","vx[3]=(px[2]+c*(px[3]-px[2])*10)/1000+px[2]","vy[3]=(py[2]+c*(py[3]-py[2])*10)/1000+py[2]","vx[4]=(vx[1]+c*(vx[2]-vx[1])*10)/1000+vx[1]","vy[4]=(vy[1]+c*(vy[2]-vy[1])*10)/1000+vy[1]","vx[5]=(vx[2]+c*(vx[3]-vx[2])*10)/1000+vx[2]","vy[5]=(vy[2]+c*(vy[3]-vy[2])*10)/1000+vy[2]","vx[6]=(vx[4]+c*(vx[5]-vx[4])*10)/1000+vx[4]","vy[6]=(vy[4]+c*(vy[5]-vy[4])*10)/1000+vy[4]","c+=1"%\n%
		set "$bezier=^!$bezier^!^!color[%%m]^!%esc%[^!vy[6]^!;^!vx[6]^!H%pixel%"%\n%
	)%\n%
)) else set args=

:_arc DON'T CALL
rem arc x y size DEGREES(0-360) arcRotationDegrees(0-360) lineThinness color
set arc=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-7" %%1 in ("^!args^!") do (%\n%
	if "%%~7" equ "" ( set "hue=30" ) else ( set "hue=%%~7")%\n%
    for /l %%e in (%%~4,%%~6,%%~5) do (%\n%
		set /a "_x=%%~3 * ^!cos:x=%%~e^! + %%~1", "_y=%%~3 * ^!sin:x=%%~e^! + %%~2"%\n%
		^!plot^! ^^!_x^^! ^^!_y^^! ^^!hue^^! %pixel%%\n%
	)%\n%
)) else set args=

:_plot_HSL_RGB DON'T CALL
rem plot_HSL_RGB x y 0-360 0-10000 0-10000
set plot_HSL_RGB=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	set /a "H=%%3", "S=%%4", "L=%%5"%\n%
	if %%3 geq 360 set /a "H=360"%\n%
	if %%3 leq 0   set /a "H=0"%\n%
	set /a "va=2*L-10000"%\n%
	for /f "tokens=1" %%a in ("^!va^!") do if %%a lss 0 set /a "va=-va"%\n%
	set /a "C=(10000-va)*S/10000"%\n%
	set /a "h1=H*10000/60"%\n%
	set /a "mm=(h1 %% 20000) - 10000"%\n%
	for /f "tokens=1" %%a in ("^!mm^!")  do if %%a lss 0 set /a "mm=-mm"%\n%
	set /a "X=C *(10000 - mm)/10000"%\n%
	set /a "m=L - C/2"%\n%
	for /f "tokens=1" %%a in ("^!H^!") do (%\n%
		if %%a lss 60  ( set /a "R=C+m", "G=X+m", "B=0+m" ) else (%\n%
		if %%a lss 120 ( set /a "R=X+m", "G=C+m", "B=0+m" ) else (%\n%
		if %%a lss 180 ( set /a "R=0+m", "G=C+m", "B=X+m" ) else (%\n%
		if %%a lss 240 ( set /a "R=0+m", "G=X+m", "B=C+m" ) else (%\n%
		if %%a lss 300 ( set /a "R=X+m", "G=0+m", "B=C+m" ) else (%\n%
		if %%a lss 360 ( set /a "R=C+m", "G=0+m", "B=X+m" ))))))%\n%
	)%\n%
	set /a "R=R*255/10000", "G=G*255/10000", "B=B*255/10000"%\n%
	^!rgbplot^! %%1 %%2 ^^!R^^! ^^!G^^! ^^!B^^!%\n%
)) else set args=

:_plot_HSV_RGB DON'T CALL
rem plot_HSV_RGB x y 0-360 0-10000 0-10000
set plot_HSV_RGB=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	set /a "H=%%3", "S=%%4", "V=%%5"%\n%
	if %%3 geq 360 set /a "H=360"%\n%
	if %%3 leq 0   set /a "H=0"%\n%
	set /a "h1=h*10000/60"%\n%
	set /a "mm=(h1 %% 20000) - 10000"%\n%
	for /f "tokens=1" %%a in ("^!mm^!") do if %%a lss 0 set /a "mm=-mm"%\n%
	set /a "C=(V * S) / 10000"%\n%
	set /a "X=C *(10000 - mm) / 10000"%\n%
	set /a "m=V - C"%\n%
	for /f "tokens=1" %%a in ("^!H^!") do (%\n%
		if %%a lss 60  ( set /a "R=C+m", "G=X+m", "B=0+m") else (%\n%
		if %%a lss 120 ( set /a "R=X+m", "G=C+m", "B=0+m") else (%\n%
		if %%a lss 180 ( set /a "R=0+m", "G=C+m", "B=X+m") else (%\n%
		if %%a lss 240 ( set /a "R=0+m", "G=X+m", "B=C+m") else (%\n%
		if %%a lss 300 ( set /a "R=X+m", "G=0+m", "B=C+m") else (%\n%
		if %%a lss 360 ( set /a "R=C+m", "G=0+m", "B=X+m"))))))%\n%
	)%\n%
	set /a "R=R*255/10000", "G=G*255/10000", "B=B*255/10000"%\n%
	^!rgbplot^! %%1 %%2 ^^!R^^! ^^!G^^! ^^!B^^!%\n%
)) else set args=

:_clamp DON'T CALL
rem clamp x min max RETURNVAR
set clamp=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set /a "xx=%%~1", "yy=%%2", "zz=%%3"%\n%
	for /f "tokens=1-3" %%x in ("^!xx^! ^!yy^! ^!zz^!") do (%\n%
			   if %%x lss %%y ( set /a "xx=%%y"%\n%
		) else if %%x gtr %%z ( set /a "xx=%%z" )%\n%
	)%\n%
	for /f "tokens=1" %%x in ("^!xx^!") do (%\n%
		if "%%4" neq "" ( set /a "%%4=%%x" ) else ( echo=%%x)%\n%
	)%\n%
)) else set args=

:__map DON'T CALL
rem _map min max X RETURNVAR
set _map=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	%= Scale, bias and saturate x to 0..100 range =%%\n%
	set /a "clamped=((%%3) - %%1) * 100 ^/ (%%2 - %%1) + 1"%\n%
	for /f "tokens=1" %%c in ("^!clamped^!") do ^!clamp^! %%c 0 100 CLAMPED_x %\n%
	%= Evaluate polynomial =%%\n%
	set /a "ss=^(3*100 - 2 * CLAMPED_x^) * CLAMPED_x^/100 * CLAMPED_x^/100"%\n%
	for /f "tokens=1" %%x in ("^!ss^!") do (%\n%
		if "%%4" neq "" ( set "%%4=%%x" ) else ( echo=%%x)%\n%
	)%\n%
)) else set args=

:_FNCross DON'T CALL
rem FNcross x1 y1 x2 y2 RETURNVAR
set FNcross=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	set /a "%%~5=%%~1*%%~4 - %%~2*%%~3"%\n%
)) else set args=

:_intersect DON'T CALL
rem CROSS VECTOR PRODUCT algorithm
rem intersect x1 y1 x2 y2 x3 y3 x4 y4 RETURNVAR RETURNVAR
set intersect=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-10" %%a in ("^!args^!") do (%\n%
	%= x1-a y1-b x2-c y2-d x3-e y3-f x4-g y4-h x-i y-j =%%\n%
	!^FNcross^! %%a %%b %%c %%d FNx%\n%
	!^FNcross^! %%e %%f %%g %%h FNy%\n%
	set /a "_t1=%%a-%%c", "_t2=%%c-%%d", "_t3=%%e - %%g", "_t4=%%f-%%h"%\n%
	for /f "tokens=1-4" %%1 in ("^!_t1^! ^!_t2^! ^!_t3^! ^!_t4^!") do ^!FNcross^! %%1 %%2 %%3 %%4 det%\n%
	for /f "tokens=1-6" %%1 in ("^!_t1^! ^!_t2^! ^!_t3^! ^!_t4^! ^!FNx^! ^!FNy^!") do (%\n%
		^!FNcross^! %%5 %%1 %%6 %%3 _x1%\n%
		set /a "%%i=_x1 / det"%\n%
		^!FNcross^! %%5 %%1 %%6 %%3 _y1%\n%
		set /a "%%j=_y1 / det"%\n%
	)%\n%
)) else set args=

:_HSLline DON'T CALL
rem HSLline x1 y1 x2 y2 0-360 0-10000 0-10000
set HSLline=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-7" %%1 in ("^!args^!") do (%\n%
	set /a "xa=%%~1", "ya=%%~2", "xb=%%~3", "yb=%%~4", "dx=%%~3 - %%~1", "dy=%%~4 - %%~2"%\n%
	for /f "tokens=1-2" %%j in ("^!dx^! ^!dy^!") do (%\n%
		if %%~k lss 0 ( set /a "dy=-%%~k", "stepy=-1" ) else ( set "stepy=1" )%\n%
		if %%~j lss 0 ( set /a "dx=-%%~j", "stepx=-1" ) else ( set "stepx=1" )%\n%
		set /a "dx<<=1", "dy<<=1"%\n%
	)%\n%
	for /f "tokens=1-8" %%a in ("^!dx^! ^!dy^! ^!xa^! ^!xb^! ^!ya^! ^!yb^! ^!stepx^! ^!stepy^!") do (%\n%
		if %%~a gtr %%~b (%\n%
			set /a "fraction=%%~b - (%%~a >> 1)"%\n%
			for /l %%x in (%%~c,%%~g,%%~d) do (%\n%
				for /f "tokens=1" %%j in ("^!fraction^!") do if %%~j geq 0 set /a "ya+=%%~h", "fraction-=%%~a"%\n%
				set /a "fraction+=%%~b"%\n%
				for /f "tokens=1" %%j in ("^!ya^!") do (%\n%
					if 0 leq %%x if 0 leq %%~j ^!plot_HSL_RGB^! %%x %%~j %%~5 %%~6 %%~7%\n%
				)%\n%
			)%\n%
		) else (%\n%
			set /a "fraction=%%~a - (%%~b >> 1)"%\n%
			for /l %%y in (%%~e,%%~h,%%~f) do (%\n%
				for /f "tokens=1" %%j in ("^!fraction^!") do if %%~j geq 0 set /a "xa+=%%~g", "fraction-=%%~b"%\n%
				set /a "fraction+=%%~a"%\n%
				for /f "tokens=1" %%j in ("^!xa^!") do (%\n%
					if 0 leq %%~j if 0 leq %%y ^!plot_HSL_RGB^! %%~j %%y %%~5 %%~6 %%~7%\n%
				)%\n%
			)%\n%
		)%\n%
	)%\n%
)) else set args=

goto :eof

:___________________________________________________________________________________________
:utilityFunctions
rem %sort[fwd]:#=stingArray%                               thanks lowsun for these #
SET "sort[fwd]=(FOR %%S in (%%#%%) DO @ECHO %%S) ^| SORT"
rem %sort[rev]:#=stingArray%                                                       #
SET "sort[rev]=(FOR %%S in (%%#%%) DO @ECHO %%S) ^| SORT /R"
rem %filter[fwd]:#=stingArray%                                                     #
SET "filter[fwd]=(FOR %%F in (%%#%%) DO @ECHO %%F) ^| SORT /UNIQ"
rem %filter[rev]:#=stingArray%                                                     #
SET "filter[rev]=(FOR %%F in (%%#%%) DO @ECHO %%F) ^| SORT /UNIQ /R"
rem -------------------------------------------------------------------------------#

:_hexToRGB DON'T CALL
rem %hexToRGB% 00a2ed
set hexToRGB=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-3" %%1 in ("^!args:~1,2^! ^!args:~3,2^! ^!args:~5,2^!") do (%\n%
	set /a "R=0x%%~1", "G=0x%%~2", "B=0x%%~3"%\n%
)) else set args=

:_getLen DON'T CALL
rem %getlen% "string" <rtn> $length
set getLen=for %%# in (1 2) do if %%#==2 ( for /f "tokens=*" %%1 in ("^!args^!") do (%\n%
	set "$_str=%%~1#"%\n%
	set "$length=0"%\n%
	for %%P in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (%\n%
		if "^!$_str:~%%P,1^!" NEQ "" (%\n%
			set /a "$length+=%%P"%\n%
			set "$_str=^!$_str:~%%P^!"%\n%
		)%\n%
	)%\n%
)) else set args=

:_pad DON'T CALL
rem %pad% "string".int <rtn> $padding
set "$paddingBuffer=                                                                                "
set pad=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-3 delims=." %%x in ("^!args^!") do (%\n%
    set "$padding="^&set "$_str=%%~x"^&set "len="%\n%
    (for %%P in (32 16 8 4 2 1) do if "^!$_str:~%%P,1^!" NEQ "" set /a "len+=%%P" ^& set "$_str=^!$_str:~%%P^!") ^& set /a "len-=2"%\n%
    set /a "s=%%~y-len"^&for %%a in (^^!s^^!) do set "$padding=^!$paddingBuffer:~0,%%a^!"%\n%
    if "%%~z" neq "" set "%%~z=^!$padding^!"%\n%
)) else set args=

:_encodeB64 DON'T CALL
rem %encode% "string" <rtn> base64
set encode=for %%# in (1 2) do if %%#==2 ( for /f "tokens=*" %%1 in ("^!args^!") do (%\n%
	echo=%%~1^>inFile.txt%\n%
	certutil -encode "inFile.txt" "outFile.txt"^>nul%\n%
	for /f "tokens=* skip=1" %%a in (outFile.txt) do (%\n%
		if "%%~a" neq "-----END CERTIFICATE-----" (%\n%
			set "base64=%%a"%\n%
		)%\n%
	)%\n%
	del /f /q "outFile.txt"%\n%
	del /f /q "inFile.txt"%\n%
)) else set args=

:_decodeB64 DON'T CALL
rem %decode:?=!base64!%
set decode=for %%# in (1 2) do if %%#==2 ( for /f "tokens=*" %%1 in ("^!args^!") do (%\n%
	echo %%~1^>inFile.txt%\n%
	certutil -decode "inFile.txt" "outFile.txt"^>nul%\n%
	for /f "tokens=*" %%a in (outFile.txt) do (%\n%
		set "plainText=%%a"%\n%
	)%\n%
	del /f /q outFile.txt%\n%
	del /f /q inFile.txt%\n%
)) else set args=

:_string_properties DON'T CALL
rem %string_properties "string" <rtn> $_len, $_rev $_upp $_low
set string_properties=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1 delims=" %%1 in ("^!args^!") do (%\n%
	for %%i in ($_len $_rev $_upp $_low) do set "%%i="%\n%
    set "$_str=%%~1" ^& set "$_strC=%%~1" ^& set "$_upp=^!$_strC:~1^!" ^& set "$_low=^!$_strC:~1^!"%\n%
    for %%P in (64 32 16 8 4 2 1) do if "^!$_str:~%%P,1^!" NEQ "" set /a "$_len+=%%P" ^& set "$_str=^!$_str:~%%P^!"%\n%
    set "$_str=^!$_strC:~1^!"%\n%
    for /l %%a in (^^!$_len^^!,-1,0) do set "$_rev=^!$_rev^!^!$_str:~%%~a,1^!"%\n%
    for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do set "$_upp=^!$_upp:%%i=%%i^!"%\n%
    for %%i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "$_low=^!$_low:%%i=%%i^!"%\n%
)) else set args=

rem I take no credit for this gem of a name, but the function does as the name suggests.
:_F.A.R.T - Find And Replace Tool DON'T CALL
rem %fart:?=FILE NAME.EXT% "String":Line#
set fart=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4 delims=:/" %%1 in ("?:^!args:~1^!") do (%\n%
	set "linesInFile=0"%\n%
	for /f "usebackq tokens=*" %%i in ("%%~1") do (%\n%
		set /a "linesInFile+=1"%\n%
		if /i "%%~4" neq "s" (%\n%
			if ^^!linesInFile^^! equ %%~3 echo=%%~2^>^>-temp-.txt%\n%
			echo %%i^>^>-temp-.txt%\n%
		) else (%\n%
			if ^^!linesInFile^^! equ %%~3 ( echo=%%~2^>^>-temp-.txt ) else echo %%i^>^>-temp-.txt%\n%
		)%\n%
	)%\n%
	ren "%%~1" "deltmp.txt" ^& ren "-temp-.txt" "%%~1" ^& del /f /q "deltmp.txt"%\n%
)) else set args=

:_getLatency DON'T CALL
rem %getLatency% <rtn> %latency%
set "getLatency=for /f "tokens=2 delims==" %%l in ('ping -n 1 google.com ^| findstr /L "time="') do set "latency=%%l""

:_download DON'T CALL
rem %download% url file
set download=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-2" %%1 in ("^!args^!") do (%\n%
	Powershell.exe -command "(New-Object System.Net.WebClient).DownloadFile('%%~1','%%~2')"%\n%
)) else set args=

:_ZIP DON'T CALL
rem %zip% file.ext zipFileName
set ZIP=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-2" %%1 in ("^!args^!") do (%\n%
	tar -cf %%~2.zip %%~1%\n%
)) else set args=

:_UNZIP DON'T CALL
rem %unzip% zipFileName
set UNZIP=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1" %%1 in ("^!args^!") do (%\n%
	tar -xf %%~1.zip%\n%
)) else set args=

:_License DO NOT use unless you are DONE editing your code.
rem %license% "mySignature" NOTE: You MUST add at least 1 signature to your script ":::mySignature" without the quotes
set License=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1 delims=" %%1 in ("^!args^!") do (%\n%
	for /f "tokens=*" %%x in ("^!self^!") do set /a "x=%%~zx"%\n%
	for /f "tokens=1,2 delims=:" %%a in ('findstr /n ":::" "%~F0"') do (%\n%
        if "%%b" equ %%1 set /a "i+=1", "x+=i+%%a"%\n%
	)%\n%
	if not exist "^!temp^!\%~n0_cP.txt" echo ^^!x^^!^>"^!temp^!\%~n0_cP.txt"%\n%
	if exist "^!temp^!\%~n0_cP.txt" ^<"^!temp^!\%~n0_cP.txt" set /p "g="%\n%
	if "^!x^!" neq "^!g^!" start /b "" cmd /c del "%~f0" ^& exit%\n%
)) else set args=
goto :eof

:setStyle
rem %setStyle% rgb or %setStyle% bit
set setStyle=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1" %%1 in ("^!args^!") do (%\n%
	if /i "%%~1" equ "rgb" (%\n%
		set "style=2"%\n%
	) else if /i "%%~1" equ "bit" (%\n%
		set "style=5"%\n%
	)%\n%
)) else set args=
goto :eof

:sprites
rem 4x4
set "ball[0]=[1C   [1B[4D     [1B[5D     [1B[5D     [1B[4D   [1D[2A[0m"
set "ball[1]=[1CÛÛÛ[1B[4DÛÛÛÛÛ[1B[5DÛÛÛÛÛ[1B[5DÛÛÛÛÛ[1B[4DÛÛÛ[1D[2A[0m"
goto :eof
:characterSprites_8x8
set "chr[-A]=[3CÛÛ[3C[B[8D[2CÛ[2CÛ[2C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛÛÛÛÛÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8DÛÛÛ[2CÛÛÛ[7A[0m"
set "chr[-B]=ÛÛÛÛÛÛ[2C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[3CÛ[2C[B[8D[CÛÛÛÛÛÛ[C[B[8D[CÛ[5CÛ[B[8D[CÛ[5CÛ[B[8D[CÛ[5CÛ[B[8DÛÛÛÛÛÛÛ[C[7A[0m"
set "chr[-C]=[2CÛÛÛÛ[CÛ[B[8D[CÛ[4CÛÛ[B[8DÛ[6CÛ[B[8DÛ[6C[C[B[8DÛ[6C[C[B[8DÛ[6CÛ[B[8D[CÛ[4CÛÛ[B[8D[2CÛÛÛÛ[CÛ[7A[0m"
set "chr[-D]=ÛÛÛÛÛÛ[2C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[5CÛ[B[8D[CÛ[5CÛ[B[8D[CÛ[5CÛ[B[8D[CÛ[5CÛ[B[8D[CÛ[4CÛ[C[B[8DÛÛÛÛÛÛ[2C[7A[0m"
set "chr[-E]=ÛÛÛÛÛÛÛÛ[B[8D[CÛ[5CÛ[B[8D[CÛ[6C[B[8D[CÛÛÛ[4C[B[8D[CÛ[6C[B[8D[CÛ[6C[B[8D[CÛ[5CÛ[B[8DÛÛÛÛÛÛÛÛ[7A[0m"
set "chr[-F]=ÛÛÛÛÛÛÛÛ[B[8D[CÛ[5CÛ[B[8D[CÛ[5CÛ[B[8D[CÛ[2CÛ[3C[B[8D[CÛÛÛÛ[3C[B[8D[CÛ[2CÛ[3C[B[8D[CÛ[6C[B[8DÛÛÛ[5C[7A[0m"
set "chr[-G]=[2CÛÛÛÛÛÛ[B[8D[CÛ[5CÛ[B[8DÛ[6C[C[B[8DÛ[2CÛÛÛÛÛ[B[8DÛ[2CÛ[3CÛ[B[8DÛ[6CÛ[B[8D[CÛ[4CÛ[C[B[8D[2CÛÛÛÛ[2C[7A[0m"
set "chr[-H]=ÛÛÛ[2CÛÛÛ[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛÛÛÛÛÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8DÛÛÛ[2CÛÛÛ[7A[0m"
set "chr[-I]=ÛÛÛÛÛÛÛ[C[B[8D[3CÛ[4C[B[8D[3CÛ[4C[B[8D[3CÛ[4C[B[8D[3CÛ[4C[B[8D[3CÛ[4C[B[8D[3CÛ[4C[B[8DÛÛÛÛÛÛÛ[C[7A[0m"
set "chr[-J]=[2CÛÛÛÛÛÛ[B[8D[5CÛ[2C[B[8D[5CÛ[2C[B[8D[5CÛ[2C[B[8DÛÛ[3CÛ[2C[B[8DÛ[4CÛ[2C[B[8DÛ[4CÛ[2C[B[8D[CÛÛÛÛ[3C[7A[0m"
set "chr[-K]=ÛÛÛ[CÛÛÛÛ[B[8D[CÛ[3CÛ[2C[B[8D[CÛ[2CÛ[3C[B[8D[CÛÛÛ[4C[B[8D[CÛ[2CÛ[3C[B[8D[CÛ[3CÛ[2C[B[8D[CÛ[4CÛ[C[B[8DÛÛÛ[2CÛÛÛ[7A[0m"
set "chr[-L]=ÛÛÛ[5C[B[8D[CÛ[6C[B[8D[CÛ[6C[B[8D[CÛ[6C[B[8D[CÛ[6C[B[8D[CÛ[5CÛ[B[8D[CÛ[5CÛ[B[8DÛÛÛÛÛÛÛÛ[7A[0m"
set "chr[-M]=ÛÛ[3CÛÛÛ[B[8D[CÛÛ[CÛ[CÛ[C[B[8D[CÛ[CÛ[2CÛ[C[B[8D[CÛ[CÛ[2CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8DÛÛÛ[2CÛÛÛ[7A[0m"
set "chr[-N]=ÛÛ[3CÛÛÛ[B[8D[CÛÛ[3CÛ[C[B[8D[CÛ[CÛ[2CÛ[C[B[8D[CÛ[2CÛ[CÛ[C[B[8D[CÛ[3CÛÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8DÛÛÛ[2CÛÛÛ[7A[0m"
set "chr[-O]=[2CÛÛÛÛ[2C[B[8D[CÛ[4CÛ[C[B[8DÛ[6CÛ[B[8DÛ[6CÛ[B[8DÛ[6CÛ[B[8DÛ[6CÛ[B[8D[CÛ[4CÛ[C[B[8D[2CÛÛÛÛ[2C[7A[0m"
set "chr[-P]=ÛÛÛÛÛÛÛ[C[B[8D[CÛ[5CÛ[B[8D[CÛ[5CÛ[B[8D[CÛ[5CÛ[B[8D[CÛÛÛÛÛÛ[C[B[8D[CÛ[6C[B[8D[CÛ[6C[B[8DÛÛÛ[5C[7A[0m"
set "chr[-Q]=[CÛÛÛÛÛÛ[C[B[8DÛ[6CÛ[B[8DÛ[6CÛ[B[8DÛ[6CÛ[B[8DÛ[6CÛ[B[8DÛ[2CÛ[3CÛ[B[8D[CÛÛÛÛÛÛ[C[B[8D[3CÛ[4C[7A[0m"
set "chr[-R]=ÛÛÛÛÛÛÛ[C[B[8D[CÛ[5CÛ[B[8D[CÛ[5CÛ[B[8D[CÛ[5CÛ[B[8D[CÛÛÛÛÛÛ[C[B[8D[CÛ[3CÛ[2C[B[8D[CÛ[4CÛ[C[B[8DÛÛÛ[2CÛÛÛ[7A[0m"
set "chr[-S]=[CÛÛÛÛÛ[CÛ[B[8DÛ[5CÛÛ[B[8DÛ[6CÛ[B[8D[CÛÛÛÛÛ[2C[B[8D[6CÛ[C[B[8DÛ[6CÛ[B[8DÛÛ[5CÛ[B[8DÛ[CÛÛÛÛÛ[C[7A[0m"
set "chr[-T]=ÛÛÛÛÛÛÛÛ[B[8DÛ[3CÛ[2CÛ[B[8D[4CÛ[3C[B[8D[4CÛ[3C[B[8D[4CÛ[3C[B[8D[4CÛ[3C[B[8D[4CÛ[3C[B[8D[3CÛÛÛ[2C[7A[0m"
set "chr[-U]=ÛÛÛ[2CÛÛÛ[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[2CÛÛÛÛ[2C[7A[0m"
set "chr[-V]=ÛÛÛ[2CÛÛÛ[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[2CÛ[3CÛ[C[B[8D[2CÛ[2CÛ[2C[B[8D[3CÛ[CÛ[2C[B[8D[4CÛ[3C[7A[0m"
set "chr[-W]=ÛÛÛ[2CÛÛÛ[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[4CÛ[C[B[8D[CÛ[CÛ[2CÛ[C[B[8D[CÛ[CÛ[2CÛ[C[B[8D[CÛ[CÛ[2CÛ[C[B[8D[2CÛ[CÛÛ[2C[7A[0m"
set "chr[-X]=ÛÛÛ[2CÛÛÛ[B[8D[CÛ[4CÛ[C[B[8D[2CÛ[2CÛ[2C[B[8D[3CÛÛ[3C[B[8D[2CÛ[2CÛ[2C[B[8D[2CÛ[2CÛ[2C[B[8D[CÛ[4CÛ[C[B[8DÛÛÛ[2CÛÛÛ[7A[0m"
set "chr[-Y]=ÛÛÛ[2CÛÛÛ[B[8D[CÛ[4CÛ[C[B[8D[2CÛ[2CÛ[2C[B[8D[3CÛ[CÛ[2C[B[8D[4CÛ[3C[B[8D[4CÛ[3C[B[8D[4CÛ[3C[B[8D[3CÛÛÛ[2C[7A[0m"
set "chr[-Z]=ÛÛÛÛÛÛÛÛ[B[8DÛ[5CÛ[C[B[8DÛ[4CÛ[2C[B[8D[4CÛ[3C[B[8D[3CÛ[4C[B[8D[2CÛ[4CÛ[B[8D[CÛ[5CÛ[B[8DÛÛÛÛÛÛÛÛ[7A[0m"
set "chr[0]=[2CÛÛÛÛ[2C[1B[8D[CÛ[4CÛ[C[1B[8DÛ[4CÛ[CÛ[1B[8DÛ[3CÛ[2CÛ[1B[8DÛ[2CÛ[3CÛ[1B[8DÛ[CÛ[4CÛ[1B[8D[CÛ[4CÛ[C[1B[8D[2CÛÛÛÛ[2C[7A[0m"
set "chr[1]=[2CÛÛ[4C[1B[8D[CÛ[CÛ[4C[1B[8D[3CÛ[4C[1B[8D[3CÛ[4C[1B[8D[3CÛ[4C[1B[8D[3CÛ[4C[1B[8D[3CÛ[4C[1B[8DÛÛÛÛÛÛÛÛ[7A[0m"
set "chr[2]=[CÛÛÛÛÛÛ[C[1B[8DÛ[6CÛ[1B[8D[6C[CÛ[1B[8D[5CÛÛ[C[1B[8D[3CÛÛ[3C[1B[8D[CÛÛ[4CÛ[1B[8DÛ[6CÛ[1B[8DÛÛÛÛÛÛÛÛ[7A[0m"
set "chr[3]=[CÛÛÛÛÛÛ[C[1B[8DÛ[6CÛ[1B[8DÛ[6CÛ[1B[8D[4CÛÛÛ[C[1B[8D[6C[CÛ[1B[8DÛ[6CÛ[1B[8DÛ[6CÛ[1B[8D[CÛÛÛÛÛÛ[C[7A[0m"
set "chr[4]=[5CÛÛ[C[1B[8D[4CÛ[CÛ[C[1B[8D[3CÛ[2CÛ[C[1B[8D[2CÛ[3CÛ[C[1B[8D[CÛ[4CÛ[C[1B[8DÛÛÛÛÛÛÛÛ[1B[8D[6CÛ[C[1B[8D[5CÛÛÛ[7A[0m"
set "chr[5]=ÛÛÛÛÛÛÛÛ[1B[8DÛ[6CÛ[1B[8DÛ[6C[C[1B[8DÛÛÛÛÛÛÛ[C[1B[8D[6C[CÛ[1B[8DÛ[6CÛ[1B[8DÛ[6CÛ[1B[8D[CÛÛÛÛÛÛ[C[7A[0m"
set "chr[6]=[CÛÛÛÛÛÛ[C[1B[8DÛ[6CÛ[1B[8DÛ[6C[C[1B[8DÛÛÛÛÛÛÛ[C[1B[8DÛ[6CÛ[1B[8DÛ[6CÛ[1B[8DÛ[6CÛ[1B[8D[CÛÛÛÛÛÛ[C[7A[0m"
set "chr[7]=ÛÛÛÛÛÛÛÛ[1B[8DÛ[6CÛ[1B[8D[6CÛ[C[1B[8D[5CÛ[2C[1B[8D[4CÛ[3C[1B[8D[3CÛ[4C[1B[8D[3CÛ[4C[1B[8D[2CÛÛÛ[3C[7A[0m"
set "chr[8]=[CÛÛÛÛÛÛ[C[1B[8DÛ[6CÛ[1B[8DÛ[6CÛ[1B[8D[CÛÛÛÛÛÛ[C[1B[8DÛ[6CÛ[1B[8DÛ[6CÛ[1B[8DÛ[6CÛ[1B[8D[CÛÛÛÛÛÛ[C[7A[0m"
set "chr[9]=[CÛÛÛÛÛÛ[C[1B[8DÛ[6CÛ[1B[8DÛ[6CÛ[1B[8DÛ[6CÛ[1B[8D[CÛÛÛÛÛÛÛ[1B[8D[6C[CÛ[1B[8DÛ[6CÛ[1B[8D[CÛÛÛÛÛÛ[C[7A[0m"
set "chr[_]=[6C[2C[1B[8D[6C[2C[1B[8D[6C[2C[1B[8D[6C[2C[1B[8D[6C[2C[1B[8D[6C[2C[1B[8D[6C[2C[1B[8D        [7A[0m"
set "chr[.]=ÛÛÛÛÛÛÛÛ[1B[8DÛÛÛÛÛÛÛÛ[1B[8DÛÛÛÛÛÛÛÛ[1B[8DÛÛÛÛÛÛÛÛ[1B[8DÛÛÛÛÛÛÛÛ[1B[8DÛÛÛÛÛÛÛÛ[1B[8DÛÛÛÛÛÛÛÛ[1B[8DÛÛÛÛÛÛÛÛ[7A[0m"
set "tile[grass][0]=[38;2;8;222;36mÛÛÛÛÛÛÛÛ[B[8D[38;2;0;139;94mÛ[38;2;8;222;36mÛÛÛ[38;2;0;139;94mÛ[38;2;8;222;36mÛÛÛ[B[8D[38;2;0;139;94mÛÛ[38;2;8;222;36mÛ[38;2;0;139;94mÛÛÛ[38;2;8;222;36mÛ[38;2;0;139;94mÛ[B[8D[38;2;165;85;62mÛ[38;2;8;222;36mÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛÛÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛ[B[8D[38;2;165;85;62mÛ[38;2;8;222;36mÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛ[38;2;124;38;77mÛ[38;2;165;85;62mÛÛÛ[B[8D[38;2;165;85;62mÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛÛÛÛÛÛ[B[8D[38;2;165;85;62mÛÛÛÛÛ[38;2;110;125;164mÛ[38;2;165;85;62mÛÛ[B[8D[38;2;165;85;62mÛ[38;2;254;168;0mÛ[38;2;165;85;62mÛÛÛÛÛÛ[7A[0m"
set "tile[grass][1]=[38;2;8;222;36mÛÛÛÛÛÛÛÛ[B[8D[38;2;8;222;36mÛÛÛÛ[38;2;0;139;94mÛ[38;2;8;222;36mÛÛÛ[B[8D[38;2;0;139;94mÛ[38;2;8;222;36mÛÛ[38;2;0;139;94mÛÛ[38;2;8;222;36mÛÛÛ[B[8D[38;2;0;139;94mÛ[38;2;8;222;36mÛÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛ[38;2;0;139;94mÛ[38;2;8;222;36mÛ[38;2;0;139;94mÛ[B[8D[38;2;0;139;94mÛ[38;2;8;222;36mÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛÛÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛ[B[8D[38;2;165;85;62mÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛÛÛ[38;2;254;168;0mÛ[38;2;0;139;94mÛÛ[B[8D[38;2;165;85;62mÛÛÛÛÛÛÛÛ[B[8D[38;2;165;85;62mÛÛ[38;2;110;125;164mÛ[38;2;165;85;62mÛÛÛ[38;2;249;206;164mÛ[38;2;165;85;62mÛ[7A[0m"
set "tile[grass][2]=[38;2;8;222;36mÛÛÛÛÛÛÛÛ[B[8D[38;2;0;139;94mÛ[38;2;8;222;36mÛ[38;2;0;139;94mÛÛÛ[38;2;8;222;36mÛÛ[38;2;0;139;94mÛ[B[8D[38;2;0;139;94mÛÛ[38;2;165;85;62mÛÛ[38;2;0;139;94mÛ[38;2;8;222;36mÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛ[B[8D[38;2;165;85;62mÛÛÛÛÛ[38;2;8;222;36mÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛ[B[8D[38;2;165;85;62mÛ[38;2;254;168;0mÛ[38;2;165;85;62mÛÛÛ[38;2;0;139;94mÛ[38;2;8;222;36mÛ[38;2;165;85;62mÛ[B[8D[38;2;165;85;62mÛÛÛÛÛ[38;2;8;222;36mÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛ[B[8D[38;2;165;85;62mÛÛÛ[38;2;94;85;80mÛ[38;2;165;85;62mÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛÛ[B[8D[38;2;165;85;62mÛÛÛÛÛÛÛÛ[7A[0m"
set "tile[grass][3]=[38;2;8;222;36mÛÛÛÛÛÛÛÛ[B[8D[38;2;8;222;36mÛÛÛÛÛ[38;2;0;139;94mÛÛ[38;2;8;222;36mÛ[B[8D[38;2;0;139;94mÛÛ[38;2;8;222;36mÛÛÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛ[38;2;0;139;94mÛ[B[8D[38;2;165;85;62mÛ[38;2;0;139;94mÛ[38;2;8;222;36mÛÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛÛÛ[B[8D[38;2;165;85;62mÛÛ[38;2;0;139;94mÛ[38;2;8;222;36mÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛÛÛ[B[8D[38;2;165;85;62mÛÛÛ[38;2;0;139;94mÛ[38;2;165;85;62mÛÛ[38;2;124;38;77mÛ[38;2;165;85;62mÛ[B[8D[38;2;165;85;62mÛ[38;2;254;168;0mÛ[38;2;165;85;62mÛÛÛÛÛÛ[B[8D[38;2;165;85;62mÛÛÛÛ[38;2;255;118;167mÛ[38;2;165;85;62mÛÛÛ[7A[0m"
goto :eof

:buildSketch to avoid illegal characters, decode from base64 to bat file,. open and inspect sketch.bat
if exist Sketch.bat goto :eof
for %%i in (
	"QGVjaG8gb2ZmICYgc2V0bG9jYWwgZW5hYmxlRGVsYXllZEV4cGFuc2lvbiAmIHNl"
	"dCAiKD0oc2V0ICJcPT8iICYgcmVuICIlfm54MCIgLXQuYmF0ICYgcmVuICI/LmJh"
	"dCIgIiV+bngwIiIgJiBzZXQgIik9cmVuICIlfm54MCIgIl5eIVxeXiEuYmF0IiAm"
	"IHJlbiAtdC5iYXQgIiV+bngwIikiICYgc2V0ICJzZWxmPSV+bngwIiAmIHNldCAi"
	"ZmFpbGVkTGlicmFyeT1yZW4gLXQuYmF0ICIlfm54MCIgJmVjaG8gTGlicmFyeSBu"
	"b3QgZm91bmQgJiB0aW1lb3V0IC90IDMgJiBleGl0Ig0KDQpzZXQgInJldmlzaW9u"
	"UmVxdWlyZWQ9NC4wLjAiDQooJSg6Pz1MaWJyYXJ5JSAmJiAoY2FsbCA6cmV2aXNp"
	"b24pfHwoJWZhaWxlZExpYnJhcnklKSkyPm51bA0KCWNhbGwgOlN0ZExpYiAvdzpO"
	"IC9oOk4gL2ZzOk4gL3RpdGxlOiJmb29iYXIiIC9yZ2I6ImZvbyI6ImJhciIgL2Rl"
	"YnVnIC9leHRsaWIgLzNyZHBhcnR5IC9tdWx0aSAvc3ByaXRlIC9tYXRoIC9taXNj"
	"IC9zaGFwZSAvYWMgL3R1cnRsZSAvY3Vyc29yIC9jcjpOIC9nZnggL3V0aWwNCiUp"
	"JSAgJiYgKGNscyZnb3RvIDpzZXR1cCkNCjpzZXR1cA0KDQpyZW0gWU9VUiBDT0RF"
	"IEdPRVMgSEVSRQ0KDQpwYXVzZSAmIGV4aXQ="
) do echo %%~i>>"encodedSketch.txt"
certutil -decode "encodedSketch.txt" "Sketch.bat"
del /q /f "encodedSketch.txt"
goto :eof

:setFont DON'T CALL
if "%~2" equ "" goto :eof
call :init_setfont
%setFont% %~1 %~2
goto :eof

:init_setfont DON'T CALL
:: - BRIEF -
::  Get or set the console font size and font name.
:: - SYNTAX -
::  %setfont% [fontSize [fontName]]
::    fontSize   Size of the font. (Can be 0 to preserve the size.)
::    fontName   Name of the font. (Can be omitted to preserve the name.)
:: - EXAMPLES -
::  Output the current console font size and font name:
::    %setfont%
::  Set the console font size to 14 and the font name to Lucida Console:
::    %setfont% 14 Lucida Console
setlocal DisableDelayedExpansion
set setfont=for /l %%# in (1 1 2) do if %%#==2 (^
%=% for /f "tokens=1,2*" %%- in ("? ^^!arg^^!") do endlocal^&powershell.exe -nop -ep Bypass -c ^"Add-Type '^
%===% using System;^
%===% using System.Runtime.InteropServices;^
%===% [StructLayout(LayoutKind.Sequential,CharSet=CharSet.Unicode)] public struct FontInfo{^
%=====% public int objSize;^
%=====% public int nFont;^
%=====% public short fontSizeX;^
%=====% public short fontSizeY;^
%=====% public int fontFamily;^
%=====% public int fontWeight;^
%=====% [MarshalAs(UnmanagedType.ByValTStr,SizeConst=32)] public string faceName;}^
%===% public class WApi{^
%=====% [DllImport(\"kernel32.dll\")] public static extern IntPtr CreateFile(string name,int acc,int share,IntPtr sec,int how,int flags,IntPtr tmplt);^
%=====% [DllImport(\"kernel32.dll\")] public static extern void GetCurrentConsoleFontEx(IntPtr hOut,int maxWnd,ref FontInfo info);^
%=====% [DllImport(\"kernel32.dll\")] public static extern void SetCurrentConsoleFontEx(IntPtr hOut,int maxWnd,ref FontInfo info);^
%=====% [DllImport(\"kernel32.dll\")] public static extern void CloseHandle(IntPtr handle);}';^
%=% $hOut=[WApi]::CreateFile('CONOUT$',-1073741824,2,[IntPtr]::Zero,3,0,[IntPtr]::Zero);^
%=% $fInf=New-Object FontInfo;^
%=% $fInf.objSize=84;^
%=% [WApi]::GetCurrentConsoleFontEx($hOut,0,[ref]$fInf);^
%=% If('%%~.'){^
%===% $fInf.nFont=0; $fInf.fontSizeX=0; $fInf.fontFamily=0; $fInf.fontWeight=0;^
%===% If([Int16]'%%~.' -gt 0){$fInf.fontSizeY=[Int16]'%%~.'}^
%===% If('%%~/'){$fInf.faceName='%%~/'}^
%===% [WApi]::SetCurrentConsoleFontEx($hOut,0,[ref]$fInf);}^
%=% Else{(''+$fInf.fontSizeY+' '+$fInf.faceName)}^
%=% [WApi]::CloseHandle($hOut);^") else setlocal EnableDelayedExpansion^&set arg=
endlocal &set "setfont=%setfont%"
if !!# neq # set "setfont=%setfont:^^!=!%"
exit /b