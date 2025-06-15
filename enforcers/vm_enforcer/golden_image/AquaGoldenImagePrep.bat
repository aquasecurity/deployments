@echo off
SETLOCAL ENABLEEXTENSIONS 

set AQUA_ROOT_DIR=C:\Program Files\AquaSec
set AQUA_DATA_DIR=C:\Program Files\AquaSec\data

cmd /c exit /b 0

goto check_Permissions

:check_Permissions
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Administrator privilege is required.
    exit 1
)

:check_commandline
set OPTION=%1
IF "%OPTION%" EQU "--silent" goto stop_service
IF "%OPTION%" EQU "--help" goto display_usage
goto display_prompt

:display_usage
@echo.
@echo Aqua Security Golden Image Preparation script
@echo.
@echo Usage: %0 [--silent ^| --help]
@echo.
goto end

:display_prompt
@echo.
SET /P PROCEED=Aqua Security Golden Image Preparation script will perform irrevertible cleanup actions on VM Enforcer. Proceed? [Y/N]
IF /I "%PROCEED%" NEQ "Y" goto end

:please_wait
@echo.
@echo Please wait

:stop_service
net stop slkd >nul 2>&1
net stop containermonitor >nul 2>&1
goto delete_logical_name

:delete_logical_name
reg add HKEY_LOCAL_MACHINE\SOFTWARE\AquaSecurity\WindowsAgent /v AgentLogicalName /t REG_SZ /d "" /f
goto delete_database

:delete_database
del /Q /F "%AQUA_DATA_DIR%\*.db*" >nul 2>&1
goto delete_guid

:delete_guid
del /Q /F "%AQUA_DATA_DIR%\guid" >nul 2>&1
goto create_golden_image_file

:create_golden_image_file
copy /y NUL "%AQUA_ROOT_DIR%\GOLDEN_IMAGE" >nul 2>&1
goto print_success

:print_success
@echo.
@echo Operation successfull. VM Enforcer is ready for Golden Image creation.
goto end

:end
