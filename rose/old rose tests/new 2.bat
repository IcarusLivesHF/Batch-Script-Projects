@echo off & setlocal enableDelayedExpansion

rem ===================================================================
rem  Monte Carlo Rose  -  progressive z-buffered renderer
rem
rem  Technique credit: the Monte-Carlo-into-a-z-buffer approach is the
rem  one Roman Cortes used for his 1k rose.  This is an independent
rem  implementation of that idea over the petal surface we already
rem  ported, not a translation of his code.
rem
rem  WHY THIS BEATS THE POINT-CLOUD VERSION
rem    There is no frame.  Each accepted sample writes ONE coloured
rem    cell and stays there, so nothing is ever recomputed or redrawn.
rem    Cost per sample is constant and the picture simply converges the
rem    longer you leave it running.  Expect a recognisable bloom in
rem    seconds and a solid one after a minute or two.
rem
rem  Both surface parameters are random indices into small precomputed
rem  tables, so a sample costs a handful of set /a and nothing else.
rem  Sampling is 100%% efficient - every (r,theta) pair is on the petal.
rem ===================================================================

if "%~1"=="" call :Set_Font "consolas" 8 nomax %1 || exit

call :init
call :buildLUT
goto :render



rem ===================================================================
:buildLUT
set /a "ONE=256, SIZE=34, NT=1020, NR=127"

rem ---- theta table --------------------------------------------------
rem  Everything here depends only on theta.  phi is walked forward by
rem  repeated integer multiply rather than exp():
rem      phi -= phi * DECAY / 1000000        DECAY = (1-e^(-3/1440))*1e6
rem  Random ACCESS to phi is why this must be a table - the recurrence
rem  only works walking theta in order, so it is done once, here.
set /a "phi=115562, n=0"
for /l %%t in (-360,3,2700) do (
	set /a "x=phi/100" & set /a "sp=(!sinDD!)*ONE/10000"
	set /a "x=phi/100" & set /a "cp=(!cosDD!)*ONE/10000"
	set /a "x=%%t*10"  & set /a "st=(!sinDD!)*ONE/10000"
	set /a "x=%%t*10"  & set /a "ct=(!cosDD!)*ONE/10000"
	set /a "m=(36*%%t/10) %% 360, u=m*ONE/180"
	set /a "t1=ONE-u, t2=t1*t1/ONE, t3=t2*5/4-ONE/4, t4=t3*t3/ONE, pc=ONE-t4/2"
	for %%n in (!n!) do set /a "sp_%%n=sp, cp_%%n=cp, st_%%n=st, ct_%%n=ct, pc_%%n=pc"
	set /a "n+=1, phi-=phi*2082/1000000"
)

rem ---- r table ------------------------------------------------------
rem  hangDown coefficient and the unlit HSB->RGB colour, per shell.
rem  Hue is fixed at 340 so the sector is constant and collapses to
rem      R = v      G = v(1-s)      B = v(1 - 2s/3)
for /l %%i in (0,1,%NR%) do (
	set /a "r=%%i*261/%NR%"
	set /a "r2=r*r/ONE, w=13*r/10-ONE, w2=w*w/ONE"
	set /a "r_%%i=r, hc_%%i=2*(r2*w2/ONE)"
	set /a "v=50+50*r/ONE, sat=100-50*r/ONE"
	set /a "bR_%%i=255*v/100, bG_%%i=255*v*(100-sat)/10000, bB_%%i=255*v*(300-2*sat)/30000"
)
goto :eof



rem ===================================================================
:render
rem  z is stored as "bigger = nearer" with a positive offset, so an
rem  untouched cell reads 0 through set /a and is beaten by any real
rem  sample.  That means the 12800-cell z-buffer needs no init pass.
set /a "total=0, cnt=0"
set "buf="

for /l %%# in () do (
	set /a "n=!random! %% %NT%, ri=!random! %% %NR%"

	for %%n in (!n!) do for %%i in (!ri!) do (
		set /a "hd=hc_%%i*sp_%%n/ONE, rad=r_%%i*sp_%%n/ONE+hd*cp_%%n/ONE, base=pc_%%n*rad/ONE"
		if !base! gtr 0 (
			set /a "k=SIZE*base/ONE, mx=k*st_%%n/ONE, mz=k*ct_%%n/ONE"
			set /a "vert=r_%%i*cp_%%n/ONE-hd*sp_%%n/ONE, my=0-(SIZE*pc_%%n/ONE)*vert/ONE"
			set /a "ry=(my*CA-mz*SA)/10000, rz=(my*SA+mz*CA)/10000"
			set /a "px=mx*2+cenX, py=ry+cenY"

			if !px! geq 1 if !px! leq %wid% if !py! geq 1 if !py! leq %hei% (
				set /a "zi=rz*100+100000, idx=py*%wid%+px"
				for %%d in (!idx!) do (
					set /a "old=zb_%%d"
					if !old! lss !zi! (
						set /a "zb_%%d=zi"
						set /a "sh=60+rz*45/40"
						set /a "sh=130+((sh-130)&((sh-130)>>31)), sh=sh-((sh-20)&((sh-20)>>31))"
						set /a "cR=bR_%%i*sh/100, cR=255+((cR-255)&((cR-255)>>31))"
						set /a "cG=bG_%%i*sh/100, cG=255+((cG-255)&((cG-255)>>31))"
						set /a "cB=bB_%%i*sh/100, cB=255+((cB-255)&((cB-255)>>31))"
						set "buf=!buf!%\e%[48;2;!cR!;!cG!;!cB!m%\e%[!py!;!px!H "
						set /a "cnt+=1"
					)
				)
			)
		)
	)

	set /a "total+=1"
	rem flush in batches - one echo per accepted sample would dominate
	rem the cost, and the buffer must stay under cmd's 8191 char line.
	if !cnt! geq 150 (
		echo !buf!%\e%[m
		set "buf=" & set /a "cnt=0"
		title Rose   samples: !total!
	)
)
pause>nul
goto :eof



rem ===================================================================
:init
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set /a "wid=160, hei=80, cenX=wid/2, cenY=hei/2"
mode %wid%,%hei%
echo %\e%[2J%\e%[H%\e%[?25l

rem fixed view: rotateX(-30).  Constant, so cos/sin are taken once.
set /a "CA=8660, SA=-5000"

set "_P=a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "sinDD=(a=((      x*31416/1800)%%62832)+(((      x*31416/1800)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),%_P%)"
set "cosDD=(a=((15708-x*31416/1800)%%62832)+(((15708-x*31416/1800)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),%_P%)"
set "_P="
goto :eof



rem ===================================================================
:Set_Font FontName FontSize max/nomax dummy
if "%4"=="" (
	for /f "tokens=1,2 delims=x" %%a in ("%~2") do if "%%b"=="" (set /a "FontSize=%~2*65536") else set /a "FontSize=%%a+%%b*65536"
	reg add "HKCU\Console\%~nx0" /v FontSize /t reg_dword /d !FontSize! /f >nul
	reg add "HKCU\Console\%~nx0" /v FaceName /t reg_sz /d "%~1" /f >nul
	set "m=" & if /I "%~3"=="max" set "m=/max"
	start "%~nx0" !m! "%ComSpec%" /c "%~f0" _
	exit /b 1
) else ( >nul reg delete "HKCU\Console\%~nx0" /f )
goto:eof