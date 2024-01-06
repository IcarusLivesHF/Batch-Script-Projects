@echo off & setlocal enableDelayedExpansion 

if "%~1" neq "" goto :%~1

set /a "wid=130", "hei=40"
mode %wid%,%hei%
timeout /t 7
cls

call :macros
call :sprites
call :multithread_init 0 2

set /a "paddle.length=12"
set /a "player.x=3"
set /a "player.y=hei / 2 - 5"
set /a "computer.x=127"
set /a "computer.y=hei / 2 - 5"
set /a "ball.x=wid / 2"
set /a "ball.y=hei / 2"
set /a "ball.i=(!random! %% 2 * 2 - 1)"
set /a "ball.j=(!random! %% 2 * 2 - 1)"
set /a "ball.speed=5"
set "player.movementSpeed=5"
set "computer.movementSpeed=5"
for %%i in (player computer) do set "%%i.score=0"
set /a "centy=hei / 2 - 10"

title Made by IcarusLives
	for /l %%i in (20,1,230) do (
		echo %esc%[!centy!;10H%esc%[38;2;%%i;%%i;%%im%BatchPongLogo%
		for /l %%i in (1,200,1000000) do rem
	)
	for /l %%i in (230,-1,20) do (
		echo %esc%[!centy!;10H%esc%[38;2;%%i;%%i;%%im%BatchPongLogo%
		for /l %%i in (1,200,1000000) do rem
	)
for /l %%i in (1,200,1000000) do rem

"%~F0" Controller >"%temp%\%~n0_signal.txt" | "%~F0" Engine <"%temp%\%~n0_signal.txt"
exit

:Engine
	for /l %%# in () do (		title P or {ENTER} to Pause.    TAB to QUIT.
	
		set /a "frameCount=(frameCount + 1) %% 0x7FFFFFFF"
		
		if !pause! equ 2 (
			
			rem Pause ----------------------------------------------------------------
			set /a "fadingLength=((frameCount / 2) + (frameCount / 4)) %% 300"
			if !fadingLength! lss 150 (
				set /a "fade+=2"
				if !fade! gtr 230 set "fade=230"
			) else (
				set /a "fade-=2"
				if !fade! lss 20   set "fade=20"
			)
			set "screen=!screen!%esc%[48;2;!fade!;!fade!;!fade!m%esc%[38;5;16m%esc%[!hh!;!hw!H%pauseIcon%%esc%[0m"
		) else (
		
		rem All "during game" movement actions here.
			
			rem ball ----------------------------------------------------------------
			2>nul set /a "%every:x=ball.speed%" && (
				set /a "ball.x+=ball.i", "ball.y+=ball.j"
			
				if !ball.x! lss 0 (
					set /a "computer.score+=1",^
					       "ball.x=wid / 2", "ball.y=hei / 2",^
					       "ball.i=(!random! %% 2 * 2 - 1)",^
					       "ball.j=(!random! %% 2 * 2 - 1)"
				)
				if !ball.x! gtr %wid% (
					set /a "player.score+=1",^
					       "ball.x=wid / 2", "ball.y=hei / 2",^
					       "ball.i=(!random! %% 2 * 2 - 1)",^
					       "ball.j=(!random! %% 2 * 2 - 1)"
				)
				if !ball.y! leq 0     set /a "ball.y=0",   "ball.j*=-1"
				if !ball.y! geq %hei% set /a "ball.y=hei", "ball.j*=-1"
				
				if !ball.x! equ !computer.x! (
					if !ball.y! geq !computer.y! (
						set /a "compMaxY=paddle.length + computer.y"
						if !ball.y! leq !compMaxY! (
							set /a "ball.i*=-1"
						)
					)
				)
				
				if !ball.x! equ !player.x! (
					if !ball.y! geq !player.y! (
						set /a "playerMaxY=paddle.length + player.y"
						if !ball.y! leq !playerMaxY! (
							set /a "ball.i*=-1"
						)
					)
				)
				
				
			)
			
			
			rem computer paddle ----------------------------------------------------------------
			2>nul set /a "%every:x=computer.movementSpeed%" && (
				if !ball.y! gtr !computer.y! (
					if !computer.y! lss 29 (
						set /a "computer.y+=2"
					) else set "computer.y=29"
				)
				if !ball.y! lss !computer.y! (
					if !computer.y! gtr 1 (
						set /a "computer.y-=2"
					) else set "computer.y=1"
				)
			)
			
		)
		
		
		rem concatenation to display under this line ----------------------------------------------------------------
		set "screen=!screen!%esc%[!ball.y!;!ball.x!H%pixel%!screen!%esc%[!player.y!;!player.x!H%paddle%!screen!%esc%[!computer.y!;!computer.x!H%paddle%"
		
		rem get score ----------------------------------------------------------------
		%sevenSegmentDisplay% 43 20 !player.score!   10
		set "screen=!screen!!$sevenSegmentDisplay!%esc%[0m"
		%sevenSegmentDisplay% 86 20 !computer.score! 9
		set "screen=!screen!!$sevenSegmentDisplay!%esc%[0m"
		
		rem display ----------------------------------------------------------------
		echo %esc%[2J%esc%[0;65H%dividerSprite%%esc%[H!screen!
		set "screen="

		
		rem gather input from control thread ----------------------------------------------------------------
		%= Read last key press from input buffer - Non blocking input =%
		if not "!Lastkey!"=="Pause" set "lastKey=!key!"
		set "NewKey="
		if "%blocking%" neq "true" set "key="
		set /p "NewKey="
		if defined NewKey for %%v in (!newKey!) do (
			If not "!key_%%v!"=="" set "key=!key_%%v!"
			If /i "%%v" == "quit" exit
		)
		
		%= Implement Control actions. =%
		if defined key (
			if "!key!"=="Pause" (
				set /a "!key!=!pause! %% 2 + 1"
				set "key="
				if not "!key!" == "Pause" set "key=!lastKey!"
				set /a "hh=hei / 2", "hw=wid / 2 - 4"
			)
	
			2>nul set /a "%every:x=player.movementSpeed%" && (
			
				if not !pause! equ 2 (
					if "!key!"=="Up" (
						if !player.y! gtr 1 (
							set /a %Up:?=player%
						) else set "player.y=1"
					)
					if "!Key!"=="Down" (
						if !player.y! lss 29 (
							set /a %Down:?=player%
						) else set "player.y=29"
					)
				)
			)
		)
	)

exit


:Controller
Setlocal DISABLEdelayedExpansion
	REM Environment handling allows use of ! key
	For /l %%C in () do (
		If Exist "%SignalFile:Signal=Stop%" (
			exit
		)
		Set "Key="
		for /f "delims=" %%A in ('C:\Windows\System32\xcopy.exe /w "%~f0" "%~f0" 2^>nul') do If not Defined Key (
	      	set "key=%%A"
			Setlocal ENABLEdelayedExpansion
	      	set key=^!KEY:~-1!
			If "!key!" == "!QUITKEY!" (
				>"%SignalFile:Signal=Abort%" Echo(
				<nul Set /P "=quit"
				EXIT
			)
			If not "!Key!" == "%BS%" If not "!Key!" == "!CR!" (%= Echo without Linefeed. Allows output of Key and Space =%
				1> %~n0txt.tmp (echo(!key!!sub!)
				copy %~n0txt.tmp /a %~n0txt2.tmp /b > nul
				type %~n0txt2.tmp
				del %~n0txt.tmp %~n0txt2.tmp
			)Else (
				If "!Key!" == "%BS%" <nul Set /p "={BACKSPACE}"
				If "!Key!" == "!CR!" <nul Set /p "={ENTER}"
			)
			Endlocal
		)
	)

:multithread_init
	if "%~1" neq "1" set "blocking=true"
	set "signalFile=%temp%\%~n0_signal.txt"
	del /f /q "%SignalFile%" 2>nul 1>nul
	del /f /q "%SignalFile:Signal=Stop%"  2>nul 1>nul
	del /f /q "%SignalFile:Signal=Abort%" 2>nul 1>nul

	for /f %%a in ('"prompt $H&for %%b in (1) do rem"') do set "BS=%%a"
	for /f %%A in ('copy /z "%~dpf0" nul') do set "CR=%%A"
	for /f "delims=" %%T in ('forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo(0x09"') do set "TAB=%%T"

	set "QUITKEY=!TAB!"
	set "key_D=Right"     & set "key_6=Right"
	set "key_A=Left"      & set "key_4=Left"
	set "key_W=Up"        & set "key_8=Up"
	set "key_S=Down"      & set "key_2=Down"
	set "key_P=Pause"     & Set "Pause=1" & Set "key_ =Pause" & Set "key_{ENTER}=Pause"

	if "%~2" neq "" (
		set "movementDistance=%~2"
	) else (
		set "movementDistance=1"
	)
	set "Right=?.x+=movementDistance"     & set "Left= ?.x-=movementDistance"
	set "Up=   ?.y-=movementDistance"     & set "Down= ?.y+=movementDistance"
goto :eof

:macros
(for /f %%a in ('echo prompt $E^| cmd') do set "esc=%%a" ) || ( set "esc=" ) & set "\e="
<nul set /p "=[?25l">con

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)

set "every=1/(((~(0-(frameCount%%x))>>31)&1)&((~((frameCount%%x)-0)>>31)&1))"

rem %sevenSegmentDisplay% x y value color
set /a "segbool[0]=0x7E", "segbool[1]=0x30", "segbool[2]=0x6D", "segbool[3]=0x79", "segbool[4]=0x33", "segbool[5]=0x5B", "segbool[6]=0x5F", "segbool[7]=0x70", "segbool[8]=0x7F", "segbool[9]=0x7B"
set sevenSegmentDisplay=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set "$sevenSegmentDisplay="%\n%
	set /a "qx1=%%~1", "qx2=%%~1 + 1", "qx3=%%~1 + 2", "qx4=%%~1 - 1", "qy1=%%~2", "qy2=%%~2 + 1", "qy3=%%~2 + 2", "qy4=%%~2 + 3", "qy5=%%~2 + 4", "qy6=%%~2 + 5", "qy7=%%~2 + 6"%\n%
	for %%j in ( "6 1 1 2 1" "5 3 2 3 3" "4 3 5 3 6" "3 1 7 2 7" "2 4 5 4 6" "1 4 2 4 3" "0 1 4 2 4" ) do (%\n%
		for /f "tokens=1-5" %%v in ("%%~j") do (%\n%
			set /a "a=%%~4 * ((segbool[%%~3] >> %%~v) & 1)"%\n%
			set "$sevenSegmentDisplay=^!$sevenSegmentDisplay^![38;5;^!a^!m[^!qy%%x^!;^!qx%%w^!HÛ[^!qy%%z^!;^!qx%%y^!HÛ"%\n%
		)%\n%
	)%\n%
)) else set args=
goto :eof

:sprites
	set "pixel=Û"
	set "pauseIcon=%esc%(0lqqqqqqqqk%esc%[10D%esc%[Bx %esc%(BPAUSED%esc%(0 x%esc%[10D%esc%[Bmqqqqqqqqj%esc%[10D%esc%[2A%esc%[0m"
	set "paddle=%pixel%%esc%[D%esc%[B%pixel%%esc%[D%esc%[B%pixel%%esc%[D%esc%[B%pixel%%esc%[D%esc%[B%pixel%%esc%[D%esc%[B%pixel%%esc%[D%esc%[B%pixel%%esc%[D%esc%[B%pixel%%esc%[D%esc%[B%pixel%%esc%[D%esc%[B%pixel%%esc%[D%esc%[B%pixel%%esc%[D%esc%[B%pixel%%esc%[D%esc%[0m"
	set "dividerSprite=%esc%(0x%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx%esc%[D%esc%[Bx"
	set "batchPongLogo= ,ggggggggggg,                                                ,ggggggggggg,                                      %esc%[113D%esc%[BdP"""88""""""Y8,               I8              ,dPYb,        dP"""88""""""Y8,                                    %esc%[113D%esc%[BYb,  88      `8b               I8              IP'`Yb        Yb,  88      `8b                                    %esc%[113D%esc%[B `"  88      ,8P            88888888           I8  8I         `"  88      ,8P                                    %esc%[113D%esc%[B     88aaaad8P"                I8              I8  8'             88aaaad8P"                                     %esc%[113D%esc%[B     88""""Y8ba    ,gggg,gg    I8      ,gggg,  I8 dPgg,           88"""""    ,ggggg,     ,ggg,,ggg,     ,gggg,gg %esc%[113D%esc%[B     88      `8b  dP"  "Y8I    I8     dP"  "Yb I8dP" "8I          88        dP"  "Y8ggg ,8" "8P" "8,   dP"  "Y8I %esc%[113D%esc%[B     88      ,8P i8'    ,8I   ,I8,   i8'       I8P    I8          88       i8'    ,8I   I8   8I   8I  i8'    ,8I %esc%[113D%esc%[B     88_____,d8',d8,   ,d8b, ,d88b, ,d8,_    _,d8     I8,         88      ,d8,   ,d8'  ,dP   8I   Yb,,d8,   ,d8I %esc%[113D%esc%[B    88888888P"  P"Y8888P"`Y888P""Y88P""Y8888PP88P     `Y8         88      P"Y8888P"    8P'   8I   `Y8P"Y8888P"888%esc%[113D%esc%[B                                                                                                            ,d8I'%esc%[113D%esc%[B                                                                                                          ,dP'8I %esc%[113D%esc%[B                                                                                                         ,8"  8I %esc%[113D%esc%[B                                                                                                         I8   8I %esc%[113D%esc%[B                                                                                                         `8, ,8I %esc%[113D%esc%[B                                                                                                          `Y8P"  %esc%[113D%esc%[B%esc%[0m"
goto :eof
