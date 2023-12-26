@echo off & setlocal enableDelayedExpansion & title Christmas 2023

call :characterSprites_8x8
set /a "wid=160","hei=40", "maxW=wid - 10"
mode %wid%,%hei%

set "total=25"
for /l %%a in (1,1,%total%) do (
	set /a "starX[%%a]=!random! %% (wid-1) + 1",^
	       "starY[%%a]=!random! %% (hei-1) + 1",^
	       "twinkleSpeed[%%a]=!random! %% 18 + 4",^
	       "snowX[%%a]=!random! %% (wid-1) + 1",^
	       "snowY[%%a]=!random! %% (hei-1) + 1",^
	       "fadeSpeed[%%a]=!random! %%  18 + 4"
)

for /l %%i in (1,1,5) do (
	set /a "snowman[%%i].x=!random! %% (wid - 10) + 10", "snowman[%%i].i=1"
)

set "every=1/(((~(0-(frameCount%%x))>>31)&1)&((~((frameCount%%x)-0)>>31)&1))"

for /l %%# in () do ( set /a "frameCount+=1"

	for /l %%i in (1,1,5) do (
		set /a "snowman[%%i].x+=snowman[%%i].i"
		
		if !snowman[%%i].x! leq 10     set /a "snowman[%%i].x=10", "snowman[%%i].i*=-1"
		if !snowman[%%i].x! geq %maxW% set /a "snowman[%%i].x=wid - 10", "snowman[%%i].i*=-1"
		
		set "screen=!screen![35;!snowman[%%i].x!H!snowman!"
	)
	
	for /l %%a in (1,1,%total%) do (
		
		set /a "twinkle[%%a]+=twinkleSpeed[%%a]",^
		       "fade[%%a]+=fadeSpeed[%%a]"
		
		if !twinkle[%%a]! leq 0 ( set /a "twinkle[%%a]=0",^
		                                 "twinkleSpeed[%%a]*=-1",^
		                                 "starX[%%a]=!random! %% (wid-1) + 1",^
		                                 "starY[%%a]=!random! %% (hei-1) + 1"
		)
		if !twinkle[%%a]! geq 255 ( set /a "twinkle[%%a]=255",^
		                                   "twinkleSpeed[%%a]*=-1"
		)
		if !fade[%%a]! leq 0 ( set /a "fade[%%a]=0",^
		                              "fadeSpeed[%%a]*=-1",^
		                              "snowX[%%a]=!random! %% (wid-1) + 1",^
		                              "snowY[%%a]=!random! %% (hei-1) + 1"
		)
		if !fade[%%a]! geq 255 ( set /a "fade[%%a]=255",^
		                                "fadeSpeed[%%a]*=-1"
		)
		
		2>nul set /a "%every:x=3%" && (
			set /a "snowY[%%a]+=1"
		)
		
		set "screen=!screen![38;2;!twinkle[%%a]!;!twinkle[%%a]!;!twinkle[%%a]!m[!starY[%%a]!;!starX[%%a]!H€[38;2;!fade[%%a]!;!fade[%%a]!;!fade[%%a]!m[!snowY[%%a]!;!snowX[%%a]!H*"
	)
	
	2>nul set /a "%every:x=15%" && ( 
		set "logo=!xmasLogo:x=[38;5;9m!" & set "logo=!logo:y=[38;5;10m!"
	)
	2>nul set /a "%every:x=30%" && ( 
		set "logo=!xmasLogo:x=[38;5;10m!" & set "logo=!logo:y=[38;5;9m!"
	)
	
	echo=[2J[H!screen![10;15H!logo![0m%treeLayer%
	set "screen="
)

:characterSprites_8x8 these are the letters for "Merry Christmas"
set "chr[-A]=[3C€€[3C[B[8D[2C€[2C€[2C[B[8D[C€[4C€[C[B[8D[C€[4C€[C[B[8D[C€€€€€€[C[B[8D[C€[4C€[C[B[8D[C€[4C€[C[B[8D€€€[2C€€€[7A[0m"
set "chr[-C]=[2C€€€€[C€[B[8D[C€[4C€€[B[8D€[6C€[B[8D€[6C[C[B[8D€[6C[C[B[8D€[6C€[B[8D[C€[4C€€[B[8D[2C€€€€[C€[7A[0m"
set "chr[-E]=€€€€€€€€[B[8D[C€[5C€[B[8D[C€[6C[B[8D[C€€€[4C[B[8D[C€[6C[B[8D[C€[6C[B[8D[C€[5C€[B[8D€€€€€€€€[7A[0m"
set "chr[-H]=€€€[2C€€€[B[8D[C€[4C€[C[B[8D[C€[4C€[C[B[8D[C€€€€€€[C[B[8D[C€[4C€[C[B[8D[C€[4C€[C[B[8D[C€[4C€[C[B[8D€€€[2C€€€[7A[0m"
set "chr[-I]=€€€€€€€[C[B[8D[3C€[4C[B[8D[3C€[4C[B[8D[3C€[4C[B[8D[3C€[4C[B[8D[3C€[4C[B[8D[3C€[4C[B[8D€€€€€€€[C[7A[0m"
set "chr[-M]=€€[3C€€€[B[8D[C€€[C€[C€[C[B[8D[C€[C€[2C€[C[B[8D[C€[C€[2C€[C[B[8D[C€[4C€[C[B[8D[C€[4C€[C[B[8D[C€[4C€[C[B[8D€€€[2C€€€[7A[0m"
set "chr[-R]=€€€€€€€[C[B[8D[C€[5C€[B[8D[C€[5C€[B[8D[C€[5C€[B[8D[C€€€€€€[C[B[8D[C€[3C€[2C[B[8D[C€[4C€[C[B[8D€€€[2C€€€[7A[0m"
set "chr[-S]=[C€€€€€[C€[B[8D€[5C€€[B[8D€[6C€[B[8D[C€€€€€[2C[B[8D[6C€[C[B[8D€[6C€[B[8D€€[5C€[B[8D€[C€€€€€[C[7A[0m"
set "chr[-T]=€€€€€€€€[B[8D€[3C€[2C€[B[8D[4C€[3C[B[8D[4C€[3C[B[8D[4C€[3C[B[8D[4C€[3C[B[8D[4C€[3C[B[8D[3C€€€[2C[7A[0m"
set "chr[-Y]=€€€[2C€€€[B[8D[C€[4C€[C[B[8D[2C€[2C€[2C[B[8D[3C€[C€[2C[B[8D[4C€[3C[B[8D[4C€[3C[B[8D[4C€[3C[B[8D[3C€€€[2C[7A[0m"
set "chr[_]=[6C[2C[1B[8D[6C[2C[1B[8D[6C[2C[1B[8D[6C[2C[1B[8D[6C[2C[1B[8D[6C[2C[1B[8D[6C[2C[1B[8D        [7A[0m"

rem use the sprites above to build the words "MERRY CHRISTMAS", x and y will be substring'd into a vt100 color code
set "xmasLogo=x%chr[-m]% y%chr[-e]% x%chr[-r]% y%chr[-r]% x%chr[-y]% %chr[_]% y%chr[-c]% x%chr[-h]% y%chr[-r]% x%chr[-i]% y%chr[-s]% x%chr[-t]% y%chr[-m]% x%chr[-a]% y%chr[-s]% [0m"

set "snowman=[3C___[3C[9D[B[C_≥___≥_[C[9D[B[2C('[C')[2C[9D[B<([2C.[2C)>[9D[B(___.___)[9D[B[5A[0m"
set "tree=[2C/\[2C[6D[B[C/[2C\[C[6D[B[C/[2C\[C[6D[B/_[2C_\[6D[B[2C≥≥[2C[6D[B[5A[0m"
set "treeLayer=[35;35H%tree%[35;65H%tree%[35;115H%tree%[35;135H%tree%"
goto :eof