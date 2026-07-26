@echo off & setlocal enableDelayedExpansion

call :Set_Font "consolas" 12 nomax %1 || exit

call :init
call :buildLUT

set /a "total=0, cnt=0"
set "buf="

for /l %%# in () do (
	set /a "n=!random! %% %NT%, ri=!random! %% %NR%"

	for %%n in (!n!) do for %%i in (!ri!) do (
		set /a "hd=hc_%%i*sp_%%n/ONE, rad=r_%%i*sp_%%n/ONE+hd*cp_%%n/ONE, base=pc_%%n*rad/ONE"
		if !base! gtr 0 (
			set /a "k=SIZE*base/ONE, mx=k*st_%%n/ONE, mz=k*ct_%%n/ONE",^
				   "vert=r_%%i*cp_%%n/ONE-hd*sp_%%n/ONE, my=0-(SIZE*pc_%%n/ONE)*vert/ONE",^
				   "ry=(my*CA-mz*SA)/10000, rz=(my*SA+mz*CA)/10000",^
				   "px=mx*2+cenX, py=ry+cenY"

			if !px! geq 1 if !px! leq %wid% if !py! geq 1 if !py! leq %hei% (
				set /a "zi=rz*100+100000, idx=py*%wid%+px"
				for %%d in (!idx!) do (
					set /a "old=zb_%%d"
					if !old! lss !zi! (
						set /a "zb_%%d=zi",^
							   "sh=60+rz*45/40",^
							   "sh=130+((sh-130)&((sh-130)>>31)), sh=sh-((sh-20)&((sh-20)>>31))",^
							   "cR=bR_%%i*sh/100, cR=255+((cR-255)&((cR-255)>>31))",^
							   "cG=bG_%%i*sh/100, cG=255+((cG-255)&((cG-255)>>31))",^
							   "cB=bB_%%i*sh/100, cB=255+((cB-255)&((cB-255)>>31))",^
							   "cnt+=1"
						set "buf=!buf!%\e%[48;2;!cR!;!cG!;!cB!m%\e%[!py!;!px!H "
					)
				)
			)
		)
	)

	set /a "total+=1"
	if !cnt! geq 150 (
		echo !buf!%\e%[m
		set "buf=" & set /a "cnt=0"
		title Rose   samples: !total!
	)
)
pause>nul



:buildLUT
set /a "ONE=256, SIZE=34, NT=1020, NR=127, phi=115562, n=0"
for /l %%t in (-360,3,2700) do (
	set /a "sp=!sin:x=phi/100!*ONE/10000",^
		   "cp=!cos:x=phi/100!*ONE/10000",^
		   "st=!sin:x=%%t*10!*ONE/10000",^
		   "ct=!cos:x=%%t*10!*ONE/10000",^
		   "m=(36*%%t/10) %% 360, u=m*ONE/180",^
		   "t1=ONE-u, t2=t1*t1/ONE, t3=t2*5/4-ONE/4, t4=t3*t3/ONE, pc=ONE-t4/2"
	set /a "sp_!n!=sp, cp_!n!=cp, st_!n!=st, ct_!n!=ct, pc_!n!=pc",^
		   "n+=1, phi-=phi*2082/1000000"
)

for /l %%i in (0,1,%NR%) do (
	set /a "r=%%i*261/%NR%",^
		   "r2=r*r/ONE, w=13*r/10-ONE, w2=w*w/ONE",^
		   "r_%%i=r, hc_%%i=2*(r2*w2/ONE)",^
		   "v=50+50*r/ONE, sat=100-50*r/ONE",^
		   "bR_%%i=255*v/100, bG_%%i=255*v*(100-sat)/10000, bB_%%i=255*v*(300-2*sat)/30000"
)
goto :eof





:init
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set /a "wid=160, hei=80, cenX=wid/2, cenY=hei/2"
mode %wid%,%hei%
echo %\e%[2J%\e%[H%\e%[?25l

rem fixed view: rotateX(-30).  Constant, so cos/sin are taken once.
set /a "CA=8660, SA=-5000"

set "_sin=a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "sin=(a=((      x*31416/1800)%%62832)+(((      x*31416/1800)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),%_sin%)"
set "cos=(a=((15708-x*31416/1800)%%62832)+(((15708-x*31416/1800)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),%_sin%)"
set "_sin="
goto :eof



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