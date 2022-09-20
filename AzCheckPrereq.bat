@echo off

set stm32programmercli="C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"


if exist %stm32programmercli% ( 
    echo STM32CubeProgrammer Successfully Installed
    echo.
) else (
    echo ERR: STM32CubeProgrammer Not Installed 
    echo You will be redierected to download STM32CubeProgrammer
    echo Please Install STM32CubeProgrammer and run the script again
    timeout 5
    start "" https://www.st.com/en/development-tools/stm32cubeprog.html#get-software
    goto :err
)


python --version 2>NUL
if errorlevel 1 (
    echo ERR: Python Not Installed 
    echo You will be redierected to download Python
    echo Please Install Python and run the script again
    timeout 5
    start "" https://www.python.org/downloads/
    goto :err
) else (
    echo Python Successfully Installed
    echo.
)


pi --version 2>NUL
if errorlevel 1 (
    echo ERR: pip Not Installed 
    echo Pip will now be installed.
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    python get-pip.py
) else (
    echo pip Successfully Installed
    echo.
    call python -m pip install pyserial
)


call azc --version 2>NUL
if errorlevel 1 (
    echo ERR: AZ CLI Not Installed 
    echo You will be redierected to download AZCLI
    echo Please Install AZCLI and run the script again
    timeout 5
    start "" https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
) else (
    echo AZ CLI Successfully Installed
    echo.
)


call az extension add --name azure-iot 
call az extension update --name azure-iot
call az extension add --name account
call az extension update --name account

call az login --allow-no-subscription
call az account tenant list > tenant.txt

for %%i in (tenant.txt) do (
    if %%~z%i LSS 100 (
        echo. 
        echo You azure account is not associated with a tenant
        echo Send an email to alnur.elberier@st.com to request to be added to a tenant
        echo Check your email to accept the tenant invitation. 
        echo Run this script again after joining the tenant. 
        goto :err
    )
)

echo.
echo Requirement Check Success

:err
pause
