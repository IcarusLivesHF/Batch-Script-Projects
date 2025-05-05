rem %@fillRect% w h color <rtn> !$fillRect!
set @fillRect=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-3" %%1 in ("^!args^!") do (%\n%
    if "%%~3" neq "" ( set "$fillrect=%\e%[48;5;%%~3m" ) else set "$fillrect=%\e%[48;5;15m"%\n%
    set "$fillRect=^!$fillRect^!^!$s:~0,%%2^!%\e%[0m"%\n%
	set "$fillrect=^!$fillrect: =%\e%[%%1X%\e%[B^!"%\n%
)) else set args=




rem set /a "h=0-3600, s=0-10000, l=0-10000, %@hsl.rgb%" <rtn> !r! !g! !b!
set "HSL(n)=k=(n*100+(h %% 3600)/3) %% 1200, u=k-300, q=900-k, u=q-((q-u)&((u-q)>>31)), u=100-((100-u)&((u-100)>>31)), max=u-((u+100)&((u+100)>>31))"
set "@HSL.RGB=(%HSL(n):n=0%", "r=(l-(s*((10000-l)-(((10000-l)-l)&((l-(10000-l))>>31)))/10000)*max/100)*255/10000","%HSL(n):n=8%", "g=(l-(s*((10000-l)-(((10000-l)-l)&((l-(10000-l))>>31)))/10000)*max/100)*255/10000", "%HSL(n):n=4%", "b=(l-(s*((10000-l)-(((10000-l)-l)&((l-(10000-l))>>31)))/10000)*max/100)*255/10000)"
set "hsl(n)="



set @getTimeCS=for /f "tokens=1-4 delims=:.," %%a in ("^!time: =0^!") do set /a "?=(((1%%a*60)+1%%b)*60+1%%c)*100+1%%d"



set "pointRect=((~(f-b)>>31)&1) & ((~(d-f)>>31)&1) & ((~(e-a)>>31)&1) & ((~(c-e)>>31)&1)"


set "newSnake=(snakeX=(^!random^! %% (wid / scl)) * scl + 1, snakeY=(^!random^! %% (hei / scl)) * scl + 1)"

set "newFood=(foodX=(^!random^! %% (wid / scl)) * scl + 1, foodY=(^!random^! %% (hei / scl)) * scl + 1)"

set "growSnake=(grow=1, total+=1, fadeAmount=255 / (total + 1))"