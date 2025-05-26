set /a "registerButtonX=wid / 2 - REGISTER_ansiShadow_double_wid / 2",^
	   "registerButtonY=hei / 2 - REGISTER_ansiShadow_double_hei / 2"

%@hoverButton% !registerButtonX! !registerButtonY! REGISTER_ansiShadow_double_wid REGISTER_ansiShadow_double_hei 48;2;0;40;0;38;5;15 48;2;102;187;106;38;5;16 REGISTER_ansiShadow_double L
%@hoverSound% register hover_click.wav

if "!$clicked!" equ "1" (
	
	if not defined .played %@playSound% "%sfx%\bright_confirm.wav"
	set ".played=true"
	
	set /a "_centerPromptX=wid / 2 - 59 / 2"
	echo %\e%[48;2;26;37;47;38;5;15m%\e%[24;!_centerPromptX!HScript will restart itself upon successful account creation%\e%[m
	
	
	
	call scripts\createPassword && (
	  md ".config\"
	  
	  %@unique%
	  set "$username=!$unique!"
	  echo !$unique!>".config\ID.dat"
	  
	  %@encode% !$password!
	  echo !$encode!>".config\user.dat"
	  
	  set "$encode="
	  set "$password="
	  set ".played="
	  exit /b 0
	)
	
)
exit /b 1