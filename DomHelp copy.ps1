
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
$wc = New-Object System.Net.WebClient
foreach ($productLink in $readyLinks) {
    Write-Host "NextLink : $($Productlink)"
    If ($ProductLink -match "product") {
        $ProdLinkName = $ProductLink.Substring($ProductLink.IndexOf('product/') + 8)
        Write-Host "`tSearching for images in [$($ProdLinkName)]"
        $page = Invoke-WebRequest -Uri $productLink # -UseBasicParsing
        Write-host "`tlooking for product code [This can take a while]"


        # instead of just $page, would these checks be quicker?
        # $page.RawContent
        # outerHTML                    : <a class="product-card__link w-full inline-block bg-white group" href="/product/replay-grey-hyperflex-bio-anbass-slim-fit-jean-19848">
        # lassName                    : product-card__link w-full inline-block bg-white group
        # or searching .Document ?

        $CheckStr = $page.RawContent.ToString()
        IF ($CheckStr -match 'class="container product') {
            # IF ($page -match '<p>Product Code: (?<productCode>.*?)</p>') {
            $images = $page.Images | Select-object -ExpandProperty src
            $imageSources = @()
            Write-Host "`t`tDownloading Images"
            $count = 0
            foreach ($image in $images) {
                if ($image -match "jpg" -Or $image -match "png") {
                    $count += 1
                    Write-host "`t`t`tDownloading $($Image)"
                    $wc.DownloadFile($image, "C:\Temp\WebImages\$($ProdLinkName)-img$count.jpg")
                }
            }
            Write-Host "Finished downloading images"
        }
    }

}

$outputData = [pscustomobject]@{ }
$outputDataTemp = @{}

# Just need to fix the below to ouput correctly!
#[string]$csvPath = 'C:\Users\Dom\Documents\DesignerWear\Software\Sandbox\Powershell\WebScrape\test.csv'
[string]$csvPath = 'C:\Temp\test.csv'

# $finalImageLinks | ForEach-Object{ [pscustomobject]$_ } | Export-CSV -Path $csvPath -NoTypeInformation