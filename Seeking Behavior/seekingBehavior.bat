@echo off & setlocal enableDelayedExpansion

call :init

set /a "target.x=wid / 2","target.y=hei / 2"
set /a "seeker.x=wid / 2","seeker.y=hei / 2", "speed=3", "maxSpeed=6"


for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t1=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100"
for /l %%# in () do (

	for /f "tokens=1-4 delims=:.," %%a in ("!time: =0!") do set /a "t2=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d-36610100, dt=t2-t1"
	
	if !dt! gtr 5 (

		set /a "t1=t2", "frames+=1"
		set /a "sx=seeker.x, tx=target.x, sy=seeker.y, ty=target.y",^
		       "force.x=((((tx - sx)>>31|1)*(tx - sx)) / (tx - sx)) * speed",^
			   "force.y=((((ty - sy)>>31|1)*(ty - sy)) / (ty - sy)) * speed"
		set /a "acceleration.x+=force.x", "acceleration.y+=force.y"
		set /a "velocity.x+=acceleration.x", "velocity.y+=acceleration.y",^
		       "acceleration.x=0", "acceleration.y=0",^
		       "1/(frames %% 50)" || ( set /a "target.x=!random! %% wid", "target.y=!random! %% hei" )
		
		if !velocity.x! gtr %maxSpeed% set /a "velocity.x=maxSpeed"
		if !velocity.y! gtr %maxSpeed% set /a "velocity.y=maxSpeed"

		set /a "seeker.x+=velocity.x", "seeker.y+=velocity.y"
		
		set "scrn=!scrn!%\e%[!target.y!;!target.x!HX"
		if !seeker.x! geq 1 if !seeker.x! leq %wid% (
			if !seeker.y! geq 1 if !seeker.y! leq %hei% (
				set "scrn=!scrn!%\e%[!seeker.y!;!seeker.x!H@"
			)
		)
		
		echo %\e%[2J%\e%[H!scrn!
		set "scrn="
	)
)2>nul

:init
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

set /a "wid=115,hei=100", "frames=40"
mode %wid%,%hei%
goto :eof