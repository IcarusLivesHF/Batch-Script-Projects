@echo off & setlocal enableDelayedExpansion

call :Set_Font "lucida console" 2 nomax %1 || exit
call :init




set /a "x=45, y=85,       rw=%rnd(x,y)%, rh=%rnd(x,y)%",^
       "x=rw, y=wid - rw, rx=%rnd(x,y)%",^
       "x=rh, y=hei - rh, ry=%rnd(x,y)%",^
       "                  ra=rx + rw",^
       "                  rb=ry + rh",^
       "x=2, y=3,         ri=%rndSgn% * %rnd(x,y)%",^
       "x=1, y=3,         rj=%rndSgn% * %rnd(x,y)%"

%@rect% !rw! !rh!


set "particles=8"
for /l %%i in (1,1,%particles%) do (
    set /a "x=rx, y=ra,   px[%%i]=%rnd(x,y)%",^
	       "x=ry, y=rb,   py[%%i]=%rnd(x,y)%",^
	       "x=1,  y=3,    pi[%%i]=%rndSgn% * %rnd(x,y)%",^
	       "x=2,  y=3,    pj[%%i]=%rndSgn% * %rnd(x,y)%"
)




                      for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do (
						set /a "t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100")
for /l %%# in () do ( for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do (
                        set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, dt=t2-t1")
	
    if !dt! gtr 3 (
        set /a "t1=t2",^
		       "rx+=ri",^
			   "ry+=rj",^
			   "ra=rx + rw",^
			   "rb=ry + rh"
		
		       if !rx! leq 0    ( set /a "rx-=ri, ri*=-1" 
		) else if !ra! geq !wid!  set /a "rx-=ri, ri*=-1"
		
		       if !ry! leq 0    ( set /a "ry-=rj, rj*=-1"
		) else if !rb! geq !hei!  set /a "ry-=rj, rj*=-1"
		
		for /l %%i in (1,1,%particles%) do (
		
			set /a "px[%%i]+=pi[%%i] + ri",^
			       "py[%%i]+=pj[%%i] + rj"
				   
			       if !px[%%i]! leq !rx! ( set /a "px[%%i]=rx, pi[%%i]*=-1"
			) else if !px[%%i]! geq !ra!   set /a "px[%%i]=ra, pi[%%i]*=-1"
			
			       if !py[%%i]! leq !ry! ( set /a "py[%%i]=ry, pj[%%i]*=-1"
			) else if !py[%%i]! geq !rb!   set /a "py[%%i]=rb, pj[%%i]*=-1"
			
		)
		%@bezier% !px[1]!  !py[1]! !px[2]!  !py[2]! !px[3]!  !py[3]! !px[4]!  !py[4]! 21
		set "scrn=!$bezier!"
		%@bezier% !px[5]!  !py[5]! !px[6]!  !py[6]! !px[7]!  !py[7]! !px[8]!  !py[8]! 196
		set "scrn=!scrn!!$bezier!"
		
		echo %\e%[2J%\e%[H%\e%[!ry!;!rx!H!$rect!!scrn!
		set "scrn="
	)
)

:init

set /a "hei=200,wid=400"
mode %wid%,%hei%

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER       \n =%
)


for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a" %= \e =%
echo %\e%[?25l


set "rnd(x,y)=(((^!random^! * 32768 + ^!random^!) %% (y - x + 1)) + x)"
set "rndSgn=(^!random^! %% 2 * 2 - 1)"


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

rem %@bezier% x1 y1 x2 y2 x3 y3 x4 y4 color <rtn> $bezier
set @bezier=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-9" %%1 in ("^!args^!") do (%\n%
    if "%%~9" equ "" ( set "$bezier=%\e%[48;5;15m" ) else ( set "$bezier=%\e%[48;5;%%~9m" )%\n%
    set /a "steps=30", "dt=1000 / steps", "t=0",^
           "C3x=-%%~1 + 3*%%~3 - 3*%%~5 + %%~7", "C2x=3*(%%~1 - 2*%%~3 + %%~5)", "C1x=3*(%%~3 - %%~1)", "C0x=%%~1",^
           "C3y=-%%~2 + 3*%%~4 - 3*%%~6 + %%~8", "C2y=3*(%%~2 - 2*%%~4 + %%~6)", "C1y=3*(%%~4 - %%~2)", "C0y=%%~2"%\n%
	for /l %%i in (0,1,^^!steps^^!) do (%\n%
		set /a "t2 = t * t / 1000",^
			   "t3 = t2 * t / 1000",^
			   "vx = ((C3x*t3 + C2x*t2 + C1x*t + C0x) / 1000) + %%~1",^
			   "vy = ((C3y*t3 + C2y*t2 + C1y*t + C0y) / 1000) + %%~2",^
			   "t += dt"%\n%
		set "$bezier=^!$bezier^!%\e%[^!vy^!;^!vx^!H "%\n%
	)%\n%
	set "$bezier=^!$bezier^!%\e%[0m"%\n%
)) else set args=

goto :eof

:Set_Font FontName FontSize max/nomax dummy
if "%4"=="" (
	for /f "tokens=1,2 delims=x" %%a in ("%~2") do if "%%b"=="" (set /a "FontSize=%~2*65536") else set /a "FontSize=%%a+%%b*65536"
	reg add "HKCU\Console\%~nx0" /v FontSize /t reg_dword /d !FontSize! /f
	reg add "HKCU\Console\%~nx0" /v FaceName /t reg_sz /d "%~1" /f
	set "m=" & if /I "%~3"=="max" set "m=/max"
	start "%~nx0" !m! "%ComSpec%" /c "%~f0" _ 
	exit /b 1
) else ( >nul reg delete "HKCU\Console\%~nx0" /f )
goto:eof
