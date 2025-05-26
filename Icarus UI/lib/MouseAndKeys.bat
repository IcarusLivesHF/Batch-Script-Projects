
rem substitute ? for R,L:   if %onClick:?=L% ( do code )
set        "@onClick="^^!?_click^^!.^^!last_?_click^^!" equ "1.0""
set "@onClickRelease="^^!?_click^^!.^^!last_?_click^^!" equ "0.1""
set   "@holdingClick="^^!?_click^^!.^^!last_?_click^^!" equ "1.1""


rem use with onClick/onClickRelease
rem usage: set /a "%saveLastClicks%"
set "@saveLastClicks=last_l_click=l_click, last_r_click=r_click, last_b_click=b_click"


rem determine if mouse is hovering over a box, button, etc.
rem set /a "a=x, b=y, c=x+wid, d=y+hei, return=%@hovering%"
set "@hovering=((~((mouseX - a) | (c - mouseX) | (mouseY - b) | (d - mouseY)) >> 31) & 1)"

rem bounding box macro with L/R click validation
rem set /a "a=, b=, c=, d=, %clickingInsideBox:?=L or R%" <rtn> !$clickingInsideBox! 0:false or 1:true
set "@clickingInsideBox=$clickingInsideBox=^!@hovering^! & ?_click"


rem determine a key press even if other keys are being held
rem
rem do within if defined keysPressed ( )
rem
rem %@asyncKeys:?=27% ( echo You're pressing ESC key )
set "@asyncKeys=if NOT "^^!keysPressed^^!" == "^^!keysPressed:-?-=^^!""


