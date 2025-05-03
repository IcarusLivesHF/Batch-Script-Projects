set "skipIntro=false"

set "directionMap=2013xxxxxxxxxxxxxxxxxxxxxxxx2xx1xxxxxxxxxxxxxx3xxx0"

set /a "scl=4, s=10000, l=5000"


%@fillRect% %scl% %scl%
set "segment=!$fillRect:%\e%[48;5;15m=!"
set "food=!$fillRect:%\e%[48;5;15m=!"