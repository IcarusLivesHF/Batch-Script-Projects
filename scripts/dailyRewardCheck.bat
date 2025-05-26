rem grab date timestamp for daily "reward"
for /f "tokens=2 delims==" %%G in ('wmic os get localdatetime /value') do set "$datetime=%%G"
set "$datetime=!$datetime:~0,8!"

if exist ".config\dateTime.txt" (
	for /f "usebackq delims=" %%i in (".config\dateTime.txt") do (
		for /f "usebackq delims=" %%j in (".config\dailyReward.dat") do (
			set /a "dailyReward=%%j"
			if %%~i lss !$datetime! (
				set /a "dailyReward+=1"
			)
			set /a "%@sumPoints%"
			echo !dailyReward! >".config\dailyReward.dat"
			echo=!$datetime!>".config\dateTime.txt"
		)
	)
) else (
	echo=!$datetime!>".config\dateTime.txt"
	echo 1 >".config\dailyReward.dat"
	set /a "dailyReward=1", "%@sumPoints%"
)