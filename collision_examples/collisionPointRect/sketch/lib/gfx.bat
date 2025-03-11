rem get \e
for /f %%a in ('echo prompt $E^| cmd') do set "\e=%%a"

rem get \n
(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)
rem define @32bitlimit if we wasn't already
set "@32bitlimit=0x7FFFFFFF"

rem define a few buffers
for /l %%i in (0,1,5) do set "barBuffer=!barBuffer!!barBuffer! " & set "qBuffer=!qBuffer!!qBuffer!q"

rem defined sin/cos (RADIANS)
set /a "PI=(35500000/113+5)/10, HALF_PI=(35500000/113/2+5)/10, TAU=TWO_PI=2*PI, PI32=PI+HALF_PI"
set "_SIN=a-a*a/1920*a/312500+a*a/1920*a/15625*a/15625*a/2560000-a*a/1875*a/15360*a/15625*a/15625*a/16000*a/44800000"
set "si=(a=(x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!)"
set "co=(a=(15708 - x)%%62832, c=(a>>31|1)*a, a-=(((c-47125)>>31)+1)*((a>>31|1)*62832)  +  (-((c-47125)>>31))*( (((c-15709)>>31)+1)*(-(a>>31|1)*31416+2*a)  ), !_SIN!)"
set "_sin="

rem predefine angles for any given ellipse/circle to optimize performance of the macro = 32 points : step 1963
for /l %%i in (0,1963,%tau%) do (
	set /a "ci=!co:x=%%i!, so=!si:x=%%i!"
	set "PRE=!PRE!"!ci! !so!" "	
)

rem if hei/wid not defined, get dimensions now.
for /f "skip=2 tokens=2" %%a in ('mode') do if not defined hei (set /a "hei=height=%%a") else if not defined wid set /a "wid=width=%%a"


:_plot
rem %@plot% y;x 2/5;0-255;0-255;0-255
set @plot=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-2" %%1 in ("^!args^!") do (%\n%
	set "$plot=^!$plot^!%\e%[48;%%2m%\e%[%%1H %\e%[0m"%\n%
)) else set args=

:_ellipse
rem %@ellipse% x y ch cw <rtn> $ellipse
set @ellipse=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set "$ellipse=%\e%[48;5;15m"%\n%
	for %%x in (%pre%) do for /f "tokens=1,2" %%x in ("%%~x") do (%\n%
		set /a "xa=%%~3 * %%~x/10000 + %%~1", "ya=%%~4 * %%~y/10000 + %%~2"%\n%
		set "$ellipse=^!$ellipse^!%\e%[^!ya^!;^!xa^!H "%\n%
	)%\n%
	set "$ellipse=^!$ellipse^!%\e%[0m"%\n%
)) else set args=

:_circle
rem %@circle% x y r <rtn> $circle
set @circle=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-3" %%1 in ("^!args^!") do (%\n%
	set "$circle=%\e%[48;5;15m"%\n%
	for %%x in (%pre%) do for /f "tokens=1,2" %%x in ("%%~x") do (%\n%
		set /a "xa=%%~3 * %%~x/10000 + %%~1", "ya=%%~3 * %%~y/10000 + %%~2"%\n%
		set "$circle=^!$circle^!%\e%[^!ya^!;^!xa^!H "%\n%
	)%\n%
	set "$circle=^!$circle^!%\e%[0m"%\n%
)) else set args=

:_rect
rem %@rect% x y w h <rtn> $rect
set @rect=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set "$rect=%\e%[%%~2;%%~1H%\e%(0%\e%7l^!qBuffer:~0,%%~3^!k%\e%8%\e%[B"%\n%
	for /l %%i in (1,1,%%~4) do set "$rect=^!$rect^!%\e%7x%\e%[%%~3Cx%\e%8%\e%[B"%\n%
	set "$rect=^!$rect^!m^!qBuffer:~0,%%~3^!j%\e%(B%\e%[0m"%\n%
)) else set args=

:_line
rem %@line% x0 y0 x1 y1 color <rtn> $line
set @line=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	if "%%~5" equ "" ( set "hue=15" ) else ( set "hue=%%~5")%\n%
	set "$line=%\e%[48;5;^!hue^!m"%\n%
	set /a "xa=%%~1", "ya=%%~2", "xb=%%~3", "yb=%%~4", "dx=%%~3 - %%~1", "dy=%%~4 - %%~2"%\n%
	if ^^!dy^^! lss 0 ( set /a "dy=-dy", "stepy=-1" ) else ( set "stepy=1" )%\n%
	if ^^!dx^^! lss 0 ( set /a "dx=-dx", "stepx=-1" ) else ( set "stepx=1" )%\n%
	set /a "dx<<=1", "dy<<=1"%\n%
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

:_bezier
rem %@bezier% x1 y1 x2 y2 x3 y3 x4 y4 color <rtn> $bezier
set @bezier=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-9" %%1 in ("^!args^!") do (%\n%
	if "%%~9" equ "" ( set "hue=15" ) else ( set "hue=%%~9")%\n%
    set "$bezier=%\e%[48;5;^!hue^!m"%\n%
    for /l %%. in (1,1,50) do (%\n%
        set /a "_=%%.<<1,N=((%%~1+_*(%%~3-%%~1)*10)/1000+%%~1),O=((%%~3+_*(%%~5-%%~3)*10)/1000+%%~3),P=((%%~2+_*(%%~4-%%~2)*10)/1000+%%~2),Q=((N+_*(O-N)*10)/1000+N),S=((%%~4+_*(%%~6-%%~4)*10)/1000+%%~4),T=((P+_*(S-P)*10)/1000+P),vx=(Q+_*(((O+_*(((%%~5+_*(%%~7-%%~5)*10)/1000+%%~5)-O)*10)/1000+O)-Q)*10)/1000+Q,vy=(T+_*(((S+_*(((%%~6+_*(%%~8-%%~6)*10)/1000+%%~6)-S)*10)/1000+S)-T)*10)/1000+T"%\n%
        set "$bezier=^!$bezier^!%\e%[^!vy^!;^!vx^!H "%\n%
    )%\n%
	set "$bezier=^!$bezier^!%\e%[0m"%\n%
)) else set args=

:_arc
rem %@arc% x y size DEGREES(0-360) arcRotationDegrees(0-360) lineThinness color
set @arc=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-7" %%1 in ("^!args^!") do (%\n%
	set "$arc=%\e%[48;5;15m"%\n%
    for /l %%e in (%%~4,%%~6,%%~5) do (%\n%
		set /a "_x=%%~3 * ^!co:x=%%e^!/10000 + %%~1", "_y=%%~3 * ^!si:x=%%e^!/10000 + %%~2"%\n%
		set "$arc=^!$arc^!%\e%[^!_y^!;^!_x^!H "%\n%
	)%\n%
	set "$arc=^!$arc^!%\e%[0m"%\n%
)) else set args=

:_bar
rem %@bar% currentValue maxValue MaxlengthOfBar vtColorScheme(2 or 5) colorCode colorCode colorCode
set @Bar=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-7" %%1 in ("^!args^!") do (%\n%
	set /a "barVal=%%~3*%%~1/%%~2", "onethird=%%~2 / 3", "twoThird=onethird * 2"%\n%
	if %%~1 lss ^^!onethird^^! (%\n%
		set "hue=%%~5"%\n%
	) else if %%~1 gtr ^^!oneThird^^! if %%~1 lss ^^!twoThird^^! (%\n%
		set "hue=%%~6"%\n%
	) else if %%~1 gtr ^^!twoThird^^! (%\n%
		set "hue=%%~7"%\n%
	)%\n%
	for /f "tokens=1,2" %%i in ("^!barVal^! ^!hue^!") do (%\n%
		set "$bar=%\e%[48;%%~4;%%~jm^!barBuffer:~0,%%~i^!%\e%[0m"%\n%
	)%\n%
)) else set args=

:_sevenSegmentDisplay
rem %@sevenSegmentDisplay% x y value color <rtn> $sevenSegmentDisplay
set /a "segbool[0]=0x7E", "segbool[1]=0x30", "segbool[2]=0x6D", "segbool[3]=0x79", "segbool[4]=0x33", "segbool[5]=0x5B", "segbool[6]=0x5F", "segbool[7]=0x70", "segbool[8]=0x7F", "segbool[9]=0x7B"
set @sevenSegmentDisplay=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set "$sevenSegmentDisplay="%\n%
	set /a "qx1=%%~1", "qx2=%%~1 + 1", "qx3=%%~1 + 2", "qx4=%%~1 - 1", "qy1=%%~2", "qy2=%%~2 + 1", "qy3=%%~2 + 2", "qy4=%%~2 + 3", "qy5=%%~2 + 4", "qy6=%%~2 + 5", "qy7=%%~2 + 6"%\n%
	for %%j in ( "6 1 1 2 1" "5 3 2 3 3" "4 3 5 3 6" "3 1 7 2 7" "2 4 5 4 6" "1 4 2 4 3" "0 1 4 2 4" ) do (%\n%
		for /f "tokens=1-5" %%v in ("%%~j") do (%\n%
			set /a "a=%%~4 * ((segbool[%%~3] >> %%~v) & 1)"%\n%
			set "$sevenSegmentDisplay=^!$sevenSegmentDisplay^!%\e%[48;5;^!a^!m%\e%[^!qy%%x^!;^!qx%%w^!H %\e%[^!qy%%z^!;^!qx%%y^!H "%\n%
		)%\n%
	)%\n%
)) else set args=

:_msgBox
rem %@msgBox% ;title;text;x;y;textColor;boxColor;boxLength
set @msgBox=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-7 delims=;" %%1 in ("^!args:~1^!") do (%\n%
	if "%%~5" neq "" ( set "t.color=%%~5" ) else ( set "t.color=15" )%\n%
	if "%%~6" neq "" ( set "box.color=%%~6" ) else ( set "box.color=15" )%\n%
	if "%%~7" neq "" ( set "msgBox.length=%%~7" ) else ( set "msgBox.length=60" )%\n%
	set "str=X%%~2"%\n%
	set "str=^!str:?=^!" ^& set "length=0" ^& for /l %%b in (10,-1,0) do set /a "length|=1<<%%b" ^& for %%c in (^^!length^^!) do if "^!str:~%%c,1^!" equ "" set /a "length&=~1<<%%b"%\n%
	set /a "msgBox.height=length / msgBox.length + 4", "msgBox.width=msgBox.length - 2"%\n%
	for /f "tokens=1-3" %%a in ("^!msgBox.width^! ^!msgBox.length^! ^!msgBox.height^!") do (%\n%
		set "$msgBox=%\e%[38;5;^!box.color^!m%\e%[%%~4;%%~3HÚ%\e%(0^!qBuffer:~0,%%~a^!%\e%(B¿%\e%[%%~bD%\e%[B³%\e%[%%~aC³%\e%[%%~bD%\e%[BÃ%\e%(0^!qBuffer:~0,%%~a^!%\e%(B´%\e%[%%~bD%\e%[B"%\n%
		for /l %%i in (0,1,%%~c) do set "$msgBox=^!$msgBox^!³%\e%[%%~aC³%\e%[%%~bD%\e%[B"%\n%
		set "$msgBox=^!$msgBox^!À%\e%(0^!qBuffer:~0,%%~a^!%\e%(BÙ%\e%[0m"%\n%
	)%\n%
	set "str=^!str:=?^!"%\n%
	set /a "textx=%%~3 + 2", "texty=%%~4 + 1", "msgBox.width-=2"%\n%
	set "$msgBox=^!$msgBox^!%\e%[38;5;^!t.color^!m%\e%[^!texty^!;^!textx^!H%%~1%\e%[^!texty^!;^!textx^!H%\e%[3B"%\n%
	for /f "tokens=1,2" %%a in ("^!msgBox.width^! ^!msgBox.length^!") do (%\n%
		for /l %%i in (1,%%~a,^^!length^^!) do (%\n%
			set "$msgBox=^!$msgBox^!^!str:~%%~i,%%~a^!%\e%[%%~aD%\e%[B"%\n%
		)%\n%
	)%\n%
	set "$msgBox=^!$msgBox^!%\e%[0m%\e%[E"%\n%
	for %%i in (textx texty str box.color msgbox.height msgbox.width msgbox.length) do set "%%i="%\n%
)) else set args=