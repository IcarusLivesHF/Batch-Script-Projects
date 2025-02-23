@echo off & setlocal enableDelayedExpansion

call :init

set "rnd(x,y)=(((^!random^! * 32768 + ^!random^!) %% (y - x + 1)) + x)"
set "rndSgn=(^!random^! %% 2 * 2 - 1)"

set /a "x=15, y=25,       rw=%rnd(x,y)%, rh=%rnd(x,y)%",^
       "x=rw, y=wid - rw, rx=%rnd(x,y)%",^
       "x=rh, y=hei - rh, ry=%rnd(x,y)%",^
       "                  ra=rx + rw",^
       "                  rb=ry + rh",^
       "x=2, y=3,         ri=%rndSgn% * %rnd(x,y)%",^
       "x=1, y=3,         rj=%rndSgn% * %rnd(x,y)%",^
       "x=rx, y=ra,       px=%rnd(x,y)%",^
       "x=ry, y=rb,       py=%rnd(x,y)%",^
       "x=1, y=3,         pi=%rndSgn% * %rnd(x,y)%",^
       "x=2, y=3,         pj=%rndSgn% * %rnd(x,y)%"


for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100"
for /l %%# in () do (
	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, dt=t2-t1"
	
    if !dt! gtr 3 (
        set /a "t1=t2", "rx+=ri, ry+=rj", "ra=rx + rw, rb=ry + rh", "px+=pi + ri, py+=pj + rj"
		
		if !rx! leq 0 ( set /a "rx-=ri, ri*=-1" ) else if !ra! geq !wid! set /a "rx-=ri, ri*=-1"
		if !ry! leq 0 ( set /a "ry-=rj, rj*=-1" ) else if !rb! geq !hei! set /a "ry-=rj, rj*=-1"
		if !px! leq !rx! ( set /a "px-=pi, pi*=-1" ) else if !px! geq !ra! set /a "px-=pi, pi*=-1"
		if !py! leq !ry! ( set /a "py-=pj, pj*=-1" ) else if !py! geq !rb! set /a "py-=pj, pj*=-1"
		
		%@rect% !rw! !rh!
		
		echo %\e%[2J%\e%[H%\e%[!ry!;!rx!H!$rect!%\e%[48;5;196m%\e%[!py!;!px!H %\e%[0m
	)
)

:init

set /a "hei=wid=80"
mode %wid%,%hei%

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)


for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%
echo %\e%[?25l


for /l %%i in (0,1,80) do set "$q=!$q!q"
rem %@rect% w h <rtn> !$rect!
set @rect=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-2" %%1 in ("^!args^!") do (%\n%
	set /a "$w=%%~1-2", "$h=%%~2-2"%\n%
	for /f "tokens=1,2" %%A in ("^!$w^! ^!$h^!") do (%\n%
		set "$rect=^!$q:~0,%%~B^!"%\n%
		set "$rect=%\e%(0%\e%7l^!$q:~0,%%~A^!k%\e%8%\e%[B^!$rect:q=%\e%7x%\e%[%%~ACx%\e%8%\e%[B^!m^!$q:~0,%%~A^!j%\e%(B%\e%[0m"%\n%
	)%\n%
	set "$w=" ^& set "$h="%\n%
)) else set args=

goto :eof