
setlocal EnableDelayedExpansion
	for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%
    echo.
    set "pw="
	set /a "_centerPromptX=wid / 2 - 10"
    set /p "pw=%\e%[48;2;26;37;47;38;5;15m%\e%[27;!_centerPromptX!HEnter NEW password: %\e%[m"
    
	set "atLeastOneLowercase=False"
	set "atLeastOneUppercase=False"
	set "atLeastOneNumber=False"
	set "atLeastOneSpecial=False"
	set "requiredLength=8"
	set "valid=false"

	set "str=%PW%#"
	set "$length=0"
	for %%P in (8 4 2 1) do if "!str:~%%P,1!" NEQ "" (
		set /a "$length+=%%P"
		set "str=!str:~%%P!"
	)

	for /l %%j in (0,1,%$length%) do (
		for /l %%i in (0,1,9) do if "!pw:~%%j,1!" equ "%%~i" set "atLeastOneNumber=True"
		for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do if "!pw:~%%j,1!" equ "%%~i" set "atLeastOneUppercase=True"	
		for %%i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do if "!pw:~%%j,1!" equ "%%~i" set "atLeastOneLowercase=True"
		for %%i in ({ } ~ [ \ ] _ ` : ; = ? @   # $ ' * + , - . /) do if "!pw:~%%j,1!" equ "%%~i" set "atLeastOneSpecial=True"
	)

	if !$length! geq !requiredLength! (
		if "!atLeastOneLowercase!" neq "False" (
			if "!atLeastOneUppercase!" neq "False" (
				if "!atLeastOneNumber!" neq "False" (
					if "!atLeastOneSpecial!" neq "False" (
						set /p "confirmation=%\e%[48;2;26;37;47;38;5;15m%\e%[29;!_centerPromptX!HRe-Enter  password: %\e%[m"
						if "!confirmation!"=="%pw%" (
							set "valid=true"
						) else echo The password you re-entered did %\e%[38;5;9mnot%\e%[m match.
					) else echo Password should have at least %\e%[38;5;9m1 %\e%[38;5;33mSpecial character%\e%[m.
				) else echo Password should have at least %\e%[38;5;9m1 %\e%[38;5;46mNumber%\e%[m.
			) else echo Password should have at least %\e%[38;5;9m1 %\e%[38;5;202mUppercase%\e%[m.
		) else echo Password should have at least %\e%[38;5;9m1 %\e%[38;5;226mLowercase%\e%[m.
	) else echo Password should be at least %\e%[38;5;9m8 %\e%[38;5;162mcharacters in length%\e%[m.
	
	if "%valid%" neq "false" (
		endlocal & set "$password=%pw%" & exit /b 0
	) else echo Please try again
	pause
endlocal
exit /b 1