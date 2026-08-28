@echo off & setlocal enableDelayedExpansion

set "cfg=COLS=800, ROWS=500, HZ=160, VA=1, FOCAL=650, CAMH=220, SPY=-20, SPZ=580, SPR=150, CELL=170, NFOG=24, NSHD=6, NSKY=128, SKYMAX=600, RIMPX=2, LX=-380, LY=850, LZ=-360, SUN0=988, SUN1=966, SUN2=934, RYMIN=8, ZN=420, ZF=3400, RN=60, RF=760, SHMUL=980, SHSOFT=135"

call :Set_Font "mxplus ibm ega 8x8" 1 nomax %1 || exit
call :init


set /a "pct=-1"

for /l %%r in (0,1,%ROWS1%) do (

	set /a "v=%%r-%HZ%, KK=%VA2%*v*v+%F2%"
	set /a "dc=%FOCAL%*%SPZ%-%VA%*v*%SPY%"

	set /a "bg=dc*10/%GC%, uu=bg*bg/100-KK"
	set /a "hasb=1-((uu-1)>>31&1), uu-=(uu>>31&1)*uu"
	set /a "um=!sqrt:N=uu!"
	set /a "bL=%CX%-um-3, bR=%CX%+um+3"
	set /a "bL-=(bL>>31&1)*bL, bd=%COLS1%-bR, bR+=(bd>>31&1)*bd"

	set /a "sr=%%r+1"
	set "_s=%\e%[!sr!;1H"

	if !v! leq 0 (

		set /a "aa=100*(%VA2%*v*v+%F2%), na=!sqrt:N=aa!"
		set /a "vy=0-%VA%*v*10000/na, sk=vy*%NSKY%/%SKYMAX%"
		set /a "fd=%NSKY1%-sk, sk+=(fd>>31&1)*fd, sk-=(sk>>31&1)*sk"
		for %%h in (!sk!) do set "_s=!_s!!CLRK_%%h!!PADSP:~0,%COLS%!"

	) else (

		set /a "QR=%CAMH%*1000/(%VA%*v), ZR=%FOCAL%*QR/1000"
		set /a "fz=(ZR-%ZN%)*%NFOG%/(%ZF%-%ZN%)"
		set /a "fz-=(fz>>31&1)*fz, fd=%NFOG1%-fz, fz+=(fd>>31&1)*fd"

		if !fz! geq %NFOG1% (
			for %%h in (%HAZEP%) do set "_s=!_s!!CLRK_%%h!!PADSP:~0,%COLS%!"
		) else (
			set /a "dz=ZR-%SHZ%, dz2=dz*dz, sh2=%SHR2%-dz2, scL=1, scR=0"
			if !sh2! gtr 0 (
				set /a "hf=!sqrt:N=sh2!"
				set /a "scL=%CX%+(%SHX%-hf)*1000/QR, scR=%CX%+(%SHX%+hf)*1000/QR"
			)
			set /a "zpar=((ZR+%XOFF%)/%CELL%)&1"
			set /a "xa=(0-%CX%)*QR/1000, xb=(%COLS1%-%CX%)*QR/1000"
			set /a "kA=(xa+%XOFF%)/%CELL%, kB=(xb+%XOFF%)/%CELL%, cprev=0"
			set /a "ky0=%CKBASE%+fz*%NSHD%*2, ky1=ky0+2"

			for /l %%k in (!kA!,1,!kB!) do (
				set /a "bx=(%%k+1)*%CELL%-%XOFF%, cend=%CX%+bx*1000/QR+1"
				set /a "fd=%COLS%-cend, cend+=(fd>>31&1)*fd"
				if !cend! gtr !cprev! (
					set /a "pa=cprev, pb=cend-1, par=(%%k+zpar)&1"
					set /a "kL=ky0+par, ks=ky1+par"
					set /a "ml=scL, fd=ml-pa, ml-=(fd>>31&1)*fd"
					set /a "mr=scR, fd=pb-mr, mr+=(fd>>31&1)*fd"
					set /a "wm=mr-ml+1, wm-=(wm>>31&1)*wm"
					if !wm!==0 (
						set /a "w=pb-pa+1"
						for %%w in (!w!) do for %%h in (!kL!) do set "_s=!_s!!CLRK_%%h!!PADSP:~0,%%w!"
					) else (
						set /a "wl=ml-pa, wr=pb-mr"
						if !wl! gtr 0 for %%w in (!wl!) do for %%h in (!kL!) do set "_s=!_s!!CLRK_%%h!!PADSP:~0,%%w!"
						for %%w in (!wm!) do for %%h in (!ks!) do set "_s=!_s!!CLRK_%%h!!PADSP:~0,%%w!"
						if !wr! gtr 0 for %%w in (!wr!) do for %%h in (!kL!) do set "_s=!_s!!CLRK_%%h!!PADSP:~0,%%w!"
					)
					set /a "cprev=cend"
				)
			)
		)
	)

	<nul set /p "=!_s!%\e%[m"

	if !hasb!==1 (
		set /a "sc=bL+1"
		set "_b=%\e%[!sr!;!sc!H"
		set /a "pid=-1, rs=bL"

		for /l %%c in (!bL!,1,!bR!) do (

			set /a "u=%%c-%CX%, id=%SKIPK%"
			set /a "aa=100*(u*u+KK), na=!sqrt:N=aa!"
			set /a "b10=dc*100/na, d100=b10*b10-%C100%"

			if !d100! geq 0 (
				set /a "sq=!sqrt:N=d100!, t10=b10-sq"
				set /a "vx=u*10000/na, vy=0-%VA%*v*10000/na, vz=%FOCAL%*10000/na"
				set /a "px=t10*vx/10000, py=t10*vy/10000, pz=t10*vz/10000"
				set /a "nx=t10*vx/%SPR10%, ny=(t10*vy/10-%SPY1K%)/%SPR%, nz=(t10*vz/10-%SPZ1K%)/%SPR%"
				set /a "dt=(vx*nx+vy*ny+vz*nz)/1000, adt=(dt>>31|1)*dt"
				set /a "rx=vx-2*dt*nx/1000, ry=vy-2*dt*ny/1000, rz=vz-2*dt*nz/1000"
				set /a "sun=(rx*%LX%+ry*%LY%+rz*%LZ%)/1000"

				if !adt! lss %RIM1% set /a "id=%RIMP%+1"
				if !adt! lss %RIM0% set /a "id=%RIMP%"

				if !id!==%SKIPK% (
					set /a "sid=%SKIPK%"
					if !sun! geq %SUN2% set /a "sid=%SUNP%+2"
					if !sun! geq %SUN1% set /a "sid=%SUNP%+1"
					if !sun! geq %SUN0% set /a "sid=%SUNP%"
					if not !sid!==%SKIPK% set /a "id=sid"
				)

				if !id!==%SKIPK% if !ry! geq 0 (
					set /a "sk=ry*%NSKY%/%SKYMAX%, fd=%NSKY1%-sk, sk+=(fd>>31&1)*fd"
					set /a "id=sk"
				)

				if !id!==%SKIPK% (
					set /a "ryn=0-ry"
					if !ryn! lss %RYMIN% set /a "id=%HAZEP%"
				)
				if !id!==%SKIPK% (
					set /a "tr=(py+%CAMH%)*1000/ryn"
					if !tr! geq %RF% set /a "id=%HAZEP%"
				)
				if !id!==%SKIPK% (
					set /a "fg=(tr-%RN%)*%NFOG%/(%RF%-%RN%)"
					set /a "fg-=(fg>>31&1)*fg, fd=%NFOG1%-fg, fg+=(fd>>31&1)*fd"
					if !fg! geq %NFOG1% set /a "id=%HAZEP%"
				)
				if !id!==%SKIPK% (
					set /a "hitx=px+tr*rx/1000, hitz=pz+tr*rz/1000"
					set /a "sdx=hitx-%SHX%, sdz=hitz-%SHZ%"
					set /a "ax=(sdx>>31|1)*sdx, az=(sdz>>31|1)*sdz, shd=3"
					if !ax! lss 1200 if !az! lss 1200 (
						set /a "d2=sdx*sdx+sdz*sdz"
						if !d2! lss %SHRO2% set /a "shd=4"
						if !d2! lss %SHR2% set /a "shd=5"
					)
					set /a "xp=((hitx+%XOFF%)/%CELL%+(hitz+%XOFF%)/%CELL%)&1"
					set /a "id=%CKBASE%+(fg*%NSHD%+shd)*2+xp"
				)
			)

			if !id! neq !pid! (
				if !pid! geq 0 (
					set /a "w=%%c-rs"
					if !pid!==%SKIPK% (
						for %%w in (!w!) do set "_b=!_b!%\e%[%%wC"
					) else (
						for %%w in (!w!) do for %%h in (!pid!) do set "_b=!_b!!CLRK_%%h!!PADSP:~0,%%w!"
					)
				)
				set /a "rs=%%c, pid=id"
			)
		)

		set /a "w=bR+1-rs"
		if !pid! geq 0 if !w! gtr 0 (
			if !pid!==%SKIPK% (
				for %%w in (!w!) do set "_b=!_b!%\e%[%%wC"
			) else (
				for %%w in (!w!) do for %%h in (!pid!) do set "_b=!_b!!CLRK_%%h!!PADSP:~0,%%w!"
			)
		)
		<nul set /p "=!_b!%\e%[0m"
	)

	set /a "p=%%r*100/%ROWS1%"
	if !p! neq !pct! (
		set /a "pct=p, bars=p/2"
		set "bar="
		for /l %%z in (1,1,!bars!) do set "bar=!bar!#"
		title rendering !bar! !p!%%  
	)
)

title done - %COLS%x%ROWS%
pause >nul
exit



:init
set /a "%cfg%"
mode %COLS%,%ROWS%
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

for /f "tokens=1 delims==" %%v in ('set') do (
	if /i not "%%v"=="\e" if /i not "%%v"=="cfg" set "%%v="
)
set /a "%cfg%" & set "cfg="

set /a "COLS1=COLS-1, ROWS1=ROWS-1, CX=COLS/2"
set /a "VA2=VA*VA, F2=FOCAL*FOCAL, XOFF=1000*CELL"
set /a "NFOG1=NFOG-1, NSHD1=NSHD-1, NSKY1=NSKY-1"
set /a "SPR10=10*SPR, SPY1K=SPY*1000, SPZ1K=SPZ*1000"
set /a "C0=SPY*SPY+SPZ*SPZ-SPR*SPR, C100=C0*100"

set "sqrt=( M=(N),q=M/(11264)+40, q=(M/q+q)>>1, q=(M/q+q)>>1, q=(M/q+q)>>1, q=(M/q+q)>>1, q=(M/q+q)>>1, q+=(M-q*q)>>31 )"
set /a "GC=!sqrt:N=C0!"

set /a "lq=LX*LX+LY*LY+LZ*LZ, LM=!sqrt:N=lq!"
set /a "LX=LX*1000/LM, LY=LY*1000/LM, LZ=LZ*1000/LM"

set /a "ss=(SPY+CAMH)*1000/LY"
set /a "SHX=0-LX*ss/1000, SHZ=SPZ-LZ*ss/1000"
set /a "SHRD=SPR*SHMUL/1000, SHR2=SHRD*SHRD, SHRO=SHRD*SHSOFT/100, SHRO2=SHRO*SHRO"

set /a "RPX=FOCAL*SPR/SPZ, rq=2*RIMPX*1000000/RPX"
set /a "RIM1=!sqrt:N=rq!, rq=RIMPX*1000000/RPX"
set /a "RIM0=!sqrt:N=rq!"

set /a "HAZEP=NSKY, SUNP=NSKY+1, RIMP=NSKY+4"
set /a "CKBASE=NSKY+6, SKIPK=99999"

set "PADSP= "
for /l %%z in (1,1,11) do set "PADSP=!PADSP!!PADSP!"

set /a "KA_R=196, KA_G=206, KA_B=226"
set /a "KB_R=16,  KB_G=28,  KB_B=74"
set /a "FL_R=210, FL_G=214, FL_B=224"
set /a "FD_R=24,  FD_G=29,  FD_B=40"
set "DM_0=100" & set "DM_1=70" & set "DM_2=45"
set "DM_3=64"  & set "DM_4=45" & set "DM_5=29"

for /l %%s in (0,1,%NSKY1%) do (
	set /a "mm=%%s*1000/%NSKY1%"
	set /a "cr=%KA_R%+(%KB_R%-%KA_R%)*mm/1000",^
	       "cg=%KA_G%+(%KB_G%-%KA_G%)*mm/1000",^
	       "cb=%KA_B%+(%KB_B%-%KA_B%)*mm/1000"
	set "CLRK_%%s=%\e%[48;2;!cr!;!cg!;!cb!m"
)
set "CLRK_%HAZEP%=%\e%[48;2;%KA_R%;%KA_G%;%KA_B%m"
set "CLRK_%SUNP%=%\e%[48;2;255;253;246m"
set /a "i=SUNP+1" & set "CLRK_!i!=%\e%[48;2;255;240;202m"
set /a "i=SUNP+2" & set "CLRK_!i!=%\e%[48;2;238;206;150m"
set "CLRK_%RIMP%=%\e%[48;2;14;16;22m"
set /a "i=RIMP+1" & set "CLRK_!i!=%\e%[48;2;52;58;70m"

for /l %%o in (0,1,%NFOG1%) do for /l %%s in (0,1,%NSHD1%) do (
	set /a "mm=%%o*1000/%NFOG1%, dm=!DM_%%s!"
	set /a "lr=(%FL_R%+(%KA_R%-%FL_R%)*mm/1000)*dm/100",^
	       "lg=(%FL_G%+(%KA_G%-%FL_G%)*mm/1000)*dm/100",^
	       "lb=(%FL_B%+(%KA_B%-%FL_B%)*mm/1000)*dm/100"
	set /a "dr=(%FD_R%+(%KA_R%-%FD_R%)*mm/1000)*dm/100",^
	       "dg=(%FD_G%+(%KA_G%-%FD_G%)*mm/1000)*dm/100",^
	       "db=(%FD_B%+(%KA_B%-%FD_B%)*mm/1000)*dm/100"
	set /a "kk=%CKBASE%+(%%o*%NSHD%+%%s)*2"
	set "CLRK_!kk!=%\e%[48;2;!lr!;!lg!;!lb!m"
	set /a "kk+=1"
	set "CLRK_!kk!=%\e%[48;2;!dr!;!dg!;!db!m"
)

<nul set /p "=%\e%[?25l%\e%[2J"
goto :eof



:Set_Font FontName FontSize max/nomax dummy
if "%4"=="" (
	for /f "tokens=1,2 delims=x" %%a in ("%~2") do if "%%b"=="" (set /a "FontSize=%~2*65536") else set /a "FontSize=%%a+%%b*65536"
	reg add "HKCU\Console\%~nx0" /v FontSize /t reg_dword /d !FontSize! /f
	reg add "HKCU\Console\%~nx0" /v FaceName /t reg_sz /d "%~1" /f
	reg add "HKCU\Console\%~nx0" /v VirtualTerminalLevel /t reg_dword /d 1 /f
	set "m=" & if /I "%~3"=="max" set "m=/max"
	start "%~nx0" !m! "%ComSpec%" /c "%~f0" _
	exit /b 1
) else ( >nul reg delete "HKCU\Console\%~nx0" /f )
goto :eof
