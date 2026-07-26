@echo off
setlocal enabledelayedexpansion

rem -------------------------
rem Parametri e costanti
rem -------------------------
rem 10=1024
set /a "scalabit=10, one=1<<scalabit"
set /a "size=80"
set /a "max_color=255"
set /a "pi=31416*one/10000"

For /F %%a in ('Echo prompt $E^| %comspec%') Do Set ESC=%%a

mode %size%,%size%

call :init

pause>nul

set /a "center=size/2"
set /a "radiusf=size*one/2"

for /L %%Y in (1,1,%size%) do (
    title Row %%Y
    for /L %%X in (1,1,%size%) do (

        rem coordinate fixed-point
        set /a "dx=(%%X-center)*one"
        set /a "dy=(%%Y-center)*one"

        rem distanza (approssimata) in fixed-point: sqrt(dx^2+dy^2)
    rem divisioni e moltiplicazioni ottimizzate per non andare in overflow
        set /a "tmp=(dx/one*dx+dy/one*dy)"
        set /a "distancef=%sqrt(N):N=tmp%"

        rem angolo
        call :fast_atan2 dy dx atan2
        set /a "hue=atan2*180*one/pi"
        if !hue! lss 0 set /a "hue+=360*one"

    if !hue! lss 0 pause
    set /a maxhue=360*one
    if !hue! gtr !maxhue! pause

        rem calcolo log2 parts: frac in [0..one-1], exp intero!!!!!
        call :log2_parts distancef frac exp

        rem mappatura su HSV: saturazione piena, value dalla frazione
        set /a "sat=one"
        set /a "val=frac"

        call :hsvtorgb hue sat val r g b

        echo %ESC%[%%Y;%%XH%ESC%[48;2;!r!;!g!;!b!m %ESC%[H

    )
)

title done
pause>nul
goto :eof