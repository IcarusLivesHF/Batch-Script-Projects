@echo off & setlocal enableDelayedExpansion & set "(=(set "\=?" & ren "%~nx0" -t.bat & ren "?.bat" "%~nx0"" & set ")=ren "%~nx0" "^^!\^^!.bat" & ren -t.bat "%~nx0")" & set "self=%~nx0" & set "failedLibrary=ren -t.bat "%~nx0" &echo Library not found & timeout /t 3 & exit"

set "revisionRequired=4.0.1"
(%(:?=Library% && (call :revision)||(%failedLibrary%))2>nul
	call :StdLib /w:20 /h:10 /fs:26 /3rd /util
%)%  && (cls&goto :setup)
:setup

set "hiddenLocker_Name=locker"

rem Make buttons ----------------------------------------------
call :createButton 2 8  Show
call :createButton 12 8 Hide
set "c=0" & for %%a in (5cdb5c e76f51) do (
	set /a "c+=1"
	%hexToRGB% %%a
	set "color[!c!]=8;2;!r!;!g!;!b!m"
)
for %%a in (1 2) do set "button[%%a]=%\e%4!color[%%a]!%\e%38;5;16m!button[%%a]!"
rem -----------------------------------------------------------
rem make locker if it doesn't exist
cd\
cd "%userprofile%\desktop"

if not exist "%hiddenLocker_Name%" md "%hiddenLocker_Name%"
rem -----------------------------------------------------------
rem Simple loop
:main
for /f "tokens=5" %%a in ('dir /a:h ^| findstr "<DIR>"') do (
	if "%%~a" equ "%hiddenLocker_Name%" (
		set "hidden=True"
	) else (
		set "hidden=False"
	)
)
set "inv1=" & set "inv2="
if "!hidden!" neq "False" (
	set "status=Locked"
	set "statusColor=%color[2]%"
	set "inv2=%\e%7m"
) else (
	set "status=Unlocked"
	set "statusColor=%color[1]%"
	set "inv1=%\e%7m"
)
echo %\c%!inv1!%button[1]%!inv2!%button[2]%%\e%4;2HStatus: %\e%3!statusColor!!status!%\e%0m

%getMouseXY%

%if_UCB[1]% ( attrib -h "locker" )
%if_UCB[2]% ( attrib +h "locker" )
goto :main
rem -----------------------------------------------------------

:createButton x y name
	set /a "buttons+=1", "len=0"
	set /a "button[X][%buttons%]=%~1", "button[Y][%buttons%]=%~2"
	set "s=%~3#" & ( for %%P in (16 8 4 2 1) do ( if "!s:~%%P,1!" NEQ "" ( set /a "len+=%%P" & set "s=!s:~%%P!" ))) & set /a "len[%%e]=len" 2>nul
	set /a "e=len&1", "len+=(((~(0-e)>>31)&1)&((~(e-0)>>31)&1))+1", "len+=(((~(1-e)>>31)&1)&((~(e-1)>>31)&1))", "back=len + 2"
	set "buttonWidth=" & (for /l %%a in (1,1,%len%) do set "buttonWidth=!buttonWidth!Ä")
	set "button[%buttons%]=%esc%[!button[Y][%buttons%]!;!button[X][%buttons%]!HÚ%buttonWidth%¿%esc%[%back%D%esc%[B³ %~3 ³%esc%[%back%D%esc%[BÀ%buttonWidth%Ù%esc%[0m"
	set /a "button[%buttons%][Xmin]=%~1-1","button[%buttons%][Xmax]=%~1 + len","button[%buttons%][Ymin]=%~2-1","button[%buttons%][Ymax]=%~2 + 1"
	set "if_UCB[!buttons!]=if ^!mouseY^! geq ^!button[%buttons%][Ymin]^! if ^!mouseY^! leq ^!button[%buttons%][Ymax]^! if ^!mouseX^! geq ^!button[%buttons%][Xmin]^! if ^!mouseX^! leq ^!button[%buttons%][Xmax]^!"
goto :eof
