rem predefine angles for any given ellipse to optimize performance of the macro
REM 64  points : step 981
set "PRE="9999 0" "9952 980" "9808 1950" "9571 2901" "9240 3824" "8821 4711" "8318 5552" "7735 6340" "7075 7067" "6349 7726" "5562 8311" "4721 8815" "3835 9236" "2913 9568" "1962 9806" "992 9950" "12 9999" "-968 9953" "-1938 9810" "-2890 9573" "-3813 9245" "-4700 8827" "-5542 8324" "-6331 7742" "-7059 7084" "-7719 6358" "-8305 5572" "-8810 4732" "-9231 3846" "-9563 2924" "-9803 1973" "-9949 1004" "-9998 24" "-9953 -956" "-9813 -1926" "-9577 -2878" "-9250 -3802" "-8832 -4690" "-8332 -5532" "-7749 -6321" "-7093 -7050" "-6368 -7712" "-5582 -8298" "-4742 -8804" "-3857 -9226" "-2935 -9560" "-1985 -9801" "-1016 -9948" "-36 -9998" "944 -9955" "1915 -9816" "2867 -9580" "3791 -9254" "4679 -8838" "5522 -8338" "6312 -7757" "7042 -7101" "7703 -6377" "8291 -5592" "8798 -4753" "9221 -3868" "9557 -2947" "9799 -1997" "9946 -1028" "9999 -48" "












:_point
rem %@point% y;x 2/5;0-255;0-255;0-255
set @point=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-2" %%1 in ("^!args^!") do (%\n%
	set "$point=^!$point^!%\e%[48;%%2m%\e%[%%1H %\e%[0m"%\n%
)) else set args=







:_ellipse
rem %@ellipse% x y ch cw color <rtn> $ellipse
set @ellipse=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
	if "%%~5" equ "" ( set "$ellipse=%\e%[48;5;15m" ) else ( set "$ellipse=%\e%[48;5;%%~5m" )%\n%
	for %%x in (%pre%) do for /f "tokens=1,2" %%x in ("%%~x") do (%\n%
		set /a "xa=%%~3 * %%~x/10000 + %%~1", "ya=%%~4 * %%~y/10000 + %%~2"%\n%
		set "$ellipse=^!$ellipse^!%\e%[^!ya^!;^!xa^!H "%\n%
	)%\n%
	set "$ellipse=^!$ellipse^!%\e%[0m"%\n%
)) else set args=

:_circle
rem %@circle% cx cy cr COLOR <rtn> !$circle!
set @circle=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	if "%%~4" equ "" ( set "$circle=%\e%[48;5;15m" ) else ( set "$circle=%\e%[48;5;%%~4m" )%\n%
	set /a "$d=3 - 2 * %%~3, x=0, y=%%~3"%\n%
	^!While^! (%\n%
		set /a "a=%%~1 + x, b=%%~2 + y, c=%%~1 - x, d=%%~2 - y, e=%%~1 - y, f=%%~1 + y, g=%%~2 + x, h=%%~2 - x"%\n%
		set "$circle=^!$circle^!%\e%[^!b^!;^!a^!H %\e%[^!b^!;^!c^!H %\e%[^!d^!;^!a^!H %\e%[^!d^!;^!c^!H %\e%[^!g^!;^!f^!H %\e%[^!g^!;^!e^!H %\e%[^!h^!;^!f^!H %\e%[^!h^!;^!e^!H "%\n%
		if ^^!$d^^! leq 0 ( set /a "$d=$d + 4 * x + 6"%\n%
		) else set /a "y-=1", "$d=$d + 4 * (x - y) + 10"%\n%
		if ^^!x^^! GEQ ^^!y^^! ^!End.while^!%\n%
		set /a "x+=1"%\n%
	)%\n%
	set "$circle=^!$circle^!%\e%[0m"%\n%
)) else set args=

:_fillCircle
rem %@fillCircle% radius color <rtn> !$fillCircle!
set @fillCircle=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1,2" %%1 in ("^!args^!") do (%\n%
	if "%%~2" neq "" ( set "$fillCircle=%\e%[48;5;%%~2m" ) else ( set "$fillCircle=%\e%[48;5;15m" )%\n%
	set /a "$rr=%%~1 * %%~1", "hr=%%~1 - 1"%\n%
	for /l %%y in (-%%~1,1,%%~1) do (%\n%
		set "$sx=0"%\n%
		for /l %%x in (-%%~1,1,%%~1) do (%\n%
			set /a "$xxyy=%%x*%%x+%%y*%%y"%\n%
			if ^^!$xxyy^^! lss ^^!$rr^^! set /a "$sx+=1"%\n%
		)%\n%
		if ^^!$sx^^! gtr 0 (%\n%
			set /a "shift=lx / 2 - $sx / 2"%\n%
			if ^^!shift^^! leq -1 (%\n%
				set "shift=%\e%[^!shift:-=^!D"%\n%
				set "shift=^!shift:1=^!"%\n%
			) else if ^^!shift^^! geq 1 (%\n%
				set "shift=%\e%[^!shift^!C"%\n%
				set "shift=^!shift:1=^!"%\n%
			) else (%\n%
				set "shift="%\n%
			)%\n%
			set "$fillCircle=^!$fillCircle^!^!shift^!%\e%7%\e%[^!$sx^!X%\e%8%\e%[B"%\n%
			set /a "lx=$sx"%\n%
		)%\n%
	)%\n%
	set "$fillCircle=%\e%[^!hr^!A^!$fillCircle^!%\e%8%\e%[0m"%\n%
)) else set args=







:_rect
rem %@rect% x y w h <rtn> !$rect!
set @rect=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	set /a "$w=%%~3-2", "$h=%%~4-2"%\n%
	for /f "tokens=1,2" %%A in ("^!$w^! ^!$h^!") do (%\n%
		set "$rect=^!$q:~0,%%~B^!"%\n%
		set "$rect=%\e%[%%~2;%%~1H%\e%(0%\e%7l^!$q:~0,%%~A^!k%\e%8%\e%[B^!$rect:q=%\e%7x%\e%[%%~ACx%\e%8%\e%[B^!m^!$q:~0,%%~A^!j%\e%(B%\e%[0m"%\n%
	)%\n%
	set "$w=" ^& set "$h="%\n%
)) else set args=

:_fillRect
rem %@fillRect% x y w h color <rtn> !$fillRect!
set @fillRect=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-5" %%1 in ("^!args^!") do (%\n%
    if "%%~5" neq "" ( set "$fillrect=%\e%[48;5;%%~5m" ) else set "$fillrect=%\e%[48;5;15m"%\n%
    set "$fillRect=^!$fillRect^!^!$s:~0,%%4^!%\e%[0m"%\n%
	set "$fillrect=%\e%[%%~2;%%~1H^!$fillrect: =%\e%[%%3X%\e%[B^!"%\n%
)) else set args=

:_roundRect
rem %@roundrect% x y w h r color <rtn> !$roundrect!
set @roundrect=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-6" %%1 in ("^!args^!") do (%\n%
    if "%%~6" neq "" ( set "$roundrect=%\e%[48;5;%%~6m" ) else set "$roundrect=%\e%[48;5;15m"%\n%
    set /a "$s1=%%~1 + %%~5",^
	       "$t1=%%~1 + %%~3 - %%~5",^
		   "$s2=%%~2 + %%~5",^
		   "$t2=%%~2 + %%~4 - %%~5",^
		   "$e=%%~5 * %%~5",^
		   "$s1t1=(%%~1 + %%~3 - %%~5) - (%%~1 + %%~5)"%\n%
    set "$roundrect=^!$roundrect^!%\e%[%%~2;^!$s1^!H%\e%[^!$s1t1^!X%\e%[%%~4B%\e%[^!$s1t1^!X"%\n%
    for /l %%i in (^^!$s2^^!,1,^^!$t2^^!) do set "$roundrect=^!$roundrect^!%\e%[%%~i;%%~1H %\e%[%%~3C "%\n%
    for /l %%i in (1,1,%%~5) do (%\n%
		set /a "$i=%%i-1, dy=($e - $i*$i)/%%~5, $x1=$s1 - %%i,$y1=$s2 - dy,$x2=$t1 + %%i,$y2=$t2 + dy"%\n%
		set "$roundrect=^!$roundrect^!%\e%[^!$y1^!;^!$x1^!H %\e%[^!$y1^!;^!$x2^!H %\e%[^!$y2^!;^!$x1^!H %\e%[^!$y2^!;^!$x2^!H "%\n%
    )%\n%
    set "$roundrect=^!$roundrect^!%\e%[0m"%\n%
)) else set args=








:_triangle
rem %@triangle% x1 y1 x2 y2 x3 y3 color <rtn> !$triangle!
set @triangle=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-8" %%1 in ("^!args^!") do (%\n%
	set /a "$x1=%%~1, $y1=%%~2, $x2=%%~3, $y2=%%~4, $x3=%%~5, $y3=%%~6"%\n%
	if ^^!$y1^^! gtr ^^!$y2^^! ( set /a "$x1^^=$x2, $x2^^=$x1, $x1^^=$x2, $y1^^=$y2, $y2^^=$y1, $y1^^=$y2" )%\n%
	if ^^!$y1^^! gtr ^^!$y3^^! ( set /a "$x1^^=$x3, $x3^^=$x1, $x1^^=$x3, $y1^^=$y3, $y3^^=$y1, $y1^^=$y3" )%\n%
	if ^^!$y2^^! gtr ^^!$y3^^! ( set /a "$x2^^=$x3, $x3^^=$x2, $x2^^=$x3, $y2^^=$y3, $y3^^=$y2, $y2^^=$y3" )%\n%
	set /a "$d1=($x2 - $x1), $d2=($x3 - $x1), $d3=($x3 - $x2)"%\n%
	set "$triangle=%\e%[48;5;%%~7m"%\n%
	for /L %%y in (^^!$y1^^!,1,^^!$y3^^!) do ( %\n%
		if %%y lss ^^!$y2^^! ( %\n%
			if ^^!$y1^^! equ ^^!$y2^^! (set /a "$xs=$x1") else set /a "$xs=$x1+(%%y-$y1)*$d1 / ($y2 - $y1)"%\n%
			if ^^!$y1^^! equ ^^!$y3^^! (set /a "$xe=$x1") else set /a "$xe=$x1+(%%y-$y1)*$d2 / ($y3 - $y1)"%\n%
		) else ( %\n%
			if ^^!$y2^^! equ ^^!$y3^^! (set /a "$xs=$x2") else set /a "$xs=$x2+(%%y-$y2)*$d3 / ($y3 - $y2)"%\n%
			if ^^!$y1^^! equ ^^!$y3^^! (set /a "$xe=$x1") else set /a "$xe=$x1+(%%y-$y1)*$d2 / ($y3 - $y1)"%\n%
		)%\n%
		if ^^!$xs^^! gtr ^^!$xe^^! (	set /a "$dx=$xs-$xe+1"%\n%
					if ^^!$xe^^! lss 1 set /a "$dx=$dx-(-$xe+1), $xe=1"%\n%
					set "$triangle=^!$triangle^!%\e%[%%y;^!$xe^!H%\e%[^!$dx^!X"%\n%
			) else (%\n%
					set /a "$dx=$xe-$xs+1"%\n%
					if ^^!$xs^^! lss 1 set /a "$dx=$dx-(-$xs+1), $xs=1"%\n%
					set "$triangle=^!$triangle^!%\e%[%%y;^!$xs^!H%\e%[^!$dx^!X"%\n%
		)%\n%
	)%\n%
	if "%%~8" neq "" set "$triStrip=^!$triStrip^!^!$triangle^!"%\n%
)) else set args=