@echo off & setlocal enableDelayedExpansion & mode 80,40

call :caesarcipher "hello world" 4

pause & exit

:caesarcipher "string" shiftLength
set "$cipher="
set "string=%~1"
set "shift.length=%~2" & rem 0-26
set "alpha=abcdefghijklmnopqrstuvwxyz "
set "shift=!alpha:~%shift.length%!!alpha:~0,%shift.length%!"

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
echo Caesar Cipher: %$cipher%
goto :eof