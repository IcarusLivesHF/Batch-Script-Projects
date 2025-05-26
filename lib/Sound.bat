set "sfx=assets\sfx"

:_playSound
REM %@playSound% "%sfx%\path"
set "@playSound=if /i "^^!soundEnabled^^!" equ "true" start "" /B lib\3rdparty\cmdwiz playsound"