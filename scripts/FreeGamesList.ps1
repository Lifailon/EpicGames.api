# Переменные url
$count = "500"
$price = "tierFree"
$url = "https://store.epicgames.com/ru/browse?sortBy=releaseDate&sortDir=DESC&priceTier=$($price)&category=Game&count=$($count)&start=0"
# Делаем запрос
# $Agents = $(
#     "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
#     "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:88.0) Gecko/20100101 Firefox/88.0",
#     "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.818.66 Safari/537.36 Edg/90.0.818.46",
#     "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko",
#     "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36 OPR/60.0.3255.170",
#     "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.212 Safari/537.36 Brave/90.0",
#     "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/89.0.4389.114 Safari/537.36 Vivaldi/3.7"
# )
# $userAgent = Get-Random -InputObject $Agents
# $handler = New-Object System.Net.Http.HttpClientHandler
# $handler.AllowAutoRedirect = $true
# $httpClient = New-Object System.Net.Http.HttpClient($handler)
# # WebClient
# $requestMessage = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get, $url)
# $requestMessage.Headers.Add("User-Agent", $userAgent)
# $requestMessage.Headers.Add("Accept", "text/html")
# $response = $httpClient.SendAsync($requestMessage).Result
# $content = $response.Content.ReadAsStringAsync().Result

$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
$response = Invoke-WebRequest -UseBasicParsing -Uri $url -WebSession $session -Headers @{
    "Accept"="text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7"
    "Service-Worker-Navigation-Preload"="true"
    "Upgrade-Insecure-Requests"="1"
    "sec-ch-ua"="`"Chromium`";v=`"124`", `"Google Chrome`";v=`"124`", `"Not-A.Brand`";v=`"99`""
    "sec-ch-ua-mobile"="?0"
    "sec-ch-ua-platform"="`"Windows`""
}
$content = $response.Content

# Логируем (проверяем содержимое)
Write-Host "---------------------- Agent ------------------------"
Write-Host $userAgent
Write-Host "---------------------- Agent ------------------------"
Write-Host "---------------------- Content ----------------------"
Write-Host $content
Write-Host "---------------------- Content ------------------------"
# Вытаскиваем json из html
$json = $($($($content -split "__REACT_QUERY_INITIAL_QUERIES__ = ")[1] -split "window.server_rendered")[0] -replace ";")
# Обрабатываем данные
$games = $($json | ConvertFrom-Json).queries.state.data[-1].catalog.searchStore.elements
# Сохраняем файл
$path = "${env:GITHUB_WORKSPACE}/json/FreeGames.json"
$games | ConvertTo-Json -Depth 10 | Out-File $path