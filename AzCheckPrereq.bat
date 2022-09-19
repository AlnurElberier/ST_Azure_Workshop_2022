@echo off

set stm32programmercli="C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"


if exist %stm32programmercli% ( 
    echo STM32CubeProgrammer Successfully Installed
    echo.
) else (
    echo ERR: STM32CubeProgrammer Not Installed 
    start "" https://www.st.com/en/development-tools/stm32cubeprog.html#get-software
)


python --version 2>NUL
if errorlevel 1 (
    echo ERR: Python Not Installed 
    start "" https://www.python.org/downloads/
) else (
    echo Python Successfully Installed
    echo.
)


@REM pip --version 2>NUL
@REM if errorlevel 1 (
@REM     echo ERR: pip Not Installed 
@REM     start "" https://www.geeksforgeeks.org/how-to-install-pip-on-windows/
@REM ) else (
@REM     echo pip Successfully Installed
@REM     echo.
@REM )

@REM git --version 2>NUL
@REM if errorlevel 1 (
@REM     echo ERR: Git Not Installed 
@REM     start "" https://git-scm.com/download/win
@REM ) else (
@REM     echo Git Successfully Installed
@REM     echo.
@REM )

call pip install pyserial

call az --version 2>NUL
if errorlevel 1 (
    echo ERR: AZ CLI Not Installed 
    start "" https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
) else (
    echo AZ CLI Successfully Installed
    echo.
)


call az extension add --name azure-iot
call az extension update --name azure-iot
call az login
call az extension add --name account
call az account list
call az account tenant list


pause
