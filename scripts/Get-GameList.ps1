$pathFree     = "${env:GITHUB_WORKSPACE}/api/free/index.json"
$pathDiscount = "${env:GITHUB_WORKSPACE}/api/discount/index.json"
$pathGiveaway = "${env:GITHUB_WORKSPACE}/api/giveaway/index.json"

function Get-GameList {
    param (
        [ValidateSet("tierFree","tierDiscouted")][string]$Price,
        [ValidateSet("en-US","ru")][string]$Region,
        [ValidateRange(100,500)][int]$Count
    )
    $url = "https://store.epicgames.com/$region/browse?sortBy=releaseDate&sortDir=DESC&priceTier=$($price)&category=Game&count=$($count)&start=0"
    $Agents = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
    
    # v1 (HttpClient)
    # $handler = New-Object System.Net.Http.HttpClientHandler
    # $handler.AllowAutoRedirect = $true
    # $HttpClient = New-Object System.Net.Http.HttpClient($handler)
    # $requestMessage = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get, $url)
    # $requestMessage.Headers.Add("User-Agent", $userAgent)
    # $requestMessage.Headers.Add("Accept", "text/html")
    # $response = $HttpClient.SendAsync($requestMessage).Result
    # $content = $response.Content.ReadAsStringAsync().Result

    # v2 (WebClient)
    # $WebClient = New-Object System.Net.WebClient
    # $userAgent = Get-Random -InputObject $Agents
    # $WebClient.Headers.Add("User-Agent", $userAgent)
    # $WebClient.Headers.Add("Accept", "text/html")
    # $content = $WebClient.DownloadString($url)

    $session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
    $session.UserAgent = $Agents
    $response = Invoke-WebRequest -Uri $url -WebSession $session -Headers @{
        "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
        "Service-Worker-Navigation-Preload"="true"
        "Upgrade-Insecure-Requests"="1"
        "sec-ch-ua"="`"Chromium`";v=`"124`", `"Google Chrome`";v=`"124`", `"Not-A.Brand`";v=`"99`""
        "sec-ch-ua-mobile"="?0"
        "sec-ch-ua-platform"="`"Windows`""
    }
    $content = $response.Content

    # Write-Host "---------------------- Content ----------------------"
    # Write-Host $content
    # Write-Host "---------------------- Content ------------------------"

    # Get json from html
    $json = $($($($content -split "__REACT_QUERY_INITIAL_QUERIES__ = ")[1] -split "window.server_rendered")[0] -replace ";")
    # Data filtering
    $games = $($json | ConvertFrom-Json).queries.state.data[-1].catalog.searchStore.elements

    # Output formatting
    $Collections = New-Object System.Collections.Generic.List[System.Object]
    if ($Price -eq "tierFree") {
        foreach ($game in $games) {
            $Collections.Add([PSCustomObject]@{
                Title           = $game.title
                Developer       = $game.developerDisplayName
                Publisher       = $game.publisherDisplayName
                Description     = $game.description
                Url             = "https://store.epicgames.com/$region/p/$($game.offerMappings.pageSlug)"
                ReleaseDate     = $game.releaseDate
                FullPrice       = $game.price.totalPrice.fmtPrice.originalPrice
                CurrentPrice    = $game.price.totalPrice.fmtPrice.discountPrice
                DiscountEndDate = $game.price.lineOffers.appliedRules.endDate
            })
        }
    }
    else {
        foreach ($game in $games) {
            $Collections.Add([PSCustomObject]@{
                Title           = $game.title
                Developer       = $game.developerDisplayName
                Publisher       = $game.publisherDisplayName
                Description     = $game.description
                Url             = "https://store.epicgames.com/$region/p/$($game.offerMappings.pageSlug)"
                ReleaseDate     = $game.releaseDate
                FullPrice       = $game.price.totalPrice.fmtPrice.originalPrice
                Discount        = [string]$([math]::Round((1 - ($($game.price.totalPrice.discountPrice) / $($game.price.totalPrice.originalPrice))) * 100, 2)) + " %"
                CurrentPrice    = $game.price.totalPrice.fmtPrice.discountPrice
                DiscountEndDate = $game.price.lineOffers.appliedRules.endDate
            })
        }
    }
    $Collections
}

### Save json files (for api)

$Free = Get-GameList -Price tierFree -Region en-US -Count 500
if ($null -ne $Free) {
    $Free | ConvertTo-Json -Depth 10 | Out-File $pathFree
}

$Discount = Get-GameList -Price tierDiscouted -Region en-US -Count 500
if ($null -ne $Discount) {
    $Discount | ConvertTo-Json -Depth 10 | Out-File $pathDiscount
}

$Giveaway = $Free | Where-Object FullPrice -ne 0
if ($null -ne $Giveaway) {
    $Giveaway | ConvertTo-Json -Depth 10 | Out-File $pathGiveaway
}

Function ConvertTo-Markdown {
    [CmdletBinding()]
    [OutputType([string])]
    Param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true
        )]
        [PSObject[]]$InputObject
    )
    Begin {
        $items = @()
        $columns = @{}
    }
    Process {
        ForEach($item in $InputObject) {
            $items += $item
            $item.PSObject.Properties | ForEach-Object {
                if($null -ne $_.Value) {
                    if(-not $columns.ContainsKey($_.Name) -or $columns[$_.Name] -lt $_.Value.ToString().Length) {
                        $columns[$_.Name] = $_.Value.ToString().Length
                    }
                }
            }
        }
    }
    End {
        ForEach($key in $($columns.Keys)) {
            $columns[$key] = [Math]::Max($columns[$key], $key.Length)
        }
        $header = @()
        ForEach($key in $columns.Keys) {
            $header += ('{0,-' + $columns[$key] + '}') -f $key
        }
        $header -join ' | '
        $separator = @()
        ForEach($key in $columns.Keys) {
            $separator += '-' * $columns[$key]
        }
        $separator -join ' | '
        ForEach($item in $items) {
            $values = @()
            ForEach($key in $columns.Keys) {
                $values += ('{0,-' + $columns[$key] + '}') -f $item.($key)
            }
            $values -join ' | '
        }
    }
}

### Generated Markdown

"## Giveaway" | Out-File index.md
$giveawayGitHub = Invoke-RestMethod "https://lifailon.github.io/epic-games-radar/api/giveaway" | Select-Object Title,CurrentPrice,FullPrice,DiscountEndDate,Developer,Publisher,Url,ReleaseDate
$giveawayGitHub | ConvertTo-Markdown | Out-File index.md -Append

"## Discount" | Out-File index.md -Append
$discountGitHub = Invoke-RestMethod "https://lifailon.github.io/epic-games-radar/api/discount" | Select-Object Title,Discount,CurrentPrice,FullPrice,DiscountEndDate,Developer,Publisher,Url,ReleaseDate
$discountGitHub | ConvertTo-Markdown | Out-File index.md -Append

"## Free" | Out-File index.md -Append
$freeGitHub = Invoke-RestMethod "https://lifailon.github.io/epic-games-radar/api/free" | Select-Object Title,CurrentPrice,FullPrice,DiscountEndDate,Developer,Publisher,Url,ReleaseDate
$freeGitHub | ConvertTo-Markdown | Out-File index.md -Append


# Markdown to HTML
$md = $(Get-Content index.md -Raw | ConvertFrom-Markdown).html

$html = @"
<!DOCTYPE html>
<html>
<head>
    <style>
        table {
            border-collapse: collapse;
            width: 100%;
        }
        th, td {
            border: 1px solid black;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
$md
</body>
</html>
"@

$html | Out-File "index.html"