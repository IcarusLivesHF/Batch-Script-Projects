set "degreesMode=0"
if /i "%~1" equ ""        set /a "degreesMode+=1"
if /i "%~1" equ "degrees" set /a "degreesMode+=1"

if %degreesMode% gtr 0 (
	rem This version of SIN/COS is for DEGREES
	set "sin=(a=((x*31416/180)%%62832)+(((x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) "
	set "cos=(a=((15708-x*31416/180)%%62832)+(((15708-x*31416/180)%%62832)>>31&62832), b=(a-15708^a-47124)>>31,a=(-a&b)+(a&~b)+(31416&b)+(-62832&(47123-a>>31)),a-a*a/1875*a/320000+a*a/1875*a/15625*a/16000*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000) "
) else if /i "%~1" equ "radians" (
	rem This version of SIN/COS is for RADIANS
	set /a "PI=31416, HALF_PI=PI / 2, TAU=TWO_PI=2*PI, PI32=PI+HALF_PI, QUARTER_PI=PI / 4"
	set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
	set "sin=(a=(        x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!)"
	set "cos=(a=(15708 - x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!)"
	set "_sin="
)
set "degreesMode="
set "rotate=^!cos:x=theta^! / 10000 + 1 * ^!sin:x=theta^! / 10000"

set "Atan(x)=( r=x, t=((((r>>31|1)*r)-1077)>>31)+1, y=(r>>31)+1, y=10000000/(y*(r-((r-1)&((r-1)>>31)))+(1-y)*(r-((r+1)&((-1-r)>>31)))), t*(((r>>31|-r>>31&1)*90000-((y*100000+43205*y/2000*y/10000*y/5)/(((1000000000+7649*y/1000*y)+(584*y/50*y/10000*y/10000*y/10/2) )/100000) )*180*100/31416)/10)+(1-t)*((r*1000000+43205*r/100*r/1000*r)/(((1000000000+7649*r/10*r)+(584*r/10*r/100*r/1000*r/10))/100000)*180*100/314159) )"

set "atan2(x,y)=I0=((~-x>>31)&1)&((~x>>31)&1), $atan2=I0*(9000*((y>>31)-((-y)>>31)))+(1-I0)*(^!Atan(x):x=(1000*y)/x^!+18000*(-(x>>31))*(1+2*(y>>31)))"

rem set /a "n=, out=%sqrt%"
set "sqrt=( M=(N),q=M/(11264)+40, q=(M/q+q)>>1, q=(M/q+q)>>1, q=(M/q+q)>>1, q=(M/q+q)>>1, q=(M/q+q)>>1, q+=(M-q*q)>>31 )"

rem set /a "x=, out=%abs%"
set "Abs=(((x)>>31|1)*(x))"

rem set /a "x1=, y1=, x2=, y2=, out=%dist%"
set "dist=( @=x2-x1, $=y2-y1, ?=(((@>>31|1)*@-(($>>31|1)*$))>>31)+1, ?*(2*(@>>31|1)*@-($>>31|1)*$-((@>>31|1)*@-($>>31|1)*$)) + ^^^!?*((@>>31|1)*@-($>>31|1)*$-((@>>31|1)*@-($>>31|1)*$*2)) )"

rem set /a "v=, a=, b=, c=, d=, out=%map%"
set "map=c + (d - c) * (v - a) / (b - a)"

rem set /a "a=, b=, c=, out=%lerp%"
set "lerp=?=(a + c * (b - a) * 10) / 1000 + a"

rem set /a "a=, b=, c=, out=%interpolate%"
set "interpolate=a + (b - a) * c / 100"

rem set /a "low=, high=, value=%clamp:x=value%
set "clamp= (leq=((low-(x))>>31)+1)*low  +  (geq=(((x)-high)>>31)+1)*high  +  ^^^!(leq+geq)*(x) "

rem set /a "out=%randomMagnitude%"
set "randomMagnitude=(^!random^! %% 2 * 2 - 1) * (^!random^! %% 3 + 1)"

REM set /a "x=, n=, %pow%" & %@pow% <rtn> !$pow!
set "$b=x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x*x"
set "pow=$z=n * 2 - 1"
set "@pow=for %%a in (^!$z^!) do set /a $pow=^!$b:~0,%%a^!"
