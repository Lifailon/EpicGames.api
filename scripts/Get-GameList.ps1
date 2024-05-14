# ${env:GITHUB_WORKSPACE} = ".\"
$pathFree     = "${env:GITHUB_WORKSPACE}/api/free/index.json"
$pathDiscount = "${env:GITHUB_WORKSPACE}/api/discount/index.json"
$pathGiveaway = "${env:GITHUB_WORKSPACE}/api/giveaway/index.json"

function Get-GameList {
    param (
        [ValidateSet("tierFree","tierDiscouted")][string]$Price,
        [ValidateSet("en-US","ru")][string]$Region,
        [ValidateRange(100,500)][int]$Count
    )
    # $url = "https://store.epicgames.com/$region/browse?sortBy=releaseDate&sortDir=DESC&priceTier=tierDiscouted&category=Game&count=500&start=0"
    $url = "https://store.epicgames.com/en-US/browse?sortBy=releaseDate&sortDir=DESC&priceTier=$($price)&category=Game&count=$($count)&start=0"
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

    # Get json from html
    $json = $($($($content -split "__REACT_QUERY_INITIAL_QUERIES__ = ")[1] -split "window.server_rendered")[0] -replace ";")
    # Data filtering
    $games = $($json | ConvertFrom-Json).queries.state.data[-1].catalog.searchStore.elements

    # Output formatting
    $Collections = New-Object System.Collections.Generic.List[System.Object]
    if ($Price -eq "tierFree") {
        foreach ($game in $games) {
            $urlGame = $game.offerMappings.pageSlug
            if ($null -eq $urlGame) {
                $urlGame = $game.title.ToLower().replace(" ","-")
            }
            $Collections.Add([PSCustomObject]@{
                Title           = $game.title
                Developer       = $game.developerDisplayName
                Publisher       = $game.publisherDisplayName
                Description     = $game.description
                Url             = "https://store.epicgames.com/$region/p/$urlGame"
                ReleaseDate     = $game.releaseDate
                FullPrice       = $game.price.totalPrice.fmtPrice.originalPrice
                CurrentPrice    = $game.price.totalPrice.fmtPrice.discountPrice
                DiscountEndDate = $game.price.lineOffers.appliedRules.endDate
            })
        }
    }
    else {
        foreach ($game in $games) {
            $urlGame = $game.offerMappings.pageSlug
            if ($null -eq $urlGame) {
                $urlGame = $game.title.ToLower().replace(" ","-")
            }
            $Collections.Add([PSCustomObject]@{
                Title           = $game.title
                Developer       = $game.developerDisplayName
                Publisher       = $game.publisherDisplayName
                Description     = $game.description
                Url             = "https://store.epicgames.com/$region/p/$urlGame"
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

switch (Get-Random -InputObject @(1, 2)) {
    1 {
        Write-Host "---------------------- Start function Free ---------------------------"
        $Free = Get-GameList -Price tierFree -Region en-US -Count 500
        if ($null -ne $Free) {
            $Free | ConvertTo-Json -Depth 10 | Out-File $pathFree
        }
        Write-Host "---------------------- End function Free -----------------------------"
        
        Start-Sleep $(Get-Random -Minimum 15 -Maximum 45)

        Write-Host "---------------------- Start function Discouted ----------------------"
        $Discount = Get-GameList -Price tierDiscouted -Region en-US -Count 500
        if ($null -ne $Discount) {
            $Discount | ConvertTo-Json -Depth 10 | Out-File $pathDiscount
        }
        Write-Host "---------------------- End function Discouted ------------------------"
    }
    2 {
        Write-Host "---------------------- Start function Discouted ----------------------"
        $Discount = Get-GameList -Price tierDiscouted -Region en-US -Count 500
        if ($null -ne $Discount) {
            $Discount | ConvertTo-Json -Depth 10 | Out-File $pathDiscount
        }
        Write-Host "---------------------- End function Discouted ------------------------"
        
        Start-Sleep $(Get-Random -Minimum 15 -Maximum 45)
        
        Write-Host "---------------------- Start function Free ---------------------------"
        $Free = Get-GameList -Price tierFree -Region en-US -Count 500
        if ($null -ne $Free) {
            $Free | ConvertTo-Json -Depth 10 | Out-File $pathFree
        }
        Write-Host "---------------------- End function Free -----------------------------"
    }
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

### Get the date of last changes of json files in the repository

$dateGiveaway = Get-Date -Format "dd.MM.yyyy HH:mm" -Date $(Invoke-RestMethod -Uri "https://api.github.com/repos/Lifailon/epic-games-radar/commits?path=api/giveaway/index.json")[0].commit.author.date
$dateDiscount = Get-Date -Format "dd.MM.yyyy HH:mm" -Date $(Invoke-RestMethod -Uri "https://api.github.com/repos/Lifailon/epic-games-radar/commits?path=api/discount/index.json")[0].commit.author.date
$dateFree = Get-Date -Format "dd.MM.yyyy HH:mm" -Date $(Invoke-RestMethod -Uri "https://api.github.com/repos/Lifailon/epic-games-radar/commits?path=api/free/index.json")[0].commit.author.date

### Generated Markdown

"## Giveaway:" | Out-File index.md
"Last update: $dateGiveaway" | Out-File index.md -Append
"" | Out-File index.md -Append
$giveawayGitHub = Invoke-RestMethod "https://lifailon.github.io/epic-games-radar/api/giveaway"
$giveawayGitHub | Select-Object -ExcludeProperty Description | ConvertTo-Markdown | Out-File index.md -Append

"## Discount:" | Out-File index.md -Append
"Last update: $dateDiscount" | Out-File index.md -Append
"" | Out-File index.md -Append
$discountGitHub = Invoke-RestMethod "https://lifailon.github.io/epic-games-radar/api/discount"
$discountGitHub | Select-Object -ExcludeProperty Description | ConvertTo-Markdown | Out-File index.md -Append

"## Free:" | Out-File index.md -Append
"Last update: $dateFree" | Out-File index.md -Append
"" | Out-File index.md -Append
$freeGitHub = Invoke-RestMethod "https://lifailon.github.io/epic-games-radar/api/free"
$freeGitHub | Select-Object -ExcludeProperty Description | ConvertTo-Markdown | Out-File index.md -Append


### Markdown to HTML

$md = $(Get-Content index.md -Raw | ConvertFrom-Markdown).html

$html = @"
<!DOCTYPE html>
<html>
    <head>
        <title>Epic Games Radar</title>
        <style>
            header {
                background-color: #4051B5;
                color: white;
                text-align: center;
                padding: 20px 0;
                position: fixed;
                width: 100%;
                top: 0;
                left: 0;
                z-index: 1000;
            }
            header a {
                color: white;
                text-decoration: none;
                font-size: 26px;
            }
            body {
                margin: 0;
                padding-top: 80px;
                padding-left: 200px;
                padding-right: 200px;
            }
            h2 {
                color: #4051B5;
            }
            table {
                border-collapse: collapse;
                width: 100%;
                margin: auto;
                font-size: 14px;
            }
            th, td {
                border: 1px solid black;
                padding: 8px;
                text-align: left;
                cursor: pointer;
            }
            th {
                background-color: #6495ED;
                color: white;
                cursor: pointer;
                transition: background-color 0.3s;
            }
            th:hover {
                background-color: #4051B5;
            }
            .ascending::after {
                content: " ▲";
            }
            .descending::after {
                content: " ▼";
            }
            .scroll-to-top {
                position: fixed;
                bottom: 20px;
                right: 20px;
                background-color: #6495ED;
                color: #fff;
                border: none;
                border-radius: 50%;
                width: 50px;
                height: 50px;
                font-size: 24px;
                cursor: pointer;
                display: none;
                z-index: 1000;
            }
            .scroll-to-top:hover {
                background-color: #4051B5;
            }
        </style>
    </head>
    <body>
        <header onclick="window.location.href='https://lifailon.github.io/';">
            <a href="https://lifailon.github.io">Home</a>
            <span> 🔹 </span>
            <a href="https://lifailon.github.io/epic-games-radar">Epic Games Radar</a>
        </header>
        <button class="scroll-to-top" onclick="scrollToTop()">↑</button>
        <script>
            function scrollToTop() {
                window.scrollTo({
                    top: 0,
                    behavior: 'smooth'
                });
            }
            window.onscroll = function() {
                var scrollButton = document.querySelector('.scroll-to-top');
                if (document.body.scrollTop > 20 || document.documentElement.scrollTop > 20) {
                    scrollButton.style.display = 'block';
                } else {
                    scrollButton.style.display = 'none';
                }
            };
            document.addEventListener("DOMContentLoaded", function() {
                var tableLinks = document.querySelectorAll("table a");
                tableLinks.forEach(function(link) {
                    link.setAttribute("target", "_blank");
                });
            });
            document.addEventListener("DOMContentLoaded", function() {
                var tables = document.querySelectorAll("table");
                tables.forEach(function(table) {
                    makeTableSortable(table);
                });
            });
            function makeTableSortable(table) {
                var headers = table.querySelectorAll("th");
                headers.forEach(function(header, index) {
                    header.addEventListener("click", function() {
                        sortTable(table, index);
                    });
                });
            }
            function sortTable(table, columnIndex) {
                var rows = Array.from(table.rows).slice(1);
                var ascending = !table.rows[0].cells[columnIndex].classList.contains("ascending");
                rows.sort(function(rowA, rowB) {
                    var cellA = rowA.cells[columnIndex].textContent.trim();
                    var cellB = rowB.cells[columnIndex].textContent.trim();
                    return ascending ? cellA.localeCompare(cellB) : cellB.localeCompare(cellA);
                });
                rows.forEach(function(row) {
                    table.appendChild(row);
                });
                updateHeaderClasses(table, columnIndex, ascending);
            }
            function updateHeaderClasses(table, columnIndex, ascending) {
                var headers = table.querySelectorAll("th");
                headers.forEach(function(header, index) {
                    if (index === columnIndex) {
                        if (ascending) {
                            header.classList.add("ascending");
                            header.classList.remove("descending");
                        } else {
                            header.classList.add("descending");
                            header.classList.remove("ascending");
                        }
                    } else {
                        header.classList.remove("ascending");
                        header.classList.remove("descending");
                    }
                });
            }
        </script>
        $md
    </body>
</html>
"@

$html | Out-File "index.html"