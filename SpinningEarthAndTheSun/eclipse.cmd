@echo off & setlocal enableDelayedExpansion

set "cfg=COLS=160, ROWS=60, rad=20, FRAMES=36, PERIOD=450, TILT=350, SX=118, SY=26, SK=8000, SMIN=3, BOFF=0, LX=7000, LY=-5500, LZ=-4500, NSH=8, AMB=0, NLON=72, NLAT=16, SECT=1, NCUT=4, NDIV=2, BGL=12"

call :Set_Font "consolas" 8 nomax %1 || exit
call :init


rem  little stars
for /l %%i in (1,1,%NSTARS%) do (
	set /a "$lx=!random! %% %COLS% + 1, $ly=!random! %% %ROWS% + 1, $lc=!random! %% 3"
	for %%c in (!$lc!) do <nul set /p "=%\e%[!$ly!;!$lx!H!TW_%%c!%\e%[0m"
)

rem  the star
for /l %%r in (0,1,%ROWS1%) do (

	set /a "$yt=%%r*2-%SY%, $yb=$yt+%HALF%, $t2=$yt*$yt, $b2=$yb*$yb"
	set "$s=" & set /a "$pk=-1, $run=0"

	for /l %%c in (0,1,%COLS1%) do (
		set /a "$dx=%%c-%SX%, $xx=$dx*$dx",^
			       "$a=%SK%/($xx+$t2+1), $a+=((255-$a)>>31&1)*(255-$a)",^
			       "$a-=$a %% (1+$a/16), $a-=(($a-%SMIN%)>>31&1)*$a",^
			       "$a+=(((-$a)>>31)&1)*(1-((%BGL%-$a)>>31&1))*(%BGL%-$a)",^
			       "$b=%SK%/($xx+$b2+1), $b+=((255-$b)>>31&1)*(255-$b)",^
			       "$b-=$b %% (1+$b/16), $b-=(($b-%SMIN%)>>31&1)*$b",^
			       "$b+=(((-$b)>>31)&1)*(1-((%BGL%-$b)>>31&1))*(%BGL%-$b)",^
			       "$k=$a*256+$b, $run+=1"

		if !$k! neq !$pk! (
			if !$pk! geq 0 call :starRun
			set /a "$pk=$k, $run=1"
		)
	)
	set /a "$run+=1" & call :starRun

	set /a "$sr=%%r+1"
	<nul set /p "=%\e%[!$sr!;1H!$s!%\e%[0m"
)

rem sphere precomp
set /a "pct=-1, curR=0, curC=0"
for /l %%r in (0,1,%R2%) do (

	set /a "y1=(%%r-%rad%)*100, wy2=%R2SQ%-y1*y1",^
	       "wy2-=(wy2>>31&1)*wy2, w1=!sqrt:N=wy2!",^
	       "cL=%C2R%-w1/50, cR=%C2R%+w1/50"

	set "MV_%%r=" & set "RUN_%%r="

	if !cR! geq !cL! (

		set /a "dr=%%r-curR, dc=cL-curC"
		set /a "ar=(dr>>31|1)*dr, ac=(dc>>31|1)*dc"
		set "_mv="
		if !dr! lss 0 set "_mv=%\e%[!ar!A"
		if !dr! gtr 0 set "_mv=%\e%[!ar!B"
		if !dc! lss 0 set "_mv=!_mv!%\e%[!ac!D"
		if !dc! gtr 0 set "_mv=!_mv!%\e%[!ac!C"
		set "MV_%%r=!_mv!"

		set /a "pid=-1, rs=cL"

		for /l %%c in (!cL!,1,!cR!) do (

			set /a "x1=(%%c-%C2R%)*50, z2=wy2-x1*x1",^
			       "z2-=(z2>>31&1)*z2, z1=!sqrt:N=z2!",^
			       "xa=(x1*%cT%+y1*%sT%)/10000, ya=(y1*%cT%-x1*%sT%)/10000",^
			       "lam=(x1*%LX%+y1*%LY%+z1*%LZ%)/%R100%",^
			       "sh=(lam+%AMB%+10000)*%NSH%/20000",^
			       "sh-=(sh>>31&1)*sh, sd=%NSH1%-sh, sh+=(sd>>31&1)*sd",^
			       "sh-=(sh&1)*(((sh-%NCUT%)>>31)&1)",^
			       "atm=((z1-%ATH%)>>31)&1, la=0, lo=0"

			set /a "x=xa, y=z1, th=%atan2%/10",^
			       "lo=(th %% 3600 + 3600) %% 3600 * %NLON% / 3600",^
			       "la=(ya+%R100%)*%NLAT%/%R200%",^
			       "la-=(la>>31&1)*la, ld=%NLAT1%-la, la+=(ld>>31&1)*ld",^
			       "dk=((sh-%NCUT%)>>31)&1, lo-=dk*(lo %% %NDIV%)"

			set /a "id=((la*%NLON%+lo)*%NSH%+sh)*2+atm"

			if !id! neq !pid! (
				if !pid! geq 0 (
					set /a "q=(%%c-rs)*%BASE%+pid"
					set "RUN_%%r=!RUN_%%r! !q!"
				)
				set /a "rs=%%c, pid=id"
			)
		)

		set /a "q=(cR+1-rs)*%BASE%+pid"
		set "RUN_%%r=!RUN_%%r! !q!"
		set /a "curR=%%r, curC=cR+1"
	)

	set /a "p=%%r*100/%R2%"
	if !p! neq !pct! (
		set /a "pct=p, bars=p/2"
		set "bar="
		for /l %%z in (1,1,!bars!) do set "bar=!bar!#"
		title !bar! !p!%%  
	)
)

set "Atan=" & set "atan2=" & set "sqrt=" & set "sin=" & set "cos=" & set "$p="

rem build the frames
set /a "pct=-1, have=0"

for /l %%f in (0,1,%FRAMES1%) do if not defined full (

	set "_s=" & set /a "nc=0, kf=%%f*%ADV%"

	for /l %%r in (0,1,%R2%) do (

		set "_s=!_s!!MV_%%r!"
		
		set "r=!RUN_%%r!"
		for %%q in (!r!) do (

			set /a "$d=%%q %% %BASE%, w=%%q/%BASE%, atm=$d&1, $u=$d>>1",^
			       "sh=$u %% %NSH%, $u=$u/%NSH%",^
			       "lo=($u %% %NLON% - kf + %NLON%) %% %NLON%, la=$u/%NLON%",^
			       "ti=la*%NLON%+lo"

			for %%t in (!ti!) do set /a "key=(1-atm)*(!TEX:~%%t,1!*%NSH%+sh)+atm*(%ATMB%+sh)"
			for %%w in (!w!) do for %%h in (!key!) do set "_s=!_s!!CLRK_%%h!!PADSP:~0,%%w!"
		)

		if not "!_s:~3500,1!"=="" (
			for %%p in (!nc!) do set "F_%%f_%%p=!_s!%\e%[0m"
			set /a "nc+=1"
			set "_s="
		)
	)

	for %%p in (!nc!) do set "F_%%f_%%p=!_s!%\e%[0m"
	set "FC_%%f=!nc!"

	for /l %%p in (0,1,!nc!) do if not defined F_%%f_%%p set "full=1"
	if not defined full set /a "have=%%f+1"
	set "_s="

	set /a "p=have*100/%FRAMES%"
	if !p! neq !pct! (
		set /a "pct=p, bars=p/2"
		set "bar="
		for /l %%z in (1,1,!bars!) do set "bar=!bar!#"
		title !bar! !p!%%  
	)
)

for /l %%r in (0,1,%R2%) do (set "RUN_%%r=" & set "MV_%%r=")
set "TEX="

if defined full if %have% gtr 2 set /a "have-=2"
if %have% lss 1 (
	echo=%\e%[0m
	echo.
	echo   no frames stored - lower rad, FRAMES or NSH
	pause
	exit
)


rem render everything
set "clock=!time: =0!"
set /a "t0=%@mark%, tp=t0, ec=0, pk=-1"

for /l %%L in () do (
	set "clock=!time: =0!"
	set /a "t2=%@mark%, e=t2-t0, e+=(e>>31&1)*8640000"

	set /a "r=e %% %PERIOD%, k=(r*%SECT%*%have%/%PERIOD%) %% %have%"

	if !k! neq !pk! (
		set /a "pk=k, ec+=1"

		for %%f in (!k!) do (
			<nul set /p "=%\e%[%BY%;%BX%H"
			for /l %%p in (0,1,!FC_%%f!) do <nul set /p "=!F_%%f_%%p!"
		)
	)

	if !ec! geq 24 (
		set /a "d=t2-tp, d+=(d>>31&1)*8640000, d+=((d-1)>>31&1)*(1-d)",^
		       "ips=ec*10000/d, tp=t2, ec=0, ipi=ips/100, ipf=ips %% 100"
		set "ipf=0!ipf!"
		title !ipi!.!ipf:~-2! img/sec   %have%f x %SECT%
	)
)
exit




:init
set /a "%cfg%"
mode %COLS%,%ROWS%
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set "BLK=" & set /a "HALF=1"
for /f %%a in ('forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo 0xDF" 2^>nul') do set "BLK=%%a"
if not defined BLK (set "BLK= " & set /a "HALF=0")

for /f "tokens=1 delims==" %%v in ('set') do (
	if /i not "%%v"=="\e" if /i not "%%v"=="cfg" if /i not "%%v"=="BLK" if /i not "%%v"=="HALF" set "%%v="
)

set /a "gotW=160", "gotH=60
set /a "%cfg%" & set "cfg="
set /a "COLS=gotW, ROWS=gotH, COLS1=COLS-1, ROWS1=ROWS-1"
set /a "NSTARS=COLS*ROWS/70"
set /a "R100=rad*100, R200=2*R100, R2SQ=R100*R100"
set /a "ATH=R100*35/100"
set /a "R2=2*rad, C2R=2*rad, ballH=2*rad+1, ballW=4*rad+1"
set /a "FRAMES1=FRAMES-1, NSH1=NSH-1, NLON1=NLON-1, NLAT1=NLAT-1"
set /a "anim=SECT*FRAMES*100/PERIOD"
set /a "BASE=NLAT*NLON*NSH*2, ADV=NLON/FRAMES, ATMB=6*NSH"
set /a "chk=ADV*FRAMES"
set /a "BX=(COLS-ballW)/2+1+BOFF, BY=(ROWS-ballH)/2+1"

set "PADSP= " & set "PADBLK=%BLK%"
for /l %%z in (1,1,8) do (
	set "PADSP=!PADSP!!PADSP!"
	set "PADBLK=!PADBLK!!PADBLK!"
)

set "TW_0=%\e%[38;5;15m." & set "TW_1=%\e%[38;5;222m." & set "TW_2=%\e%[38;5;117m."

set "@mark=((((1^!clock:~0,2^!-100)*60+(1^!clock:~3,2^!-100))*60+(1^!clock:~6,2^!-100))*100+(1^!clock:~9,2^!-100))"
set "$p=$b=$a*(1+2*($a>>31)), $n=$a*(1800-$b), $d=4051000-$b*(1800-$b), $n*2000/$d*20+$n*2000%%$d*20/$d"
set "sin=($a=1800-(x+3600000)%%3600, %$p%)"
set "cos=($a=1800-(x+3600900)%%3600, %$p%)"
set "sqrt=( M=(N),q=M/(11264)+40, q=(M/q+q)>>1, q=(M/q+q)>>1, q=(M/q+q)>>1, q=(M/q+q)>>1, q=(M/q+q)>>1, q+=(M-q*q)>>31 )"
set "Atan=( $1=(x), $t=(((($1>>31|1)*$1)-1077)>>31)+1, $y=10000000/((($1>>31)+1)*($1-(($1-1)&(($1-1)>>31)))-($1>>31)*$1), $t*((($1>>31|-$1>>31&1)*90000-(($y*100000+43205*$y/2000*$y/10000*$y/5)/((((1000000000+7649*$y/1000*$y)+(584*$y/50*$y/10000*$y/10000*$y/10/2) )/100000)|1) )*180*100/31416)/10)+(1-$t)*(($1*1000000+43205*$1/100*$1/1000*$1)/((((1000000000+7649*$1/10*$1)+(584*$1/10*$1/100*$1/1000*$1/10))/100000)|1)*180*100/314159) )"
set "atan2=(I0=((~-x>>31)&1)&((~x>>31)&1), I0*(9000*((y>>31)-((-y)>>31)))+(1-I0)*(^!Atan:x=(1000*y)/(x+I0)^!+18000*(-(x>>31))*(1+2*(y>>31))))"

set /a "cT=!cos:x=TILT!, sT=!sin:x=TILT!"

set "TEX="
set "TEX=%TEX%441144444444444444444444144444410011144444444444444444444444444444444444"
set "TEX=%TEX%110011122225555222222222211111100122222222222222222222222222222222222222"
set "TEX=%TEX%000000011115555222222221100000000012255222222223333333333311111111111111"
set "TEX=%TEX%000000000001555222222110000000000122222222111222225555552222221000000000"
set "TEX=%TEX%000000000000133222221000000000001333333333231113222222222221110000000000"
set "TEX=%TEX%000000000000011222211111000000001333333333233331112222222210000000000000"
set "TEX=%TEX%000000000000000111112222110000001222222222222110001111111100000000000000"
set "TEX=%TEX%000000000000000000015552221100000111222222222100000000000000000000000000"
set "TEX=%TEX%000000000000000000015552222210000000112222221000000000000000000000000000"
set "TEX=%TEX%000000000000000000001552222221000000012222221000000000000001111110000000"
set "TEX=%TEX%000000000000000000000152222210000000013322210000000000000012222221100000"
set "TEX=%TEX%000000000000000000000152222100000000001322210000000000000012333322210000"
set "TEX=%TEX%000000000000000000000152211000000000000111100000000000000012222222100000"
set "TEX=%TEX%000000000000000000001221100000000000000000000000000000000001111111000000"
set "TEX=%TEX%111111111111111111111111111111111111111111111111111111111111111111111111"
set "TEX=%TEX%444444444444444444444444444444444444444444444444444444444444444444444444"

set "D0=3-9-23 5-14-37 7-21-55 10-30-77"
set "D0=2-5-13 4-11-30 7-21-55 10-30-77"   
set "D1=7-21-25 11-34-40 17-51-60 23-70-83"    
set "D2=7-21-9 12-34-14 18-51-21 25-70-30"     
set "D3=27-22-13 44-36-22 65-54-32 90-75-45"   
set "D4=31-31-32 50-51-52 74-75-77 103-105-107"
set "D5=18-16-13 30-26-22 44-38-32 62-53-45"   
set "D6=13-22-32 22-36-52 32-54-77 45-75-107"  

set "P0=18 25 26 32"
set "P1=24 31 38 45"
set "P2=22 28 34 71"
set "P3=94 137 179 180"
set "P4=145 188 254 231"
set "P5=59 95 138 145"
set "P6=25 32 45 117"

for /l %%t in (0,1,6) do (
	set /a "i=%%t*%NSH%"
	for %%v in (!D%%t!) do (
		set "c=%%v"
		set "CLRK_!i!=%\e%[48;2;!c:-=;!m"
		set /a "i+=1"
	)
	for %%v in (!P%%t!) do (
		set "CLRK_!i!=%\e%[48;5;%%vm"
		set /a "i+=1"
	)
)
set "c=" & for /l %%t in (0,1,6) do (set "P%%t=" & set "D%%t=")


<nul set /p "=%\e%[?25l"
goto :eof




:starRun
set /a "$w=$run-1, $ca=$pk/256, $cb=$pk %% 256"
if !$w! leq 0 goto :eof
if !$pk!==0 (
	set "$s=!$s!%\e%[!$w!C"
) else (
	set /a "$ca+=(1-((-$ca)>>31&1))*%BGL%, $cb+=(1-((-$cb)>>31&1))*%BGL%"
	for %%w in (!$w!) do set "$s=!$s!%\e%[38;2;!$ca!;!$ca!;!$ca!;48;2;!$cb!;!$cb!;!$cb!m!PADBLK:~0,%%w!"
)
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
goto :eof
