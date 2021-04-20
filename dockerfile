# escape=`

FROM mcr.microsoft.com/windows/servercore/iis

ADD source c:\source

RUN C:\source\SQLEXPR_x64_ENU\SETUP.exe /Q /ACTION=INSTALL /FEATURES=SQLENGINE /INSTANCENAME=MSSQLSERVER /SECURITYMODE=SQL /SAPWD="P@ssword!" /SQLSVCACCOUNT="NT AUTHORITY\System" /AGTSVCACCOUNT="NT AUTHORITY\System" /SQLSYSADMINACCOUNTS="BUILTIN\Administrators" /IACCEPTSQLSERVERLICENSETERMS=1 /TCPENABLED=1 /UPDATEENABLED=False

RUN powershell -Command " `
 Remove-Item C:\source -Recurse `
"

RUN powershell -NoProfile -Command Remove-Item -Recurse C:\inetpub\wwwroot\*

RUN powershell -Command " `
 Install-WindowsFeature Web-Server,Web-Asp-Net45,Web-Mgmt-Service,web-windows-auth,web-dyn-compression,web-http-redirect -Verbose ; `
 New-ItemProperty -Path HKLM:\software\microsoft\WebManagement\Server -Name EnableRemoteManagement -Value 1 -Force ; `
 Set-Service -Name wmsvc -StartupType Automatic ; `
 New-LocalUser iisadmin -Password ( 'P@ssword!' | ConvertTo-SecureString -AsPlainText -Force) ; `
 Add-LocalGroupMember -Group Administrators -Member iisadmin `
"
WORKDIR /inetpub/wwwroot

COPY content/ .

ENTRYPOINT "ping -t localhost > NULL"