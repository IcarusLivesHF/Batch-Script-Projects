(set \n=^^^
%= This creates an escaped Line Feed - DO NOT ALTER =%
)

set "cmdwiz=lib\cmdwiz\cmdwiz"

:_mouse_and_keys
set "@mouse_and_keys=key=x / 2, MX=((x>>10) & 2047)+1, MY=((x>>21) & 1023)+1, LMB=(x & 2)>>1, RMB=(x & 4)>>2, DLB=(x & 8)>>3, DRB=(x & 16)>>4, MWD=(x & 32)>>5, MWU=(x & 64)>>6"

:_connectController
rem %@connectController% main controller "path"
set @connectController=for %%# in (1 2) do if %%#==2 ( for /f "tokens=1-4" %%1 in ("^!args^!") do (%\n%
	"%%~4" %%~2 ^>"%%~3" ^| "%%~4" %%~1 ^<"%%~3"%\n%
)) else set args=

:_controller
rem %@controller%
set @controller=(%\n%
	for /l %%# in () do (%\n%
		if exist "%temp%\%~n0_abort.txt" (%\n%
			del /f /q "%temp%\%~n0_abort.txt"^>nul%\n%
			exit%\n%
		)%\n%
		%cmdwiz% getch_or_mouse^>nul%\n%
		echo=^^!errorlevel^^!%\n%
	)%\n%
)