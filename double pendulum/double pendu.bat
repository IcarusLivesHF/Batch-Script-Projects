@echo off & setlocal enableDelayedExpansion
call :Set_Font "consolas" 6 nomax %1 || exit

call :init

set /a "gravity=980"
set /a "m1=10, m2=10"
set /a "L1=100, L2=100"
set /a "damping=1"

set /a "angle1=PI*3/4, angle2=PI*3/4, angleV1=0, angleV2=0"

set /a "rod1=40, rod2=40, bobRows=3, cirN=14, cirN1=cirN-1"
set /a "originX=wid/2, originY=rod1+rod2+bobRows+2"
set /a "rodHue=8, bob1Hue=51, bob2Hue=226, pivHue=15"

set /a "trailN=40, trailN1=trailN-1, trI=0"

set /a "stepUnits=16, maxSteps=4"

set /a "vCap=150000"

set /a "tickCap=25, tickCapU=tickCap*16, debtCap=tickCapU*4"
set /a "tick16=16, avgHi=512, debt=0"
set /a "totalTicks=0, totalTime=0, frameCount=0, frameNo=0"

for /l %%i in (0,1,%cirN1%) do (
	set /a "t=%%i*TAU/cirN"
	set /a "cx_%%i=bobRows*!cos:x=t!/10000, cy_%%i=bobRows*!sin:x=t!/10000"
)

set /a "s1=!sin:x=angle1!"
set /a "c1=!cos:x=angle1!"
set /a "s2=!sin:x=angle2!"
set /a "c2=!cos:x=angle2!"
set /a "b1c=originX + 2*rod1*s1/10000, b1r=originY + rod1*c1/10000"
set /a "b2c=b1c + 2*rod2*s2/10000, b2r=b1r + rod2*c2/10000"
for /l %%k in (0,1,%trailN1%) do set /a "trC_%%k=b2c, trR_%%k=b2r"

echo=%\e%[?25l%\e%[2J

set "clock=!time: =0!"
set /a "t1=(((1!clock:~0,2!-100)*60+(1!clock:~3,2!-100))*60+(1!clock:~6,2!-100))*100+(1!clock:~9,2!-100)"

for /l %%L in () do (
    set "clock=!time: =0!"
    set /a "t2=(((1!clock:~0,2!-100)*60+(1!clock:~3,2!-100))*60+(1!clock:~6,2!-100))*100+(1!clock:~9,2!-100)",^
           "frameCS=t2-t1, frameCS+=(frameCS>>31&1)*8640000, t1=t2",^
           "frameCount+=1"

    if !frameCS! gtr 0 (
        if !totalTicks! gtr 500 set /a "frameCount/=2, totalTicks/=2"
        if !frameCount! gtr 100000 set /a "frameCount/=2, totalTicks/=2"

        set /a "totalTicks+=frameCS",^
               "totalTime=(totalTime+frameCS) %% ((1<<31)-1)",^
               "titleTick=frameNo%%12, frameNo+=1",^
               "sample=frameCS*16",^
               "sample-=((tickCapU-sample)>>31&1)*(sample-tickCapU)",^
               "sampleHi=sample*32",^
               "den=32-24*(1-((sampleHi-avgHi)>>31&1))",^
               "avgHi=(avgHi*(den-1)+sampleHi+den/2)/den",^
               "tick16=avgHi/32",^
               "debt+=sample-tick16",^
               "debt-=((debtCap-debt)>>31&1)*(debt-debtCap)",^
               "debt+=((debt+debtCap)>>31&1)*(-debtCap-debt)",^
               "pay=debt/8, tick16+=pay, debt-=pay",^
               "tick16-=((tickCapU-tick16)>>31&1)*(tick16-tickCapU)",^
               "tick16+=((tick16-1)>>31&1)*(1-tick16)"

        if !titleTick! equ 0 (
            set /a "cec=totalTime%%100, sec=totalTime/100%%60",^
                   "min=totalTime/6000%%60, hr=totalTime/360000",^
                   "lps=(frameCount*10000+totalTicks/2)/totalTicks",^
                   "fps=160000/tick16",^
                   "lpsi=lps/100, lpsf=lps%%100, fpsi=fps/100, fpsf=fps%%100"
            for %%i in (cec sec min lpsf fpsf) do (set "%%i=0!%%i!" & set "%%i=!%%i:~-2!")
            title FPS !fpsi!.!fpsf!    LPS !lpsi!.!lpsf!    !hr!:!min!:!sec!.!cec!    steps !steps!    tick16 !tick16!
        )

        rem ------------------------------------------------------- physics
        set /a "steps=(tick16+stepUnits-1)/stepUnits"
        if !steps! gtr %maxSteps% set /a "steps=maxSteps"
        set /a "dt=tick16/steps, dt+=((dt-1)>>31&1)*(1-dt)"

        for /l %%s in (1,1,!steps!) do (
            set /a "d=angle1-angle2, dd=2*d, d12=angle1-2*angle2"
            set /a "s1=!sin:x=angle1!"
            set /a "c1=!cos:x=angle1!"
            set /a "sd=!sin:x=d!"
            set /a "cd=!cos:x=d!"
            set /a "cdd=!cos:x=dd!"
            set /a "s12=!sin:x=d12!"

            set /a "w1=angleV1/100, w2=angleV2/100, w1sq=w1*w1, w2sq=w2*w2"

            set /a "den0=(2*m1+m2)*10000 - m2*cdd",^
                   "den1=L1*den0/10000, den2=L2*den0/10000"

            set /a "in1=w2sq*L2 + (w1sq*L1/10000)*cd",^
                   "n1=-( (2*m1+m2)*gravity*(s1/10) + m2*gravity*(s12/10) + 2*m2*(in1/10000)*(sd/10) )",^
                   "alpha1=n1/den1"

            set /a "sum2=(m1+m2)*L1*(w1sq/100)/100 + (m1+m2)*gravity*c1/10000 + m2*L2*(w2sq/100)/100*(cd/100)/100",^
                   "n2=2*sum2*(sd/10)",^
                   "alpha2=n2/den2"

            set /a "angleV1+=alpha1*dt/160, angleV2+=alpha2*dt/160",^
                   "angleV1-=angleV1*damping*dt/160000, angleV2-=angleV2*damping*dt/160000",^
                   "angleV1-=((vCap-angleV1)>>31&1)*(angleV1-vCap), angleV1+=((angleV1+vCap)>>31&1)*(-vCap-angleV1)",^
                   "angleV2-=((vCap-angleV2)>>31&1)*(angleV2-vCap), angleV2+=((angleV2+vCap)>>31&1)*(-vCap-angleV2)",^
                   "angle1+=angleV1*dt/1600, angle2+=angleV2*dt/1600",^
                   "angle1%%=TAU, angle2%%=TAU"
        )

        set /a "s1=!sin:x=angle1!"
        set /a "c1=!cos:x=angle1!"
        set /a "s2=!sin:x=angle2!"
        set /a "c2=!cos:x=angle2!"
        set /a "b1c=originX + rod1*s1/10000, b1r=originY + rod1*c1/10000",^
               "b2c=b1c + rod2*s2/10000, b2r=b1r + rod2*c2/10000"

        set /a "trI=(trI+1)%%trailN"
        set /a "trC_!trI!=b2c, trR_!trI!=b2r"

        set "scrn="
        for /l %%k in (0,1,%trailN1%) do (
            set /a "age=(trI-%%k+trailN)%%trailN, hue=226-6*(5*age/trailN1)",^
                   "tc=trC_%%k, tr=trR_%%k",^
                   "tc-=((wid-tc)>>31&1)*(tc-wid), tc+=((tc-1)>>31&1)*(1-tc)",^
                   "tr-=((hei-tr)>>31&1)*(tr-hei), tr+=((tr-1)>>31&1)*(1-tr)"
            set "scrn=!scrn!%\e%[48;5;!hue!m%\e%[!tr!;!tc!H "
        )

        %@line% !originX! !originY! !b1c! !b1r! !rodHue!
        set "scrn=!scrn!!$line!"
        %@line% !b1c! !b1r! !b2c! !b2r! !rodHue!
        set "scrn=!scrn!!$line!"

        for %%b in (1 2) do (
            if %%b equ 1 ( set /a "bc=b1c, br=b1r" & set "bh=!bob1Hue!" ) else ( set /a "bc=b2c, br=b2r" & set "bh=!bob2Hue!" )
            set "scrn=!scrn!%\e%[48;5;!bh!m"
            for /l %%i in (0,1,%cirN1%) do (
                set /a "cc=bc+cx_%%i, cr=br+cy_%%i",^
                       "cc-=((wid-cc)>>31&1)*(cc-wid), cc+=((cc-1)>>31&1)*(1-cc)",^
                       "cr-=((hei-cr)>>31&1)*(cr-hei), cr+=((cr-1)>>31&1)*(1-cr)"
                set "scrn=!scrn!%\e%[!cr!;!cc!H "
            )
        )

        set "scrn=!scrn!%\e%[48;5;!pivHue!m%\e%[!originY!;!originX!H "
        echo=%\e%[2J%\e%[H!scrn!%\e%[0m%\e%[H
        set "scrn="
    )
)

rem ==========================================================================
:init
set /a "wid=width=200, hei=height=200"
mode con: cols=%wid% lines=%hei%

for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set /a "PI=(35500000/113+5)/10, HALF_PI=(35500000/113/2+5)/10, TAU=TWO_PI=2*PI, PI32=PI+HALF_PI"
set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "sin=(a=(x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!)"
set "cos=(a=(15708 - x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!)"

(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)

:_line
set @line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^! 15") do (%\n%
	set /a "xa=%%~1, ya=%%~2, xb=%%~3, yb=%%~4"%\n%
	set /a "xa-=((wid-xa)>>31&1)*(xa-wid), xa+=((xa-1)>>31&1)*(1-xa)"%\n%
	set /a "xb-=((wid-xb)>>31&1)*(xb-wid), xb+=((xb-1)>>31&1)*(1-xb)"%\n%
	set /a "ya-=((hei-ya)>>31&1)*(ya-hei), ya+=((ya-1)>>31&1)*(1-ya)"%\n%
	set /a "yb-=((hei-yb)>>31&1)*(yb-hei), yb+=((yb-1)>>31&1)*(1-yb)"%\n%
	set "$line=%\e%[48;5;%%~5m"%\n%
	set /a "dx=xb-xa, dy=yb-ya"%\n%
	if ^^!dy^^! lss 0 ( set /a "dy=-dy", "stepy=-1" ) else ( set "stepy=1" )%\n%
	if ^^!dx^^! lss 0 ( set /a "dx=-dx", "stepx=-1" ) else ( set "stepx=1" )%\n%
	set /a "dx<<=1, dy<<=1"%\n%
	if ^^!dx^^! gtr ^^!dy^^! (%\n%
		set /a "fraction=dy - (dx >> 1)"%\n%
		for /l %%x in (^^!xa^^!,^^!stepx^^!,^^!xb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "ya+=stepy", "fraction-=dx"%\n%
			set /a "fraction+=dy"%\n%
			set "$line=^!$line^!%\e%[^!ya^!;%%xH "%\n%
		)%\n%
	) else (%\n%
		set /a "fraction=dx - (dy >> 1)"%\n%
		for /l %%y in (^^!ya^^!,^^!stepy^^!,^^!yb^^!) do (%\n%
			if ^^!fraction^^! geq 0 set /a "xa+=stepx", "fraction-=dy"%\n%
			set /a "fraction+=dx"%\n%
			set "$line=^!$line^!%\e%[%%y;^!xa^!H "%\n%
		)%\n%
	)%\n%
	set "$line=^!$line^!%\e%[0m"%\n%
)) else set args=
goto :eof

:Set_Font FontName FontSize max/nomax dummy
if "%4"=="" (
	for /f "tokens=1,2 delims=x" %%a in ("%~2") do (
		if "%%b"=="" (set /a "FontSize=%~2*65536"
		) else        set /a "FontSize=%%a+%%b*65536")
	reg add "HKCU\Console\%~nx0" /v FontSize /t reg_dword /d !FontSize! /f
	reg add "HKCU\Console\%~nx0" /v FaceName /t reg_sz /d "%~1" /f
	set "m=" & if /I "%~3"=="max" set "m=/max"
	set "_conhost="
	if exist "%SystemRoot%\System32\conhost.exe" set "_conhost=%SystemRoot%\System32\conhost.exe"
	if defined _conhost (
		start "%~nx0" !m! "!_conhost!" "%ComSpec%" /c "%~f0" _
	) else start "%~nx0" !m! "%ComSpec%" /c "%~f0" _
	exit /b 1
) else ( >nul reg delete "HKCU\Console\%~nx0" /f )
goto:eof