@echo off & setlocal enableDelayedExpansion

if "%~1" neq "" goto :%~1


"%~F0" Controller >"%temp%\%~n0_signal.txt" | "%~F0" Main <"%temp%\%~n0_signal.txt"
exit



:Main
	for /l %%# in () do (
		
		if defined key set "lastKey=!key!"
		set "key=" & set /p "key="
		
		echo !time! - !lastKey!

	)
exit



:Controller
for /l %%# in () do (
	for /f "tokens=*" %%i in ('choice /c:wasd /n') do <nul set /p "=%%~i"
)
exit
