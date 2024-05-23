@echo off & setlocal enableDelayedExpansion

call :atbashcipher "hello world"

pause & exit

:atbashcipher "string"
set "$cipher="
set "string=%~1"
set "alpha=abcdefghijklmnopqrstuvwxyz "
set "shift= zyxwvutsrqponmlkjihgfedcba"

for /l %%b in (12,-1,0) do (
    set /a "string.length|=1<<%%b"
    for %%c in (!string.length!) do if "!string:~%%c,1!" equ "" (
        set /a "string.length&=~1<<%%b"
    )
)

for /l %%i in (0,1,%string.length%) do for /l %%j in (0,1,26) do (
	if /i "!string:~%%i,1!" equ "!alpha:~%%j,1!" (
		set "$cipher=!$cipher!!shift:~%%j,1!"
    )
)
echo ATBASH: %$cipher%
goto :eof