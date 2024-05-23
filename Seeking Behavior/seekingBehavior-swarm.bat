@echo off & setlocal enableDelayedExpansion

call :init

set /a "target.x=wid / 2","target.y=hei / 2", "target.i=(!random! %% 2 * 2 - 1) * (!random! %% 2 + 1), target.j=(!random! %% 2 * 2 - 1) * (!random! %% 2 + 1)"

set "entities=14"
for /l %%i in (1,1,%entities%) do (
	set /a "seeker[%%i].x=!random! %% wid","seeker[%%i].y=!random! %% hei", "speed[%%i]=!random! %% 2 + 1", "maxSpeed=10"
)

for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100"
for /l %%# in () do (
	
	rem use deltaTime to limit frameRate
	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, dt=t2-t1"
	
	if !dt! gtr 5 (

		set /a "t1=t2", "frames+=1"
		
		rem every 50 frames make target at random position
		REM set /a "1/(frames %% 50)" || ( 
			REM set /a "target.x=(!random! * ((wid - 15) - 15 + 1) / 32768) + 15",^
			       REM "target.y=(!random! * ((hei - 15) - 15 + 1) / 32768) + 15"
		REM )
		
		for /l %%i in (1,1,%entities%) do (
			
			rem seek the target
			set /a "sx=seeker[%%i].x, tx=target.x, sy=seeker[%%i].y, ty=target.y",^
				   "force[%%i].x=((((tx - sx)>>31|1)*(tx - sx)) / (tx - sx)) * speed[%%i]",^
				   "force[%%i].y=((((ty - sy)>>31|1)*(ty - sy)) / (ty - sy)) * speed[%%i]"
				   
			rem increase acceleration by force
			set /a "acceleration[%%i].x+=force[%%i].x", "acceleration[%%i].y+=force[%%i].y"
			
			rem add acceleration to velocity
			set /a "velocity[%%i].x+=acceleration[%%i].x", "velocity[%%i].y+=acceleration[%%i].y"
			
			rem reset acceleration
			set /a "acceleration[%%i].x=0", "acceleration[%%i].y=0"
			
			rem set a max velocity
			if !velocity[%%i].x! gtr %maxSpeed% set /a "velocity[%%i].x=maxSpeed"
			if !velocity[%%i].y! gtr %maxSpeed% set /a "velocity[%%i].y=maxSpeed"
			
			rem add velocity to seeker position
			set /a "seeker[%%i].x+=velocity[%%i].x", "seeker[%%i].y+=velocity[%%i].y"
			
			rem draw seeker on screen if it's within edges
			set "scrn=!scrn!%\e%[38;5;10m%\e%[!target.y!;!target.x!HX"
			if !seeker[%%i].x! geq 1 if !seeker[%%i].x! leq %wid% (
				if !seeker[%%i].y! geq 1 if !seeker[%%i].y! leq %hei% (
					set "scrn=!scrn!%\e%[48;5;7m%\e%[!seeker[%%i].y!;!seeker[%%i].x!H%ball%"
				)
			)
		)

		rem draw screen
		echo %\e%[2J%\e%[H!scrn!
		REM echo %\e%[H!scrn!
		set "scrn="
	)
	REM for /l %%i in (1,5,100000) do rem
)2>nul

:init
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set /a "wid=200,hei=150", "frames=40"
mode %wid%,%hei%

set "ball=[C   [B[4D     [B[5D     [B[5D     [B[4D   [D[2A[0m"

set @bezier=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-8" %%1 in ("^!args^!") do (%\n%
    set "$bezier=%\e%[48;5;15m"%\n%
        set /a "A=%%~1","B=%%~2","C=%%~3","D=%%~4","E=%%~5","F=%%~6","G=%%~7","H=%%~8","I=C-A","J=E-C","K=G-E","L=D-B","M=F-D"%\n%
    for /l %%. in (1,1,50) do (%\n%
        set /a "_=%%.<<1,N=((A+_*I*10)/1000+A),O=((C+_*J*10)/1000+C),P=((B+_*L*10)/1000+B),Q=((N+_*(O-N)*10)/1000+N),S=((D+_*M*10)/1000+D),T=((P+_*(S-P)*10)/1000+P),vx=(Q+_*(((O+_*(((E+_*K*10)/1000+E)-O)*10)/1000+O)-Q)*10)/1000+Q,vy=(T+_*(((S+_*(((F+_*(H-F)*10)/1000+F)-S)*10)/1000+S)-T)*10)/1000+T"%\n%
        set "$bezier=^!$bezier^!%\e%[^!vy^!;^!vx^!H "%\n%
    )%\n%
)) else set args=
goto :eof