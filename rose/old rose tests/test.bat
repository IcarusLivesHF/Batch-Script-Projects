@echo off & setlocal enableDelayedExpansion
for %%n in (5000 30000 100000) do (
    for /f "tokens=1 delims==" %%i in ('set zz_ 2^>nul') do set "%%i="
    for /l %%i in (1,1,%%n) do set /a "zz_%%i=%%i"
    set "t0=!time!"
    for /l %%i in (1,1,20000) do set /a "q=zz_1234+zz_%%n"
    echo %%n vars:  !t0!  -^>  !time!
)
pause