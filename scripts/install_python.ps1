$url = "https://www.python.org/ftp/python/3.10.7/python-3.10.7-amd64.exe"

$output = "C:/tmp/python-3.10.7-amd64.exe"

New-Item -ItemType Directory -Force -Path C:/tmp

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $output


& $output /passive InstallAllUsers=1 PrependPath=1 Include_test=0 