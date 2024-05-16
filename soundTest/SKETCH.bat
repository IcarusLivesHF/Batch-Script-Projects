@echo off & setlocal enableDelayedExpansion

if "%~1" neq "" goto :%~1

call lib\stdlib 70 55
call lib\gfx
call lib\sound

set "cy=8"

"%~F0" Controller >"%temp%\%~n0_signal.txt" | "%~F0" Main <"%temp%\%~n0_signal.txt"
exit

:Main
	for /l %%# in () do (
	
		%@rect% 5 5 60 45
		set "scrn=!scrn!!$rect!"
		
		for /l %%i in (1,1,6) do (
			set /a "y=3 * %%i + 5"
			set "scrn=!scrn!%\e%[!y!;10H%%i. "
		)
		
		set "com=" & set /p "com="
		if /i "!com!" equ "w" (	
			%@playSound% "%sfx%\pointer3.wav"
			if !cy! geq 11 set /a "cy-=3"
		)
		if /i "!com!" equ "s" (  
			%@playSound% "%sfx%\pointer3.wav"
			if !cy! leq 20 set /a "cy+=3"
		)
		if /i "!com!" equ "d" (	 %@playSound% "%sfx%\confirm.wav"  )
		if /i "!com!" equ "a" (  %@playSound% "%sfx%\cancel.wav"  )
		
		set "scrn=!scrn!%\e%[!cy!;8H"
		
		title !cy!
		echo %\h%!scrn!
		set "scrn="
	)
exit



:Controller
for /l %%# in () do (
	for /f "tokens=*" %%i in ('choice /c:wasd /n') do <nul set /p "=%%~i"
)
exit