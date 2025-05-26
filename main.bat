@echo off & setlocal enableDelayedExpansion

if "%~1" neq "_" if "%~1" neq "" goto :%~1
call :Set_Font "lucida console" 14 nomax %1 || exit

call lib\atlas 122 38
call lib\radish
call lib\sound
call lib\calendar 3 3 239
call lib\slider 90 36 30 0 100 15 196
call scripts\macros
call scripts\init
call assets\sprites








( %radish% "%~nx0" radish_wait ) & exit
:radish_wait
( %while% ( if exist "radish_ready" %endwhile% )) & del /f /q "radish_ready"
REM ----------------------------------------------------------




:reset
%@getTimeCS:?=t1%
%while% ( %@getTimeCS:?=t2%, "deltatime=t2-t1"

	set /a "t1=t2",^
		   "frameCount+=1",^
		   "totalTicks+=deltatime",^
		   "totalTime=(totalTime + deltatime) %% $32b",^
		   "cec=totalTime %% 100",^
		   "sec=totalTime / 100 %% 60",^
		   "min=totalTime / 6000 %% 60",^
		   " hr=totalTime / 360000",^
		   "memoryDump=sec %% memoryDumpRate"
	if !totalTicks! GEQ 100 (
		set /a "fps=frameCount * 1000 / totalTicks",^
			   "fpsi=fps / 10, fpsf=fps %% 10",^
			   "frameCount=totalTicks=0"
	)
	
	rem periodically empty useless variables from memory - check init.bat memoryDumpRate. The value is in SECONDS.
	if "!memoryDump!" equ "0" (
		for /f "tokens=1 delims==" %%i in ('set _') do set "%%~i="
	)
	
	set "cec=0!cec!" & set "cec=!cec:~-2!"
	set "sec=0!sec!" & set "sec=!sec:~-2!"

title ^
ID:!$username!   ^|   ^
FPS: !fpsi!.!fpsf!   ^|   ^
Runtime: !hr!:!min!:!sec!:!cec!  ^|   ^
Calendar: !$calendar.click!

	REM ----------------------------------------------------------
	%@radish%
	
	%@calendar.click% L
	
	%@dragSlider%
	
	
	rem Exit
	%@hoverButton% !exitButton_X! !exitButton_Y! 4 4 48;2;40;0;0;38;2;239;114;114 48;2;252;37;37;38;5;15 exitButton L
	%@hoverSound% exit hover_click.wav
	rem ESC or MAIN CLOSE BUTTON
	if "!$clicked!" equ "1" ( %endWhile% & exit ) else if defined keyspressed (%@asynckeys:?=27% ( %endWhile% & exit ))
	
	
	rem Register/Login
	       if not exist ".config\"     ( call scripts\offerToRegister && ( start /b "" cmd /c "%~nx0" & exit )
	) else if "!$loggedIn!" neq "true" ( call scripts\offerToLogin    && ( set "$loggedIn=true" ))

	
	
	if "!$loggedIn!" neq "false" (
		%@timedUserMsgBox% 2 15 32 6 33 15 239 10;Powered By Atlas;Welcome !$username!;.welcome;.dailyRewardMessage
		%@timedUserMsgBox% 2 17 32 7 196 15 239 5;Daily Reward +1;Total Points: !$totalPoints!;.dailyRewardMessage
		
		set /a ".adX=wid/2-32/2"
		if not defined .ad if "!min!.!sec!" equ "0.25" set ".ad=1"
		%@timedUserMsgBox% !.adX! 3 32 20 21 16 7 12;Advertisement;This project is still a work in progress. There are still a few things I want to implement. Overall, this is more of an environment to test so UI macros, and less of an independent project. Thank you for supporting my work. I appreciate you all.;.ad
	)
	


set /a "bgR=26 + $sliderValue, bgG=37 + $sliderValue, bgB=47 + $sliderValue"
rem display everything ------------------------------------------------------------------------------------------------
echo %@background%^
%\e%[%icarus_centerHei%;%icarus_centerWid%H%icarus%^
!exitButtonDisplay!^
!small_creditsDisplay!^
!REGISTER_ansiShadow_doubleDisplay!^
!LOGIN_ansiShadow_doubleDisplay!^
!$calendar!^
!sliderDisplay!^
!message!^
%\e%[!.boxY!;!.boxX!H!$msgbox!^
%\e%[!.timeLeftY!;!.timeLeftX!H%\e%[48;5;!.boxColor!;38;5;16m!.timeLeft!%\e%[m

)
goto :reset




:Set_Font FontName FontSize max/nomax dummy
if "%4"=="" (
	for /f "tokens=1,2 delims=x" %%a in ("%~2") do if "%%b"=="" (set /a "FontSize=%~2*65536") else set /a "FontSize=%%a+%%b*65536"
	reg add "HKCU\Console\%~nx0" /v FontSize /t reg_dword /d !FontSize! /f
	reg add "HKCU\Console\%~nx0" /v FaceName /t reg_sz /d "%~1" /f
	set "m=" & if /I "%~3"=="max" set "m=/max"
	start "%~nx0" !m! "%ComSpec%" /c "%~f0" _ 
	exit /b 1
) else ( >nul reg delete "HKCU\Console\%~nx0" /f )
goto:eof
