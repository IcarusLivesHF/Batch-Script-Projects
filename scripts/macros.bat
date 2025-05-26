




set "@background=%\e%[H%\e%[48;2;^!bgR^!;^!bgG^!;^!bgB^!m%\e%[0J%\e%[H%\e%[m"





rem @getTimeCS:?=VAR <rtn> !VAR!
set @getTimeCS=for /f "tokens=1-4 delims=:.," %%a in ("^!time: =0^!") do set /a "?=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d"





rem @unique <rtn> $unique - create a unique ID
set "@unique=for /f "tokens=1-7 delims=/.-: " %%a in ("%date:* =% %time: =0%") do set "$unique=%%c%%a%%b%%d%%e%%f%%g""





rem substitute 0s for other reward types
set "@sumPoints=($totalPoints=dailyReward + 0 + 0 + 0 + 0)"









rem ----------------------------------------------------------------------------------------------------------
rem === encoding in base64 ===================================================================================
rem ----------------------------------------------------------------------------------------------------------
rem @encode "string" <rtn> $encode
set @encode=for %%# in (1 2) do if %%#==2 ( for /f "tokens=*" %%1 in ("^!args^!") do (%\n%
	echo=%%~1^>inFile.txt%\n%
	certutil -encode "inFile.txt" "outFile.txt"^>nul%\n%
	for /f "tokens=* skip=1" %%a in (outFile.txt) do (%\n%
		if "%%~a" neq "-----END CERTIFICATE-----" (%\n%
			set "$encode=!$encode!%%a"%\n%
		)%\n%
	)%\n%
	del /f /q "outFile.txt"%\n%
	del /f /q "inFile.txt"%\n%
)) else set args=



rem @decode "base64" <rtn> $decode
set @decode=for %%# in (1 2) do if %%#==2 ( for /f "tokens=*" %%1 in ("^!args^!") do (%\n%
	echo %%~1^>inFile.txt%\n%
	certutil -decode "inFile.txt" "outFile.txt"^>nul%\n%
	for /f "tokens=*" %%a in (outFile.txt) do (%\n%
		set "$decode=%%a"%\n%
	)%\n%
	del /f /q outFile.txt%\n%
	del /f /q inFile.txt%\n%
)) else set args=
rem ----------------------------------------------------------------------------------------------------------
rem ==========================================================================================================
rem ----------------------------------------------------------------------------------------------------------










rem ----------------------------------------------------------------------------------------------------------
rem === @HOVERBUTTON PACKAGE =================================================================================
rem ----------------------------------------------------------------------------------------------------------
rem 4 different sets of R G B required below
rem x y w h 48;2;r;g;b;38;2;r;g;b 48;2;r;g;b;38;2;r;g;b spriteName L/R
set @hoverButton=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-8" %%1 in ("^!args^!") do (%\n%
	set /a "a=%%~1 - 1",^
	       "b=%%~2 - 1",^
		   "c=%%~1 + %%~3 - 1",^
		   "d=%%~2 + %%~4 - 2",^
	       "$hovering=%@hovering%",^
		   "$clicked=$hovering & %%~8_click"%\n%
	if "^!$hovering^!" equ "0" ( %\n%
		     set "_%%~7_hightlight=%%~5"%\n%
	) else ( set "_%%~7_hightlight=%%~6")%\n%
	set "%%~7Display=%\e%[^!_%%~7_hightlight^!m%\e%[%%~2;%%~1H^!%%~7^!%\e%[m"%\n%
)) else set args=



rem rising-edge
rem @hoverSound NAME sound.wav
set @hoverSound=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1,2" %%1 in ("^!args^!") do (%\n%
	set /a "_lastHover_%%~1=_hover_%%~1, _hover_%%~1=_hovering_%%~1=%@hovering%, _%%~1HoverSound=_hovering_%%~1 & ~_lastHover_%%~1 & 1"%\n%
	if "^!_%%~1HoverSound^!" equ "1" ^!@playSound^! "%sfx%\%%~2"%\n%
)) else set args=
rem ----------------------------------------------------------------------------------------------------------
rem === END @HOVERBUTTON PACKAGE =============================================================================
rem ----------------------------------------------------------------------------------------------------------








rem ----------------------------------------------------------------------------------------------------------
rem === @MSGBOX PACKAGE ======================================================================================
rem ----------------------------------------------------------------------------------------------------------
rem w h c1 c2 bc;title;text <rtn> $msgbox
set @msgbox=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-3 delims=;" %%A in ("^!args^!") do (%\n%
	set "_string="%\n%
	set "_chunkOfText="%\n%
	for /f "tokens=1-5" %%1 in ("%%~A") do (%\n%
		set /a "_d=%%1 - 2, _d2=_d - 2"%\n%
		set /a "_b=%%2 - 1"%\n%
		set "_fillRect=^!$s:~0,%%2^!"%\n%
		set "_fillrect=^!_fillrect: =%\e%[%%1X%\e%[B^!"%\n%
		set "_hLine=^!$q:~0,%%1^!"%\n%
		set "_hLine=^!_hLine:~0,-2^!"%\n%
		set "_vLine=^!$s:~0,%%2^!"%\n%
		set "_vLine=^!_vLine:~0,-1^!"%\n%
		set "_vLine=^!_vLine: =x%\e%[D%\e%[B^!"%\n%
		rem this can be made into a single line, but for readability it is like this%\n%
		set "$msgbox=%\e%7%\e%[2B%\e%[2C%\e%[48;5;16m^!_fillRect^!%\e%8"%\n%
		set "$msgbox=^!$msgbox^!%\e%7%\e%[48;5;%%5m^!_fillRect^!%\e%8"%\n%
		set "$msgbox=^!$msgbox^!%\e%7%\e%(0%\e%[38;5;15ml^!_hLine^!%\e%[38;5;16mk%\e%8%\e%[%%2B"%\n%
		set "$msgbox=^!$msgbox^!%\e%7%\e%[38;5;15mm%\e%[38;5;16m^!_hLine^!j%\e%8%\e%[%%2A%\e%[B"%\n%
		set "$msgbox=^!$msgbox^!%\e%7%\e%[38;5;15m^!_vLine^!%\e%8%\e%[%%1C%\e%[D"%\n%
		set "$msgbox=^!$msgbox^!%\e%7%\e%[38;5;16m^!_vLine^!%\e%8%\e%[^!_d^!D%\e%[C%\e%[B"%\n%
		set "$msgbox=^!$msgbox^!%\e%7%\e%[38;5;16ml^!_hLine:~0,-4^!%\e%[38;5;15mk%\e%8%\e%[^!_b^!B%\e%[2A"%\n%
		set "$msgbox=^!$msgbox^!%\e%7%\e%[38;5;16mm%\e%[38;5;15m^!_hLine:~0,-4^!j%\e%8%\e%[^!_b^!A%\e%[3B"%\n%
		set "$msgbox=^!$msgbox^!%\e%7%\e%[38;5;16m^!_vLine:~0,-24^!%\e%8%\e%[^!_d^!C%\e%[3D"%\n%
		set "$msgbox=^!$msgbox^!%\e%7%\e%[38;5;15m^!_vLine:~0,-24^!%\e%(B%\e%8%\e%[^!_d2^!D%\e%[C%\e%[2A"%\n%
		set "$msgbox=^!$msgbox^!%\e%7%\e%[38;5;%%~3m%%~B%\e%8"%\n%
		set "$msgbox=^!$msgbox^!%\e%7%\e%[%%~1C%\e%[4D%\e%[38;5;196mX%\e%[38;5;16m%\e%8%\e%[2B%\e%[2C"%\n%
		set "$msgbox=^!$msgbox^!%\e%[38;5;%%~4m"%\n%
		set "_text=%%~C"%\n%
		if "^!_text^!" neq "^!_text:,=^!" set "_text=^!_text:,=`^!"%\n%
		for %%i in (^^!_text^^!) do (%\n%
			set "_str=%%i#"%\n%
			set "$length=0"%\n%
			for %%P in (32 16 8 4 2 1) do if "^!_str:~%%P,1^!" NEQ "" (%\n%
				set /a "$length+=%%P"%\n%
				set "_str=^!_str:~%%P^!"%\n%
			)%\n%
			set /a "_sum+=$length + 1, _diff=%%1 - 6 - _sum"%\n%
			if ^^!_diff^^! gtr 0 (%\n%
				set "_string=^!_string^!%%i "%\n%
			) else (%\n%
				set "_chunkOfText=^!_chunkOfText^!%\e%7^!_string^!%\e%8%\e%[B"%\n%
				set "_string=%%~i "%\n%
				set /a "_sum=$length + 1"%\n%
			)%\n%
		)%\n%
		set "$msgbox=^!$msgbox^!^!_chunkOfText^!^!_string^!"%\n%
		set "_sum="%\n%
	)%\n%
	if "^!$msgbox^!" neq "^!$msgbox:`=^!" set "$msgbox=^!$msgbox:`=,^!"%\n%
	for %%i in (_hline _vline _fillRect _string _sum _diff _chunkOfText _str _d _d2 _b) do set "%%~i="%\n%
)) else set args=



rem @clickAndDrag x y w h L/R
set @clickAndDrag=for %%# in (1 2) do if %%#==2 (for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	set /a "$clickingInsideBox=((~((mouseX - %%~1 + 1) | (%%~1 + %%~3 - mouseX - 1) | (mouseY - %%~2 + 1) | (%%~2 + %%~4 - mouseY - 2)) >> 31) & 1) & %%~5_click"%\n%
	if ^^!$clickingInsideBox^^! equ 1 ( %\n%
		if defined dragging ( set /a "%%~1=mouseX - offsetX, %%~2=mouseY - offsetY"%\n%
		)        else       ( set /a "offsetX=mouseX - %%~1, offsetY=mouseY - %%~2, dragging=1" )%\n%
	) else set "dragging="%\n%
)) else set args=



rem 0 by default, 1 if true if mouse is clicking 
set "@ifClickingPoint=(_t=(mouseX^x)|(mouseY^y)|(L_click^1), (~(_t|-_t)>>31)&1)"

rem uses all macros above to create a clickable/movable/closable msgbox
rem @timedUserMsgBox x y wid hei color1 color2 color3 seconds stringVAR(unexpanded) titleVAR(unexpanded) ID(to trigger another msgbox)
set @timedUserMsgBox=for %%# in (1 2) do if %%#==2 (for /f "tokens=1-5 delims=;" %%a in ("^!args^!") do (%\n%
	if not defined .active (%\n%
		if defined %%~d (%\n%
			set "%%~d="%\n%
			for /f "tokens=1-8" %%1 in ("%%~a") do (%\n%
				set /a ".%%~d_active=.active=1",^
					   ".boxX=%%~1, .boxY=%%~2, .boxWid=%%~3, .boxHei=%%~4, .boxColor=%%~7",^
					   ".activeTimer=totalTime + %%~8 * 100"%\n%
				if not defined $msgbox (%\n%
					^!@msgbox^! ^^!.boxWid^^! ^^!.boxHei^^! %%~5 %%~6 %%~7;%%~b;%%~c%\n%
				)%\n%
			)%\n%
		)%\n%
	)%\n%
	if defined .%%~d_active (%\n%
		^!@clickAndDrag^! .boxX .boxY .boxWid .boxHei L %\n%
		set /a ".exitX=.boxX + .boxWid - 3",^
		       ".exitY=.boxY",^
			   "x=.exitX, y=.exitY, $closeMsgbox=^!@ifClickingPoint^!",^
			   ".timeLeft=(.activeTimer - totalTime) / 100",^
			   ".timeLeftX=.boxX + .boxWid - 6",^
			   ".timeLeftY=.boxY + .boxHei - 2",^
			   "$closeMsgbox+=((.timeLeft-1)>>31)&1"%\n%
		if "^!$closeMsgbox^!" equ "1" (%\n%
			for /f "tokens=1 delims==" %%i in ('set .') do set "%%~i="%\n%
			set "$msgbox="%\n%
			if "%%~e" neq "" set "%%~e=1"%\n%
		)%\n%
	)%\n%
)) else set args=
rem only 1 msgbox can be active at a time, so if any are triggered on a timer, but one exists, it will be skipped.

rem ----------------------------------------------------------------------------------------------------------
rem === END @MSGBOX PACKAGE ==================================================================================
rem ----------------------------------------------------------------------------------------------------------



