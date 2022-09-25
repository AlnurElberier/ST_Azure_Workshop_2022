@echo off

set stm32programmercli="C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"
set STM32CubeExpansion_Cloud_AZURE="C:\STM32CubeExpansion_Cloud_AZURE_V2.0.1"
set rerun=1==0

echo. 

if exist %stm32programmercli% ( 
    echo.
    echo STM32CubeProgrammer Successfully Installed
    echo.
) else (
    echo.
    echo Installing STM32CubeProgrammer
    curl "https://public.sn.files.1drv.com/y4mC3dcNQf9JVHYkFcuZBk0keyYWYY_RlV07C99jUaHlO9-hOd8YRGrtPwsDaMa20EO35GwUeFC9Lw8q-2Ifw8yv1fFd-pYUGeS94MiUue7W7dnWMVxBBTg-iI8MR397vRsVBYuzdo_hDTCBOAH4Xhs4LViTCTBNHMPdfLGypC9Jd3frFrvBT9C5H_o77cbFKkvEe4E62pIueKJ7aWXac6K5CGNhabF9ycJBOQJms1gZtM" -o "en.stm32cubeprg-win64_v2-11-0.zip"
    call powershell -command "Expand-Archive en.stm32cubeprg-win64_v2-11-0.zip"
    call start .\en.stm32cubeprg-win64_v2-11-0\SetupSTM32CubeProgrammer_win64.exe
    echo.
)

python --version 2>NUL
if errorlevel 1 (
    echo.
    echo Installing Python
    call powershell  .\scripts\install_python.ps1
    set rerun=1==1
    echo.
) else (
    echo.
    echo Python Successfully Installed
    echo.
)

    

call az --version 2>NUL
if errorlevel 1 (
    echo.
    echo Installing AZCLI
    call powershell  .\scripts\install_azcli.ps1
    set rerun=1==1
    echo.
) else (
    echo.
    echo AZ CLI Successfully Installed
    echo.
)


if exist %STM32CubeExpansion_Cloud_AZURE% ( 
    echo.
    echo X-CUBE-AZURE Successfully Installed
    echo.
) else (
    echo Downloading X-CUBE-AZURE
    curl "https://public.sn.files.1drv.com/y4my4D2H2XthqPvH0Co2SuTHQfSaKll2lOR_TI_F68Rl_pRQNYJmtaMnUimHSZtPmKDLwHUnotFudCMg3YOxA5_oQcYyNF1_4R983AvTCv9BlqvQnZkiAUKhi9nZa7FiaCcnuL3ZzGQZKM4th5rgor86YcCPCaafSYLdLK-RX6GalLXhNX81u4zGTUqzFKav5kq0_s9MTF8QuuJywebLN3StBrdqKlz3PBeFeb1wEA0yYE" -o "en.x-cube-azure_v2-0-1.zip"
    echo Extracting X-CUBE-AZURE
    powershell -command "Expand-Archive en.x-cube-azure_v2-0-1.zip C:\."
)


if %rerun% (
    goto:err
) else (

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
        echo.
    )

    call python -m pip install pyserial




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
        )
    )


    call python .\scripts\configureJson.py
)




echo.
echo Successfull Requirement Check 
echo.
pause

%SystemRoot%\explorer.exe "C:\STM32CubeExpansion_Cloud_AZURE_V2.0.1\Projects\B-U585I-IOT02A\Applications\TFM_Azure_IoT\AzureScripts"
goto:exit

:err
echo Plese run the script again
pause

:exit