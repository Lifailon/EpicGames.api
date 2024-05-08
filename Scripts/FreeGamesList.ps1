# Переменные url
$count = "500"
$price = "tierFree"
$url = "https://store.epicgames.com/ru/browse?sortBy=releaseDate&sortDir=DESC&priceTier=$($price)&category=Game&count=$($count)&start=0"
# Делаем запрос
$userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
$handler = New-Object System.Net.Http.HttpClientHandler
$handler.AllowAutoRedirect = $true
$httpClient = New-Object System.Net.Http.HttpClient($handler)
$requestMessage = [System.Net.Http.HttpRequestMessage]::new([System.Net.Http.HttpMethod]::Get, $url)
$requestMessage.Headers.Add("User-Agent", $userAgent)
$requestMessage.Headers.Add("Accept", "text/html")
$response = $httpClient.SendAsync($requestMessage).Result
$content = $response.Content.ReadAsStringAsync().Result
# Логируем (проверяем содержимое)
Write-Host "---------------------- Content ----------------------"
Write-Host $content
Write-Host "---------------------- Content ------------------------"
# Вытаскиваем json из html
$json = $($($($content -split "__REACT_QUERY_INITIAL_QUERIES__ = ")[1] -split "window.server_rendered")[0] -replace ";")
# Обрабатываем данные
$games = $($json | ConvertFrom-Json).queries.state.data[-1].catalog.searchStore.elements
# Сохраняем файл
$path = "${env:GITHUB_WORKSPACE}/freeGames.json"
$games | ConvertTo-Json -Depth 10 | Out-File $path