set "skipIntro=false"

set "scl=4" & rem 1 - 4, can go higher, but not really recommended
if %scl% lss 1 set "scl=1"



set "targetFPS=15"
set "MIN_FRAME_INTERVAL_CS=5"

set "directionMap=2013xxxxxxxxxxxxxxxxxxxxxxxx2xx1xxxxxxxxxxxxxx3xxx0"

%@fillRect% %scl% %scl%
set "segment=!$fillRect:%\e%[48;5;15m=!"
set "food=%segment%"