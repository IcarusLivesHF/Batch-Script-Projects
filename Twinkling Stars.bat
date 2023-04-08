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

for /l %%a in (1,1,25) do (
	set /a "starX[%%a]=!random! %% (wid-1) + 1"
	set /a "starY[%%a]=!random! %% (hei-1) + 1"
	set /a "twinkle[%%a]=0"
	set /a "twinkleSpeed[%%a]=!random! %% 4 + 2"
	set /a "twinkleOffset[%%a]=!random! %% 50"
)

%loop% (
	
	set /a "frameCount+=1"
	
	for /l %%a in (1,1,25) do (
		
		if !frameCount! gtr !twinkleOffset[%%a]! (
			set /a "twinkle[%%a]+=twinkleSpeed[%%a]"
		)
		
		if !twinkle[%%a]! leq 0   set /a "twinkle[%%a]=0",   "twinkleSpeed[%%a]*=-1"
		if !twinkle[%%a]! geq 255 set /a "twinkle[%%a]=255", "twinkleSpeed[%%a]*=-1"
		
		set "screen=!screen!%esc%[38;2;!twinkle[%%a]!;!twinkle[%%a]!;!twinkle[%%a]!m%esc%[!starY[%%a]!;!starX[%%a]!H%pixel%"
	)
	echo %\c%!screen!& set "screen="
)
