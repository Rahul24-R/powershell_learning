# Installing any application remotely encounters double hop issue when it tries connects to SQL remotely.
    # We followed this article to work around this issue. https://4sysops.com/archives/solve-the-powershell-multi-hop-problem-without-using-credssp/
    # We also ensure what ever settings we set to avoid double hop are reverted after the installation.



   $cred = Get-Credential
   $remoteSession = New-PSSession -ComputerName "machinename(XXX)" -Credential $cred -ErrorAction Stop
   $configstr = "PSSConfig_$((Get-Date).ToString('hh-mm-ss'))"     #just a string value to give for the configuration name
    Invoke-Command -Session $script:remoteSession -ScriptBlock {    
        Write-Output "$(Get-Date) - Configuring PSSessionConfiguration $using:configstr"
        Write-Host " $(Register-PSSessionConfiguration -Name $using:configstr -RunAsCredential $using:cred )"        
    } # Configuring double hop settings
        
    Invoke-Command  -ComputerName $script:currentnode -Credential $script:cred -ScriptBlock {   
        . "C:\SilentInstaller\installscript.ps1"  -param1 $using:value1 -param2 $using:value2 #executing this script on the remote machine
    } -ConfigurationName $configstr     #needs to have this configuration name



   Invoke-Command -Session $script:remoteSession -ScriptBlock {    
        Write-Output "$(Get-Date) - Removing PSSessionConfiguration $using:configstr"
        write-Host "$(UnRegister-PSSessionConfiguration -Name $using:configstr)"    
    }# Undoing double hop config  settings