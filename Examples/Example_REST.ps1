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

 
#Prompt For Credentials
#$Credential = $host.ui.PromptForCredential("Need credentials", "Please enter your user name and password.", "", "MyLoginName")
 
# ScriptSetCredentials
$global:User = "loginname"
$global:PWord = ConvertTo-SecureString -String "pwd123" -AsPlainText -Force
$global:Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
 
#Use Credentials
$global:MyCreds = Get-Credential -credential $Credential
 
$URL = "https://www.designerwear.co.uk/sale"

#Build Params rather than manually add the lon list to the command later
$Params = @{'Method' = 'GET';
            'ContentType' = 'application/json'; 
            'Credential' = $MyCreds ;
           # 'OutFile' =  $PSScriptRoot + '\cUrlResult.json';
            'Uri' = $URL
}
# $MyResult = Invoke-RestMethod @Params


$MyResult = Invoke-WebRequest -Uri $URL -UseBasicParsing
 
# $MyResult
 
#Added Sleep Because the write-host ppeared before result.
start-sleep -Seconds 3 
write-host "$($MyResult.Count) Records Returned"
 
# $MyResult = Invoke-WebRequest -Uri $url -UseBasicParsing
$HTML = New-Object -Com "HTMLFile"
$src = $MyResult.RawContent
# $HTML.write($src)
$HTML.IHTMLDocument2_write($src)

$HTML.all | Format-List

# $HTML | Out-File ".\kjtest.txt"
$src | Out-File ".\kjtest2.txt"

$HTML.all.tags("a") | Select-object uniqueID, href | Format-Table -AutoSize 

foreach ($obj in $HTML.all) { 
    $obj.getElementsByClassName('a') 
} 


$wc = New-Object System.Net.WebClient
$req = Invoke-WebRequest -Uri "https://theautomationcode.com/feed/"
$images = $req.Images | Select -ExpandProperty src
$count = 0
foreach($img in $images){    
   $wc.DownloadFile($img,"C:\Temp\WebImages\img$count.jpg")
}