@echo off & setlocal enableDelayedExpansion

rem ===================================================================
rem made by IcarusLives
rem
rem RESOURCES/REFERENCES:
rem https://discord.com/channels/288498150145261568/866440127320817684/1353357227884544010
rem https://web.archive.org/web/20250512110825/http://www.romancortes.com/blog/1k-rose/
rem https://www.youtube.com/watch?v=YsGeMIpEcY4 
rem  
rem ===================================================================

call :Set_Font "lucida console" 5 nomax %1 || exit

call :init

set /a "ONE=256, SIZE=68, FY=70, NR=64, TSTEP=1, DECAY=694"
set /a "INNER=2*NR/3, OUTER=INNER+1, RMIN=4"
set /a "LASTN=3060/TSTEP, PERIOD=360/TSTEP, HALF=PERIOD/2, Q1=PERIOD/4, Q3=3*PERIOD/4"

rem ---- petal hue (full-saturation endpoint, 0-255 per channel) -------
rem    255,  0, 85  rose        255,120,  0  orange
rem    228, 20, 30  red         255,190,  0  yellow
set /a "PETR=228, PETG=20, PETB=30"

rem ---- stem ---------------------------------------------------------
set /a "STMHUER=58, STMHUEG=150, STMHUEB=52"
set /a "STMRAD=7, STMTOP=-10, STMBOT=132, STMVAL=72, STMSAT=92, STMBEND=9"

rem ---- leaves: shadow and light endpoints, plus gloss ----------------
set /a "LFSHDR=16, LFSHDG=54, LFSHDB=40"
set /a "LFLITR=176, LFLITG=228, LFLITB=92"
set /a "LFGLOSS=200, LFCURL=105, LFCUP=42"

rem ---- per-r constants: identical for every ring ---------------------
title Rose   precomputing . . . Render takes a long time, please be patient. Thank you
for /l %%i in (1,1,%NR%) do (
	set /a "rr=%%i*261/NR, r2=rr*rr/ONE, w=13*rr/10-ONE, w2=w*w/ONE"
	set /a "r_%%i=rr, hc_%%i=2*(r2*w2/ONE)"
	set /a "v=42+58*rr/ONE, sat=100-28*rr/ONE, inv=255*(100-sat)"
	set /a "bR_%%i=v*(PETR*sat+inv)/10000, bG_%%i=v*(PETG*sat+inv)/10000, bB_%%i=v*(PETB*sat+inv)/10000"
)

set /a "phi=115562"
for /l %%n in (0,1,%LASTN%) do set /a "phi_%%n=phi, phi-=phi*DECAY/1000000"

(
	call :stem
	call :leaves

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
				set /a "sp=(!sinDD:x=ph!)*ONE/10000",^
					   "cp=(!cosDD:x=ph!)*ONE/10000",^
					   "st=(!sinDD:x=th*10!)*ONE/10000",^
					   "ct=(!cosDD:x=th*10!)*ONE/10000",^
					   "m=(36*th/10) %% 360, u=m*ONE/180, t1=ONE-u, t2=t1*t1/ONE, t3=t2*5/4-ONE/4, t4=t3*t3/ONE, pc=ONE-t4/2"
				set /a "ast=st, ast=(ast^(ast>>31))-(ast>>31)"

				set /a "nx=sp*st/ONE, ny=cp, nz=sp*ct/ONE, dotL=(nx*LX+ny*LY+nz*LZ)/ONE, dotL=dotL-(dotL&(dotL>>31)), shadeB=32+dotL*92/ONE, spc=SIZE*pc/ONE"

				set "buf="
				if !ast! gtr 46 (
					for /l %%i in (%RMIN%,1,%INNER%) do (
						set /a "hd=hc_%%i*sp/ONE, base=pc*(r_%%i*sp/ONE+hd*cp/ONE)/ONE, kk=SIZE*base/ONE, mz=kk*ct/ONE, my=0-spc*(r_%%i*cp/ONE-hd*sp/ONE)/ONE, rz=(my*SA+mz*CA)/10000, px=kk*st/ONE+cenX, py=(my*CA-mz*SA)/10000+FY, bad=((px-1)|(%wid%-1-px)|(py-1)|(%hei%-1-py))>>31, sh=shadeB+rz/8, cR=bR_%%i*sh/100, cR=255+((cR-255)&((cR-255)>>31)), cG=bG_%%i*sh/100, cG=255+((cG-255)&((cG-255)>>31)), cB=bB_%%i*sh/100, cB=255+((cB-255)&((cB-255)>>31))"
						if !base! gtr 0 if !bad! equ 0 set "buf=!buf!%\e%[48;2;!cR!;!cG!;!cB!m%\e%[!py!;!px!H  %\e%[B%\e%[2D  "
					)
					for /l %%i in (%OUTER%,1,%NR%) do (
						set /a "hd=hc_%%i*sp/ONE, base=pc*(r_%%i*sp/ONE+hd*cp/ONE)/ONE, kk=SIZE*base/ONE, mz=kk*ct/ONE, my=0-spc*(r_%%i*cp/ONE-hd*sp/ONE)/ONE, rz=(my*SA+mz*CA)/10000, px=kk*st/ONE+cenX, py=(my*CA-mz*SA)/10000+FY, bad=((px-1)|(%wid%-2-px)|(py-1)|(%hei%-1-py))>>31, sh=shadeB+rz/8, cR=bR_%%i*sh/100, cR=255+((cR-255)&((cR-255)>>31)), cG=bG_%%i*sh/100, cG=255+((cG-255)&((cG-255)>>31)), cB=bB_%%i*sh/100, cB=255+((cB-255)&((cB-255)>>31))"
						if !base! gtr 0 if !bad! equ 0 set "buf=!buf!%\e%[48;2;!cR!;!cG!;!cB!m%\e%[!py!;!px!H   %\e%[B%\e%[3D   "
					)
				) else (
					for /l %%i in (%RMIN%,1,%NR%) do (
						set /a "hd=hc_%%i*sp/ONE, base=pc*(r_%%i*sp/ONE+hd*cp/ONE)/ONE, kk=SIZE*base/ONE, mz=kk*ct/ONE, my=0-spc*(r_%%i*cp/ONE-hd*sp/ONE)/ONE, rz=(my*SA+mz*CA)/10000, px=kk*st/ONE+cenX, py=(my*CA-mz*SA)/10000+FY, bad=((px-1)|(%wid%-2-px)|(py-1)|(%hei%-1-py))>>31, zi=rz*100+100000, idx=py*%wid%+px, sh=shadeB+rz/8, cR=bR_%%i*sh/100, cR=255+((cR-255)&((cR-255)>>31)), cG=bG_%%i*sh/100, cG=255+((cG-255)&((cG-255)>>31)), cB=bB_%%i*sh/100, cB=255+((cB-255)&((cB-255)>>31))"
						if !base! gtr 0 if !bad! equ 0 for %%z in (!idx!) do (
							set /a "old=zc_%%z"
							if !old! lss !zi! set /a "zc_%%z=zi" & set "buf=!buf!%\e%[48;2;!cR!;!cG!;!cB!m%\e%[!py!;!px!H  %\e%[B%\e%[2D  "
						)
					)
				)
				echo !buf!%\e%[m%\e%[H
			)
		)
		title Rose   %%d / %HALF%   Render takes a long time, please be patient. Thank you
	)
)>rose.txt

type rose.txt
title Rose   done
pause >nul
goto :eof




:stem
rem  Only the FRONT half of the cylinder is drawn (cos a > 0).  The
rem  back projects onto the same columns, so drawing it would be an
rem  ordering problem for no gain - and skipping it means the stem
rem  needs no depth sorting at all.
rem
rem  The stem bends on a quadratic in height.  A dead-straight stem is
rem  most of what made the first version look machined.
title Rose   stem . . . Render takes a long time, please be patient. Thank you
set /a "stmspan=STMBOT-STMTOP, stminv=255*(100-STMSAT)"

for /l %%a in (-84,7,84) do (
	set /a "sang=%%a*10"
	set /a "saz=(!sinDD:x=sang!)*ONE/10000, caz=(!cosDD:x=sang!)*ONE/10000"

	rem  cylinder normal is (sin a, 0, cos a): ny is zero, so this is
	rem  the flower's lambert term with one fewer multiply
	set /a "dotS=(saz*LX+caz*LZ)/ONE, dotS=dotS-(dotS&(dotS>>31)), shadeS=24+dotS*104/ONE"
	set /a "qR=STMVAL*(STMHUER*STMSAT+stminv)/10000*shadeS/100, qR=255+((qR-255)&((qR-255)>>31))"
	set /a "qG=STMVAL*(STMHUEG*STMSAT+stminv)/10000*shadeS/100, qG=255+((qG-255)&((qG-255)>>31))"
	set /a "qB=STMVAL*(STMHUEB*STMSAT+stminv)/10000*shadeS/100, qB=255+((qB-255)&((qB-255)>>31))"

	set "buf="
	for /l %%y in (%STMTOP%,2,%STMBOT%) do (
		set /a "prog=(%%y-STMTOP)*ONE/stmspan, swid=STMRAD*(58+42*prog/ONE)/100, bend=STMBEND*prog/ONE*prog/ONE, mz=swid*caz/ONE, px=swid*saz/ONE+bend+cenX, py=(%%y*CA-mz*SA)/10000+FY, bad=((px-1)|(%wid%-2-px)|(py-1)|(%hei%-1-py))>>31"
		if !bad! equ 0 set "buf=!buf!%\e%[!py!;!px!H  %\e%[B%\e%[2D  "
	)
	echo %\e%[48;2;!qR!;!qG!;!qB!m!buf!%\e%[m%\e%[H
)

rem ---- prickles: small down-swept triangles on the silhouette --------
set /a "pkR=qR*72/100, pkG=qG*72/100, pkB=qB*72/100"
for %%p in ("30 1" "56 -1" "84 1" "108 -1") do (
	for /f "tokens=1,2" %%Y in ("%%~p") do (
		set /a "prog=(%%Y-STMTOP)*ONE/stmspan, swid=STMRAD*(58+42*prog/ONE)/100, bend=STMBEND*prog/ONE*prog/ONE"
		set /a "tx0=swid*%%Z+bend+cenX, ty0=(%%Y*CA)/10000+FY"
		set "buf="
		for /l %%t in (0,1,6) do (
			set /a "txx=tx0+%%t*%%Z, hh=(7-%%t)*3/4"
			for /l %%h in (0,1,!hh!) do (
				set /a "tyy=ty0+%%h+%%t/2"
				set "buf=!buf!%\e%[!tyy!;!txx!H "
			)
		)
		echo %\e%[48;2;!pkR!;!pkG!;!pkB!m!buf!%\e%[m%\e%[H
	)
)
goto :eof



rem ===================================================================
:leaves
rem  Entries:  azimuth  attach_y  length  width  tilt  droop
rem  A NEGATIVE tilt lifts the leaf off the stem; the quadratic droop
rem  then overtakes it, so the blade arches up and the tip falls back
rem  down.  Keep droop above about 1.8*|tilt| or it never comes down.
rem  Azimuth near +-90 lays the leaf across the view; pointing it at
rem  the camera makes it project straight down under a -30 rotation.
title Rose   leaves . . . Render takes a long time, please be patient. Thank you

for %%p in ("-104 56 46 21 -55 95" "80 78 48 22 -52 92" "-116 52 34 9 -30 55" "104 56 36 9 -28 52") do (
	for /f "tokens=1-6" %%A in ("%%~p") do (

		set /a "lang=%%A*10, lroot=%%B, llen=%%C, lwid=%%D, ltilt=%%E, ldroop=%%F"
		set /a "saz=(!sinDD:x=lang!)*ONE/10000, caz=(!cosDD:x=lang!)*ONE/10000"

		for /l %%u in (2,2,!llen!) do (
			rem  half-width: q(2-q) keeps the pointed ends but fills the
			rem  middle, then a shallow sawtooth serrates the edge
			set /a "qq=4*%%u*(llen-%%u)*ONE/(llen*llen), hw=lwid*qq*(2*ONE-qq)/(ONE*ONE)"
			set /a "saw=%%u %% 10, hw=hw*(92+saw*8/9)/100, hw=(hw/2)*2, nhw=0-hw"
			set /a "uy=lroot+(%%u*ltilt+%%u*%%u*ldroop/llen)/ONE"

			rem  local slope of the arch, not the root tilt - otherwise
			rem  the lighting fights the shape everywhere but the base
			set /a "lslope=ltilt+2*%%u*ldroop/llen"

			set "buf="
			if !hw! gtr 0 for /l %%v in (!nhw!,2,!hw!) do (
				rem  cv is the cross-slope of the cup, so the normal
				rem  rolls across the blade and the two sides light
				rem  differently.  hcup lifts the edges in 3D as well.
				set /a "cv=LFCURL*%%v/hw, hcup=LFCUP*%%v*%%v/(hw*ONE)",^
				       "av=%%v, av=(av^(av>>31))-(av>>31), vm=(av-1)>>31",^
				       "vs=(%%v*30/hw+%%u*2+240) %% 30, vm=vm|((vs-1)>>31)",^
				       "nlx=(lslope*saz+cv*caz)/ONE, nlz=(lslope*caz-cv*saz)/ONE",^
				       "dotF=(nlx*LX+ONE*LY+nlz*LZ)/ONE, dotF=dotF-(dotF&(dotF>>31))",^
				       "shf=20+dotF*98/ONE, tt=(shf-20)*100/98",^
				       "tt=100+((tt-100)&((tt-100)>>31)), tt=tt-(tt&(tt>>31))",^
				       "tt=(tt&~vm)|((tt*58/100)&vm)",^
				       "gl=dotF-185, gl=gl-(gl&(gl>>31)), gl=gl*gl/64*LFGLOSS/ONE",^
				       "mx=(%%u*saz-%%v*caz)/ONE, mz=(%%u*caz+%%v*saz)/ONE",^
				       "px=mx+cenX, py=((uy-hcup)*CA-mz*SA)/10000+FY",^
				       "bad=((px-1)|(%wid%-1-px)|(py-1)|(%hei%-1-py))>>31",^
				       "cR=(LFSHDR*(100-tt)+LFLITR*tt)/100+gl, cR=255+((cR-255)&((cR-255)>>31))",^
				       "cG=(LFSHDG*(100-tt)+LFLITG*tt)/100+gl, cG=255+((cG-255)&((cG-255)>>31))",^
				       "cB=(LFSHDB*(100-tt)+LFLITB*tt)/100+gl, cB=255+((cB-255)&((cB-255)>>31))"
				if !bad! equ 0 set "buf=!buf!%\e%[48;2;!cR!;!cG!;!cB!m%\e%[!py!;!px!H  %\e%[B%\e%[2D  "
			)
			if defined buf echo !buf!%\e%[m%\e%[H
		)
	)
)
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