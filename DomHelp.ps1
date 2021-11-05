
$URL = "https://www.designerwear.co.uk/replay"

# Invoke Webrequest to given Link
$MyResult = Invoke-WebRequest -Uri $URL -UseBasicParsing
start-sleep -Seconds 5 
write-host "$($MyResult.Count) Records Returned"

$mainElement = $MyResult.ParsedHtml.body.getElementsByTagName('div')
Write-Host $mainElement | Format-List

$HTML = New-Object -Com "HTMLFile"
$src = $MyResult.RawContent
$HTML.IHTMLDocument2_write($src)

$LinkList = $HTML.all.tags("a") | Where-Object { $_.href -like "*Product*" } 
$Linklist | Select-Object -First 1

$productLinks = @()

# Store all links that relate to products
foreach ($obj in $Linklist) { 
    If ($obj.href -like "*product*") {
        $hrefText = $obj.href
        $newHrefText = $hrefText -replace ".*:"
        $productLinks += $newHrefText
    }
}

$productLinks = $productLinks | select-object -Unique

# Filter through links and store 'clean' links
$cleanLinks = @()
foreach ($link in $productLinks) {
    If ( $link -notmatch '#' ) {
        $cleanLinks += $link
    }
}

# Build Product Links
$readyLinks = @()
$baseURL = "https://www.designerwear.co.uk"
foreach ($link in $cleanLinks) {
    $builtLink = $baseURL + $link
    $readyLinks += $builtLink
}


# Check if URL is Live
foreach ($productLink in $readyLinks) {
    $HTTP_Request = [System.Net.WebRequest]::Create($productLink)
    $HTTP_Response = $HTTP_Request.GetResponse()
    $HTTP_Status = [int]$HTTP_Response.StatusCode
    If ($HTTP_Status -eq 200) { Write-Host $productLink" is OK!" }
    Else { Write-Host "Site may be down, or link broken!" }
    If ($HTTP_Response -eq $null) { }
    Else { $HTTP_Response.Close() }
}


$cloudfrontImgSources = @()
$finalImageLinks = @()
$productCodes = @()

# Navigate to each product link, and store image sources - NOT WORKING
foreach ($productLink in $readyLinks) {
    $page = Invoke-WebRequest -Uri $productLink
    $pageContent = $page.Content
    start-sleep -Seconds 5
    $page -match '<p>Product Code: (?<productCode>.*?)</p>'
    $productCodes += $Matches['productCode']
    $images = $page.Images
    # $testImage = $images[22]
    $imageSources = @()
    foreach ($image in $images) {
        # Write-Host $image.src
        $imageSources += $image.src
    }
    foreach ($imgSource in $imageSources) {
        If ($imgSource -match 'cloudfront' -and $imgSource -notmatch 'blocks') {
            # Write-Host "True"
            $cloudfrontImgSources += $imgSource
        }
        Else {
            # Write-Host "False"
        }
    }
    foreach ($link in $cloudfrontImgSources) {
        $resolution = $link.SubString(52,7)
        $integer = [int]$resolution.SubString(0,3)
        If ($integer -gt 400) {
            $finalImageLinks += $link
            Write-Host $resolution "- Resolution looks good!"
        }
        Else {
            Write-Host $resolution "- Resolution too low."
        }
    }
    $cloudfrontImgSources = @()
}

$outputData = [pscustomobject]@{ }
$outputDataTemp = @{}

# Just need to fix the below to ouput correctly!
#[string]$csvPath = 'C:\Users\Dom\Documents\DesignerWear\Software\Sandbox\Powershell\WebScrape\test.csv'
[string]$csvPath = 'C:\Temp\test.csv'

$finalImageLinks | ForEach-Object{ [pscustomobject]$_ } | Export-CSV -Path $csvPath -NoTypeInformation