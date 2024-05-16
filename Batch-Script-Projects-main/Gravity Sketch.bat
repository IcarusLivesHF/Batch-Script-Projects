@echo off & setlocal enableDelayedExpansion

set "gravity=@G=1, _G_=@G * ?.mass, ?.acceleration+=_G_, ?.velocity+=?.acceleration, ?.acceleration*=0, ?+=?.velocity"

set "ball=[C€[C[3D[B€€€[3D[B[C€[C[3A[0m"

set /a "wid=80", "hei=40"
mode %wid%,%hei%

for /l %%i in (1,1,15) do (
	set /a "ball[%%i].y=!random! %% hei", "ball[%%i].x=!random! %% wid", "ball[%%i].y.mass=!random! %% 3 + 1",^
	       "ball[%%i].r=!random! %% 255",^
	       "ball[%%i].g=!random! %% 255",^
	       "ball[%%i].b=!random! %% 255"
)


:main

	for /l %%i in (1,1,15) do (
		
		set /a "!gravity:?=ball[%%i].y!"
		
		if !ball[%%i].y! geq %hei% set /a "ball[%%i].y=hei", "ball[%%i].y.velocity*=-1"
		
		set "screen=!screen![38;2;!ball[%%i].r!;!ball[%%i].g!;!ball[%%i].b!m[!ball[%%i].y!;!ball[%%i].x!H%ball%"
	)
	echo=[2J[H!screen!
	set "screen="
	for /l %%# in (1,30,1000000) do rem
goto :main
