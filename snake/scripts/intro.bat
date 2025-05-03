set "intro=%\e%7Please change your font to RASTER FONTS%\e%8%\e%[2B%\e%7      [W][6D[B[A][S][D]%\e%8%\e%[2B%\e%7       OR%\e%8%\e%[2B%\e%7      [▲][6D[B[◄][▼][►]%\e%8%\e%[3B%\e%7  [ESC] at ANY TIME to QUIT%\e%8%\e%[3BEnjoy and..."


for %%i in (0 10 20 30 40 50 60 70 80 90 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250 255 245 235 225 215 205 195 185 175 165 155 145 135 125 115 105 95 85 75 65 55 45 35 25 11) do (
	echo %\e%[2J%\e%[40;13H%\e%[38;2;%%i;%%i;%%im%presentation%%\e%[50;19H%SNAKE_LOGO%%\e%[m
	pathping 127.0.0.1 -n -q 1 -p 50  >nul
)


echo %\e%[40;33H%intro%
pause