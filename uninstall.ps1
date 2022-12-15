& python -m pip uninstall pyserial
& python -m pip uninstall pip 
& pip uninstall pip
Get-Package "*python*" | Uninstall-Package

& az extension remove --name azure-iot
& az extension remove --name account
Get-Package "*az*" | Uninstall-Package