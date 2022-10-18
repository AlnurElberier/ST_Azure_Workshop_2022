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

set STM32CubeProgrammer_Required_Version="STM32CubeProgrammer version: 2.09.0 "
set Python_Required_Version="Python 3.10.7"
set azcli_version="azure-cli                         2.40.0 *"
set ws_userPrincipalName="stm32u585_outlook.com#EXT#@iotcloudservicesst.onmicrosoft.com"


set STM32CubeProgrammer_CLI="C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"
set STM32CubeExpansion_Cloud_AZURE="C:\STM32CubeExpansion_Cloud_AZURE_V2.1.0"


set rerun=1==0

set DOWNLOAD_LINK_STM32_CUBE_PROG="https://stm32iot.blob.core.windows.net/firmware/en.stm32cubeprg-win64_v2-11-0.zip"

set DOWNLOAD_LINK_X_CUBE_AZURE="https://stm32iot.blob.core.windows.net/firmware/en.x-cube-azure_v2-1-0.zip"

set DOWNLOAD_LINK_PYTHON="https://www.python.org/ftp/python/3.10.7/python-3.10.7-amd64.exe"
set DOWNLOAD_LINK_AZCLI="https://azcliprod.blob.core.windows.net/msi/azure-cli-2.40.0.msi"
set DOWNLOAD_LINK_GET_PIP="https://bootstrap.pypa.io/get-pip.py"

echo. 


:: Check if computer connected to the Internet
::call :Check_Internet_Connection

if %ERRORLEVEL% NEQ 0 (
    mshta "javascript:alert('[ERROR] You are not connected to the Internet. Please connecto to the Internet and run the script again.');close()"
    EXIT /B 1
)

IF NOT EXIST "tools" mkdir "tools"

:: Extract X-CUBE-AZURE
call :Instal_X_CUBE_AZURE

:: Check if STM32CubeProgrammer is installed with correct version
if exist %STM32CubeProgrammer_CLI% (
    call :Check_STM32CubeProgrammer_version
) else (   
    call :Install_STM32CubeProgrammer
)

if %ERRORLEVEL% NEQ 0 (
    mshta "javascript:alert('[ERROR] Wrong STM32CubeProgrammer version. please Uninstall STM32CubeProgrammer and run the script again');close()"
    EXIT /B 1
) 

:: Check if python is installed with correct version
python --version 2>NUL
if errorlevel 1  (
    call :Install_Python
    set rerun=1==1
) else (
    call :Check_Python_version
)

if %ERRORLEVEL% NEQ 0 (
    mshta "javascript:alert('[ERROR] Wrong Python version. Please Uninstall Python and run the script again');close()"
    EXIT /B 1
) 

:: Check if AZ CLI is installed.
call az --version 2>NUL
if errorlevel 1 (
    call :Install_AZCLI
    set rerun=1==1
) else (
    call :Check_AZCLI_version
)

if %ERRORLEVEL% NEQ 0 (
    mshta "javascript:alert('[ERROR] Wrong AZCLI version. Please Uninstall AZCLI and run the script again');close()"
    EXIT /B 1
)

if %rerun% (
    echo Plese run the script again
    mshta "javascript:alert('Plese run the script again');close()"
    EXIT /B 1
)

:: Check Pip. install if not installed
call :Check_Pip

:: Install pyserial
echo Installing pyserial...
call python -m pip install pyserial

:: Install AZ extensions
call :Install_AZ_extensions

echo Redirecting to a browser window to log in to Azure
mshta "javascript:alert('Redirecting to a browser window to log in to Azure. Use credentials from credentials.txt file.');close()"

:: Open credentials.txt that contains the user email address and password
start notepad "credentials.txt"
timeout 5

:: Logout from Azure
call az logout

:: Login to Azure
call az login

if %ERRORLEVEL% NEQ 0 (
    echo Log in error. Plese run the script again
    mshta "javascript:alert('[ERROR] Log in error. Plese run the script again');close()"
    EXIT /B 1
) 

:: Check if we are loged in to the correct account
call :Check_userPrincipalName

if %ERRORLEVEL% NEQ 0 (
    mshta "javascript:alert('[ERROR] Log in error. Plese run the script again');close()"
    EXIT /B 1
) 

:: Update the config.json file with the workshop configuration
call python .\scripts\configureJson.py


:: We have a successful check
echo.
echo Successful Requirement Check 
echo.

:: Open STM32CubeExpansion_Cloud_AZURE directory
%SystemRoot%\explorer.exe %STM32CubeExpansion_Cloud_AZURE%

:: End of the script
EXIT /B 0


::##########################################################
:: Install Functions
::##########################################################


::##########################################################
:: Install Python
::##########################################################
:Install_Python
rem Download python-3.10.7-amd64.exe if not present in tools directory
IF NOT EXIST .\tools\python-3.10.7-amd64.exe (
    echo Downloading Python
    curl  %DOWNLOAD_LINK_PYTHON% -o ".\tools\python-3.10.7-amd64.exe"
)

rem Install python
echo Installing Python
call  .\tools\python-3.10.7-amd64.exe /passive InstallAllUsers=1 PrependPath=1 Include_test=0 
    
EXIT /B 0

::##########################################################
:: Install AZCLI
::##########################################################
:Install_AZCLI
rem Download azure-cli-2.40.0.msi if not present in tools directory
IF NOT EXIST .\tools\azure-cli-2.40.0.msi (
    echo Downloading AZ CLI
    curl %DOWNLOAD_LINK_AZCLI% -o ".\tools\azure-cli-2.40.0.msi"
)

rem Install AZ CLI
echo Installing AZCLI
call .\tools\azure-cli-2.40.0.msi

EXIT /B 0

::##########################################################
:: Install AZ extensions
::##########################################################
:Install_AZ_extensions
echo.
echo Installing AZ extensions
echo.
call az extension add --name azure-iot 
call az extension update --name azure-iot
call az extension add --name account
call az extension update --name account

EXIT /B 0

::##########################################################
:: Install STM32CubeProgrammer
::##########################################################
:Install_STM32CubeProgrammer
echo.
echo STM32CubeProgrammer missing
echo.

rem Download en.stm32cubeprg-win64_v2-11-0.zip if not present in tools directory
IF NOT EXIST .\tools\en.stm32cubeprg-win64_v2-11-0.zip (
    echo Downloading STM32CubeProgrammer
    curl %DOWNLOAD_LINK_STM32_CUBE_PROG% -o ".\tools\en.stm32cubeprg-win64_v2-11-0.zip"   
)

rem Extract en.stm32cubeprg-win64_v2-11-0.zip
IF NOT EXIST .\tools\en.stm32cubeprg-win64_v2-11-0 (
    echo Extracting STM32CubeProgrammer
    call powershell -command "Expand-Archive .\tools\en.stm32cubeprg-win64_v2-11-0.zip .\tools\en.stm32cubeprg-win64_v2-11-0"
)

rem Install STM32CubeProgrammer
echo Installing STM32CubeProgrammer
call .\tools\en.stm32cubeprg-win64_v2-11-0\SetupSTM32CubeProgrammer_win64.exe

EXIT /B 0

::##########################################################
:: Install X-CUBE-AZURE
::##########################################################
:Instal_X_CUBE_AZURE
if exist %STM32CubeExpansion_Cloud_AZURE% ( 
    echo.
    echo X-CUBE-AZURE Successfully Installed
    echo.
) else (
    
    rem Download en.x-cube-azure_v2-1-0.zip if not present in tools directory
    IF NOT EXIST .\tools\en.x-cube-azure_v2-1-0.zip (
        echo Downloading X-CUBE-AZURE
        curl %DOWNLOAD_LINK_X_CUBE_AZURE% -o ".\tools\en.x-cube-azure_v2-1-0.zip"
    )

    rem Extract en.x-cube-azure_v2-1-0.zip to C:
    echo Extracting X-CUBE-AZURE
    powershell -command "Expand-Archive .\tools\en.x-cube-azure_v2-1-0.zip C:\."
)

EXIT /B 0

::##########################################################
:: Check Functions
::##########################################################

::##########################################################
:: Check Pip. install if not installed
::##########################################################
:Check_Pip
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
)

EXIT /B 0

::##########################################################
:: Check if computer is connected to the Internet
::##########################################################
:Check_Internet_Connection
Ping www.google.com -n 1 -w 1000 > ping.txt

if errorlevel 1 (
    echo.
    echo You are not connected to the Internet.
    echo Please connecto to the Internet and run the script again.
    echo.
    EXIT /B 1
)

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
    echo Installed version        : "%xprvar%"
    echo Minimum required version : %STM32CubeProgrammer_Required_Version%
    echo please Uninstall STM32CubeProgrammer and run the script again
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
    echo Installed version        : "%xprvar%"
    echo Minimum required version : %Python_Required_Version%
    echo please Uninstall Python and run the script again
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

rem Get AZ CLI version
call az --version > az_version.txt

set /p xprvar=<az_version.txt

if %azcli_version% LEQ "%xprvar%" ( 
    echo.
    echo AZCLI is version OK
    echo.
    EXIT /B 0
) else (
    echo.
    echo AZCLI version error
    echo Installed version        : "%xprvar%"
    echo Minimum required version : %azcli_version%
    echo.
    EXIT /B 1
)

EXIT /B 0


::##########################################################
:: Function: Check userPrincipalName
::##########################################################
:Check_userPrincipalName
call az ad signed-in-user show --query userPrincipalName>userPrincipalName.txt

set set current_userPrincipalName=""

set /p current_userPrincipalName=<userPrincipalName.txt

if %current_userPrincipalName% NEQ %ws_userPrincipalName% (
    echo Log in error. Plese run the script again
    EXIT /B 1
)

EXIT /B 0   