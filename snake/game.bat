@echo off & setlocal enableDelayedExpansion & chcp 65001>nul

if "%~1" neq "" goto :%~1

call lib\atlas 100 100
call lib\radish
call scripts\macros 
call scripts\init
call scripts\sprites

( %radish% "%~nx0" radish_wait ) & exit
:radish_wait
( %while% if exist "radish_ready" %endwhile% ) & del /f /q "radish_ready"

if "!skipIntro!" neq "true" (
	call scripts\intro
)



:reset
set /a "%newSnake%, %newFood%"


%@getTimeCS:?=t1%
%while% (
	%@getTimeCS:?=t2%, "deltaTime=t2-t1"
	
	if !deltaTime! gtr !MIN_FRAME_INTERVAL_CS!  (

		%@radish%
		
		set /a "t1=t2",^
		       "prevX=snakeX",^
		       "prevY=snakeY",^
		       "snakeX+=xSpeed * scl",^
		       "snakeY+=ySpeed * scl",^
			   "h+=100, s=10000, l=5000, %@hsl.rgb%",^
			   "fade=255",^
			   "frameCount+=1",^
			   "totalDT+=deltaTime"

		if !totalDT! GEQ 100 (
			set /a "fps=frameCount * 100 / totalDT, frameCount=totalDT=0"
			
			if !fps! lss %targetFPS% (
				if !MIN_FRAME_INTERVAL_CS! gtr 0 (
					set /a "MIN_FRAME_INTERVAL_CS-=1"
				)
			) else set /a "MIN_FRAME_INTERVAL_CS+=1"
		)
		title [ESC] to QUIT   ^|   Score: !total!   ^|   FPS: !FPS!:!MIN_FRAME_INTERVAL_CS!    !keysPressed!
		
		
		if defined keysPressed (
			%asyncKeys:?=27% %endwhile% & goto :GameOver
			%asyncKeys:?=49% set /a "%newFood%"   & rem Press 1 for new food
			%asyncKeys:?=50% set /a "%growSnake%" & rem Press 2 to grow snake. Must be moving otherwise you will collide with yourself resulting in GameOver
		
			set /a "i=!keysPressed:-=! - 37"
			for %%i in (!i!) do set "newDir=!directionMap:~%%i,1!"
			
			if "!newDir!" neq "x" (
				if "!newDir!"=="0" if not "!ySpeed!"=="1"  set "direction=0"
				if "!newDir!"=="1" if not "!xSpeed!"=="-1" set "direction=1"
				if "!newDir!"=="2" if not "!xSpeed!"=="1"  set "direction=2"
				if "!newDir!"=="3" if not "!ySpeed!"=="-1" set "direction=3"
				
					   if !direction! equ 0 ( set /a "xSpeed=0,  ySpeed=-1"
				) else if !direction! equ 1 ( set /a "xSpeed=1,  ySpeed=0"
				) else if !direction! equ 2 ( set /a "xSpeed=-1, ySpeed=0"
				) else if !direction! equ 3 ( set /a "xSpeed=0,  ySpeed=1"
				)
			)
		)
		
		
		       if !snakeX! lss 0     ( %endwhile% & goto :GameOver
		) else if !snakeX! gtr !wid!   %endwhile% & goto :GameOver
		       if !snakeY! lss 0     ( %endwhile% & goto :GameOver
		) else if !snakeY! gtr !hei!   %endwhile% & goto :GameOver
		
		
		if !snakeX! equ !foodX! if !snakeY! equ !foodY! (
			set /a "%newFood%, %growSnake%"
		)


		set "newTail="
		set "tailTrail="
		for %%P in (!tail_!) do (
			
			for /f "tokens=1,2" %%a in ("%%~P") do (
				if %%a equ !snakeX! if %%b equ !snakeY! (
					%endwhile% & goto :GameOver
				)
				
				set "newTail=!newTail!"!prevX! !prevY!" "
				for %%f in (!fade!) do (
					set "tailTrail=!tailTrail!%\e%[48;2;%%f;%%f;%%fm%\e%[!prevY!;!prevX!H!segment!"
				)
				set /a "prevX=%%a, prevY=%%b"
			)
			set /a "fade-=fadeAmount"
		)
		if defined grow (
			set "newTail=!newTail!"!prevX! !prevY!" "
			set "grow="
		)
		set "tail_=!newTail!"


		echo %\e%[2J%\e%[48;2;255;255;255m%\e%[!snakeY!;!snakeX!H%segment%!tailTrail!%\e%[48;2;!r!;!g!;!b!m%\e%[!foodY!;!foodX!H!food!%\e%[m
	
	)
)

















:GameOver
cls
title GameOver

rem clean up
for %%i in ( tail_ xSpeed ySpeed) do set "%%i="

set "iter=0"
rem %radish_end%

set /a "animationDuration=50 * 1000"

%@getTimeCS:?=t1%
for /l %%i in (1,1,%animationDuration%) do (
	%@getTimeCS:?=t2%, "deltaTime=t2-t1"
	if !deltaTime! gtr 10 (
		set /a "t1=t2, frames=%%i %% 4"
		for %%f in (!frames!) do <nul set /p "=%\e%[2J%\e%[!prevY!;!prevX!H!dead[%%f]!"
	)
)
goto :reset