@echo off & setlocal enableDelayedExpansion

call :Set_Font "mxplus ibm ega 8x8" 5 nomax %1 || exit

call :init

set /a "ONE=256, SIZE=100, NR=64, TSTEP=1, DECAY=694"
set /a "INNER=2*NR/3, OUTER=INNER+1"
set /a "LASTN=3060/TSTEP, PERIOD=360/TSTEP, HALF=PERIOD/2, Q1=PERIOD/4, Q3=3*PERIOD/4"

title Rose   precomputing . . .
for /l %%i in (1,1,%NR%) do (
	set /a "rr=%%i*261/NR, r2=rr*rr/ONE, w=13*rr/10-ONE, w2=w*w/ONE"
	set /a "r_%%i=rr, hc_%%i=2*(r2*w2/ONE)"
	set /a "v=42+58*rr/ONE, sat=100-28*rr/ONE"
	set /a "bR_%%i=255*v/100, bG_%%i=255*v*(100-sat)/10000, bB_%%i=255*v*(300-2*sat)/30000"
)

set /a "phi=115562"
for /l %%n in (0,1,%LASTN%) do set /a "phi_%%n=phi, phi-=phi*DECAY/1000000"

(
for /l %%d in (0,1,%HALF%) do (
	set /a "nb1=HALF-%%d, nb2=HALF+%%d"
	set "grp=!nb1!"
	if %%d neq 0 if !nb2! lss %PERIOD% set "grp=!nb1! !nb2!"

	for %%b in (!grp!) do (

		set /a "lastk=%%b+((LASTN-%%b)/PERIOD)*PERIOD"
		set "seq=%%b,%PERIOD%,%LASTN%"
		if %%b lss %Q1% set "seq=!lastk!,-%PERIOD%,%%b"
		if %%b gtr %Q3% set "seq=!lastk!,-%PERIOD%,%%b"

		for /l %%k in (!seq!) do (

			set /a "th=-360+TSTEP*%%k, ph=phi_%%k/100"
			set /a "sp=!sin:x=ph!*ONE/10000",^
			       "cp=!cos:x=ph!*ONE/10000",^
			       "st=!sin:x=th*10!*ONE/10000",^
			       "ct=!cos:x=th*10!*ONE/10000",^
			       "m=(36*th/10) %% 360, u=m*ONE/180, t1=ONE-u, t2=t1*t1/ONE, t3=t2*5/4-ONE/4, t4=t3*t3/ONE, pc=ONE-t4/2"

			set /a "nx=sp*st/ONE, ny=cp, nz=sp*ct/ONE, dotL=(nx*LX+ny*LY+nz*LZ)/ONE, dotL=dotL-(dotL&(dotL>>31)), shB=32+dotL*92/ONE, spc=SIZE*pc/ONE"

			set "buf="
			for /l %%i in (4,1,%INNER%) do (
				set /a "hd=hc_%%i*sp/ONE, base=pc*(r_%%i*sp/ONE+hd*cp/ONE)/ONE, kk=SIZE*base/ONE, mz=kk*ct/ONE, my=0-spc*(r_%%i*cp/ONE-hd*sp/ONE)/ONE, rz=(my*SA+mz*CA)/10000, px=kk*st/ONE+cenX, py=(my*CA-mz*SA)/10000+cenY, bad=((px-1)|(%wid%-1-px)|(py-1)|(%hei%-1-py))>>31, sh=shB+rz/8, cR=bR_%%i*sh/100, cR=255+((cR-255)&((cR-255)>>31)), cG=bG_%%i*sh/100, cG=255+((cG-255)&((cG-255)>>31)), cB=bB_%%i*sh/100, cB=255+((cB-255)&((cB-255)>>31))"
				if !base! gtr 0 if !bad! equ 0 set "buf=!buf!%\e%[48;2;!cR!;!cG!;!cB!m%\e%[!py!;!px!H  %\e%[B%\e%[2D  "
			)
			for /l %%i in (%OUTER%,1,%NR%) do (
				set /a "hd=hc_%%i*sp/ONE, base=pc*(r_%%i*sp/ONE+hd*cp/ONE)/ONE, kk=SIZE*base/ONE, mz=kk*ct/ONE, my=0-spc*(r_%%i*cp/ONE-hd*sp/ONE)/ONE, rz=(my*SA+mz*CA)/10000, px=kk*st/ONE+cenX, py=(my*CA-mz*SA)/10000+cenY, bad=((px-1)|(%wid%-2-px)|(py-1)|(%hei%-1-py))>>31, sh=shB+rz/8, cR=bR_%%i*sh/100, cR=255+((cR-255)&((cR-255)>>31)), cG=bG_%%i*sh/100, cG=255+((cG-255)&((cG-255)>>31)), cB=bB_%%i*sh/100, cB=255+((cB-255)&((cB-255)>>31))"
				if !base! gtr 0 if !bad! equ 0 set "buf=!buf!%\e%[48;2;!cR!;!cG!;!cB!m%\e%[!py!;!px!H   %\e%[B%\e%[3D   "
			)
			echo !buf!%\e%[m%\e%[H
		)
	)
	title Rose   %%d / %HALF%
)
)>rose.txt
type rose.txt
title Rose   done
pause >nul
goto :eof



rem ===================================================================
:init
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set /a "wid=240, hei=200, cenX=wid/2, cenY=hei/2"
mode %wid%,%hei%
echo %\e%[2J%\e%[H%\e%[?25l

rem fixed view: rotateX(-30), so cos/sin are constants (x10000)
set /a "CA=8660, SA=-5000"
set /a "LX=-102, LY=159, LZ=174"

set "_P=a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "sin=(a=((      x*31416/1800)%%62832)+(((      x*31416/1800)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),%_P%)"
set "cos=(a=((15708-x*31416/1800)%%62832)+(((15708-x*31416/1800)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),%_P%)"
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