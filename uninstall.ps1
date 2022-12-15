$tools_path = ".\tools"
$log_path   = ".\log"

Remove-Item -LiteralPath "$tools_path" -Force -Recurse
Remove-Item -LiteralPath "$log_path"   -Force -Recurse

& az extension remove --name azure-iot
& az extension remove --name account

& python -m pip uninstall pyserial
& python -m pip uninstall pip 

Get-Package "*az*" | Uninstall-Package
Get-Package "*python*" | Uninstall-Package

