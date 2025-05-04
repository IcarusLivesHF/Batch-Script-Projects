set "skipIntro=false"

set "directionMap=2013xxxxxxxxxxxxxxxxxxxxxxxx2xx1xxxxxxxxxxxxxx3xxx0"

set "scl=4"

set "targetFPS=15"
set "MIN_FRAME_INTERVAL_CS=5"

%@fillRect% %scl% %scl%
set "segment=!$fillRect:%\e%[48;5;15m=!"
set "food=%segment%"