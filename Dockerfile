FROM mcr.microsoft.com/windows/servercore:ltsc2019

LABEL maintainer="cremator"

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Invoke-WebRequest https://github.com/bazarr/bazarr.github.io/releases/latest/download/bazarr.zip -OutFile c:\bazarr.zip ; \
    Expand-Archive c:\bazarr.zip -DestinationPath C:\ ; \
    Remove-Item -Path c:\bazarr.zip -Force; \
	Start-Process "C:\Bazarr.exe" -ArgumentList '/VERYSILENT /NORESTART /SP- /SUPPRESSMSGBOXES' -Wait; \	
	Start-Sleep -s 10; \
	Stop-Service -name "Bazarr" -Force -ErrorAction SilentlyContinue; \
	Start-Sleep -s 10; \
	Remove-Item "C:/Bazarr.exe" -Force; \
	Remove-Item "C:/ProgramData/Bazarr" -Force -Recurse
RUN net user bazarr secretPassw0rd /add
RUN net localgroup Administrators bazarr /add
RUN	sc.exe config "Bazarr" obj= ".\bazarr" password= "secretPassw0rd"

EXPOSE 6767

VOLUME [ "C:/ProgramData/Bazarr" ]

CMD "if (!(Test-Path C:\ProgramData\bazarr\log\bazarr.log)) { Start-Sleep 10 } else { Get-Content C:\ProgramData\bazarr\log\bazarr.log -Wait }"