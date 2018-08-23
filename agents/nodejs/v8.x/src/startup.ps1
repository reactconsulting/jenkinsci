$ProgressPreference = 'SilentlyContinue'

# Show container informations
$ip = Get-NetAdapter | 
      Select-Object -First 1 | 
      Get-NetIPAddress | 
      Where-Object { $_.AddressFamily -eq "IPv4"} |
      Select-Object -Property IPAddress | 
      ForEach-Object { $_.IPAddress }

Write-Host "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = " -ForegroundColor Yellow
Write-Host "JENKINS AGENT CONTAINER" -ForegroundColor Yellow
Write-Host ("Started at:     {0}" -f [DateTime]::Now.ToString("yyyy-MMM-dd HH:mm:ss.fff")) -ForegroundColor Yellow
Write-Host ("Container Name: {0}" -f $env:COMPUTERNAME) -ForegroundColor Yellow
Write-Host ("Container IP:   {0}" -f $ip) -ForegroundColor Yellow
Write-Host ("Access URL:     http://{0}" -f $ip) -ForegroundColor Yellow
Write-Host "= = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = = " -ForegroundColor Yellow

& 'java' '-jar' 'agent.jar' '-jnlpUrl' ("http://{0}/computer/{1}/slave-agent.jnlp" -f $env:JENKINS_MASTER_HOST, $env:JENKINS_AGENT_ID) '-secret' $env:JENKINS_SECRET '-workDir' $env:JENKINS_WORKDIR '-failIfWorkDirIsMissing'