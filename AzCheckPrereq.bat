@echo off

set stm32programmercli="C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"
set STM32CubeExpansion_Cloud_AZURE="C:\STM32CubeExpansion_Cloud_AZURE_V2.0.1"
set rerun=1==0

set DOWNLOAD_LINK_STM32_CUBE_PROG="https://negzxq.sn.files.1drv.com/y4m5-WjjhqkTLyb2AmUUahxlP5NNRJuI6eCQ8-8Q7S2GvJLDEIPqoQ-SenyXrm1iUschFYDiZv1Gky_qNsdafs94wi00s-GMwCnCe3ANApfh96yVoWdr3vEvDIV6DQkI_AHInvaxUW_a_8Zgs08ESSwICrg7tjBWz4tEtS579T7USqU2XqL4_U12dt8rffwcZckdz0N7xWHN4FiQDviYizGog"
set DOWNLOAD_LINK_PYTHON="https://www.python.org/ftp/python/3.10.7/python-3.10.7-amd64.exe"
set DOWNLOAD_LINK_AZCLI="https://azcliprod.blob.core.windows.net/msi/azure-cli-2.40.0.msi"
set DOWNLOAD_LINK_X_CUBE_AZURE="https://nejo0q.sn.files.1drv.com/y4mYF8oM2L4xrPIeHzInK8O1fqyT4P3rXB6Iy3AmDBy4s5iVyANS3IpfjkzpSSLY5N-wdPWUSZ5bCf8F3yif8HCs4dnmit407VqkuLmB4x2dva5oyrrsfKgFucPMHJS7-GUzThaDW-RH1TthaUYhA_3bqvt4JgJ27wcGXaODeBQRuM66jZDXeM_enQXNLT-6C-gx79YFPU1I6XOe8JHIA0XTQ"
set DOWNLOAD_LINK_GET_PIP="https://bootstrap.pypa.io/get-pip.py"
echo. 

IF NOT EXIST "tools\NUL" mkdir "tools"

if exist %stm32programmercli% ( 
    echo.
    echo STM32CubeProgrammer Successfully Installed
    echo.
) else (
    echo.
    echo Installing STM32CubeProgrammer
    curl %DOWNLOAD_LINK_STM32_CUBE_PROG% -o ".\tools\en.stm32cubeprg-win64_v2-11-0.zip"
    call powershell -command "Expand-Archive .\tools\en.stm32cubeprg-win64_v2-11-0.zip .\tools\en.stm32cubeprg-win64_v2-11-0"
    call .\tools\en.stm32cubeprg-win64_v2-11-0\SetupSTM32CubeProgrammer_win64.exe
    echo.
)

python --version 2>NUL
if errorlevel 1 (
    echo.
    echo Installing Python
    curl  %DOWNLOAD_LINK_PYTHON% -o ".\tools\python-3.10.7-amd64.exe"
    call  .\tools\python-3.10.7-amd64.exe /passive InstallAllUsers=1 PrependPath=1 Include_test=0 
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
    curl %DOWNLOAD_LINK_AZCLI% -o ".\tools\azure-cli-2.40.0.msi"
    call .\tools\azure-cli-2.40.0.msi
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
    curl %DOWNLOAD_LINK_X_CUBE_AZURE% -o ".\tools\en.x-cube-azure_v2-0-1.zip"
    echo Extracting X-CUBE-AZURE
    powershell -command "Expand-Archive .\tools\en.x-cube-azure_v2-0-1.zip C:\."
)


if %rerun% (
    goto:err
) else (

    python -m pip --version 2>NUL
    if errorlevel 1 (
        echo.
        echo ERR: pip Not Installed 
        echo Pip will now be installed
        curl %DOWNLOAD_LINK_GET_PIP" -o get-pip.py
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