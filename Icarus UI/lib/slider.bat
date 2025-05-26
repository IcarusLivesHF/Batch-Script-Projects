rem initialize all of the important parts of the slider, and prefix with '_' because we want to empty these from the environment afterwards.
set /a "_sliderX=%~1",^
       "_sliderxmi=%~1",^
       "_sliderY=%~2",^
       "_sliderxma=%~1+%~3-1",^
       "_sliderymi=%~2-2",^
       "_slideryma=%~2+1",^
       "_slidermi=%~4",^
       "_sliderma=%~5",^
       "_sliderSC=%~6",^
       "_sliderPC=%~7",^
       "$sliderPosition=%~1+1"   
set "_sliderB=!$q:~0,%~3!"

rem build what the slider looks like - it looks kind of crazy,
rem but we are using \e7 \e8 \e[A and \e[B to shape the slider
rem and \e[y;xH to position the sliders position
set "@sliderDisplay=%\e%[38;5;%_sliderSC%m%\e%[%_sliderY%;%_sliderX%H"
set "@sliderDisplay=%@sliderDisplay%%\e%(0%\e%[A%\e%7l%_sliderB%k%\e%8%\e%[B"
set "@sliderDisplay=%@sliderDisplay%%\e%7t%_sliderB%u%\e%8%\e%[B"
set "@sliderDisplay=%@sliderDisplay%m%_sliderB%j%\e%(B%\e%[m"
set "@sliderDisplay=%@sliderDisplay%%\e%[48;5;%_sliderPC%m%\e%[%_sliderY%;?H %\e%[m"

rem @sliderAPI:
rem     if mouseX geq Xmin if mouseX leq Xmax if mouseY geq Ymin if mouseY leq Ymax if L_click equ 1 (
rem         map sliderValue between sliderMin and sliderMax by the location of mouseX
rem         map sliderPosition between the west edge and east edge of the slider by the location of mouseX
rem     ) 
set "@sliderAPI=( m=(~((mouseX-%_sliderxmi%)|(%_sliderxma%-mouseX)|(mouseY-%_sliderymi%)|(%_slideryma%-mouseY))>>31)&1 & L_click,"
set "@sliderAPI=%@sliderAPI%$sliderValue^=-m&($sliderValue^(%_slidermi%+(%_sliderma%-%_slidermi%)*(mouseX-%_sliderxmi%)/(%_sliderxma%-%_sliderxmi%))),
set "@sliderAPI=%@sliderAPI%$sliderPosition^=-m&($sliderPosition^(mouseX+1)) )"

rem @dragSlider:
rem     utilize @sliderAPI to obtain a new sliderPosition/Value
rem     apply the position to the @sliderDisplay by substitution @sliderDisplay:?=sliderPosition
rem     where ? is the x axis position of the slider
set @dragSlider=(%\n%
    set /a "^!@sliderAPI^!"%\n%
    for %%i in (^^!$sliderPosition^^!) do (%\n%
        set "sliderDisplay=^!@sliderDisplay:?=%%i^!"%\n%
    )%\n%
)


for /f "tokens=1 delims==" %%i in ('set _') do set "%%i="