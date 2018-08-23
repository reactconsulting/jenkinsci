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
#   - Name: reactconsulting/jekins-master
#   - Tags: latest
#
# Example build: docker build -t "reactconsulting/jenkins-master:latest" ./
# -----------------------------------

# Reference staged image
FROM reactconsulting/windowsservercore-ltsc2016-git as git

# Set start image
FROM reactconsulting/windowsservercore-openjdk:8

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

# Download jenkins latest version for Windows
# http://mirrors.jenkins-ci.org
ENV JENKINS_HOME=C:\\Jenkins
ENV JENKINS_WORKPACE=C:\\Workspace
VOLUME $JENKINS_HOME
VOLUME $JENKINS_WORKPACE

RUN \
    $newPath = ('{0};{1}' -f $env:JENKINS_HOME, $env:PATH); \
    Write-Host ('Updating PATH: {0}' -f $newPath); \
    setx /M PATH $newPath

ARG jenkins_version=latest
ENV JENKINS_VERSION=$jenkins_version
ENV JENKINS_UC='https://updates.jenkins.io'
RUN \
    Write-Host ('===== JENKINS ====='); \
    $jenkins_base_path = 'http://mirrors.jenkins-ci.org/war'; \
    $uri = ('{0}/{1}/jenkins.war' -f $jenkins_base_path, $env:JENKINS_VERSION); \
    Write-Host ('Downloading {0} ...' -f $uri); \
    Invoke-WebRequest \
        -Uri $uri \
        -UseBasicParsing \
        -OutFile jenkins.war; \
    Invoke-WebRequest \
        -Uri $jenkins_base_path/$env:JENKINS_VERSION/jenkins.war.sha256 \
        -UseBasicParsing \
        -OutFile jenkins.war.sha256; \
    $checksum = ('{0}' -f (Get-Content jenkins.war.sha256).Split('{ }')[0]).ToLower(); \
    Write-Host ('Verifying sha256 ({0}) ...' -f $checksum); \
    if ((Get-FileHash jenkins.war -Algorithm sha256).Hash.ToLower() -ne $checksum) { \
		Write-Host 'FAILED!'; \
		exit 1; \
    }; \
    Write-Host 'Verifying install ...'; \
    Write-Host ('  java -jar jenkins.war --version'); java -jar jenkins.war --version; \
	Write-Host 'Removing ...'; \
	Remove-Item jenkins.war.sha256 -Force; \
	Write-Host 'Complete.';

# Expose port for user interface
EXPOSE 8080

# Expose port for communicating with slave containers
EXPOSE 50000

COPY src /scripts

CMD [ "powershell", "C:/scripts/startup.ps1" ]