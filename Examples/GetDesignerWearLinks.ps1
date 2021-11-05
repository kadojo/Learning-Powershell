

$URL = "https://www.designerwear.co.uk/sale"

$MyResult = Invoke-WebRequest -Uri $URL -UseBasicParsing

start-sleep -Seconds 5 
write-host "$($MyResult.Count) Records Returned"
 
$HTML = New-Object -Com "HTMLFile"
$src = $MyResult.RawContent
$HTML.IHTMLDocument2_write($src)

# $HTML.all | Format-List

# $HTML.all.tags("a") | Select-object uniqueID, href | Format-Table -AutoSize 
$HTML.all.tags("a") | Select-object uniqueID, href | Where-Object { $_.href -like "*Product*" } | Format-Table -AutoSize 

$LinkList = $HTML.all.tags("a") | Where-Object { $_.href -like "*Product*" } 
$Linklist | Select-Object -First 1

# foreach ($obj in $HTML.all.tags("a")) { 
foreach ($obj in $Linklist) { 
    If ($obj.href -like "*product*") {
        Write-Host "Oh a product, think I will load this page and play [$($obj.href)]"
    }
    else {
        Write-Host "NOT interested in this page [$($obj.href)]"
    }
} 
