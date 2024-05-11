$price = "tierDiscouted" # tierFree
$region = "ru" # en-US
$count = "500"
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

# v3 (2nd query from trace in browser)
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

Write-Host "---------------------- Content ----------------------"
Write-Host $content
Write-Host "---------------------- Content ------------------------"

# Get json from html
$json = $($($($content -split "__REACT_QUERY_INITIAL_QUERIES__ = ")[1] -split "window.server_rendered")[0] -replace ";")

# Data filtering
$games = $($json | ConvertFrom-Json).queries.state.data[-1].catalog.searchStore.elements

# Output formatting
$Collections = New-Object System.Collections.Generic.List[System.Object]
foreach ($game in $games) {
    $Collections.Add([PSCustomObject]@{
        Title           = $game.title
        Developer       = $game.developerDisplayName
        publisher       = $game.publisherDisplayName
        Description     = $game.description
        Url             = "https://store.epicgames.com/$region/p/$($game.offerMappings.pageSlug)"
        ReleaseDate     = $game.releaseDate
        FullPrice       = $game.price.totalPrice.fmtPrice.originalPrice
        Discount        = "$(1-$($game.price.totalPrice.discountPrice)/$($game.price.totalPrice.originalPrice)*100) %"
        CurrentPrice    = $game.price.totalPrice.fmtPrice.discountPrice
    })
}

# Save file
$path = "${env:GITHUB_WORKSPACE}/api/free/index.json"
$Collections | ConvertTo-Json -Depth 10 | Out-File $path