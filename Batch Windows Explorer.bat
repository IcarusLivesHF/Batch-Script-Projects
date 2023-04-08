@echo off & setlocal enableDelayedExpansion

rem Revision 3.28.4
rem https://github.com/IcarusLivesHF/Windows-Batch-Library/tree/056647416d358f5c6883e985e12373f90d4f169b

set "revisionRequired=3.28.4"
set  "openLib=(ren "%~nx0" temp.bat & ren "Library.bat" "%~nx0""
set "closeLib=ren "%~nx0" "Library.bat" & ren temp.bat "%~nx0")" & set "self=%~nx0"
(2>nul %openLib% && ( call :revision ) || ( ren temp.bat "%~nx0" & echo Library.bat Required & timeout /t 3 & exit))
	call :StdLib 144 89
	call :misc
	call :macros
	call :mouse
%closeLib%  && ( cls & goto :setup)
:setup

if not exist "%temp%\NirCmd.exe" (
	set "url=https://www.nirsoft.net/utils/nircmd-x64.zip"
	set "file=nircmd.zip"

	%download% !url! !file!
	%unZIP% nircmd

	del /f /q NirCmd.chm
	del /f /q NirCmdc.exe
	del /f /q NirCmd.zip

	move /-y NirCmd.exe "%temp%"
)
call:createSlider 112 86 20 0 100 15 9
set /a "noIconsPast=hei - 7", "exitIconX=wid - 8 - 2", "exitIconY=2", "backIconX=wid - 8 - 2", "backIconY=7"
set /a "exit_X_FROM=exitIconX", "exit_X_TO=exitIconX + 8", "exit_Y_FROM=exitIconY", "exit_Y_TO=exitIconY + 4"
set /a "back_X_FROM=backIconX", "back_X_TO=backIconX + 8", "back_Y_FROM=backIconY", "back_Y_TO=backIconY + 4"
set "stdWinCol=%esc%[48;5;7m%esc%[38;5;16m"
set "folderIcon=%esc%[48;2;255;233;162m%esc%[38;5;16m.----.%esc%[48;5;16m%esc%[38;2;255;233;162m_______%esc%[48;2;255;233;162m%esc%[38;5;16m%esc%[B%esc%[13D| ? |%esc%[B%esc%[13D|   ____________%esc%[B%esc%[16D|  /           /%esc%[B%esc%[16D| /           /%esc%[B%esc%[15D|/___________/%esc%[2B%esc%[14D%esc%[0m"
set "executableIcon=.--------------.%esc%[B%esc%[16D|              |%esc%[B%esc%[16D|              |%esc%[B%esc%[16D| ? |%esc%[B%esc%[16D|              |%esc%[B%esc%[16D|______________|%esc%[2B%esc%[16D%esc%[0m"
set "backIcon=%stdWinCol%%esc%[!backIconY!;!backIconX!H.------.%esc%[B%esc%[8D|      |%esc%[B%esc%[8D| BACK |%esc%[B%esc%[8D|______|%esc%[2B%esc%[8D%esc%[0m"
set "exitIcon=%stdWinCol%%esc%[!exitIconY!;!exitIconX!H.------.%esc%[B%esc%[8D|      |%esc%[B%esc%[8D| EXIT |%esc%[B%esc%[8D|______|%esc%[2B%esc%[8D%esc%[0m"
set "startBar=%stdWinCol%.---------------------------------------------------------------------------------------------------------------------------------------------.%esc%[B%esc%[143D| START |                                                                                                                            | ^!currentTime^!^!$padding^!  |%esc%[B%esc%[143D|_______|_____________________________________________________________________________________________________________________________________|%esc%[0m"
set "load=firefox=%esc%[48;2;255;149;0m%esc%[38;5;16m.discord=%esc%[48;2;115;138;219m%esc%[38;5;16m."
(set "numOfFileColors=1" & set "fileColors[!numOfFileColors!]=%load:.=" & set /a numOfFileColors+=1 & set "fileColors[!numOfFileColors!]=%") & set /a "numOfFileColors-=1"

:main
	if "%loadedCurrentDirectory%" neq "True" (
		set "screen="
		set /a "directories=0", "executables=0", "Xpos=0", "Ypos=0"
		for /f "tokens=*" %%i in ('dir /b /o:G') do (

			set "fileInDirectory=%%i"
			
			set "currentExt=" & set "currentName=" & set "currentFileType="
			for /f "tokens=1,2 delims=." %%j in ("!fileInDirectory!") do (
				set "currentName=%%j" & set "currentExt=%%k"
			)
			
			
			if "!currentExt!" equ "" (
				set "currentFileType=Directory"
			) else set "currentFileType=Executable"
			
			if /i "!currentFileType!" equ "Directory" (
			
				set /a "directories+=1"
				set /a "folder[!directories!]_X_FROM=Xpos", "folder[!directories!]_X_TO=Xpos + 16",^
					   "folder[!directories!]_Y_FROM=Ypos", "folder[!directories!]_Y_TO=Ypos + 6"
				set "folder[!directories!]_NAME=!currentName!"
			
				%getLen% "!currentName!"
				
				if !$length! gtr 9 (
					set "fileInDirectory=!fileInDirectory:~0,9!"
				) else (
					%pad% "!currentName!".9
					set "fileInDirectory=!fileInDirectory!!$padding!"
				)
				for %%f in ("!fileInDirectory!") do (
					set "screen=!screen!!folderIcon:?=%%~f!"
				)
				
			) else if /i "!currentFileType!" equ "Executable" (
			
				set /a "executables+=1"
				set /a "executable[!executables!]_X_FROM=Xpos", "executable[!executables!]_X_TO=Xpos + 16",^
					   "executable[!executables!]_Y_FROM=Ypos", "executable[!executables!]_Y_TO=Ypos + 6"
				set "executable[!executables!]_NAME=!fileInDirectory!"
			
				for /l %%c in (1,1,%numOfFileColors%) do (
					for /f "tokens=1,2 delims=.=" %%d in ("!fileColors[%%c]!") do (
						set "color=%%e"
						if /i "%%d" equ "!currentName!" (
							set "color=!color!"
						) else (
							set /a "%rndRGB%"
							set "color=%esc%[48;2;!r!;!g!;!b!m%esc%[38;5;16m"
						)
					)
				)
			
				%getLen% "!fileInDirectory!"
				
				if !$length! gtr 12 (
					set "fileInDir=!currentName:~0,8!.!currentExt!"
				) else (
					%pad% "!currentName! !currentExt!".12
					set "fileInDir=!currentName:~0,8!.!currentExt!!$padding!"
				)
				
				for %%f in ("!fileInDir!") do (
					set "screen=!screen!!color!!ExecutableIcon:?=%%~f!"
				)
				
			)
			
			set /a "Ypos+=7"
			if !Ypos! geq %noIconsPast% (
				set /a "Xpos+=18", "Ypos=0"
				set "screen=!screen!%esc%[!Ypos!;!Xpos!H"
			)
		)
	)
	set "loadedCurrentDirectory=True"
	
	for /f "tokens=1,2 delims=:" %%a in ("!time!") do set /a "hour=%%a %% 12", "minute=%%b"
	set "currentTime=%hour%:%minute%"
	%pad% "!currentTime!".5
	
	cls & <nul set /p "=!screen!%exitIcon%%backIcon%"
	<nul set /p "=%esc%[85;0H%startBar%%esc%[H"
	<nul set /p "=%stdWinCol%%esc%[86;104HVOL: !sliderValue!%sliderBar%%sliderPos%"
	
	%allowMouseClicks%
	%allowMoveSlider%
	
	for /l %%d in (1,1,%directories%) do (
		set /a "ma=folder[%%d]_Y_FROM, mb=folder[%%d]_Y_TO, mc=folder[%%d]_X_FROM, md=folder[%%d]_X_TO"
		2>nul set /a "%mouseBound%" && (
			set "loadedCurrentDirectory=False"
			cd "!folder[%%d]_NAME!"
			for /l %%d in (1,1,%directories%) do (
				set "folder[%%d]_X_FROM="
				set "folder[%%d]_X_TO="
				set "folder[%%d]_Y_FROM="
				set "folder[%%d]_Y_TO="
				set "folder[%%d]_NAME="
			)
			goto :main
		)
	)
	
	for /l %%d in (1,1,%executables%) do (
		set /a ma=executable[%%d]_Y_FROM, mb=executable[%%d]_Y_TO,^
				mc=executable[%%d]_X_FROM, md=executable[%%d]_X_TO
		2>nul set /a "%mouseBound%" && (
			start !executable[%%d]_NAME!
			goto :main
		)
	)
	
	set /a "ma=back_Y_FROM, mb=back_Y_TO, mc=back_X_FROM, md=back_X_TO"
	2>nul set /a "%mouseBound%" && (
		set "loadedCurrentDirectory=False"
		for /l %%d in (1,1,%directories%) do (
			set "folder[%%d]_X_FROM="
			set "folder[%%d]_X_TO="
			set "folder[%%d]_Y_FROM="
			set "folder[%%d]_Y_TO="
			set "folder[%%d]_NAME="
		)
		cd..
		goto :main
	)
	
	set /a "ma=exit_Y_FROM, mb=exit_Y_TO, mc=exit_X_FROM, md=exit_X_TO"
	2>nul set /a "%mouseBound%" && (
		exit
	)
	
	set /a "v=sliderValue, a=1, b=100, c=1, d=65535, volume=%map%"
	>nul %temp%\nircmd.exe setsysvolume %volume%

goto :main

:createSlider x y length minRange maxRange barColor posColor
	for /l %%a in (1,1,%~3) do set "slider=!slider!-"
	set /a "slider[Xmin]=%~1+1","slider[Xmax]=%~1 + %~3","sxp1=%~1+1","sym1=%~2-1"
	set "sliderBar=%esc%[%~2;%~1H%esc%[48;5;16m%esc%[38;5;%~6m|%slider%|%esc%[0m"
	set "sliderPos=%esc%[%~2;%sxp1%H%esc%[38;5;%~7m�%esc%[0m"
	set "allowMoveSlider=if ^!mouseY^! equ ^!sym1^! if ^!mouseX^! geq ^!slider[Xmin]^! if ^!mouseX^! leq ^!slider[Xmax]^! set /a "adaptedY=mouseY + 1, v=mouseX, a=slider[Xmin], b=slider[Xmax], c=%~4, d=%~5, sliderValue=%map%" ^& set "sliderPos=%esc%[^^!adaptedY^^!;^^!mouseX^^!H%esc%[38;5;%~7m�%esc%[0m""
goto :eof
