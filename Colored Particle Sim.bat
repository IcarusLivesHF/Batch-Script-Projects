@echo off & setlocal enableDelayedExpansion

rem Revision 3.30.0
rem https://github.com/IcarusLivesHF/Windows-Batch-Library/tree/0097cabf9f5e8d24bc279d3ef2fa888dd12108b3

set "revisionRequired=3.30.0"
set "(=(set "\=?" & ren "%~nx0" -t.bat & ren "?.bat" "%~nx0""
set ")=ren "%~nx0" "^^!\^^!.bat" & ren -t.bat "%~nx0")" & set "self=%~nx0"
set "failedLibrary=ren -t.bat "%~nx0" &echo Library not found & timeout /t 3 & exit"
(%(:?=Library% && (call :revision)||(%failedLibrary%))2>nul
	call :stdlib /w:150 /h:50 /fs:8
	call :misc
	call :colorRange "255/(255/!hei!+2)"
	call :macros
%)%  && (cls&goto :setup)
:setup

set /a "particles=totalColorsInRange"
for /l %%p in (1,1,%particles%) do (
	%Bvector% this[%%p]
	set /a "this[%%p].y=!random! %% hei * 2 + hei + 2"
	set "this[%%p].rgb=!color[%%p]!"
)

%loop% (
	for /l %%p in (1,1,%particles%) do (
		set /a "this[%%p].y-=this[%%p].j"
		
		if !this[%%p].y! leq 0 set /a "this[%%p].y=hei + 2"
		
		if !this[%%p].y! leq %hei% (
			set "screen=!screen!%\e%!this[%%p].rgb!%\e%!this[%%p].y!;!this[%%p].x!H%.%"
		)
	)

	echo %\c%!screen!
	set "screen="
)

pause >nul & exit
