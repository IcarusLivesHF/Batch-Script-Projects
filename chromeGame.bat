@echo off & setlocal enableDelayedExpansion

if "%~1" neq "" goto :%~1

call :init 60 30
call :sprites


set /a "difficulty=1"
set /p "difficulty=%\e%[38;5;196m%\e%[16;14HDifficulty [1-5] %\e%[38;5;39m(%\e%[38;5;228mdefault%\e%[0m= %\e%[38;5;14m1%\e%[38;5;39m)%\e%[0m: "
rem --------------------------------------

set /a "speed=1"
set /a "jump=6"
set /a "floor=hei - 6"
set /a "player.x=6"
set /a "player.y=floor"
set /a "sunOsc=1"


if !difficulty! gtr 5 set "difficulty=5"
title Chrome Game - difficulty: !difficulty! ^| W to jump

for /l %%i in (1,1,10) do (
	set /a "particle[%%i].x=(!random! %% wid) + !random! %% wid"
	set /a "particle[%%i].y=!random! %% (hei - floor + 1) + floor - 1"
)
for /l %%i in (1,1,2) do (
	set /a "cloud[%%i].x=!random! %% wid"
	set /a "cloud[%%i].y=!random! %% 10 + 3"
	set /a "cloud[%%i].i=!random! %% 3 + 1"
)

"%~F0" Controller >"%temp%\%~n0_signal.txt" | "%~F0" Main <"%temp%\%~n0_signal.txt"
exit

:Main

for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100"

for /l %%# in () do (

  for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, dt=t2-t1"

  if !dt! gtr 5 (

	set /a "t1=t2"

	REM set /a "frameCount+=1"
	set /a "$TT+=dt","fps=60 * (1000 / (dt + 1)) / 1000","$sec=$TT / 100 %% 60","$min=$TT / 100 / 60 %% 60","frameCount=(frameCount + 1) %% 0x7FFFFFFF"
	if "!$sec:~1!" equ "" set "$sec=0!$sec!"
	title FPS:!fps! Time: !$min!:!$sec! Frames: !frameCount!/!$TT!
	
	rem sun
	set /a "sunRate=frameCount %% 7"
	if !sunRate! equ 0 (
		set /a "sunID+=sunOsc
	)
	if !sunID! leq 0 set /a "sunID=0", "sunOsc*=-1"
	if !sunID! geq 2 set /a "sunID=2", "sunOsc*=-1"
	for %%i in (!sunID!) do (
		set "scrn=!scrn!%\e%[2;7H!sun[%%i]!"
	)
	
	rem ground particles
	for /l %%i in (1,1,10) do (
		set /a "particle[%%i].x-=2"
		if !particle[%%i].x! leq 1 set /a "particle[%%i].x=wid"
		if !particle[%%i].x! lss %wid% (
			set "scrn=!scrn!%\e%[48;5;34;38;5;232m%\e%[!particle[%%i].y!;!particle[%%i].x!H."
		)
	)
	rem clouds
	for /l %%i in (1,1,2) do (
		set /a "rate=frameCount %% 4"
		if !rate! equ 0 set /a "cloud[%%i].x-=cloud[%%i].i"
		if !cloud[%%i].x! leq 1 set /a "cloud[%%i].x=wid", "cloud[%%i].y=!random! %% 10 + 3"
		if !cloud[%%i].x! lss %wid% (
			set "scrn=!scrn!%\e%[!cloud[%%i].y!;!cloud[%%i].x!H!cloud[%%i]!"
		)
	)
	
	rem score
	set "icon="
	set "return="
	set /a "string=frameCount", "length=0"
	set "str=x!frameCount!"
	for /l %%b in (4,-1,0) do (
		set /a "length|=1<<%%b"
		for %%c in (!length!) do (
			if "!str:~%%c,1!" equ "" (
				set /a "length&=~1<<%%b"
			)
		)
	)
	set /a "length-=1"
	for /l %%i in (0,1,!length!) do (
		set "return=!return!"!string:~%%~i,1!" "
	)
	for %%i in (!return!) do (
		set "icon=!icon!![%%~i]!%\e%[C"
	)
	set "scrn=!scrn!%\e%[8;27H%\e%[48;5;228;38;5;16m!icon!"
	
	if defined spawned (
		set /a "block.x-=speed * (difficulty + 1)"
		
		set /a "end=block.w - block.x - 1"
		if !block.x! leq !end! (
			for %%i in (x y w h) do set "block.%%i="
			set "spawned="
		)
		
		set /a "a=player.x,b=player.y,c=4,d=4,e=block.x,f=block.y,g=block.w-1,h=block.h-1", "$collisionRectRect=%@collisionRectRect%"
		
		for /f "tokens=1,2" %%x in ("!block.w! !block.h!") do (
			set "scrn=!scrn!%\e%[!block.y!;!block.x!H!box[%%~x][%%~y]!"
		)
	) else (
		
		set "spawned=true"
		set /a "block.x=wid", "block.y=floor", "block.w=!random! %% 3 + 2", "block.h=!random! %% 3 + 2"
	)

	set "com=" & set /p "com="
	if /i "!com:~0,4!" equ "quit" (
		exit
	)
	if /i "!com:~0,1!" equ "w" if !player.y! equ %floor% (
		set /a "velocity+=jump * -1"
	)
	
	set /a "acceleration+=1", "velocity+=acceleration", "acceleration=0", "player.y+=velocity"
	
	if !player.y! geq %floor% (
		set /a "player.y=floor", "velocity=0"
	)
	
	echo %\e%[2J%\e%[H%background%!scrn!%\e%[!player.y!;!player.x!H!player!
	set "scrn="
	
	if !$collisionRectRect! gtr 0 ( exit )

	rem for /l %%Z in (0,%delay%,1000000) do rem

  )
	
)2>nul
exit


:Controller
Setlocal DISABLEdelayedExpansion
	REM Environment handling allows use of ! key
For /l %%C in () do (
	Set "Key="
	for /f "delims=" %%A in ('C:\Windows\System32\xcopy.exe /w "%~f0" "%~f0" 2^>nul') do If not Defined Key (
		set "key=%%A"
		Setlocal ENABLEdelayedExpansion
		set key=^!KEY:~-1!
		If "!key!" == "!TAB!" (
			>"%SignalFile:Signal=Abort%" Echo(
			<nul Set /P "=quit"
			EXIT
		)
		1> %~n0txt.tmp (echo(!key!!sub!)
		copy %~n0txt.tmp /a %~n0txt2.tmp /b > nul
		type %~n0txt2.tmp
		del %~n0txt.tmp %~n0txt2.tmp
		Endlocal
	)
)





:init
chcp 65001>nul

for /f "tokens=1 delims==" %%a in ('set') do (
	set "unload=true"
	for %%b in ( cd Path ComSpec SystemRoot temp windir ) do if /i "%%a"=="%%b" set "unload=false"
	if "!unload!"=="true" set "%%a="
)

set "signalFile=%temp%\%~n0_signal.txt"
del /f /q "%SignalFile%" 2>nul 1>nul
del /f /q "%SignalFile:Signal=Stop%"  2>nul 1>nul
del /f /q "%SignalFile:Signal=Abort%" 2>nul 1>nul
	
for /f "delims=" %%T in ('forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo(0x09"') do set "TAB=%%T"

set /a "wid=%~1,hei=%~2" & mode %~1,%~2

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" & <nul set /p "=[?25l"

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)

REM %collisionRectRect% x1 y1 w1 h1 x2 y2 w2 h2   =>   1 if true, else 0
set "@collisionRectRect=((~((a+c)-e)>>31)&1) & ((~((e+g)-a)>>31)&1) & ((~((b+d)-f)>>31)&1) & ((~((f+h)-b)>>31)&1)"
goto :eof

:sprites
set "[1]=%\e%[C %\e%[2D%\e%[B  %\e%[2D%\e%[B▓ %\e%[2D%\e%[B▓ %\e%[3A"
set "[2]=  %\e%[2D%\e%[B%\e%[C %\e%[2D%\e%[B %\e%[C%\e%[2D%\e%[B  %\e%[3A"
set "[3]=   %\e%[3D%\e%[B%\e%[2C %\e%[3D%\e%[B%\e%[C  %\e%[3D%\e%[B   %\e%[3A"
set "[4]= ▓ %\e%[3D%\e%[B ▓ %\e%[3D%\e%[B   %\e%[3D%\e%[B%\e%[2C %\e%[3A"
set "[5]=  %\e%[2D%\e%[B %\e%[C%\e%[2D%\e%[B%\e%[C %\e%[2D%\e%[B  %\e%[3A"
set "[6]= %\e%[2C%\e%[3D%\e%[B   %\e%[3D%\e%[B %\e%[C %\e%[3D%\e%[B   %\e%[3A"
set "[7]=   %\e%[3D%\e%[B%\e%[2C %\e%[3D%\e%[B▓▓ %\e%[3D%\e%[B▓▓ %\e%[3A"
set "[8]=   %\e%[3D%\e%[B   %\e%[3D%\e%[B %\e%[C %\e%[3D%\e%[B   %\e%[3A"
set "[9]=   %\e%[3D%\e%[B %\e%[C %\e%[3D%\e%[B   %\e%[3D%\e%[B%\e%[2C %\e%[3A"
set "[0]=   %\e%[3D%\e%[B %\e%[C %\e%[3D%\e%[B %\e%[C %\e%[3D%\e%[B   %\e%[3A"

set "cloud[1]=%\e%[48;5;15m%\e%[2A%\e%7  %\e%8%\e%[B    %\e%[0m"
set "cloud[2]=%\e%[48;5;15m%\e%[2A%\e%7  %\e%8%\e%[B%\e%[D    %\e%[0m"

set "box[2][2]=%\e%[48;5;1m%\e%[2A%\e%7  %\e%8%\e%[B  %\e%[0m"
set "box[4][2]=%\e%[48;5;1m%\e%[2A%\e%7    %\e%8%\e%[B    %\e%[0m"
set "box[2][4]=%\e%[48;5;1m%\e%[2A%\e%7  %\e%8%\e%[B%\e%7  %\e%8%\e%[B%\e%7  %\e%8%\e%[B  %\e%[0m"
set "box[3][3]=%\e%[48;5;201m%\e%[3A%\e%7   %\e%8%\e%[B%\e%7   %\e%8%\e%[B   %\e%[0m"
set "box[3][4]=%\e%[48;5;201m%\e%[3A%\e%7   %\e%8%\e%[B%\e%7   %\e%8%\e%[B%\e%7   %\e%8%\e%[B   %\e%[0m"
set "box[4][3]=%\e%[48;5;201m%\e%[3A%\e%7    %\e%8%\e%[B%\e%7    %\e%8%\e%[B    %\e%[0m"
set "box[4][4]=%\e%[48;5;196m%\e%[4A%\e%7    %\e%8%\e%[B%\e%7    %\e%8%\e%[B%\e%7    %\e%8%\e%[B    %\e%[0m"
set "box[2][3]=%\e%[48;5;226m%\e%[3A%\e%7  %\e%8%\e%[B%\e%7  %\e%8%\e%[B  %\e%[0m"
set "box[3][2]=%\e%[48;5;202m%\e%[2A%\e%7   %\e%8%\e%[B   %\e%[0m"

set "player=%\e%[48;5;57m%\e%[4A%\e%7    %\e%8%\e%[B%\e%7    %\e%8%\e%[B%\e%7    %\e%8%\e%[B    %\e%[48;5;16m%\e%[2A%\e%[3D %\e%[C %\e%[9D%\e%[4A%\e%[48;2;190;90;190m%\e%[3C%\e%7     %\e%8%\e%[B%\e%7 %\e%[C%\e%[48;5;15m    %\e%[48;2;190;90;190m%\e%8%\e%[B%\e%[C%\e%7      %\e%8%\e%[B%\e%[2D          %\e%[0m%\e%[0m"
set "background=%\e%[48;5;39m%\e%[0J%\e%[23;1H%\e%[48;5;34m%\e%[0J"

set "sun[0]=%\e%[48;5;226m%\e%7%\e%[2C    %\e%8%\e%[B%\e%7%\e%[C      %\e%8%\e%[B%\e%7        %\e%8%\e%[B%\e%7  %\e%[48;5;16m %\e%[48;5;226m   %\e%[48;5;16m %\e%[48;5;226m %\e%8%\e%[B%\e%7        %\e%8%\e%[B%\e%7 %\e%[48;5;16m      %\e%[48;5;226m %\e%8%\e%[B%\e%7%\e%[C %\e%[48;5;16m    %\e%[48;5;226m %\e%8%\e%[B%\e%[2C    %\e%[0m"
set "sun[1]=%\e%[48;5;226m%\e%7%\e%[2C   %\e%8%\e%[B%\e%7%\e%[C     %\e%8%\e%[B%\e%7  %\e%[48;5;16m %\e%[48;5;226m  %\e%[48;5;16m %\e%[48;5;226m %\e%8%\e%[B%\e%7       %\e%8%\e%[B%\e%7 %\e%[48;5;16m     %\e%[48;5;226m %\e%8%\e%[B%\e%7%\e%[C %\e%[48;5;16m   %\e%[48;5;226m %\e%8%\e%[B%\e%[2C   %\e%[6A%\e%[5D%\e%[48;5;39;38;5;202m\%\e%[5C/%\e%[6B%\e%[7D/%\e%[5C\%\e%[0m"
set "sun[2]=%\e%[48;5;226m%\e%7%\e%[C    %\e%8%\e%[B%\e%7 %\e%[48;5;16m %\e%[48;5;226m  %\e%[48;5;16m %\e%[48;5;226m %\e%8%\e%[B%\e%7      %\e%8%\e%[B%\e%7  %\e%[48;5;16m  %\e%[48;5;226m  %\e%8%\e%[B%\e%7  %\e%[48;5;16m  %\e%[48;5;226m  %\e%8%\e%[B%\e%[C    %\e%[5A%\e%[5D%\e%[48;5;39;38;5;202m\%\e%[4C/%\e%[5B%\e%[6D/%\e%[4C\%\e%[0m"
goto :eof
