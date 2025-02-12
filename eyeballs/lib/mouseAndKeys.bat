
rem substitute ? for R,L:   if %onClick:?=L% ( do code )
set        "onClick="^^!?_click^^!.^^!last_?_click^^!" equ "1.0""
set "onClickRelease="^^!?_click^^!.^^!last_?_click^^!" equ "0.1""


rem use with onClick/onClickRelease
rem usage: set /a "%saveLastClicks%"
set "saveLastClicks=last_l_click=l_click, last_r_click=r_click"


rem bounding box macro with L/R click validation
rem set /a "a=, b=, c=, d=, %clickingInsideBox:?=L or R%" <rtn> !$clickingInsideBox! 0:false or 1:true
set "@clickingInsideBox=$clickingInsideBox=((~(mouseY-b)>>31)&1) & ((~(d-mouseY)>>31)&1) & ((~(mouseX-a)>>31)&1) & ((~(c-mouseX)>>31)&1) & ?_click"


rem determine a key press even if other keys are being held
rem if %asyncKeys:?=27% ( echo You're pressing ESC key )
set "asyncKeys=NOT "^^!keysPressed^^!" == "^^!keysPressed:-?-=^^!""


rem experimental
:_clickAndDrag
rem @clickAndDrag px py rx ry rw rh L
set @clickAndDrag=for %%# in (1 2) do if %%#==2 (for /f "tokens=1-7" %%1 in ("^!args^!") do (%\n%
	set /a "a=%%~1,b=%%~2,c=%%~5,d=%%~6, ^!@clickingInsideBox^!"%\n%
	if ^^!$clickingInsideBox^^! equ 1 ( %\n%
		if defined dragging ( set /a "%%~1=mouseX - offsetX, %%~2=mouseY - offsetY, %%~5=%%~1 + %%~3, %%~6=%%~2 + %%~4" %\n%
		)        else       ( set /a "offsetX=mouseX - %%~1, offsetY=mouseY - %%~2, dragging=1" )%\n%
	) else set "dragging="%\n%
)) else set args=