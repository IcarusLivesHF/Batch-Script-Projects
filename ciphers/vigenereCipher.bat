@echo off & setlocal enableDelayedExpansion

call :vigenerecipher "attack at dawn" "lemon"

pause & exit

:vigenerecipher "string" key
set "$cipher="
set "string=%~1"
set "key=%~2"
set "alpha=abcdefghijklmnopqrstuvwxyz"

set /a "string.length=0"
for /l %%b in (8,-1,0) do (
    set /a "string.length|=1<<%%b"
    for %%c in (!string.length!) do if "!string:~%%c,1!" equ "" (
		set /a "string.length&=~1<<%%b"
    )
)
set /a "string.length+=1"
for /l %%i in (1,1,4) do set "key=!key!!key!!key!!key!"
set "key=!key:~0,%string.length%!"

set /a "string.length-=1"
for /l %%i in (0,1,%string.length%) do (
	set "shift=-1"
	set "shiftalpha="
	for %%j in (a b c d e f g h j i k l m n o p q r s t u v w x y z) do (
		set /a "shift+=1"
		if /i "!key:~%%i,1!" equ "%%j" (
			for %%s in (!shift!) do (
				set "shiftalpha=!alpha:~%%s!!alpha:~0,%%s!"
			)
		)
	)
	for /l %%j in (0,1,25) do (
		if /i "!string:~%%i,1!" equ "!alpha:~%%j,1!" (
			set "$cipher=!$cipher!!shiftalpha:~%%j,1!"
		)
	)
)

echo Vigenere Cipher: %$cipher%
goto :eof