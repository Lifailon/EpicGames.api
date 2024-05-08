# Переменные url
$count = "500"
$price = "tierFree"
$url = "https://store.epicgames.com/ru/browse?sortBy=releaseDate&sortDir=DESC&priceTier=$($price)&category=Game&count=$($count)&start=0"
# Делаем запрос
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