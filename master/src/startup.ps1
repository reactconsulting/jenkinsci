$ProgressPreference = 'SilentlyContinue'

# Show container informations
$ip = Get-NetAdapter | 
      Select-Object -First 1 | 
      Get-NetIPAddress | 
      Where-Object { $_.AddressFamily -eq "IPv4"} |
      Select-Object -Property IPAddress | 
      ForEach-Object { $_.IPAddress }

Write-Host "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = " -ForegroundColor Yellow
Write-Host "JENKINS MASTER CONTAINER" -ForegroundColor Yellow
Write-Host ("Started at:     {0}" -f [DateTime]::Now.ToString("yyyy-MMM-dd HH:mm:ss.fff")) -ForegroundColor Yellow
Write-Host ("Container Name: {0}" -f $env:COMPUTERNAME) -ForegroundColor Yellow
Write-Host ("Container IP:   {0}" -f $ip) -ForegroundColor Yellow
Write-Host ("Access URL:     http://{0}:8080" -f $ip) -ForegroundColor Yellow
Write-Host "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = " -ForegroundColor Yellow

# Get jenkins configuration
$configuration = Get-Content $PSScriptRoot/configuration.json | ConvertFrom-Json

# Download plugins
if(Test-Path $PSScriptRoot/configuration.json) {
    $configuration.plugins |
        ForEach-Object {
            $plugin = $_
            $url = "$env:JENKINS_UC/download/plugins/$plugin/latest/${plugin}.hpi"

            if (Test-Path "$env:JENKINS_HOME/plugins/${plugin}.jpi") {
                Write-Host "Skipping plugin:`t[$plugin]"
            }
            else {
                Write-Host "Downloading plugin:`t[$plugin]`tfrom`t$url"
                Invoke-WebRequest -Uri $url -OutFile "$env:JENKINS_HOME/plugins/${plugin}.jpi" -UseBasicParsing -ErrorAction SilentlyContinue
            }
        }
}

& 'java' '-jar' 'jenkins.war'