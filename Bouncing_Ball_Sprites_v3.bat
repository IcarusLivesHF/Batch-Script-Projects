@echo off & setlocal enableDelayedExpansion & set "(=(set "\=?" & ren "%~nx0" -t.bat & ren "?.bat" "%~nx0"" & set ")=ren "%~nx0" "^^!\^^!.bat" & ren -t.bat "%~nx0")" & set "self=%~nx0" & set "failedLibrary=ren -t.bat "%~nx0" &echo Library not found & timeout /t 3 & exit"

set "revisionRequired=4.0.1"
(%(:?=Library% && (call :revision)||(%failedLibrary%))2>nul
	call :StdLib /w:50 /h:50 /fs:5 /gfx /misc /s
%)%  && (cls&goto :setup)
:setup
set "balls=10"
for /l %%i in (1,1,%balls%) do %BVector% this[%%i] 4 %ball[1]%
%loop% (
	rem for all balls
	for /l %%i in (1,1,%balls%) do (
		rem move objects by their vector direction
		set /a "this[%%i].x+=this[%%i].i", "this[%%i].y+=this[%%i].j"
		rem bounce against each other if they touch
		for /l %%j in (1,1,%balls%) do if %%j neq %%i  (
			rem quick distance formula
			set /a "dx=this[%%j].x - this[%%i].x", "dy=this[%%j].y - this[%%i].y", "ballDistance=dx*dx + dy*dy - this[%%i].vd*this[%%j].vd - 1"
			if !ballDistance! lss 0 (
				set /a "this[%%i].i*=-1, this[%%i].j*=-1, this[%%j].i*=-1, this[%%j].j*=-1"
			)
		)
		rem bounce against edges by inverting vector directions
		if !this[%%i].x! leq !this[%%i].vr!  set /a "this[%%i].x=this[%%i].vr",  "this[%%i].i*=-1"
		if !this[%%i].y! leq !this[%%i].vr!  set /a "this[%%i].y=this[%%i].vr",  "this[%%i].j*=-1"
		if !this[%%i].x! geq !this[%%i].vmw! set /a "this[%%i].x=this[%%i].vmw", "this[%%i].i*=-1"
		if !this[%%i].y! geq !this[%%i].vmh! set /a "this[%%i].y=this[%%i].vmh", "this[%%i].j*=-1"
		rem write to display variable
		set "screen=!screen!%\e%!this[%%i].rgb!%\e%!this[%%i].y!;!this[%%i].x!H!this[%%i].ch!"
	)
	rem display everything
	echo %\c%!screen!& set "screen="
)