@echo off & setlocal enableDelayedExpansion & set "(=(set "\=?" & ren "%~nx0" -t.bat & ren "?.bat" "%~nx0"" & set ")=ren "%~nx0" "^^!\^^!.bat" & ren -t.bat "%~nx0")" & set "self=%~nx0" & set "failedLibrary=ren -t.bat "%~nx0" &echo Library not found & timeout /t 3 & exit"
if "%~1" neq "" goto :%~1

set "revisionRequired=4.0.4"
(%(:?=Library% && (call :revision)||(%failedLibrary%))2>nul
	call :stdlib /w:90 /fs:8 /multi /gfx /s /misc
%)%  && (cls&goto :setup)
:setup

call :sprites
%BVector% this 7
%BVector% chaser
set /a "centx=wid/2","centy=hei/2"
set "points=0"
set "pacmanAnimationSpeed=7"
set "pacmanDefaultSpeed=3"
set /a "pacmanSpeed=pacmanDefaultSpeed"
set "pacmanHealth=1"
set "pacman_predetorMode_dur=300"
set "pacman_superSpeed_dur=100"
set "frenzyMode=255"
set /a "r=!random! %% 4" & (if !r! equ 0 (set "Key=Right") else if !r! equ 1 (set "Key=Left") else if !r! equ 2 (set "Key=Up") else if !r! equ 3 (set "Key=Down"))
set "chaserAnimationSpeed=30"
set /a "chaserSpeed=pacmanSpeed * 2 - 1"
set "chaserAnimatedFrame=0"
set "increaseChaserSpeedTime=1750"
set "increaseChaserSpeedChance=25"
set /a "dotAppearanceTime=200", "totalDots=startDot=1"
set "cherryAppearanceTime=2000"
set "shieldAppearanceTime=300"
set "powerUpAppearanceTime=400"
set "shieldAppearanceChance=35"
set "powerUpAppearanceChance=35"
set "pacman_predetorMode=False"
set "pacman_superSpeedMode=False"
set "cherryBool=False"
set "shieldBool=False"
set "powerUpBool=False"
set "skipIntro=False"

if "!skipIntro!" neq "True" (
	title Made by IcarusLives
	for /l %%i in (0,1,255) do (
		echo %\e%!centy!;1H%\e%38;2;%%i;%%i;0m%pacmanKindaLogo%
		%throttle:x=200%
	)
	for /l %%i in (255,-1,0) do (
		echo %\e%!centy!;1H%\e%38;2;%%i;%%i;0m%pacmanKindaLogo%
		%throttle:x=200%
	)
)

%MT_connect% Controller Engine
:Engine
	%framedLoop%
		
		REM Random dots---------------------------------------------------------------------------------------------
		2>nul set /a "%every:x=dotAppearanceTime%" && (
			set /a "totalDots+=1"
			set /a "dot_x[!totalDots!]=!random! %% (wid - 10) + 5", "dot_y[!totalDots!]=!random! %% (hei - 10) + 5"
			set /a "%rndRGB%"
			for /f "tokens=1-3" %%1 in ("!R! !G! !B!") do (
				set "dot_[!totalDots!]=!dot:COLOR=%%1;%%2;%%3!"
			)
		)
		for /l %%i in (!startDot!,1,!totalDots!) do (
			set "screen=!screen!%\e%!dot_y[%%i]!;!dot_x[%%i]!H!dot_[%%i]!"
			
			%getDistance% this.x dot_x[%%i] this.y dot_y[%%i] ballDistance
			if !ballDistance! leq 3 (
				set /a "startDot+=1"
				if !startDot! gtr !totalDots! (
					set /a "startDot=totalDots"
				)
				set "dot_[%%i]="
				set "dot_x[%%i]="
				set "dot_y[%%i]="
				set "dotR[%%i]="
				set "dotG[%%i]="
				set "dotB[%%i]="
				set /a "points+=1"
			)
		)
		REM Random Shields------------------------------------------------------------------------------------------
		if "!shieldBool!" neq "True" (
			2>nul set /a "%chance:x=shieldAppearanceChance%" && (
				2>nul set /a "%every:x=shieldAppearanceTime%" && (
					set /a "shield_x=!random! %% (wid - 10) + 5", "shield_y=!random! %% (hei - 10) + 5"
					set "totalShields=1"
					set "shieldBool=True"
				)
			)
		)
		for /l %%i in (1,1,!totalShields!) do (
			set "screen=!screen!%\e%!shield_y!;!shield_x!H%shield%"
		)
		%getDistance% this.x shield_x this.y shield_y shieldDistance
		if !shieldDistance! leq 4 (
			set /a "totalShields=0", "pacmanHealth+=1"
			set "shieldBool=False"
			set "shield_x="
			set "shield_y="
		)
		REM PowerUps------------------------------------------------------------------------------------------------
		if "!powerUpBool!" neq "True" (
			2>nul set /a "%chance:x=powerUpAppearanceChance%" && (
				2>nul set /a "%every:x=powerUpAppearanceTime%" && (
					set /a "powerUp_x=!random! %% (wid - 10) + 5", "powerUp_y=!random! %% (hei - 10) + 5"
					set "totalpowerUps=1"
					set "powerUpBool=True"
				)
			)
		)
		for /l %%i in (1,1,!totalpowerUps!) do (
			set "screen=!screen!%\e%!powerUp_y!;!powerUp_x!H%powerUp%"
		)
		%getDistance% this.x powerUp_x this.y powerUp_y powerUpDistance
		if !powerUpDistance! leq 4 (
			set "totalpowerUps=0"
			set "powerUp_x="
			set "powerUp_y="
			set "pacmanSpeed=1"
			set /a "pacman_superSpeed_duration=frameCount + pacman_superSpeed_dur"
			set "pacman_superSpeedMode=True"
		)
		if "!pacman_superSpeedMode!" neq "False" (
			if !frameCount! gtr !pacman_superSpeed_duration! (
				set "pacman_superSpeedMode=False"
				set "powerUpBool=False"
				set /a "pacmanSpeed=pacmanDefaultSpeed"
				set "pacman_superSpeed_duration="
			)
		)
		REM Random Cherries-----------------------------------------------------------------------------------------
		if "!cherryBool!" neq "True" (
			2>nul set /a "%every:x=cherryAppearanceTime%" && (
				set /a "cherry_x=!random! %% (wid - 8) + 4", "cherry_y=!random! %% (hei - 8) + 4"
				set "totalCherries=1"
				set "cherryBool=True"
			)
		)
		for /l %%i in (1,1,!totalCherries!) do (
			set "screen=!screen!%\e%!cherry_y!;!cherry_x!H%cherry%"
		)
		%getDistance% this.x cherry_x this.y cherry_y cherryDistance
		if !cherryDistance! leq 4 (
			set "totalCherries=0"
			set "cherry_x="
			set "cherry_y="
			set /a "points+=2"
			set /a "chaserSpeed+=10"
			set "pacman_predetorMode=True"
			set /a "pacman_predetorMode_duration+=(frameCount + pacman_predetorMode_dur)"
			set "frenzyMode=0"
		)
		REM -Chaser mechanics---------------------------------------------------------------------------------------
		if "!pacman_predetorMode!" neq "True" (
			if !this.x! gtr !chaser.x! ( set /a "chaser.i=1" ) else ( set /a "chaser.i=-1")
			if !this.y! gtr !chaser.y! ( set /a "chaser.j=1" ) else ( set /a "chaser.j=-1")
		) else (
			rem check if predator mode duration has worn off
			if !frameCount! gtr !pacman_predetorMode_duration! (
				set "pacman_predetorMode=False"
				set "pacman_predetorMode_duration="
				set "cherryBool=False"
				set /a "chaserSpeed-=10"
				set /a "frenzyMode=255"
			)
			if !this.x! gtr !chaser.x! ( set /a "chaser.i=-1" ) else ( set /a "chaser.i=1")
			if !this.y! gtr !chaser.y! ( set /a "chaser.j=-1" ) else ( set /a "chaser.j=1")
		)
		
		2>nul set /a "%every:x=chaserAnimationSpeed%" && (
			set /a "chaserAnimatedFrame=(chaserAnimatedFrame + 1) %% 4"
		)
		2>nul set /a "%every:x=chaserSpeed%" && (
			set /a "chaser.x+=chaser.i", "chaser.y+=chaser.j"
		)
		if !chaserSpeed! gtr 1 (
			2>nul set /a "%every:x=increaseChaserSpeedTime%" && (
				2>nul set /a "%chance:x=increaseChaserSpeedChance%" && (
					set /a "chaserSpeed-=1"
				)
			)
		)
		
		if !chaser.x! gtr 0 if !chaser.x! lss %wid% if !chaser.y! gtr 0 if !chaser.y! lss %hei% (
			for %%c in (!chaserAnimatedFrame!) do (
				set "screen=!screen!%\e%!chaser.y!;!chaser.x!H!chaser[%%c]!"
			)
		)
		
		%getDistance% this.x chaser.x this.y chaser.y chaserDistanceFromPlayer
		if !chaserDistanceFromPlayer! leq 2 (
			set /a "chaser.x=5"
			set /a "chaser.y=5"
			if "!pacman_predetorMode!" neq "True" (
				set /a "pacmanHealth-=1"
			) else (
				set /a "pacmanHealth+=2"
				set /a "points+=5"
			)
		)
		
		if !pacmanHealth! gtr 5 set "pacmanHealth=5"
		
		if !pacmanHealth! lss 1 (
			cls
			set /a "centx-=4"
			echo %\e%!centy!;!centx!HGAME OVER%\e%2B%\e%9DPoints: !points!
			exit
		)

		REM -Player movement----------------------------------------------------------------------------------------
		2>nul set /a "%every:x=pacmanAnimationSpeed%" && (
			set /a "pacmanAnimatedFrame=(pacmanAnimatedFrame + 1) %% 4"
		)
		if !this.x! leq !this.vr!  set /a "this.x=this.vr"
		if !this.x! geq !this.vmw! set /a "this.x=this.vmw - 1"
		if !this.y! leq !this.vr!  set /a "this.y=this.vr"
		if !this.y! geq !this.vmh! set /a "this.y=this.vmh"

		if /i "!lastKey!" neq "pause" (
			for /f "tokens=1-3" %%i in ("!lastKey! !pacmanAnimatedFrame! !frenzyMode!") do (
				set "screen=!screen!%\e%!this.rgb!%\e%!this.y!;!this.x!H!pacman[%%i][%%j]:frenzyMode=%%k!"
			)
		)
		
		echo %\c%!screen!
		set "screen="
		title CF: !frameCount! Health: !pacmanHealth! Points: !points!
		
		REM -Fetch player input-------------------------------------------------------------------------------------
		rem CHEAT CODES:
		rem     C - Spawn Cherry
		rem     X - Spawn Shield
		rem     Z - Spawn PowerUp
		2>nul set /a "%every:x=pacmanSpeed%" && (

			%= Read last key press from input buffer - Non blocking input =%
			if not "!Lastkey!"=="Pause" set "lastKey=!key!"
			set "NewKey="
			set /p "NewKey="
			if defined NewKey for %%v in (!newKey!) do (
				If not "!key_%%v!"=="" set "key=!key_%%v!"
				If /i "%%v" == "quit" (
					exit
				)
			)
			%= Implement Control actions. =%
			if defined key (
				if "!key!"=="pause" (
					set /a "!key!=!pause! %%2 +1"
					set "key="
				)
				if not !pause! equ 2 (
					if "!key!"=="Up" (
						set "lastXkey="
						set /a %Up:?=this%
						set "lastYkey=Up"
					)
					if "!Key!"=="Down" (
						set "lastXkey="
						set /a %Down:?=this%
						set "lastYkey=Down"
					)
					if "!key!"=="Left" (
						set "lastYkey="
						set /a %Left:?=this%
						set "lastXkey=Left"
					)
					if "!key!"=="Right" (
						set "lastYkey="
						set /a %Right:?=this%
						set "lastXkey=Right"
					)
					if "!key!"=="Cherry" (
						set /a "cherry_x=!random! %% (wid - 8) + 4", "cherry_y=!random! %% (hei - 8) + 4"
						set "totalCherries=1"
						set "cherryBool=True"
						if defined lastXkey set "key=!lastXKey!"
						if defined lastYkey set "key=!lastYKey!"
					)
					if "!key!"=="Shield" (
						set /a "shield_x=!random! %% (wid - 10) + 5", "shield_y=!random! %% (hei - 10) + 5"
						set "totalShields=1"
						set "shieldBool=True"
						if defined lastXkey set "key=!lastXKey!"
						if defined lastYkey set "key=!lastYKey!"
					)
					if "!key!"=="PowerUp" (
						set /a "powerUp_x=!random! %% (wid - 10) + 5", "powerUp_y=!random! %% (hei - 10) + 5"
						set "totalpowerUps=1"
						set "powerUpBool=True"
						if defined lastXkey set "key=!lastXKey!"
						if defined lastYkey set "key=!lastYKey!"
					)
				)2>nul
			)
		)
	)
exit

:Controller
	rem credits to T3RR0R for this code
	Setlocal DISABLEdelayedExpansion
	REM Environment handling allows use of ! key
	For /l %%C in () do (
		Set "Key="
		for /f "delims=" %%A in ('%SystemRoot%\System32\xcopy.exe /w "%~f0" "%~f0" 2^>nul') do If not Defined Key (
	      	set "key=%%A"
			Setlocal ENABLEdelayedExpansion
	      	set key=^!KEY:~-1!
			If "!key!" == "!QUITKEY!" (
				<nul Set /P "=quit"
				exit
			)
			If not "!Key!" == "%BS%" If not "!Key!" == "!CR!" (%= Echo without Linefeed. Allows output of Key and Space =%
				1> %~n0txt.tmp (echo(!Key!!sub!)
				copy %~n0txt.tmp /a %~n0txt2.tmp /b > nul
				type %~n0txt2.tmp
				del %~n0txt.tmp %~n0txt2.tmp
			)Else (
				If "!Key!" == "%BS%" <nul Set /p "={BACKSPACE}"
				If "!Key!" == "!CR!" <nul Set /p "={ENTER}"
			)
			Endlocal
	)	)


:sprites
rem Cheat code keys
set "key_C=Cherry"
set "key_X=Shield"
set "key_Z=PowerUp"
rem ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
set "pacmanKindaLogo[0]=,------.                                            ,--. ,--.,--.           ,--.        %\e%B%\e%88D"
set "pacmanKindaLogo[1]=^|ÛÛ.--.Û' ,--,--.,---.,--,--,--. ,--,--.,--,--,     ^|ÛÛ.'ÛÛÛ/`--',--,--,  ,-^|ÛÛ^| ,--,--.%\e%B%\e%88D"
set "pacmanKindaLogo[2]=^|ÛÛ'--'Û^|'Û,-.ÛÛ^|Û.--'^|ÛÛÛÛÛÛÛÛ^|'Û,-.ÛÛ^|^|ÛÛÛÛÛÛ\    ^|ÛÛ.ÛÛÛ' ,--.^|ÛÛÛÛÛÛ\'Û.-.Û^|'Û,-.ÛÛ^|%\e%B%\e%88D"
set "pacmanKindaLogo[3]=^|ÛÛ^|Û--' \Û'-'ÛÛ\Û`--.^|ÛÛ^|ÛÛ^|ÛÛ^|\Û'-'ÛÛ^|^|ÛÛ^|^|ÛÛ^|    ^|ÛÛ^|\ÛÛÛ\^|ÛÛ^|^|ÛÛ^|^|ÛÛ^|\Û`-'Û^|\Û'-'ÛÛ^|%\e%B%\e%88D"
set "pacmanKindaLogo[4]=`--'      `--`--'`---'`--`--`--' `--`--'`--''--'    `--' '--'`--'`--''--' `---'  `--`--'%\e%0m"
set "pacmanKindaLogo=%pacmanKindaLogo[0]%%pacmanKindaLogo[1]%%pacmanKindaLogo[2]%%pacmanKindaLogo[3]%%pacmanKindaLogo[4]%"
rem ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
set "pacman[Right][0]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[6DÛÛÛÛÛ[B[5DÛÛÛ[B[3DÛÛÛÛÛ[B[4DÛÛÛÛÛ[2D[3A[0m"
set "pacman[Right][1]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛ[B[5DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set "pacman[Right][2]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set "pacman[Right][3]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛ[B[5DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set  "pacman[Left][0]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[4DÛÛÛÛÛ[B[3DÛÛÛ[B[5DÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set  "pacman[Left][1]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[5DÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set  "pacman[Left][2]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set  "pacman[Left][3]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[5DÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set  "pacman[Down][0]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛ[CÛÛÛ[B[7DÛÛÛ[CÛÛÛ[B[6DÛ[3CÛ[4D[3A[0m"
set  "pacman[Down][1]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛ[CÛÛÛ[B[6DÛÛ[CÛÛ[B[4D[3A[0m"
set  "pacman[Down][2]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[4D[3A[0m"
set  "pacman[Down][3]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛ[CÛÛÛ[B[6DÛÛ[CÛÛ[B[4D[3A[0m"
set    "pacman[Up][0]=[38;2;255;frenzyMode;0m[CÛ[3CÛ[B[6DÛÛÛ[CÛÛÛ[B[7DÛÛÛ[CÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[4D[3A[0m"
set    "pacman[Up][1]=[38;2;255;frenzyMode;0m[CÛÛ[CÛÛ[B[6DÛÛÛ[CÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[4D[3A[0m"
set    "pacman[Up][2]=[38;2;255;frenzyMode;0m[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[4D[3A[0m"
set    "pacman[Up][3]=[38;2;255;frenzyMode;0m[CÛÛ[CÛÛ[B[6DÛÛÛ[CÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[4D[3A[0m"
REM ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
set        "chaser[0]=[38;5;10m.[38;5;9m[38;5;10m.[B[3D[38;5;12m[38;5;15m[38;5;12m[B[3D[38;5;10m.[38;5;12m[38;5;10m.[D[A[0m"
set        "chaser[1]=[38;5;10m[38;5;12m.[38;5;10m[B[3D[38;5;12m.[38;5;15m[38;5;12m.[B[3D[38;5;10m[38;5;9m.[38;5;10m[D[A[0m"
set        "chaser[2]=[38;5;10m.[38;5;12m[38;5;10m.[B[3D[38;5;12m[38;5;15m[38;5;9m[B[3D[38;5;10m.[38;5;12m[38;5;10m.[D[A[0m"
set        "chaser[3]=[38;5;10m[38;5;12m.[38;5;10m[B[3D[38;5;9m.[38;5;15m[38;5;12m.[B[3D[38;5;10m[38;5;12m.[38;5;10m[D[A[0m"
REM ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
set "cherry=[2C[38;2;97;138;61m_[B[3D[C[38;2;159;100;66m/[B[3D[38;2;255;0;0m°[38;2;255;0;0mÛ[B[2D[38;2;255;0;0mÛÛ[A[D[0m"
set "shield=[38;5;12m'-'-'[B[5D[38;5;12m^|[38;5;7mÛSÛ[38;5;12m^|[B[5D[38;5;12m^|[38;5;7mÛÛÛ[38;5;12m^|[B[5D[38;5;12m\___/[3D[2A[0m" 
set "powerUp=[38;5;9m[C/\[B[3D/+1\[B[4D`ÛÛ'[2D[A[0m"
goto :eof
