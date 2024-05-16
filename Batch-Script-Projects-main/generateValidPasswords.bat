@echo off & setlocal enableDelayedExpansion

set "esc="
set /a "numOfPasswords=10"
for /l %%a in (1,1,%numOfPasswords%) do (
	call :generatePassword
	echo.
	echo Generated Password:%esc%[38;5;11m !generatedPassword! %esc%[0m
	echo.
)
pause & exit


:generatePassword lengthOfPassword <rtn> %generatedPassword%
rem Writes to file "generatedPasswords.txt" on DESKTOP
set "atLeastOneLowercase=False"
set "atLeastOneUppercase=False"
set "atLeastOneNumber=False"
set "atLeastOneSpecial=False"
set "requiredLength=8"
set "generatedPassword="
if "%~1" neq "" (
	set "generatedLength=%~1"
) else (
	set /a "generatedLength=requiredLength"
)
set "ascii_str= #$'*+,-./0123456789:;=?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]_`abcdefghijklmnopqrstuvwxyz{}~"
for /l %%i in (1,1,%generatedLength%) do (
	set /a "rndchr=!random! %% 85"
	for %%r in (!rndchr!) do (
		set "generatedPassword=!generatedPassword!!ascii_str:~%%r,1!"
	)
)

set "$_str=%generatedPassword%#"
set "$length=0"
for %%P in (64 32 16 8 4 2 1) do (
	if "!$_str:~%%P,1!" NEQ "" (
		set /a "$length+=%%P"
		set "$_str=!$_str:~%%P!"
	)
)
if !$length! lss !requiredLength! echo %esc%[38;5;9mPassword should be at least 8 characters in length.%esc%[0m
for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
	for /l %%j in (0,1,%$length%) do (
		if "!generatedPassword:~%%j,1!" equ "%%~i" (
			set "atLeastOneUppercase=True"
		)
	)
)
if "!atLeastOneUppercase!" neq "True" echo %esc%[38;5;9mPassword should have at least 1 Uppercase.%esc%[0m

for %%i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
	for /l %%j in (0,1,%$length%) do (
		if "!generatedPassword:~%%j,1!" equ "%%~i" (
			set "atLeastOneLowercase=True"
		)
	)
)
if "!atLeastOneLowercase!" neq "True" echo %esc%[38;5;9mPassword should have at least 1 Lowercase.%esc%[0m

for /l %%i in (0,1,9) do (
	for /l %%j in (0,1,%$length%) do (
		if "!generatedPassword:~%%j,1!" equ "%%~i" (
			set "atLeastOneNumber=True"
		)
	)
)
if "!atLeastOneNumber!" neq "True" echo %esc%[38;5;9mPassword should have at least 1 Number.%esc%[0m

for %%i in ({ } ~ [ \ ] _ ` : ; = ? @   # $ ' * + , - . /) do (
	for /l %%j in (0,1,%$length%) do (
		if "!generatedPassword:~%%j,1!" equ "%%i" (
			set "atLeastOneSpecial=True"
		)
	)
)

if "!atLeastOneSpecial!" neq "True" echo %esc%[38;5;9mPassword should have at least 1 Special character.%esc%[0m

if !$length! geq !requiredLength! (
	if "!atLeastOneLowercase!" neq "False" (
		if "!atLeastOneUppercase!" neq "False" (
			if "!atLeastOneNumber!" neq "False" (
				if "!atLeastOneSpecial!" neq "False" (
					echo %esc%[38;5;10mPassword met all requirements, and was saved to desktop.%esc%[0m
					pushd %userprofile%\desktop
					echo %date%	^|	%time%	^|	%generatedPassword%>>"generatedPasswords.txt"
					popd
				)
			)
		)
	)
)
goto :eof