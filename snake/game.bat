@echo off & setlocal enableDelayedExpansion & chcp 65001>nul

if "%~1" neq "" goto :%~1

call scripts\intro
call lib\atlas 100 100
call lib\radish
call scripts\macros 
call scripts\init
call scripts\sprites

( %radish% "%~nx0" radish_wait ) & exit
:radish_wait
( %while% if exist "radish_ready" %endwhile% ) & del /f /q "radish_ready"
rem ------------------------------------------------------------------------










:reset
set /a "%newSnake%, %newFood%"

for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100"
%while% (
	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, dt=t2-t1"
	
	if !dt! gtr 6 (
		title !total!

		%@radish%
		
		set /a "t1=t2",^
		       "prevX=snakeX",^
		       "prevY=snakeY",^
		       "snakeX+=xSpeed * scl",^
		       "snakeY+=ySpeed * scl",^
			   "h+=100, %@hsl.rgb%",^
			   "fade=255"
		
		
		if defined keysPressed (
			%asyncKeys:?=27% %endwhile% & goto :GameOver
		
			set /a "i=!keysPressed:-=! - 37"
			for %%i in (!i!) do set "newDir=!directionMap:~%%i,1!"
			
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
		
		
		       if !snakeX! lss 0     ( %endwhile% & goto :GameOver
		) else if !snakeX! gtr !wid!   %endwhile% & goto :GameOver
		       if !snakeY! lss 0     ( %endwhile% & goto :GameOver
		) else if !snakeY! gtr !hei!   %endwhile% & goto :GameOver
		
		
		if !snakeX! equ !foodX! if !snakeY! equ !foodY! (
			set /a "%newFood%, grow=1, total+=1, fadeAmount=255 / (total + 1)"
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


		echo %\e%[2J%\e%[48;2;255;255;255m%\e%[!snakeY!;!snakeX!H%segment%!tailTrail!%\e%[48;2;!r!;!g!;!b!m%\e%[!foodY!;!foodX!H!food!%\e%[0m
	
	)
)

















:GameOver
cls
title GameOver
set tail_=
rem %radish_end%

set /a "animationDuration=50 * 1000"

for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100"
for /l %%i in (1,1,%animationDuration%) do (
	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, dt=t2-t1"
	
	if !dt! gtr 8 (
		set /a "t1=t2, frames=%%i %% 4"
		title !frames!
		for %%f in (!frames!) do <nul set /p "=%\e%[!prevY!;!prevX!H!dead[%%f]!"
	)
)
goto :reset