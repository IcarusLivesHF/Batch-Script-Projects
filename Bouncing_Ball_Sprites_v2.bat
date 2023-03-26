@echo off & setlocal enableDelayedExpansion & set "(=(set "\=?" & ren "%~nx0" -t.bat & ren "?.bat" "%~nx0"" & set ")=ren "%~nx0" "^^!\^^!.bat" & ren -t.bat "%~nx0")" & set "self=%~nx0" & set "failedLibrary=ren -t.bat "%~nx0" &echo Library not found & timeout /t 3 & exit"

set "revisionRequired=3.30.2"
(%(:?=Library% && (call :revision)||(%failedLibrary%))2>nul
	call :stdlib /w:150 /h:50 /fs:8
	call :misc&(call :macros)&call :sprites
%)%  && (cls&goto :setup)
:setup
set "balls=50"
for /l %%i in (1,1,%balls%) do %BVector% this[%%i] 4 %ball[1]%

%loop% (
	for /l %%i in (1,1,%balls%) do (
		set /a "this[%%i].x+=this[%%i].i"
		set /a "this[%%i].y+=this[%%i].j"
		if !this[%%i].x! leq !this[%%i].vr!  set /a "this[%%i].x=this[%%i].vr",  "this[%%i].i*=-1"
		if !this[%%i].y! leq !this[%%i].vr!  set /a "this[%%i].y=this[%%i].vr",  "this[%%i].j*=-1"
		if !this[%%i].x! geq !this[%%i].vmw! set /a "this[%%i].x=this[%%i].vmw", "this[%%i].i*=-1"
		if !this[%%i].y! geq !this[%%i].vmh! set /a "this[%%i].y=this[%%i].vmh", "this[%%i].j*=-1"
		set "screen=!screen!%\e%!this[%%i].rgb!%\e%!this[%%i].y!;!this[%%i].x!H!this[%%i].ch!"
	)
	echo %\c%!screen!& set "screen="
)
