rem variable for direct call to tool
set "radish=lib\3rdparty\radish"

set "equ=(~(((Rmeta-x)>>31)|((x-Rmeta)>>31)))&1"
rem Usage: %@radish% <no arguments> <rtn> !mouseX! !mouseY! !L_click! !R_click! !B_click! !scrollUp! !scrollDown! !keysPressed!
set @radish=(%\n%
	for /f "tokens=1-4 delims=." %%1 in ("^!CMDCMDLINE^!") do (%\n%
		set /a "mouseX=%%~1", "mouseY=%%~2", "Rmeta=%%~3", "L_click=%equ:x=1%", "R_click=%equ:x=2%", "B_click=%equ:x=3%", "scrollUp=%equ:x=6%", "scrollDown=%equ:x=-6%"%\n%
		set "keysPressed=%%~4"%\n%
	)%\n%
)
set "equ="

rem Usage: %radish_end%
set "radish_end=(taskkill /f /im "radish.exe")>nul"


rem COPY/PASTE this code directly above your :main loop
REM ---------------------------------
	REM ( %radish% "%~nx0" radish_wait ) & exit
	REM :radish_wait
	REM ( %while% if exist "radish_ready" %end.while% ) & del /f /q "radish_ready"
REM ---------------------------------

call lib\mouseAndKeys