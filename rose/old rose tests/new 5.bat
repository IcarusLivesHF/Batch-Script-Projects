@echo off & setlocal enableDelayedExpansion

call :Set_Font "mxplus ibm ega 8x8" 4 nomax %1 || exit

call :init

set /a "ONE=256, SIZE=100, NR=64, DECAY=1388"
set /a "phi=115562, cnt=0"
set "buf="

for /l %%t in (-360,2,2700) do (

	set /a "sp=!sinDD:x=phi/100!*ONE/10000",^
		   "cp=!cosDD:x=phi/100!*ONE/10000",^
		   "st=!sinDD:x=%%t*10!*ONE/10000",^
		   "ct=!cosDD:x=%%t*10!*ONE/10000",^
		   "m=(36*%%t/10) %% 360, u=m*ONE/180, t1=ONE-u, t2=t1*t1/ONE, t3=t2*5/4-ONE/4, t4=t3*t3/ONE, pc=ONE-t4/2"


	for /l %%i in (1,1,!NR!) do (
		set /a "r=%%i*261/NR, r2=r*r/ONE, w=13*r/10-ONE, w2=w*w/ONE, hc=2*(r2*w2/ONE), hd=hc*sp/ONE, rad=r*sp/ONE+hd*cp/ONE, base=pc*rad/ONE, k=SIZE*base/ONE, mx=k*st/ONE, mz=k*ct/ONE, vert=r*cp/ONE-hd*sp/ONE, my=0-(SIZE*pc/ONE)*vert/ONE, ry=(my*CA-mz*SA)/10000, rz=(my*SA+mz*CA)/10000, px=mx+cenX, py=ry+cenY, zi=rz*100+100000, idx=py*%wid%+px, bad=((px-1)|(%wid%-1-px)|(py-1)|(%hei%-1-py))>>31"

		if !base! gtr 0 if !bad! equ 0 (
			for %%d in (!idx!) do (
				set /a "old=zb_%%d"
				if !old! lss !zi! (
					set /a "zb_%%d=zi, nx=sp*st/ONE, ny=cp, nz=sp*ct/ONE, dot=(nx*LX+ny*LY+nz*LZ)/ONE, dot=dot-(dot&(dot>>31)), sh=32+dot*92/ONE+rz/8, sh=140+((sh-140)&((sh-140)>>31)), sh=sh-((sh-18)&((sh-18)>>31)), v=42+58*r/ONE, sat=100-28*r/ONE, cR=255*v/100*sh/100, cR=255+((cR-255)&((cR-255)>>31)), cG=255*v*(100-sat)/10000*sh/100, cG=255+((cG-255)&((cG-255)>>31)), cB=255*v*(300-2*sat)/30000*sh/100, cB=255+((cB-255)&((cB-255)>>31)), cnt+=1, idx2=idx+%wid%, py2=py+1, idx3=idx+1, px2=px+1"
					set "buf=!buf!%\e%[48;2;!cR!;!cG!;!cB!m%\e%[!py!;!px!H "
					for %%e in (!idx2!) do (
						set /a "old2=zb_%%e"
						if !old2! equ 0 set /a "zb_%%e=1" & set "buf=!buf!%\e%[!py2!;!px!H "
					)
					for %%e in (!idx3!) do (
						set /a "old3=zb_%%e"
						if !old3! equ 0 set /a "zb_%%e=1" & set "buf=!buf!%\e%[!py!;!px2!H "
					)
				)
			)
		)
	)

	set /a "phi-=phi*DECAY/1000000"

	if !cnt! geq 40 ( echo !buf!%\e%[m & set "buf=" & set /a "cnt=0" )
	title Rose   theta %%t / 2700
)

echo !buf!%\e%[m
title Rose   done
pause >nul
goto :eof



:init
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set /a "wid=240, hei=200, cenX=wid/2, cenY=hei/2"
mode %wid%,%hei%
echo %\e%[2J%\e%[H%\e%[?25l

rem fixed view: rotateX(-30), so cos/sin are constants (x10000)
set /a "CA=8660, SA=-5000"
set /a "LX=-102, LY=159, LZ=174"

set "_P=a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "sinDD=(a=((      x*31416/1800)%%62832)+(((      x*31416/1800)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),%_P%)"
set "cosDD=(a=((15708-x*31416/1800)%%62832)+(((15708-x*31416/1800)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),%_P%)"
set "_P="
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