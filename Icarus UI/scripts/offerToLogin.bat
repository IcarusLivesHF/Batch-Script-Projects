set /a "loginButtonX=wid / 2 - LOGIN_ansiShadow_double_wid / 2",^
	   "loginButtonY=hei / 2 - LOGIN_ansiShadow_double_hei / 2"


%@hoverButton% !loginButtonX! !loginButtonY! LOGIN_ansiShadow_double_wid LOGIN_ansiShadow_double_hei 48;2;25;35;30;38;2;104;169;222 48;2;25;35;30;38;2;114;239;232 LOGIN_ansiShadow_double L
%@hoverSound% login hover_click.wav


set "$login=0"
if defined keyspressed %@asynckeys:?=13% ( set "$login=1" )
if "!$clicked!" equ "1" ( set "$login=1" )

if "!$login!" equ "1" (

	if not defined .played %@playSound% "%sfx%\bright_confirm.wav"
	set ".played=true"
	
	set /a "_centerPromptX=wid / 2 - 8"
	set /p "$password=%\e%[48;2;26;37;47;38;5;15m%\e%[27;!_centerPromptX!HEnter password: %\e%[m"
	
	for /f "usebackq delims=" %%i in (".config\user.dat") do (
		%@decode% %%~i
	)
	
	if "!$password!" equ "!$decode!" (
		set "LOGIN_ansiShadow_doubleDisplay="
		
		for /f "usebackq delims=" %%i in (".config\ID.dat") do (
			set "$username=%%~i"
		)
		
		call scripts\dailyRewardCheck
		
		set ".played="
		set ".welcome=1"
		exit /b 0
	) else (
		echo Incorrect password
		echo Please try again
	)
	
	set "$decode="
	set "$password="
	set "$login="
)
exit /b 1