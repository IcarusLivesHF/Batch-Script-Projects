for %%i in (0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250 255 245 235 225 215 205 195 185 175 165 155 145 135 125 115 105 95 85 75 65 55 45 35 25 11) do (
	echo %\e%[2J%\e%[40;13H%\e%[38;2;%%i;%%i;%%im%presentation%%\e%[50;19H%SNAKE_LOGO%%\e%[m
	pathping 127.0.0.1 -n -q 1 -p 50  >nul
)




:loop
	%@radish%
	
	title !keysPressed!
	rem a, b, c, d represent the area of the PLAY button
	set /a "a=34, b=59, c=70, d=66, e=mouseX, f=mouseY",^
	       "hover=%pointRect%",^
	       "userClicksPlayButton=hover & L_click"
	
	if !hover! equ 1 (
		set "highlight=38;2;144;255;144;48;2;0;40;0"
	) else (
		set "highlight=38;2;255;255;255;48;2;11;11;11"
	)
	
	if !userClicksPlayButton! equ 1 goto :exitLoop
	
	echo %\e%[2J%\e%[40;33H%intro%%\e%[60;35H%\e%[!highlight!m%playButton%%\e%[m
goto :loop
:exitLoop
