@echo off

call :dateExpiry

echo Made by Icarus Lives
pause
exit

:dateExpiry
	set "expiryDate=YYYY-MM-DD" & rem change this value
	for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set datetime=%%G
	set "currentDate=%datetime:~0,4%-%datetime:~4,2%-%datetime:~6,2%"
	if "%currentDate%" geq "%expiryDate%" start /b "" cmd /c del "%~nx0" & exit
goto :eof