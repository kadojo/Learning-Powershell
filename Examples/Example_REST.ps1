<#
Invoke-RestMethod -Method "GET" -ContentType "application/json" -Credential $NuciCreds -Proxy "http://vrhbarcwg20:8080" -ProxyUseDefaultCredentials -OutFile "\cUrlResult.json"
      [-Method <WebRequestMethod>]
      [-UseBasicParsing]
      [-Uri] <Uri>
      [-WebSession <WebRequestSession>]
      [-SessionVariable <String>]
      [-Credential <PSCredential>]
      [-UseDefaultCredentials]
      [-CertificateThumbprint <String>]
      [-Certificate <X509Certificate>]
      [-UserAgent <String>]
      [-DisableKeepAlive]
      [-TimeoutSec <Int32>]
      [-Headers <IDictionary>]
      [-MaximumRedirection <Int32>]
      [-Proxy <Uri>]
      [-ProxyCredential <PSCredential>]
      [-ProxyUseDefaultCredentials]
      [-Body <Object>]
      [-ContentType <String>]
      [-TransferEncoding <String>]
      [-InFile <String>]
      [-OutFile <String>]
      [-PassThru]
      [<CommonParameters>]
#>

Import-Module $PSScriptRoot"\Source\cURL\cURL.psm1" -Force
 
#Prompt For Credentials
#$Credential = $host.ui.PromptForCredential("Need credentials", "Please enter your user name and password.", "", "MyLoginName")
 
# ScriptSetCredentials
$global:User = "loginname"
$global:PWord = ConvertTo-SecureString -String "pwd123" -AsPlainText -Force
$global:Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
 
#Use Credentials
$global:MyCreds = Get-Credential -credential $Credential
 
#Build Params rather than manually add the lon list to the command later
$Params = @{'Method' = 'GET';
            'ContentType' = 'application/json'; 
            'Credential' = $MyCreds ;
           # 'OutFile' =  $PSScriptRoot + '\cUrlResult.json';
            'Uri' = 'https://'
}

$MyResult = Invoke-RestMethod @Params
 
$MyResult
 
#Added Sleep Because the write-host ppeared before result.
start-sleep -Seconds 3 
write-host "$($MyResult.Count) Records Returned"
 
 
