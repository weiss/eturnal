@echo off
set rel_name="eturnal"
set rel_vsn="@VERSION@"
setlocal enabledelayedexpansion
for /f "tokens=3" %%i in ('sc getkeyname %rel_name%_%rel_vsn%') do (
    set svc_name=%%i
)
sc config %svc_name% start= delayed-auto
endlocal
