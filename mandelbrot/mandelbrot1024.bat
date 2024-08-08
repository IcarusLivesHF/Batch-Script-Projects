@echo off & setlocal enableDelayedExpansion & mode 540,256

call :Set_Font "Lucida Console" 2 nomax %1 || exit

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"
set "sqrt=( q=(N)/3030-(N)/18748900*5028-(N)/2079177597*2344+31, q=((N)/(((N)/q+q)>>1)+(((N)/q+q)>>1))>>1, q=((N)/(((N)/q+q)>>1)+(((N)/q+q)>>1))>>1, q+=((N)-q*q)>>31 )"
set "map=x2 + (y2 - x2) * (v - x1) / (y1 - x1)"

for /l %%y in (-128,1,128) do for /l %%x in (-167,1,102) do (
    set /a "a=0", "b=0"
    for /l %%i in (0,1,15) do (
        set /a "aa=a * a / 1024", "bb=b * b / 1024", "aabb=aa * bb"
        if !aabb! lss 1000000 (
            set /a "b=2 * a * b / 1024 + %%y * 10", "a=aa - bb + %%x * 10",^
				   "v=%%i, x1=0, y1=15, x2=0, y2=100", "v=!sqrt:N=%map%!, x1=0, y1=10, x2=0, y2=255, bright=%map%"
        )
    )
    <nul set /p "=%\e%[48;2;!bright!;!bright!;!bright!m  "
)

pause
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