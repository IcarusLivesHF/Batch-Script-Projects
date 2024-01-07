@echo off & setlocal enableDelayedExpansion 

if "%~1" neq "" goto :%~1

set "skipIntro=FALSE"

set /a "wid=130", "hei=40"
mode %wid%,%hei%

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
set /a "ball.i=(!random! %% 2 * 2 - 1) * (!random! %% 3 + 1)"
set /a "ball.j=(!random! %% 2 * 2 - 1) * (!random! %% 3 + 1)"
set /a "ball.speed=5"
set "player.movementSpeed=5"
set "computer.movementSpeed=5"
for %%i in (player computer) do set "%%i.score=0"
set /a "centy=hei / 2 - 10"

if /i "%skipIntro%" neq "true" (
	title Made by IcarusLives
		for /l %%i in (20,1,230) do (
			echo %esc%[!centy!;10H%esc%[38;2;%%i;%%i;%%im%BatchPongLogo:E=%
			for /l %%i in (1,200,1000000) do rem
		)
		for /l %%i in (230,-1,20) do (
			echo %esc%[!centy!;10H%esc%[38;2;%%i;%%i;%%im%BatchPongLogo:E=%
			for /l %%i in (1,200,1000000) do rem
		)
	for /l %%i in (1,200,1000000) do rem
)

"%~F0" Controller >"%temp%\%~n0_signal.txt" | "%~F0" Engine <"%temp%\%~n0_signal.txt"
exit

:Engine
	for /l %%# in () do (		title P or {ENTER} to Pause.    TAB to QUIT.    FPS: !FPS!
	
		set /a "frameCount=(frameCount + 1) %% 0x7FFFFFFF", "t2=t1"
		
		%globalMS% t1
		2>nul set /a "ms=t1-t2", "fps=1000/ms"

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
					       "ball.i=(!random! %% 2 * 2 - 1) * (!random! %% 3 + 1)",^
					       "ball.j=(!random! %% 2 * 2 - 1) * (!random! %% 3 + 1)"
				)
				if !ball.x! gtr %wid% (
					set /a "player.score+=1",^
					       "ball.x=wid / 2", "ball.y=hei / 2",^
					       "ball.i=(!random! %% 2 * 2 - 1) * (!random! %% 3 + 1)",^
					       "ball.j=(!random! %% 2 * 2 - 1) * (!random! %% 3 + 1)"
				)
				if !ball.y! leq 0     set /a "ball.y=0",   "ball.j*=-1"
				if !ball.y! geq %hei% set /a "ball.y=hei", "ball.j*=-1"
				
				if !ball.x! geq !computer.x! (
					if !ball.y! geq !computer.y! (
						set /a "compMaxY=paddle.length + computer.y"
						if !ball.y! leq !compMaxY! (
							set /a "ball.i*=-1"
						)
					)
				)
				
				if !ball.x! leq !player.x! (
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
		
		
		rem check win conditions ------------------------------------------------------
		
		rem YOU WIN ----------------------------------------------------------------
		if !player.score! equ 9 (
			cls
			for /l %%p in (1,1,20) do (
				set /a "px[%%p]=!random! %% wid", "py[%%p]=hei - 1", "pd[%%p]=!random! %% 18 + 4", "dom=!random! %% 3", "pl[%%p]=!random! %% 210 + 20"
				if !dom! equ 0 set /a "pr[%%p]=!random! %% 210 + 20", "pg[%%p]=0", "pb[%%p]=0"
				if !dom! equ 1 set /a "pg[%%p]=!random! %% 210 + 20", "pb[%%p]=0", "pr[%%p]=0"
				if !dom! equ 2 set /a "pb[%%p]=!random! %% 210 + 20", "pr[%%p]=0", "pg[%%p]=0"
			)
			for /l %%z in (1,1,5000) do (
			
				for /l %%p in (1,1,20) do (
					set /a "py[%%p]-=1", "pr[%%p]-=pd[%%p]", "pg[%%p]-=pd[%%p]", "pb[%%p]-=pd[%%p]", "pl[%%p]-=pd[%%p]"
					
					if !pr[%%p]! lss 0 set "pr[%%p]=0"
					if !pg[%%p]! lss 0 set "pg[%%p]=0"
					if !pb[%%p]! lss 0 set "pb[%%p]=0"
					
					if !pl[%%p]! leq 0 (
						set /a "px[%%p]=!random! %% wid", "py[%%p]=hei - 1", "pd[%%p]=!random! %% 18 + 4", "dom=!random! %% 3", "pl[%%p]=!random! %% 210 + 20"
						if !dom! equ 0 set /a "pr[%%p]=!random! %% 210 + 20", "pg[%%p]=0", "pb[%%p]=0"
						if !dom! equ 1 set /a "pg[%%p]=!random! %% 210 + 20", "pb[%%p]=0", "pr[%%p]=0"
						if !dom! equ 2 set /a "pb[%%p]=!random! %% 210 + 20", "pr[%%p]=0", "pg[%%p]=0"
					)
					
					if !py[%%p]! gtr 0 (
						set "particleScreen=!particleScreen!%esc%[38;2;!pr[%%p]!;!pg[%%p]!;!pb[%%p]!m%esc%[!py[%%p]!;!px[%%p]!H%pixel%"
					)
				)
				echo %esc%[2J%esc%[!centy!;10H%esc%[38;2;230;230;230m%you.win:E=%!particleScreen!
				set "particleScreen="
			)
		)
		
		rem YOU LOSE ----------------------------------------------------------------
		if !computer.score! equ 9 (
			cls
			for /l %%p in (1,1,20) do (
				set /a "px[%%p]=!random! %% wid", "py[%%p]=0", "pc[%%p]=!random! %% 210 + 20", "pd[%%p]=!random! %% 18 + 4"				
			)
			for /l %%z in (1,1,5000) do (
			
				for /l %%p in (1,1,20) do (
					set /a "py[%%p]+=1", "pc[%%p]-=pd[%%p]"
					
					if !pc[%%p]! leq 0 (
						set /a "px[%%p]=!random! %% wid", "py[%%p]=0", "pc[%%p]=!random! %% 210 + 20", "pd[%%p]=!random! %% 18 + 4"	
					)
					
					if !py[%%p]! lss %hei% (
						set "particleScreen=!particleScreen!%esc%[38;2;!pc[%%p]!;!pc[%%p]!;!pc[%%p]!m%esc%[!py[%%p]!;!px[%%p]!H%pixel%"
					)
				)
				echo %esc%[2J%esc%[!centy!;10H%esc%[38;2;230;230;230m%you.lose:E=%!particleScreen!
				set "particleScreen="
			)
		)

		
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
				del /f /q %~n0txt.tmp %~n0txt2.tmp >nul
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

rem %globalMS% rtnVar
set globalMS=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1" %%1 in ("^!args^!") do (%\n%
	for /f "tokens=1-4 delims=:.," %%a in ("^!time: =0^!") do (%\n%
		set /a "%%~1=((((1%%a-1000)*60+(1%%b-1000))*60+(1%%c-1000))*100)+(1%%d-1000)"%\n%
	)%\n%
)) else set args=

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
	set "batchPongLogo= ,ggggggggggg,E[48C,ggggggggggg,E[38CE[113DE[BdP"""88""""""Y8,E[15CI8E[14C,dPYb,E[8CdP"""88""""""Y8,E[36CE[113DE[BYb,E[2C88E[6C`8bE[15CI8E[14CIP'`YbE[8CYb,E[2C88E[6C`8bE[36CE[113DE[B `"E[2C88E[6C,8PE[12C88888888E[11CI8E[2C8IE[9C`"E[2C88E[6C,8PE[36CE[113DE[BE[5C88aaaad8P"E[16CI8E[14CI8E[2C8'E[13C88aaaad8P"E[37CE[113DE[BE[5C88""""Y8baE[4C,gggg,ggE[4CI8E[6C,gggg,E[2CI8 dPgg,E[11C88"""""E[4C,ggggg,E[5C,ggg,,ggg,E[5C,gggg,gg E[113DE[BE[5C88E[6C`8bE[2CdP"E[2C"Y8IE[4CI8E[5CdP"E[2C"Yb I8dP" "8IE[10C88E[8CdP"E[2C"Y8ggg ,8" "8P" "8,E[3CdP"E[2C"Y8I E[113DE[BE[5C88E[6C,8P i8'E[4C,8IE[3C,I8,E[3Ci8'E[7CI8PE[4CI8E[10C88E[7Ci8'E[4C,8IE[3CI8E[3C8IE[3C8IE[2Ci8'E[4C,8I E[113DE[BE[5C88_____,d8',d8,E[3C,d8b, ,d88b, ,d8,_E[4C_,d8E[5CI8,E[9C88E[6C,d8,E[3C,d8'E[2C,dPE[3C8IE[3CYb,,d8,E[3C,d8I E[113DE[BE[4C88888888P"E[2CP"Y8888P"`Y888P""Y88P""Y8888PP88PE[5C`Y8E[9C88E[6CP"Y8888P"E[4C8P'E[3C8IE[3C`Y8P"Y8888P"888E[113DE[BE[100CE[8C,d8I'E[113DE[BE[100CE[6C,dP'8I E[113DE[BE[100CE[5C,8"E[2C8I E[113DE[BE[100CE[5CI8E[3C8I E[113DE[BE[100CE[5C`8, ,8I E[113DE[BE[100CE[6C`Y8P"E[2CE[113DE[B"
	set "you.lose=E[7CÛÛÛÛÛ ÛE[4CÛÛE[38CÛÛÛÛÛ ÛE[35CE[100DE[BE[4CÛÛÛÛÛÛE[2CÛE[2CÛÛÛÛÛE[35CÛÛÛÛÛÛE[2CÛE[36CE[100DE[BE[3CÛÛE[3CÛE[2CÛE[5CÛÛÛÛÛE[32CÛÛE[3CÛE[2CÛE[37CE[100DE[BE[2CÛE[4CÛE[2CÛÛE[5CÛ ÛÛE[32CÛE[4CÛE[2CÛE[38CE[100DE[BE[6CÛE[2CÛÛÛE[5CÛE[7CÛÛÛÛE[3CÛÛE[3CÛÛÛÛE[16CÛE[2CÛE[13CÛÛÛÛE[6CÛÛÛÛE[12CE[100DE[BE[5CÛÛE[3CÛÛE[5CÛE[6CÛ ÛÛÛE[2CÛ ÛÛE[4CÛÛÛE[2CÛE[11CÛÛ ÛÛE[12CÛ ÛÛÛE[2CÛE[2CÛ ÛÛÛÛ ÛE[3CÛÛÛE[3CE[100DE[BE[5CÛÛE[3CÛÛE[5CÛE[5CÛE[3CÛÛÛÛE[2CÛÛE[5CÛÛÛÛE[12CÛÛ ÛÛE[11CÛE[3CÛÛÛÛE[2CÛÛE[2CÛÛÛÛE[3CÛ ÛÛÛE[2CE[100DE[BE[5CÛÛE[3CÛÛE[5CÛE[4CÛÛE[4CÛÛE[3CÛÛE[6CÛÛE[13CÛÛ ÛÛE[10CÛÛE[4CÛÛE[2CÛÛÛÛE[7CÛE[3CÛÛÛ E[100DE[BE[5CÛÛE[3CÛÛE[5CÛE[4CÛÛE[4CÛÛE[3CÛÛE[6CÛÛE[13CÛÛ ÛÛE[10CÛÛE[4CÛÛE[4CÛÛÛE[5CÛÛE[4CÛÛÛE[100DE[BE[5CÛÛE[3CÛÛE[5CÛE[4CÛÛE[4CÛÛE[3CÛÛE[6CÛÛE[13CÛÛ ÛÛE[10CÛÛE[4CÛÛE[6CÛÛÛE[3CÛÛÛÛÛÛÛÛ E[100DE[BE[6CÛÛE[2CÛÛE[5CÛE[4CÛÛE[4CÛÛE[3CÛÛE[6CÛÛE[13CÛE[2CÛÛE[10CÛÛE[4CÛÛE[8CÛÛÛ ÛÛÛÛÛÛÛE[2CE[100DE[BE[7CÛÛ ÛE[6CÛE[4CÛÛE[4CÛÛE[3CÛÛE[6CÛÛE[16CÛE[11CÛÛE[4CÛÛE[3CÛÛÛÛE[2CÛÛ ÛÛE[7CE[100DE[BE[8CÛÛÛE[6CÛE[5CÛÛÛÛÛÛE[5CÛÛÛÛÛÛÛ ÛÛE[11CÛÛÛÛE[11CÛ ÛÛÛÛÛÛE[3CÛ ÛÛÛÛ ÛE[2CÛÛÛÛE[4CÛE[100DE[BE[9CÛÛÛÛÛÛÛÛÛE[6CÛÛÛÛE[7CÛÛÛÛÛE[3CÛÛE[9CÛE[2CÛÛÛÛÛÛÛÛÛÛÛÛÛE[3CÛÛÛÛE[7CÛÛÛÛE[4CÛÛÛÛÛÛÛ E[100DE[BE[11CÛÛÛÛ ÛÛÛE[34CÛE[5CÛÛÛÛÛÛÛÛÛE[25CÛÛÛÛÛE[2CE[100DE[BE[17CÛÛÛE[33CÛE[46CE[100DE[BE[5CÛÛÛÛÛÛÛÛE[5CÛÛÛE[33CÛE[45CE[100DE[BE[3CÛÛÛÛÛÛÛÛÛÛÛÛÛE[2CÛÛE[35CÛÛE[43CE[100DE[B ÛE[11CÛÛÛÛE[83CE[100DE[B"
	set "you.win=E[7CÛÛÛÛÛ ÛE[4CÛÛE[39CÛÛÛÛÛ ÛE[4CÛÛE[3CÛÛÛE[22CE[100DE[BE[4CÛÛÛÛÛÛE[2CÛE[2CÛÛÛÛÛE[36CÛÛÛÛÛÛE[2CÛE[2CÛÛÛÛÛE[4CÛÛÛE[4CÛE[16CE[100DE[BE[3CÛÛE[3CÛE[2CÛE[5CÛÛÛÛÛE[33CÛÛE[3CÛE[2CÛE[5CÛÛÛÛÛE[3CÛÛÛE[2CÛÛÛE[15CE[100DE[BE[2CÛE[4CÛE[2CÛÛE[5CÛ ÛÛE[33CÛE[4CÛE[2CÛÛE[5CÛ ÛÛE[6CÛÛE[2CÛE[16CE[100DE[BE[6CÛE[2CÛÛÛE[5CÛE[7CÛÛÛÛE[3CÛÛE[3CÛÛÛÛE[17CÛE[2CÛÛÛE[5CÛE[3CÛE[5CÛÛE[19CE[100DE[BE[5CÛÛE[3CÛÛE[5CÛE[6CÛ ÛÛÛE[2CÛ ÛÛE[4CÛÛÛE[2CÛE[12CÛÛE[3CÛÛE[5CÛE[9CÛÛÛÛÛE[4CÛÛÛE[2CÛÛÛÛE[3CE[100DE[BE[5CÛÛE[3CÛÛE[5CÛE[5CÛE[3CÛÛÛÛE[2CÛÛE[5CÛÛÛÛE[13CÛÛE[3CÛÛE[5CÛE[9CÛÛ ÛÛÛE[4CÛÛÛÛ ÛÛÛÛ ÛE[100DE[BE[5CÛÛE[3CÛÛE[5CÛE[4CÛÛE[4CÛÛE[3CÛÛE[6CÛÛE[14CÛÛE[3CÛÛE[5CÛE[9CÛÛE[2CÛÛE[5CÛÛE[3CÛÛÛÛ E[100DE[BE[5CÛÛE[3CÛÛE[5CÛE[4CÛÛE[4CÛÛE[3CÛÛE[6CÛÛE[14CÛÛE[3CÛÛE[5CÛE[9CÛÛE[2CÛÛE[5CÛÛE[4CÛÛE[2CE[100DE[BE[5CÛÛE[3CÛÛE[5CÛE[4CÛÛE[4CÛÛE[3CÛÛE[6CÛÛE[14CÛÛE[3CÛÛE[5CÛE[9CÛÛE[2CÛÛE[5CÛÛE[4CÛÛE[2CE[100DE[BE[6CÛÛE[2CÛÛE[5CÛE[4CÛÛE[4CÛÛE[3CÛÛE[6CÛÛE[15CÛÛE[2CÛÛE[5CÛE[9CÛÛE[2CÛÛE[5CÛÛE[4CÛÛE[2CE[100DE[BE[7CÛÛ ÛE[6CÛE[4CÛÛE[4CÛÛE[3CÛÛE[6CÛÛE[16CÛÛ ÛE[6CÛE[9CÛE[3CÛÛE[5CÛÛE[4CÛÛE[2CE[100DE[BE[8CÛÛÛE[6CÛE[5CÛÛÛÛÛÛE[5CÛÛÛÛÛÛÛ ÛÛE[16CÛÛÛE[6CÛÛÛE[6CÛE[4CÛÛE[5CÛÛE[4CÛÛE[2CE[100DE[BE[9CÛÛÛÛÛÛÛÛÛE[6CÛÛÛÛE[7CÛÛÛÛÛE[3CÛÛE[16CÛÛÛÛÛÛÛÛ ÛÛÛÛÛÛÛÛE[5CÛÛÛ ÛE[2CÛÛÛE[3CÛÛÛ E[100DE[BE[11CÛÛÛÛ ÛÛÛE[44CÛÛÛÛE[5CÛÛÛÛE[8CÛÛÛE[4CÛÛÛE[3CÛÛÛE[100DE[BE[17CÛÛÛE[80CE[100DE[BE[5CÛÛÛÛÛÛÛÛE[5CÛÛÛE[79CE[100DE[BE[3CÛÛÛÛÛÛÛÛÛÛÛÛÛE[2CÛÛE[80CE[100DE[B ÛE[11CÛÛÛÛE[83CE[100DE[B"

goto :eof
