@echo off & setlocal enableDelayedExpansion

for /f "tokens=1 delims==" %%a in ('set') do (
	set "unload=true"
	for %%b in ( Path ComSpec SystemRoot) do if /i "%%a"=="%%b" set "unload=false"
	if "!unload!"=="true" set "%%a="
)
set "unload="

set /a "hei=wid=80"
mode %wid%,%hei%

set "scissors=[48;5;10m7 [2C 8[B7[C  8[B7[C  8[B [2C [0m"
set "paper=[48;5;9m7    8[B7 [2C 8[B7 [2C 8[B    [0m"
set "rock=[48;5;12m7[C  8[B7 [2C 8[B7 [2C 8[B[C  [0m"

set "i=-1"
for %%j in (rock paper scissors) do (
	for /l %%i in (1,1,4) do (
		set /a "i+=1"
		set /a "this[!i!].x=!random! %% wid"
		set /a "this[!i!].y=!random! %% hei"
		set /a "this[!i!].i=!random! %% 2 * 2 - 1"
		set /a "this[!i!].j=!random! %% 2 * 2 - 1"
		set "this[!i!].term=%%~j"
		set "this[!i!]=!%%~j!"
	)
	set "alive[%%j]=4"
)


for /l %%# in () do (
	title Rock:!alive[rock]! Paper:!alive[paper]! scissors:!alive[scissors]!

	for /l %%i in (0,1,%i%) do (

		set /a "this[%%i].x+=this[%%i].i", "this[%%i].y+=this[%%i].j"

		for /l %%j in (0,1,%i%) do if %%j neq %%i  (

			set /a "dx=this[%%j].x - this[%%i].x", "dy=this[%%j].y - this[%%i].y", "ballDistance=dx*dx + dy*dy - 16"
			
			if !ballDistance! lss 4 (
			
				set /a "this[%%i].i*=-1, this[%%i].j*=-1, this[%%j].i*=-1, this[%%j].j*=-1"

				if /i "!this[%%i].term!" equ "rock" (
				
					       if /i "!this[%%j].term!" equ "paper"    ( set "this[%%i].term=paper" & set "this[%%i]=!this[%%j]!" & set /a "alive[rock]-=1", "alive[paper]+=1"
					) else if /i "!this[%%j].term!" equ "scissors" ( set "this[%%j].term=rock"  & set "this[%%j]=!this[%%i]!" & set /a "alive[rock]+=1", "alive[scissors]-=1" )
					
				) else if /i "!this[%%i].term!" equ "paper" (
				
					       if /i "!this[%%j].term!" equ "scissors" ( set "this[%%i].term=scissors" & set "this[%%i]=!this[%%j]!" & set /a "alive[paper]-=1", "alive[scissors]+=1"
					) else if /i "!this[%%j].term!" equ "rock"     ( set "this[%%j].term=paper"    & set "this[%%j]=!this[%%i]!" & set /a "alive[paper]+=1", "alive[rock]-=1" )
					
				) else if /i "!this[%%i].term!" equ "scissors" (
				
					       if /i "!this[%%j].term!" equ "rock"     ( set "this[%%i].term=rock"     & set "this[%%i]=!this[%%j]!" & set /a "alive[scissors]-=1", "alive[rock]+=1"
					) else if /i "!this[%%j].term!" equ "paper"    ( set "this[%%j].term=scissors" & set "this[%%j]=!this[%%i]!" & set /a "alive[scissors]+=1", "alive[paper]-=1" )
				
				)
			)
		)

		if !this[%%i].x! leq 2  ( 
			set /a "this[%%i].x=2",  "this[%%i].i*=-1"
		) else if !this[%%i].y! leq 2 (
			set /a "this[%%i].y=2",  "this[%%i].j*=-1"
		)
		
		if !this[%%i].x! geq 78 ( 
			set /a "this[%%i].x=78", "this[%%i].i*=-1"
		) else if !this[%%i].y! geq 78 (
			set /a "this[%%i].y=78", "this[%%i].j*=-1"
		)
		
		set "screen=!screen![!this[%%i].y!;!this[%%i].x!H!this[%%i]!"
	)

	echo [2J!screen!
	set "screen="
)