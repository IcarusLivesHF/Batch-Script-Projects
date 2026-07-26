@echo off & setlocal enableDelayedExpansion
set "E1=q=1"
set "E30=" & for /l %%n in (1,1,30) do set "E30=!E30!q%%n=%%n,"
set "E30=!E30!q=1"
echo %time%
for /l %%i in (1,1,20000) do set /a "%E1%"
echo %time%   20000 x 1 subexpr
for /l %%i in (1,1,20000) do set /a "%E30%"
echo %time%   20000 x 30 subexpr
pause