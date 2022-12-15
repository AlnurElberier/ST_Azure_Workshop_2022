<#
******************************************************************************
* @file    AzCheckPrereq.ps1
* @author  MCD Application Team
* @brief   Check the presequists for the X-CUBE-AZURE Quick Connect scripts
******************************************************************************
 * Copyright (c) 2022 STMicroelectronics.

 * All rights reserved.

 * This software component is licensed by ST under BSD 3-Clause license,
 * the "License"; You may not use this file except in compliance with the
 * License. You may obtain a copy of the License at:
 *                        opensource.org/licenses/BSD-3-Clause
 *
******************************************************************************
#>

$Script_Version = "1.0.0 azvws q1 2023 1"
$copyright      = "Copyright (c) 2022 STMicroelectronics."
$privacy        = "The script doesn't collect or share any data"

$Required_Version_STM32CubeProgrammer = "STM32CubeProgrammer v2.11.0"
$Required_Version_Python              = "Python 3.10.7"
$Required_Version_AZCLI               = "azure-cli                         2.40.0 *"

$PATH_STM32CubeProgrammer_CLI        = "C:\Program Files\STMicroelectronics\STM32Cube\STM32CubeProgrammer\bin\STM32_Programmer_CLI.exe"
$PATH_STM32CubeExpansion_Cloud_AZURE = "C:\STM32CubeExpansion_Cloud_AZURE_V2.1.0"

$DOWNLOAD_LINK_STM32_CUBE_PROG = "https://stm32iot.blob.core.windows.net/firmware/en.stm32cubeprg-win64_v2-11-0.zip"
$DOWNLOAD_LINK_X_CUBE_AZURE    = "https://stm32iot.blob.core.windows.net/firmware/en.x-cube-azure_v2-1-0.zip"
$DOWNLOAD_LINK_PYTHON          = "https://www.python.org/ftp/python/3.10.7/python-3.10.7-amd64.exe"
$DOWNLOAD_LINK_AZCLI           = "https://azcliprod.blob.core.windows.net/msi/azure-cli-2.40.0.msi"
$DOWNLOAD_LINK_GET_PIP         = "https://bootstrap.pypa.io/get-pip.py"

$ws_tenant_id = "aedf9cbb-56df-47c5-82a7-9a57071cab8e"

$tools_path = ".\tools"
$log_path   = ".\log"

<# Refresh envirement variables #>
function Path_Refresh 
{
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

<# Install AZCLI extensions #>
function AZCLI_Extensions_Install()
{
    Write-Output "Installing AZ extensions"

  try 
  {
    & az extension add --name azure-iot 
    & az extension update --name azure-iot
    & az extension add --name account
    & az extension update --name account
  }
  catch
  {
    return 'False'
  }

  return 'True'
}

<# Locgin to Azure account #>
function AZCLI_Login()
{
    Write-Output "Redirecting to a browser window to log in to Azure"
    Start-Sleep -Seconds 1

    Write-Output "Use the credential from  credentials.txt to log in to Azure"
    Write-Output "credentials.txt will automatically open in 3 seconds"
    Write-Output "Please return to the terminal after you login to Azure"

    Start-Sleep -Seconds 3
    
    & notepad "credentials.txt"

    Start-Sleep -Seconds 3

    #Logout from Azure
   & az logout

   #Login to Azure
   & az login  |  Out-String | Set-Content $log_path\az_login.json

   $login_info = Get-Content $log_path\az_login.json | Out-String | ConvertFrom-Json
   
   if($login_info.tenantId -eq $ws_tenant_id)
   {
    return 'True'
   }
   
   return 'Falase'
}

<# Install Python #>
function AZCLI_Install()
{
    Write-Output "Installing $Required_Version_AZCLI"

    Start-Sleep -Seconds 3

    $azcli_installer = "$tools_path\azure-cli-2.40.0.msi"

    if (!(Test-Path $azcli_installer))
    {
      Write-Output "Downloading AZCLI"
      Import-Module BitsTransfer
      Start-BitsTransfer -Source $DOWNLOAD_LINK_AZCLI -Destination $azcli_installer
    }
    
    Start-Process -Wait -FilePath  $azcli_installer

    # Refresh envirement variables
    Path_Refresh
}

<# Check if AZCLI is installed #>
function AZCLI_Check()
{
    Try
    {
        $azcli_version = & az --version

        if(!$azcli_version)
        {
            Write-Output "AZCLI not installed"
            AZCLI_Install

            return 'True'
        }

        if($azcli_version -like $Required_Version_AZCLI)
        {
            Write-Output "AZCLI $Required_Version_AZCLI installed"
            return 'True'
        }

        return 'False'
    }
    Catch
    {
        Write-Output "AZCLI not installed"
        AZCLI_Install
    }

    return 'True'
}

<# Install Python modules #>
function Python_Modules_Install()
{
    & python -m pip install pyserial
}

<# Install Python #>
function Python_Pip_Check()
{
    $pip_version = & python -m pip --version

    if(!$pip_version)
    {
      Write-Output "Installing pip"

      Start-Sleep -Seconds 3

      $pip_installer = "$tools_path\get-pip.py"

      if (!(Test-Path $pip_installer))
      {
        Import-Module BitsTransfer
        Start-BitsTransfer -Source $DOWNLOAD_LINK_GET_PIP -Destination $pip_installer
      }
    
      Start-Process -Wait -FilePath  python -ArgumentList "$pip_installer"
    }
    else 
    {
        Write-Output "pip installed"
    }
}

<# Install Python #>
function Python_Install()
{
    Start-Sleep -Seconds 3

    $python_installer = "$tools_path\python-3.10.7-amd64.exe"

    if (!(Test-Path $python_installer))
    {
        Write-Output "Downloading $Required_Version_Python"
        Import-Module BitsTransfer
        Start-BitsTransfer -Source $DOWNLOAD_LINK_PYTHON -Destination $python_installer
    }

    Write-Output "Installing $Required_Version_Python"
    Start-Process -Wait -FilePath  $python_installer -ArgumentList "/passive InstallAllUsers=1 PrependPath=1 Include_test=0"

    # Refresh envirement variables
    Path_Refresh
}

<# Check if Python is installed #>
function Python_Check()
{
    Try
    {
        $python_version = & python --version

        if(!$python_version)
        {
            Write-Output "Python not installed"
            Python_Install

            return 'True'
        }

        if($python_version -like $Required_Version_Python)
        {
            return 'True'
        }

        return 'False'
    }
    Catch
    {
        Write-Output "Python not installed"
        Python_Install
    }

    return 'True'
}

<# Install STM32CubeProgrammer #>
function STM32CubeProg_Install()
{
    $stm32cubeprg = "$tools_path\en.stm32cubeprg-win64_v2-11-0.zip"

    if (!(Test-Path $stm32cubeprg))
    {
      Write-Output "Downloading STM32CubeProgrammer"
      Import-Module BitsTransfer
      Start-BitsTransfer -Source $DOWNLOAD_LINK_STM32_CUBE_PROG -Destination "$tools_path\en.stm32cubeprg-win64_v2-11-0.zip"
    }
  
     $stm32cubeprg_extract = "$tools_path\stm32cubeprg"

     if (!(Test-Path $stm32cubeprg_extract))
     {
       #Unzip STM32CubeProgrammer
       Expand-Archive $stm32cubeprg $stm32cubeprg_extract
     }

     Write-Output "Installing $Required_Version_STM32CubeProgrammer"

     Start-Process  -Wait -FilePath  $stm32cubeprg_extract"\SetupSTM32CubeProgrammer_win64.exe"
}

<# Check STM32CubeProgrammer is installed #>
function STM32CubeProg_Check
{
    if (Test-Path -Path $PATH_STM32CubeProgrammer_CLI)
    {
        Write-Output "STM32CubeProgrammer exist"
      & $PATH_STM32CubeProgrammer_CLI "--version" |  Out-String | Set-Content $log_path\STM32CubeProgrammer_version.txt

      foreach($line in Get-Content $log_path\STM32CubeProgrammer_version.txt) 
      {
        if($line -match $regex)
        {
            if ($line.Contains($Required_Version_STM32CubeProgrammer))
            {
                return "True"
            }
        }
      }

      return 'False'
    }

    STM32CubeProg_Install

     return "True"
}

<# Check if PC is connected to internet #>
function Internet_Connection_Check
{
    Write-Output "Checking Internet connection"

    return Test-Connection -ComputerName www.st.com -Quiet
}

<# Install X-CUBE-AZURE #>
function X_CUBE_AZURE_Install()
{
    $x_cube_azure = "$tools_path\en.x-cube-azure_v2-1-0.zip"

    if (!(Test-Path $x_cube_azure))
    {
        Write-Output "Downloading X-CUBE-AZURE"
      Import-Module BitsTransfer
      Start-BitsTransfer -Source $DOWNLOAD_LINK_X_CUBE_AZURE -Destination "$tools_path\en.x-cube-azure_v2-1-0.zip"
    }
  
    Write-Output "Installing X-CUBE-AZURE to C: drive"
    Expand-Archive "$tools_path\en.x-cube-azure_v2-1-0.zip" "C:\."
}

<# Check X-CUBE-AZURE #>
function X_CUBE_AZURE_Check
{
  if (Test-Path -Path $PATH_STM32CubeExpansion_Cloud_AZURE) 
  {
    Write-Output "STM32CubeExpansion_Cloud_AZURE OK"  | Green
    return
  }

  X_CUBE_AZURE_Install
}

<# Create tools directory #>
function ToolsDir_Create()
{
  If(!(test-path -PathType container $tools_path))
  {
      New-Item -ItemType Directory -Path $tools_path
  }

  If(!(test-path -PathType container $log_path))
  {
      New-Item -ItemType Directory -Path $log_path
  }
}

function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

function Red
{
    process { Write-Host $_ -ForegroundColor Red }
}

function White
{
    process { Write-Host $_ -ForegroundColor White }
}

<#  Script start #>
Write-Output "Script version: $Script_Version"   | Green
Write-Output "$copyright"
Write-Output "$privacy"

# Refresh envirement variables
Path_Refresh

# Create tools directory
ToolsDir_Create

# Check if PC is connected to Internet
$connection_status = Internet_Connection_Check

"$connection_status"

if(!($connection_status -like 'True'))
{
    Write-Output "You are not connected to Internet. Please connect to Internet and run the script again" | Red
    Start-Sleep -Seconds 2
    Exit 1
}

Write-Output "You are connected to Internet."  | Green

# Check if X-CUBE-AZURE is installed
X_CUBE_AZURE_Check

# Check if STM32CubeProg_Check is installed
 $value = STM32CubeProg_Check

if(!($value -like 'True'))
{
    Write-Output "STM32CubeProgrammer version error"  | Red
    Write-Output "Required version : $Required_Version_STM32CubeProgrammer"
    Write-Output "please Uninstall STM32CubeProgrammer and run the script again"

    Start-Sleep -Seconds 5
    Exit 1
}

Write-Output "STM32CubeProgrammer version OK"   | Green

$value = Python_Check

if(!($value -like 'True'))
{
    Write-Output "Python version error"  | Red
    Write-Output "Required version : $Required_Version_Python"
    Write-Output "please Uninstall Python and run the script again"

    Start-Sleep -Seconds 5
    Exit 1
}

Write-Output "Python version OK"   | Green

Python_Pip_Check

Python_Modules_Install

$value = AZCLI_Check

if(!($value -like 'True'))
{
    Write-Output "AZCLI version error"  | Red
    Write-Output "Required version : $Required_Version_AZCLI"
    Write-Output "please Uninstall AZCLI and run the script again"

    Start-Sleep -Seconds 5
    Exit 1
}

Write-Output "AZCLI version OK" | Green

$value = AZCLI_Extensions_Install

if(!($value -like 'True'))
{
    Write-Output "Issue installing AZ extensions"  | Red
    Start-Sleep -Seconds 5
    Exit 1
}

Write-Output "System check successful" | Green
Exit 0

# Locgin to Azure account
$value = AZCLI_Login

if(!($value -like 'True'))
{
    Write-Output "AZCLI login error. Please run the script again and try to login again"   | Red

    Start-Sleep -Seconds 5
    Exit 1
}

Write-Output "Successful AZ login" | Green

& python .\scripts\configureJson.py

Start-Process $PATH_STM32CubeExpansion_Cloud_AZURE

Exit 0
