@echo off & setlocal enableDelayedExpansion

call lib\stdlib
call lib\gfx

%@fullscreen%

for /l %%i in (1,1,50) do %@construct% this

for /l %%# in () do (
	for %%i in (!this.list!) do (
		set /a "this[%%i].x+=this[%%i].i", "this[%%i].y+=this[%%i].j"
		
		if !this[%%i].x! leq 0     set /a "this[%%i].x=0",   "this[%%i].i*=-1"
		if !this[%%i].x! geq %wid% set /a "this[%%i].x=wid", "this[%%i].i*=-1"
		if !this[%%i].y! leq 0     set /a "this[%%i].y=0",   "this[%%i].j*=-1"
		if !this[%%i].y! geq %hei% set /a "this[%%i].y=hei", "this[%%i].j*=-1"
		
		%@concat% !this[%%i].x! !this[%%i].y! "O" screen
	)
	
	echo=%\h%!screen!
	set "screen="
)