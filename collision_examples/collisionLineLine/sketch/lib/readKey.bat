@echo off
setlocal EnableDelayedExpansion

if not defined readKeyEmpty (
	for /f "delims=" %%A in ('type NUL ^| xcopy /w "%~f0" "%~f0" 2^>nul') do (
		if not defined readKeyEmpty set "readKeyEmpty=%%A"
	)
	for /f %%a in ('"prompt $H&for %%b in (1) do rem"') do set "BS=%%a"
	for /f %%A in ('copy /z "%~dpf0" nul') do set "CR=%%A"
	for /f "delims=" %%T in ('forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo(0x09"') do set "TAB=%%T"
	for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"
)

for /l %%# in () do (
	if exist "%temp%\abort.txt" (
		del /f /q "%temp%\abort.txt">nul
		exit
	)
	set "key="
	for /f "delims=" %%A in ('xcopy /w "%~f0" "%~f0" 2^>nul') do (
		if not defined key set "key=%%A^!"
	)
	if !key! equ !readKeyEmpty!^^! (
		exit /B 1
	) else if !key! equ !readKeyEmpty! (
		set "key=^!"
	) else if !key:~-1! equ ^^ (
		set "key=^"
	) else set "key=!key:~-2,1!"

	if "!key!" equ "%bs%" set "key={backspace}"
	if "!key!" equ "!cr!" set "key={enter}"
	if "!key!" equ "!tab!" set "key={tab}"
	echo=!key!
)