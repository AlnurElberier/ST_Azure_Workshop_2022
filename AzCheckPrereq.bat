@echo off

set stm32programmercli="C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"

echo. 

choice /M "Have you downloaded X-CUBE-AZURE" /c YN

if errorlevel 2 (
    echo.
    echo Please download the latest version of X-CUBE-AZURE and run the script again
    echo You will be redierected to download X-CUBE-AZURE
    pause
    start "" https://www.st.com/en/embedded-software/x-cube-azure.html#get-software
    goto err
)

if exist %stm32programmercli% ( 
    echo.
    echo STM32CubeProgrammer Successfully Installed
    echo.
) else (
    echo.
    echo ERR: STM32CubeProgrammer Not Installed
    echo You will be redierected to download STM32CubeProgrammer
    echo Please Install STM32CubeProgrammer and run the script again
    pause
    start "" https://www.st.com/en/development-tools/stm32cubeprog.html#get-software
    goto :err
)


python --version 2>NUL
if errorlevel 1 (
    echo.
    echo ERR: Python Not Installed 
    echo Please Install Python and run the script again
    echo You will be redierected to download Python
    echo WARNING: MAKE SURE TO ADD PYTHON TO PATH AND INCLUDE PIP IN INSTALL
    pause
    start "" https://www.python.org/downloads/
    goto :err
) else (
    echo.
    echo Python Successfully Installed
    echo.
)


python -m pip --version 2>NUL
if errorlevel 1 (
    echo.
    echo ERR: pip Not Installed 
    echo Pip will now be installed
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py
    echo.
) else (
    echo.
    echo pip Successfully Installed
    echo.
    echo Installing pyserial...
    call python -m pip install pyserial
    echo.
)


call az --version 2>NUL
if errorlevel 1 (
    echo.
    echo ERR: AZ CLI Not Installed 
    echo Please Install AZCLI and run the script again
    echo You will be redierected to download AZCLI
    pause
    start "" https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
) else (
    echo.
    echo AZ CLI Successfully Installed
    echo.
)

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
echo Please return to the script after logging in
pause
call az login --allow-no-subscription
call az account tenant list > tenant.txt

for %%i in (tenant.txt) do (
    if %%~z%i LSS 100 (
        echo. 
        echo.
        echo You azure account is not associated with a tenant
        echo Send an email to alnur.elberier@st.com to request to be added to a tenant
        echo Check your email to accept the tenant invitation
        echo Run this script again after joining the tenant
        goto :err
    )
)

echo.
echo Successfull Requirement Check 
echo.
pause

:err