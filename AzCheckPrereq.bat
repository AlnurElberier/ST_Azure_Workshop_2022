::******************************************************************************
::* @file    AzCheckPrereq.bat
::* @author  MCD Application Team
::* @brief   Check the presequists for the Azure workshop
::******************************************************************************
:: * Copyright (c) 2022 STMicroelectronics.
::
:: * All rights reserved.
::
:: * This software component is licensed by ST under BSD 3-Clause license,
:: * the "License"; You may not use this file except in compliance with the
:: * License. You may obtain a copy of the License at:
:: *                        opensource.org/licenses/BSD-3-Clause
:: *
:: ******************************************************************************
@echo off

set STM32CubeProgrammer_Required_Version="STM32CubeProgrammer version: 2.11.0 "
set Python_Required_Version="Python 3.10.7"
set azcli_version="azure-cli                         2.40.0 *"

set STM32CubeProgrammer_CLI="C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"
set STM32CubeExpansion_Cloud_AZURE="C:\STM32CubeExpansion_Cloud_AZURE_V2.1.0"


set rerun=1==0

set DOWNLOAD_LINK_STM32_CUBE_PROG="https://stm32iot.blob.core.windows.net/firmware/en.stm32cubeprg-win64_v2-11-0.zip"

set DOWNLOAD_LINK_X_CUBE_AZURE="https://stm32iot.blob.core.windows.net/firmware/en.x-cube-azure_v2-1-0.zip"

set DOWNLOAD_LINK_PYTHON="https://www.python.org/ftp/python/3.10.7/python-3.10.7-amd64.exe"
set DOWNLOAD_LINK_AZCLI="https://azcliprod.blob.core.windows.net/msi/azure-cli-2.40.0.msi"
set DOWNLOAD_LINK_GET_PIP="https://bootstrap.pypa.io/get-pip.py"

echo. 


::##########################################################
:: Check if computer connected to the Internet
::##########################################################
Ping www.google.com -n 1 -w 1000 > ping.txt

if errorlevel 1 (
    echo You are not connected to the Internet.
    echo Please connecto to the Internet and run the script again.
    mshta "javascript:alert('[ERROR] You are not connected to the Internet. Please connecto to the Internet and run the script again.');close()"
    echo.

    EXIT /B 1
)

IF NOT EXIST "tools" mkdir "tools"

echo. 

::##########################################################
:: Check if STM32CubeProgrammer is installed with correct version
::##########################################################
if exist %STM32CubeProgrammer_CLI% (
    call :Check_STM32CubeProgrammer_version
) else (
    echo.
    echo STM32CubeProgrammer missing
    echo.    
    call :Install_STM32CubeProgrammer
)

if %ERRORLEVEL% NEQ 0 (
    EXIT /B 1
) 

::##########################################################
:: Check if python is installed with correct version
::##########################################################
python --version 2>NUL
if errorlevel 1 (
    echo.

    :: Download python-3.10.7-amd64.exe if not present in tools directory
    IF NOT EXIST .\tools\python-3.10.7-amd64.exe (
        echo Downloading Python
        curl  %DOWNLOAD_LINK_PYTHON% -o ".\tools\python-3.10.7-amd64.exe"
    )

    :: Install python
    echo Installing Python
    call  .\tools\python-3.10.7-amd64.exe /passive InstallAllUsers=1 PrependPath=1 Include_test=0 
    set rerun=1==1
    echo.
) else (

    :: Python installed
    echo.
    call :Check_Python_version
    echo.
)

if %ERRORLEVEL% NEQ 0 (
    EXIT /B 1
) 

::##########################################################
:: Check if AZ CLI is installed.
::##########################################################
call az --version 2>NUL
if errorlevel 1 (
    echo.
    :: Download azure-cli-2.40.0.msi if not present in tools directory
    IF NOT EXIST .\tools\azure-cli-2.40.0.msi (
        echo Downloading AZ CLI
        curl %DOWNLOAD_LINK_AZCLI% -o ".\tools\azure-cli-2.40.0.msi"
    )

    :: Install AZ CLI
    echo Installing AZCLI
    call .\tools\azure-cli-2.40.0.msi
    set rerun=1==1
    echo.
) else (

    :: AZ CLI installed
    echo.
    call :Check_AZCLI_version
    echo.
)

if %ERRORLEVEL% NEQ 0 (
    EXIT /B 1
) 

:: Extract X-CUBE-AZURE
if exist %STM32CubeExpansion_Cloud_AZURE% ( 
    echo.
    echo X-CUBE-AZURE Successfully Installed
    echo.
) else (
    
    :: Download en.x-cube-azure_v2-1-0.zip if not present in tools directory
    IF NOT EXIST .\tools\en.x-cube-azure_v2-1-0.zip (
        echo Downloading X-CUBE-AZURE
        curl %DOWNLOAD_LINK_X_CUBE_AZURE% -o ".\tools\en.x-cube-azure_v2-1-0.zip"
    )

    :: Extract en.x-cube-azure_v2-1-0.zip to C:
    echo Extracting X-CUBE-AZURE
    powershell -command "Expand-Archive .\tools\en.x-cube-azure_v2-1-0.zip C:\."
)

::##########################################################
:: Check Pip. install if not installed
::##########################################################
if %rerun% (
    goto:err
) else (

    python -m pip --version 2>NUL
    if errorlevel 1 (
        echo.
        echo ERR: pip Not Installed 
        echo Pip will now be installed
        IF NOT EXIST .\tools\get-pip.py (
            echo Downloading pip
            curl %DOWNLOAD_LINK_GET_PIP% -o ".\tools\get-pip.py"
        )
        echo Installing pip
        call python .\tools\get-pip.py
        echo.
    ) else (
        echo.
        echo pip Successfully Installed
        echo.
        echo Installing pyserial...
        echo.
    )

    call python -m pip install pyserial

:: Install AZ extensions
    echo.
    call az extension add --name azure-iot 
    echo.
    call az extension update --name azure-iot
    echo.
    call az extension add --name account
    echo.
    call az extension update --name account
    echo.

    echo Redirecting to a browser window to log in to Azure Cli

    mshta "javascript:alert('Redirecting to a browser window to log in to Azure Cli. Use credentials from credentials.txt file.');close()"

:: Open credentials.txt that contains the user email address and password
    start notepad "credentials.txt"
    sleep 5

:: Login to Azure
    call az login --allow-no-subscription

:: Update the config.json file with the workshop configuration
    call python .\scripts\configureJson.py
)


echo.
echo Successful Requirement Check 
echo.
::mshta "javascript:alert('Successful Requirement Check.');close()"

::##########################################################
:: Open STM32CubeExpansion_Cloud_AZURE directory
::##########################################################
%SystemRoot%\explorer.exe %STM32CubeExpansion_Cloud_AZURE%
goto:exit

::##########################################################
:: Exit with error
::##########################################################
:err
echo Plese run the script again
mshta "javascript:alert('Plese run the script again');close()"
EXIT /B 1
:::pause

::##########################################################
:: Exit without error
::##########################################################
:exit
EXIT /B 0

::##########################################################
:: Install STM32CubeProgrammer
::##########################################################
:Install_STM32CubeProgrammer
echo.
:: Download en.stm32cubeprg-win64_v2-11-0.zip if not present in tools directory
IF NOT EXIST .\tools\en.stm32cubeprg-win64_v2-11-0.zip (
    echo Downloading STM32CubeProgrammer
    curl %DOWNLOAD_LINK_STM32_CUBE_PROG% -o ".\tools\en.stm32cubeprg-win64_v2-11-0.zip"   
)

:: Extract en.stm32cubeprg-win64_v2-11-0.zip
IF NOT EXIST .\tools\en.stm32cubeprg-win64_v2-11-0 (
    echo Extracting STM32CubeProgrammer
    call powershell -command "Expand-Archive .\tools\en.stm32cubeprg-win64_v2-11-0.zip .\tools\en.stm32cubeprg-win64_v2-11-0"
)

:: Install STM32CubeProgrammer
echo Installing STM32CubeProgrammer
call .\tools\en.stm32cubeprg-win64_v2-11-0\SetupSTM32CubeProgrammer_win64.exe
echo.
EXIT /B 0

::##########################################################
:: Check STM32CubeProgrammer version
::##########################################################
:Check_STM32CubeProgrammer_version
setlocal enabledelayedexpansion
set xprvar=""

%STM32CubeProgrammer_CLI% --version > STM32CubeProgrammer_version.txt

for /F "delims=" %%i in (STM32CubeProgrammer_version.txt) do set "xprvar=%%i"

if %STM32CubeProgrammer_Required_Version% LEQ "%xprvar%" ( 
    echo.
    echo STM32CubeProgrammer is uptodate
    echo.
    EXIT /B 0
) else (
    echo.
    echo STM32CubeProgrammer version error
    echo Installed version: "%xprvar%"
    echo Required version : %STM32CubeProgrammer_Required_Version%
    echo please Uninstall STM32CubeProgrammer and run the script again
    mshta "javascript:alert('[ERROR] Wrong STM32CubeProgrammer version. please Uninstall STM32CubeProgrammer and run the script again');close()"
    echo.
    EXIT /B 1
)
EXIT /B 0


::##########################################################
:: Check Python version
::##########################################################
:Check_Python_version
setlocal enabledelayedexpansion

set xprvar=""

python --version > Python_version.txt

for /F "delims=" %%i in (Python_version.txt) do set "xprvar=%%i"

if %Python_Required_Version% LEQ "%xprvar%" ( 
    echo.
    echo Python is uptodate
    echo.
    EXIT /B 0
) else (
    echo.
    echo Python version error
    echo Installed version: "%xprvar%"
    echo Required version : %Python_Required_Version%
    echo please Uninstall Python and run the script again
    mshta "javascript:alert('[ERROR] Wrong Python version. please Uninstall Python and run the script again');close()"
    echo.
    EXIT /B 1

)
EXIT /B 0

::##########################################################
:: Function: Check AZ CLI version
::##########################################################
:Check_AZCLI_version
setlocal enabledelayedexpansion

set xprvar=""

::call winget install -e --id Microsoft.AzureCLI

:: Get AZ CLI version
call az --version > az_version.txt

set /p xprvar=<az_version.txt

if %azcli_version% LEQ "%xprvar%" ( 
    echo.
     echo AZCLI is uptodate
    echo.
    EXIT /B 0
) else (
    echo.
    echo AZCLI version error
    echo Installed version: "%xprvar%"
    echo Required version : %azcli_version%
    call az upgrade
    mshta "javascript:alert('[ERROR] Please run the script again');close()"
    echo.
    EXIT /B 1

)
EXIT /B 0
