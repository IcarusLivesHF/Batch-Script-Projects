@echo off & setlocal enableDelayedExpansion

if "%~1" neq "" goto :%~1

call lib\stdlib 70 55
call lib\cmdwiz
call lib\calendar 20 20

(%@connectController% main controller "%temp%\%~n0_signal.txt" "%~F0") & exit
:Main
for /l %%# in () do (

	set /p "com=" & set /a "x=com","%@mouse_and_keys%"
	
	rem l1 = 1 left click     l2 = 2 left click    r1 = 1 right click    r2 = 2 right click
	%@calendar.click% /l1
	
	echo %\h%%\e%[H!scrn!%\e%[HCOM: !mx!,!my!,!LMB!,!RMB!,!DLB!,!DRB!,!MWD!,!MWU!,-!key!-%$calendar%%\e%[31;20HDate clicked: !$calendar.click!
)2>nul

:Controller
%@controller%