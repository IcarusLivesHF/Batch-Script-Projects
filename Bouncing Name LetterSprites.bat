@echo off & setlocal enableDelayedExpansion & set "(=(set "\=?" & ren "%~nx0" -t.bat & ren "?.bat" "%~nx0"" & set ")=ren "%~nx0" "^^!\^^!.bat" & ren -t.bat "%~nx0")" & set "self=%~nx0" & set "failedLibrary=ren -t.bat "%~nx0" &echo Library not found & timeout /t 3 & exit"

set "revisionRequired=3.30.1"
(%(:?=Library% && (call :revision)||(%failedLibrary%))2>nul
	call :stdlib /w:150 /h:50 /fs:8
	call :misc
	call :cursor
	call :characterSprites
%)%  && (cls&goto :setup)
:setup


set "charWid=8"
set "spaceBetweenLetters=2"
for %%a in (I C A R U S) do (
	set /a "char+=1"
	set /a "this.x[!char!]=char * (charWid + spaceBetweenLetters) + wid / 4"
	set /a "this.y[!char!]=20"
	set /a "this.i[!char!]=!random! %% 3 + 1"
	set /a "this.j[!char!]=!random! %% 3 + 1"
	set "this.c[!char!]=!letter[%%a]!"
	for %%i in (!char!) do echo %\e%!this.y[%%i]!;!this.x[%%i]!H!letter[%%a]!
)


%loop% (

	for /l %%a in (1,1,6) do (
		
		set /a "this.x[%%a]+=this.i[%%a]"
		set /a "this.y[%%a]+=this.j[%%a]"
		
		if !this.x[%%a]! leq 8 (
			set /a "this.x[%%a]=8"
			set /a "this.i[%%a]*=-1"
		) else if !this.x[%%a]! geq %wid% (
			set /a "this.x[%%a]=%wid% - 8"
			set /a "this.i[%%a]*=-1"
		)
		
		if !this.y[%%a]! leq 0 (
			set /a "this.y[%%a]=0"
			set /a "this.j[%%a]*=-1"
		) else if !this.y[%%a]! geq %hei% (
			set /a "this.y[%%a]=%hei% - 8"
			set /a "this.j[%%a]*=-1"
		) 
		
		
		set "screen=!screen!%\e%!this.y[%%a]!;!this.x[%%a]!H!this.c[%%a]!"
	)

	echo %\c%!screen!
	set "screen="
	%throttle:x=35%
)

pause & exit
