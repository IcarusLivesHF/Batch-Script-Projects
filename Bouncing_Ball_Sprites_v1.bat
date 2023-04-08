@echo off & setlocal enableDelayedExpansion

Rem Revision 3.30.0
rem https://github.com/IcarusLivesHF/Windows-Batch-Library/tree/0097cabf9f5e8d24bc279d3ef2fa888dd12108b3

set "revisionRequired=3.30.0"
set "(=(set "\=?" & ren "%~nx0" -t.bat & ren "?.bat" "%~nx0""
set ")=ren "%~nx0" "^^!\^^!.bat" & ren -t.bat "%~nx0")" & set "self=%~nx0"
set "failedLibrary=ren -t.bat "%~nx0" &echo Library not found & timeout /t 3 & exit"
(%(:?=Library% && (call :revision)||(%failedLibrary%))2>nul
	call :stdlib /w:150 /h:50 /fs:8
	call :misc
	call :cursor
	call :macros
%)%  && (cls&goto :setup)
:setup

set "sprite[1]=%cursor[R]:?=1%   %cursor[D]:?=1%%cursor[L]:?=4%     %cursor[D]:?=1%%cursor[L]:?=5%     %cursor[D]:?=1%%cursor[L]:?=5%     %cursor[D]:?=1%%cursor[L]:?=4%   %cursor[L]:?=1%%cursor[U]:?=2%%capit%"

set "balls=20"
for /l %%i in (1,1,%balls%) do %BVector% this[%%i]
set /a "ballRad=2", "bmw=wid - ballRad", "bmh=hei - ballRad"

%loop% (
	
	for /l %%i in (1,1,%balls%) do (
		
		set /a "this[%%i].x+=this[%%i].i"
		set /a "this[%%i].y+=this[%%i].j"
		
		if !this[%%i].x! leq %ballRad% set /a "this[%%i].x=ballRad", "this[%%i].i*=-1"
		if !this[%%i].y! leq %ballRad% set /a "this[%%i].y=ballRad", "this[%%i].j*=-1"
		if !this[%%i].x! geq %bmw%     set /a "this[%%i].x=bmw",     "this[%%i].i*=-1"
		if !this[%%i].y! geq %bmh%     set /a "this[%%i].y=bmh",     "this[%%i].j*=-1"
	
		set "screen=!screen!%\e%!this[%%i].fcol!%\e%!this[%%i].y!;!this[%%i].x!H%sprite[1]%"
	)
	echo %\c%!screen!& set "screen="
)
