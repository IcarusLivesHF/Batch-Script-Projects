rem variable for direct call to tool
set "radish=lib\3rdparty\radish"

rem Usage: %@mouse_and_keys% <no arguments> <rtn> !mouseX! !mouseY! !scroll! !keysPressed!
set "@mouse_and_keys=for /f "tokens=1-4 delims=." %%1 in ("^^!CMDCMDLINE^^!") do set /a "mouseX=%%~1, mouseY=%%~2, scroll=%%~3" & set "keysPressed=%%~4""

rem Usage: %radish_end% -> alternative to 'exit'
set "radish_end=(taskkill /f /im "radish.exe")>nul & exit"


rem COPY/PASTE this code directly above your :main loop
REM ---------------------------------
	REM ( %radish% "%~nx0" radish_wait ) & exit
	REM :radish_wait
	REM ( %while% if exist "radish_ready" %end.while% ) & del /f /q "radish_ready"
REM ---------------------------------

call lib\mouseAndKeys