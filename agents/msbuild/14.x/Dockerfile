# -----------------------------------
# Author: Nicola Biancolini
#         nicola.biancolini@reactconsulting.it
#
# Company: React Consulting S.r.l.
#          http://reactconsulting.it
#
# Summary: Docker image for jenkins master.
#
# Container informations
#   - Name: reactconsulting/jenkins-agent-msbuild
#   - Tags: 14.x
#
# Example build: docker build -t "reactconsulting/jenkins-agent-msbuild:14.x" ./
# -----------------------------------

# Reference staged image for Nuget
FROM reactconsulting/windowsservercore-ltsc2016-nuget as nuget

# Reference staged image for Git
FROM reactconsulting/windowsservercore-ltsc2016-git as git

# Reference staged image for MSBuild 14.x
FROM reactconsulting/windowsservercore-ltsc2016-msbuild:14.x as msbuild

# Set start image
FROM reactconsulting/windowsservercore-openjdk:8
ENV NUGET_HOME=C:\\Nuget
RUN \
    $newPath = ('{0};{1}' -f $env:NUGET_HOME, $env:PATH); \
    Write-Host ('Updating PATH: {0}' -f $newPath); \
    setx /M PATH $newPath
COPY --from=nuget C:\\Nuget C:\\Nuget

ENV MSBUILD_HOME='C:\Program Files (x86)\MSBuild\14.0\Bin'
RUN \
    $newPath = ('{0};{1}' -f $env:MSBUILD_HOME, $env:PATH); \
    Write-Host ('Updating PATH: {0}' -f $newPath); \
    setx /M PATH $newPath
COPY --from=msbuild [ "C:/Program Files (x86)/MSBuild", "C:/Program Files (x86)/MSBuild" ]

ENV GIT_HOME=C:\\MinGit
RUN \
    $newPath = ('{0}\cmd;{1}' -f $env:GIT_HOME, $env:PATH); \
    Write-Host ('Updating PATH: {0}' -f $newPath); \
    setx /M PATH $newPath
COPY --from=git C:\\MinGit C:\\MinGit

# Set image labes
LABEL mantainer="Nicola Biancolini <nicola.biancolini@reactconsulting.it>"

# Set default shell for run command
SHELL ["powershell", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue'; "]

# Download jenkins slave from master for Windows
# http://mirrors.jenkins-ci.org
ENV JENKINS_HOME=C:\\Jenkins
ENV JENKINS_WORKPACE=C:\\Workspace
VOLUME $JENKINS_HOME
VOLUME $JENKINS_WORKPACE

RUN \
    $newPath = ('{0};{1}' -f $env:JENKINS_HOME, $env:PATH); \
    Write-Host ('Updating PATH: {0}' -f $newPath); \
    setx /M PATH $newPath

ENV JENKINS_SLAVE_VERSION=3.23
RUN \
    Write-Host ('===== JENKINS ====='); \
    $uri = ('https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/{0}/remoting-{0}.jar' -f $env:JENKINS_SLAVE_VERSION); \
    Write-Host ('Downloading {0} ...' -f $uri); \
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
    Invoke-WebRequest \
        -Uri $uri \
        -UseBasicParsing \
        -OutFile agent.jar; \
	Write-Host 'Complete.';

COPY src /scripts

CMD [ "powershell", "C:/scripts/startup.ps1" ]