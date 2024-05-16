@echo off & setlocal enableDelayedExpansion & set "(=(set "\=?" & ren "%~nx0" -t.bat & ren "?.bat" "%~nx0"" & set ")=ren "%~nx0" "^^!\^^!.bat" & ren -t.bat "%~nx0")" & set "self=%~nx0" & set "failedLibrary=ren -t.bat "%~nx0" &echo Library not found & timeout /t 3 & exit"
if "%~1" neq "" goto :%~1

rem Revision 4.0.4
rem https://github.com/IcarusLivesHF/Windows-Batch-Library/tree/8812670566744d2ee14a9a68a06be333a27488cc

set "revisionRequired=4.0.4"
(%(:?=Library% && (call :revision)||(%failedLibrary%))2>nul
	call :stdlib /w:90 /fs:8 /multi:2 /gfx /s /misc
%)%  && (cls&goto :setup)
:setup

%BVector% this 7
set /a "this.x=wid/2","this.y=hei/2"
%BVector% chaser
set /a "chaser.x=5","chaser.y=5"
for %%i in (1 2) do (
	set /a "npc[%%i].x=!random! %% wid"
	set /a "npc[%%i].y=!random! %% hei"
	set /a "dir=!random! %% 2"
	if !dir! gtr 0 (
		set /a "npc[%%i].i=!random! %% 2 + 2"
	) else (
		set /a "npc[%%i].j=!random! %% 2 + 2"
	)
)

set "pacmanDefaultSpeed=3"
set "pacman_collect_range_default=3"
set "pacmanHealth=1"
set "pacman_predetorMode_dur=300"
set "pacman_superSpeed_dur=100"
set "pacman_magnetic_dur=550"
set "pacman_invisible_dur=300"
set "chaser_frozen_dur=150"
set "increaseChaserSpeedTime=1750"
set "increaseChaserSpeedChance=20"
set "dotAppearanceTime=150"
set "cherryAppearanceTime=2000"
set "shieldAppearanceTime=300"
set "shieldAppearanceChance=25"
set "powerUpAppearanceTime=400"
set "powerUpAppearanceChance=25"
set "snowflakeAppearanceTime=350"
set "snowflakeAppearanceChance=25"
set "poofAppearanceTime=500"
set "poofAppearanceChance=25"
set "magnetAppearanceTime=400"
set "magnetAppearanceChance=25"
set "pacman_magnetic_Range=20"
set "invisibleAppearanceTime=475"
set "invisibleAppearanceChance=25"
set "teleportAppearanceTime=415"
set "teleportAppearanceChance=25"

set "pacman_invisible=False"
set "pacman_magnetic=False"
set "pacman_predetorMode=False"
set "pacman_superSpeedMode=False"
set "cherryBool=False"
set "shieldBool=False"
set "powerUpBool=False"
set "snowflakeBool=False"
set "poofBool=False"
set "magnetBool=False"
set "invisibleBool=False"
set "teleportBool=False"
set "skipIntro=False"
set /a "centx=wid/2","centy=hei/2"
set "points=0"
set "pacmanAnimationSpeed=7"
set /a "pacman_collect_range=pacman_collect_range_default"
set /a "pacmanSpeed=pacmanDefaultSpeed"
set "pacmanColorMode=255;0"
set /a "r=!random! %% 4" & (if !r! equ 0 (set "Key=Right") else if !r! equ 1 (set "Key=Left") else if !r! equ 2 (set "Key=Up") else if !r! equ 3 (set "Key=Down"))
set "chaserAnimationSpeed=30"
set /a "chaserSpeed=pacmanSpeed * 2 - 3"
set "chaserAnimatedFrame=0"
set /a "totalDots=startDot=1"
call :sprites

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
			if !ballDistance! leq !pacman_collect_range! (
				if "!pacman_magnetic!" neq "True" (
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
					set /a "points+=1","gotDots+=1"
				) else (
					if !frameCount! gtr !pacman_magnetic_duration! (
						set "pacman_magnetic_duration="
						set "pacman_magnetic=False"
						set /a "pacman_collect_range=pacman_collect_range_default"
					) else (
						if !this.x! gtr !dot_x[%%i]! ( set /a "dot_x[%%i]+=1" ) else ( set /a "dot_x[%%i]-=1" )
						if !this.y! gtr !dot_y[%%i]! ( set /a "dot_y[%%i]+=1" ) else ( set /a "dot_y[%%i]-=1" )
						
						if !ballDistance! leq !pacman_collect_range_default! (
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
							set /a "points+=1","gotDots+=1"
						)
					)
				)
			)
		)
		REM Random Teleports-----------------------------------------------------------------------------------
		if "!teleportBool!" neq "True" (
			2>nul set /a "%chance:x=teleportAppearanceChance%" && (
				2>nul set /a "%every:x=teleportAppearanceTime%" && (
					set /a "teleport_x=!random! %% (wid - 10) + 5", "teleport_y=!random! %% (hei - 10) + 5"
					set "totalteleports=1"
					set "teleportBool=True"
				)
			)
		)
		for /l %%i in (1,1,!totalteleports!) do (
			set "screen=!screen!%\e%!teleport_y!;!teleport_x!H%teleport%"
		)
		%getDistance% this.x teleport_x this.y teleport_y teleportDistance
		if !teleportDistance! leq 4 (
			set "totalteleports=0"
			set "teleportBool=False"
			set /a "this.x=!random! %% (wid - this.vd) + this.vr","this.y=!random! %% (hei - this.vd) + this.vr"
			set /a "chaser.x=this.y","chaser.y=this.x","gotteleports+=1"
			set "teleport_x="
			set "teleport_y="
		)
		REM Random Magnets-------------------------------------------------------------------------------------
		if "!magnetBool!" neq "True" (
			2>nul set /a "%chance:x=magnetAppearanceChance%" && (
				2>nul set /a "%every:x=magnetAppearanceTime%" && (
					set /a "magnet_x=!random! %% (wid - 10) + 5", "magnet_y=!random! %% (hei - 10) + 5"
					set "totalmagnets=1"
					set "magnetBool=True"
				)
			)
		)
		for /l %%i in (1,1,!totalmagnets!) do (
			set "screen=!screen!%\e%!magnet_y!;!magnet_x!H%magnet%"
		)
		%getDistance% this.x magnet_x this.y magnet_y magnetDistance
		if !magnetDistance! leq 4 (
			set "totalmagnets=0"
			set "magnetBool=False"
			set "magnet_x="
			set "magnet_y="
			set /a "gotmagnets+=1"
			set /a "pacman_magnetic_duration=frameCount + pacman_magnetic_dur"
			set /a "pacman_collect_range=pacman_magnetic_Range"
			set "pacman_magnetic=True"
		)
		REM Random Invisibles----------------------------------------------------------------------------------
		if "!invisibleBool!" neq "True" (
			2>nul set /a "%chance:x=invisibleAppearanceChance%" && (
				2>nul set /a "%every:x=invisibleAppearanceTime%" && (
					set /a "invisible_x=!random! %% (wid - 10) + 5", "invisible_y=!random! %% (hei - 10) + 5"
					set "totalinvisibles=1"
					set "invisibleBool=True"
				)
			)
		)
		for /l %%i in (1,1,!totalinvisibles!) do (
			set "screen=!screen!%\e%!invisible_y!;!invisible_x!H%cloud%"
		)
		%getDistance% this.x invisible_x this.y invisible_y invisibleDistance
		if !invisibleDistance! leq 4 (
			set "totalinvisibles=0"
			set "invisibleBool=False"
			set "invisible_x="
			set "invisible_y="
			set /a "gotinvisibles+=1"
			set "pacman_invisible=True"
			set /a "pacman_invisible_duration=frameCount + pacman_invisible_dur"
			set "pacmanColorMode=255;255"
		)
		REM Random Poofs---------------------------------------------------------------------------------------
		if "!poofBool!" neq "True" (
			2>nul set /a "%chance:x=poofAppearanceChance%" && (
				2>nul set /a "%every:x=poofAppearanceTime%" && (
					set /a "poof_x=!random! %% (wid - 10) + 5", "poof_y=!random! %% (hei - 10) + 5"
					set "totalpoofs=1"
					set "poofBool=True"
				)
			)
		)
		for /l %%i in (1,1,!totalpoofs!) do (
			set "screen=!screen!%\e%!poof_y!;!poof_x!H%poof%"
		)
		%getDistance% this.x poof_x this.y poof_y poofDistance
		if !poofDistance! leq 4 (
			set "totalpoofs=0"
			set "poofBool=False"
			set /a "chaser.x=(!random! %% wid) * -1"
			set /a "chaser.y=(!random! %% hei) * -1"
			set "poof_x="
			set "poof_y="
			set /a "gotpoofs+=1"
		)
		REM Random Snowflakes---------------------------------------------------------------------------------------
		if "!snowflakeBool!" neq "True" (
			2>nul set /a "%chance:x=snowflakeAppearanceChance%" && (
				2>nul set /a "%every:x=snowflakeAppearanceTime%" && (
					set /a "snowflake_x=!random! %% (wid - 10) + 5", "snowflake_y=!random! %% (hei - 10) + 5"
					set "totalsnowflakes=1"
					set "snowflakeBool=True"
				)
			)
		)
		for /l %%i in (1,1,!totalsnowflakes!) do (
			set "screen=!screen!%\e%!snowflake_y!;!snowflake_x!H%snowflake%"
		)
		%getDistance% this.x snowflake_x this.y snowflake_y snowflakeDistance
		if !snowflakeDistance! leq 5 (
			set "totalsnowflakes=0"
			set "snowflakeBool=False"
			set "snowflake_x="
			set "snowflake_y="
			set /a "gotsnowflakes+=1"
			set /a "chaser_frozen_duration=frameCount + chaser_frozen_dur"
			set "chaser_Frozen=True"
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
			set /a "gotShields+=1"
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
			set /a "gotPowerUps+=1"
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
			set "pacmanColorMode=0;0"
			set /a "gotCherries+=1"
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
				set "pacmanColorMode=255;0"
			)
			if !this.x! gtr !chaser.x! ( set /a "chaser.i=-1" ) else ( set /a "chaser.i=1")
			if !this.y! gtr !chaser.y! ( set /a "chaser.j=-1" ) else ( set /a "chaser.j=1")
		)
		
		2>nul set /a "%every:x=chaserAnimationSpeed%" && (
			set /a "chaserAnimatedFrame=(chaserAnimatedFrame + 1) %% 4"
		)
		
		
		if "!chaser_frozen!" neq "True" (
			if "!pacman_invisible!" neq "True" (
				2>nul set /a "%every:x=chaserSpeed%" && (
					set /a "chaser.x+=chaser.i", "chaser.y+=chaser.j"
				)
			) else (
				if !frameCount! gtr !pacman_invisible_duration! (
					set "pacman_invisible_duration="
					set "pacman_invisible=False"
					set "pacmanColorMode=255;0"
				) else (
					set /a "chaser.x+=!random! %% 3 + -1", "chaser.y+=!random! %% 3 + -1"
				)
			)
		) else (
			if !frameCount! gtr !chaser_frozen_duration! (
				set "chaser_Frozen=False"
				set "chaser_frozen_duration="
			)
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
		if !chaserDistanceFromPlayer! leq 3 (
			set /a "chaser.x=5"
			set /a "chaser.y=5"
			if "!pacman_predetorMode!" neq "True" (
				set /a "pacmanHealth-=1"
				set /a "gotByChaser+=1"
			) else (
				set /a "pacmanHealth+=2"
				set /a "points+=5"
				set /a "gotChasers+=1"
			)
		)
		
		if !pacmanHealth! gtr 5 (
			set "pacmanHealth=5"
		) else if !pacmanHealth! lss 1 (
			cls
			set /a "centx-=8", "centy-=5"
			for %%a in (
				"Game Over"
				""
				"Points: !points!"
				""
				"Dots collected:   !gotDots!"
				""
				"Chasers Eaten:    !gotChasers!"
				"Caught by Chaser: !gotByChaser!"
				""
				"Cherries Eaten:   !gotCherries!"
				"PowerUps Eaten:   !gotPowerUps!"
				"Shields  Eaten:   !gotShields!"
				"Snowflakes Eaten: !gotsnowflakes!"
				"Poofs Eaten:      !gotpoofs!"
				"Magnets Eaten:    !gotMagnets!"
				"Invisibles Eaten: !gotinvisibles!"
				"Teleports Eaten:  !gotteleports!"
				""
				"Made By IcarusLives"
			) do (
				echo %\e%!centy!;!centx!H%%~a
				set /a "centy+=1"
			)
			exit
		)
		REM -random walkers-----------------------------------------------------------------------------------------
		for %%i in (1 2) do (
			set /a "npc[%%i].x+=npc[%%i].i", "npc[%%i].y+=npc[%%i].j"
			
			%getDistance% this.x npc[%%i].x this.y npc[%%i].y NPCDistance
			if !NPCDistance! leq 3 (
				set /a "pacmanHealth-=1","gotByChaser+=1","npc[%%i].x=!random! %% wid","npc[%%i].y=!random! %% hei"
			)
			if !npc[%%i].x! leq 0     set /a "npc[%%i].x=0",   "npc[%%i].i*=-1"
			if !npc[%%i].y! leq 0     set /a "npc[%%i].y=0",   "npc[%%i].j*=-1"
			if !npc[%%i].x! geq %wid% set /a "npc[%%i].x=wid", "npc[%%i].i*=-1"
			if !npc[%%i].y! geq %hei% set /a "npc[%%i].y=hei", "npc[%%i].j*=-1"
			set "screen=!screen!%\e%!npc[%%i].y!;!npc[%%i].x!H!chaser[%%i]!""
		)2>nul
		
		REM -Player movement----------------------------------------------------------------------------------------
		2>nul set /a "%every:x=pacmanAnimationSpeed%" && (
			set /a "pacmanAnimatedFrame=(pacmanAnimatedFrame + 1) %% 4"
		)
		if !this.x! leq !this.vr!  set /a "this.x=this.vr"
		if !this.x! geq !this.vmw! set /a "this.x=this.vmw - 1"
		if !this.y! leq !this.vr!  set /a "this.y=this.vr"
		if !this.y! geq !this.vmh! set /a "this.y=this.vmh"

		if /i "!lastKey!" neq "pause" (
			for /f "tokens=1-3" %%i in ("!lastKey! !pacmanAnimatedFrame! !pacmanColorMode!") do (
				set "screen=!screen!%\e%!this.rgb!%\e%!this.y!;!this.x!H!pacman[%%i][%%j]:pacmanColorMode=%%k!"
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
		rem     B - Spawn Snowflake
		rem     N - Spawn Poof
		rem     M - Spawn Magnet
		rem     F - Spawn Invisible
		rem     G - Spawn Teleport
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
					if "!key!"=="Snowflake" (
						set /a "snowflake_x=!random! %% (wid - 10) + 5", "snowflake_y=!random! %% (hei - 10) + 5"
						set "totalsnowflakes=1"
						set "snowflakeBool=True"
						if defined lastXkey set "key=!lastXKey!"
						if defined lastYkey set "key=!lastYKey!"
					)
					if "!key!"=="Poof" (
						set /a "poof_x=!random! %% (wid - 10) + 5", "poof_y=!random! %% (hei - 10) + 5"
						set "totalpoofs=1"
						set "poofBool=True"
						if defined lastXkey set "key=!lastXKey!"
						if defined lastYkey set "key=!lastYKey!"
					)
					if "!key!"=="Magnet" (
						set /a "magnet_x=!random! %% (wid - 10) + 5", "magnet_y=!random! %% (hei - 10) + 5"
						set "totalmagnets=1"
						set "magnetBool=True"
						if defined lastXkey set "key=!lastXKey!"
						if defined lastYkey set "key=!lastYKey!"
					)
					if "!key!"=="Invisible" (
						set /a "invisible_x=!random! %% (wid - 10) + 5", "invisible_y=!random! %% (hei - 10) + 5"
						set "totalinvisibles=1"
						set "invisibleBool=True"
						if defined lastXkey set "key=!lastXKey!"
						if defined lastYkey set "key=!lastYKey!"
					)
					if "!key!"=="Teleport" (
						set /a "teleport_x=!random! %% (wid - 10) + 5", "teleport_y=!random! %% (hei - 10) + 5"
						set "totalteleports=1"
						set "teleportBool=True"
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
set "key_B=Snowflake"
set "key_N=Poof"
set "key_M=Magnet"
set "key_F=Invisible"
set "key_G=Teleport"
rem ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
set "pacmanKindaLogo[0]=,------.                                            ,--. ,--.,--.           ,--.        %\e%B%\e%88D"
set "pacmanKindaLogo[1]=^|ÛÛ.--.Û' ,--,--.,---.,--,--,--. ,--,--.,--,--,     ^|ÛÛ.'ÛÛÛ/`--',--,--,  ,-^|ÛÛ^| ,--,--.%\e%B%\e%88D"
set "pacmanKindaLogo[2]=^|ÛÛ'--'Û^|'Û,-.ÛÛ^|Û.--'^|ÛÛÛÛÛÛÛÛ^|'Û,-.ÛÛ^|^|ÛÛÛÛÛÛ\    ^|ÛÛ.ÛÛÛ' ,--.^|ÛÛÛÛÛÛ\'Û.-.Û^|'Û,-.ÛÛ^|%\e%B%\e%88D"
set "pacmanKindaLogo[3]=^|ÛÛ^|Û--' \Û'-'ÛÛ\Û`--.^|ÛÛ^|ÛÛ^|ÛÛ^|\Û'-'ÛÛ^|^|ÛÛ^|^|ÛÛ^|    ^|ÛÛ^|\ÛÛÛ\^|ÛÛ^|^|ÛÛ^|^|ÛÛ^|\Û`-'Û^|\Û'-'ÛÛ^|%\e%B%\e%88D"
set "pacmanKindaLogo[4]=`--'      `--`--'`---'`--`--`--' `--`--'`--''--'    `--' '--'`--'`--''--' `---'  `--`--'%\e%0m"
set "pacmanKindaLogo=%pacmanKindaLogo[0]%%pacmanKindaLogo[1]%%pacmanKindaLogo[2]%%pacmanKindaLogo[3]%%pacmanKindaLogo[4]%"
rem ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
set "pacman[Right][0]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[6DÛÛÛÛÛ[B[5DÛÛÛ[B[3DÛÛÛÛÛ[B[4DÛÛÛÛÛ[2D[3A[0m"
set "pacman[Right][1]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛ[B[5DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set "pacman[Right][2]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set "pacman[Right][3]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛ[B[5DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set  "pacman[Left][0]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[4DÛÛÛÛÛ[B[3DÛÛÛ[B[5DÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set  "pacman[Left][1]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[5DÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set  "pacman[Left][2]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set  "pacman[Left][3]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[5DÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[2D[3A[0m"
set  "pacman[Down][0]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛ[CÛÛÛ[B[7DÛÛÛ[CÛÛÛ[B[6DÛ[3CÛ[4D[3A[0m"
set  "pacman[Down][1]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛ[CÛÛÛ[B[6DÛÛ[CÛÛ[B[4D[3A[0m"
set  "pacman[Down][2]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[4D[3A[0m"
set  "pacman[Down][3]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛ[CÛÛÛ[B[6DÛÛ[CÛÛ[B[4D[3A[0m"
set    "pacman[Up][0]=[38;2;255;pacmanColorModem[CÛ[3CÛ[B[6DÛÛÛ[CÛÛÛ[B[7DÛÛÛ[CÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[4D[3A[0m"
set    "pacman[Up][1]=[38;2;255;pacmanColorModem[CÛÛ[CÛÛ[B[6DÛÛÛ[CÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[4D[3A[0m"
set    "pacman[Up][2]=[38;2;255;pacmanColorModem[CÛÛÛÛÛ[B[6DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[4D[3A[0m"
set    "pacman[Up][3]=[38;2;255;pacmanColorModem[CÛÛ[CÛÛ[B[6DÛÛÛ[CÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[7DÛÛÛÛÛÛÛ[B[6DÛÛÛÛÛ[4D[3A[0m"
REM ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
set        "chaser[0]=[38;5;10m.[38;5;9m[38;5;10m.[B[3D[38;5;12m[38;5;15m[38;5;12m[B[3D[38;5;10m.[38;5;12m[38;5;10m.[D[A[0m"
set        "chaser[1]=[38;5;10m[38;5;12m.[38;5;10m[B[3D[38;5;12m.[38;5;15m[38;5;12m.[B[3D[38;5;10m[38;5;9m.[38;5;10m[D[A[0m"
set        "chaser[2]=[38;5;10m.[38;5;12m[38;5;10m.[B[3D[38;5;12m[38;5;15m[38;5;9m[B[3D[38;5;10m.[38;5;12m[38;5;10m.[D[A[0m"
set        "chaser[3]=[38;5;10m[38;5;12m.[38;5;10m[B[3D[38;5;9m.[38;5;15m[38;5;12m.[B[3D[38;5;10m[38;5;12m.[38;5;10m[D[A[0m"
REM ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
set "cherry=[2C[38;2;97;138;61m_[B[3D[C[38;2;159;100;66m/[B[3D[38;2;255;0;0m°[38;2;255;0;0mÛ[B[2D[38;2;255;0;0mÛÛ[A[D[0m"
set "shield=[38;5;12m'-'-'[B[5D[38;5;12m^|[38;5;7mÛSÛ[38;5;12m^|[B[5D[38;5;12m^|[38;5;7mÛÛÛ[38;5;12m^|[B[5D[38;5;12m\___/[3D[2A[0m" 
set "powerUp=[38;5;9m[C/\[B[3D/[38;5;15m+1[38;5;9m\[B[4D`ÛÛ'[B[4D[CÛÛ[D[A[0m"
set "snowflake=[38;2;171;240;255m[2C*#*[B[5D[C#[C^|[C#[B[6D*[C\^|/[C*[B[7D#--.--#[B[7D*[C/^|\[C*[B[7D[C#[C^|[C#[B[6D[2C*#*[3A[2D[0m"
set "poof=[38;2;65;65;65m[6C#[B[7D[C.--./[B[6D/POOF\[B[6D\ÛÛÛÛ/[B[6D[C`--'[2A[3D[0m"
set "magnet=[38;5;15mÛÝ[CÛÝ[B[5D[38;2;255;0;0mÛ[38;2;155;0;0mÝ[C[38;2;0;0;255mÛ[38;2;0;0;155mÝ[B[5D[38;2;255;0;0mÛ[38;2;155;0;0mÝ[C[38;2;0;0;255mÛ[38;2;0;0;155mÝ[B[5D[38;2;255;0;0m\Û[38;5;15mÛ[38;2;0;0;255mÛ/[2A[3D[0m"
set "cloud=[38;5;15m[C_[C_[B[4D(ÛÛÛ)[B[5D(ÛÛÛ)[B[5D[C`-'[2A[3D[0m"
set "teleport=[38;2;255;0;0m[38;2;255;0;0mÛ[38;2;255;99;0m[38;2;255;99;0mÛ[38;2;255;198;0m[38;2;255;198;0mÛ[38;2;255;255;0m[38;2;255;255;0mÛ[B[4D[38;2;156;255;0m[38;2;156;255;0mÛ[38;2;57;255;0m[38;2;57;255;0mÛ[38;2;0;255;0m[38;2;0;255;0mÛ[38;2;0;255;99m[38;2;0;255;99mÛ[B[4D[38;2;0;255;198m[38;2;0;255;198mÛ[38;2;0;255;255m[38;2;0;255;255mÛ[38;2;0;156;255m[38;2;0;156;255mÛ[38;2;0;57;255m[38;2;0;57;255mÛ[B[4D[38;2;0;0;255m[38;2;0;0;255mÛ[38;2;99;0;255m[38;2;99;0;255mÛ[38;2;198;0;255m[38;2;198;0;255mÛ[38;2;255;0;255m[38;2;255;0;255mÛ[2A[2D[0m"
goto :eof
