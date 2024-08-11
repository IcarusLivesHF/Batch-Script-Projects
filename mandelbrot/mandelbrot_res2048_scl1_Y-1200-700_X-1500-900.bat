@echo off & setlocal enableDelayedExpansion & mode 601,500

call :Set_Font "mxplus ibm ega 8x8" 1 nomax %1 || exit

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set "res=2048"
set "scale=1"
for /l %%y in (-1200,1,-700) do for /l %%x in (-1500,1,-900) do (
    set /a "a=0", "b=0"
    for /l %%i in (1,1,64) do (
        set /a "aa=a * a / res",^
		       "bb=b * b / res",^
			   "aabb=aa * bb"
        if !aabb! lss 1000000000 (
            set /a "b=2 * a * b / res + %%y * scale",^
			       "a=aa - bb + %%x * scale",^
				   "bright=(%%i<<2) %% 256"
        )
    )
    <nul set /p "=%\e%[48;2;!bright!;!bright!;!bright!m "
)

pause>nul
exit

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