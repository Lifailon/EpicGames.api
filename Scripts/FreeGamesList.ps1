$count = "500"
$price = "tierFree"
$url = "https://store.epicgames.com/ru/browse?sortBy=releaseDate&sortDir=DESC&priceTier=$($price)&category=Game&count=$($count)&start=0"
$headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
    "Accept" = "text/html"
}
$response = Invoke-WebRequest -Uri $url -Headers $headers -Method Get
$json = $($($($response.Content -split "__REACT_QUERY_INITIAL_QUERIES__ = ")[1] -split "window.server_rendered")[0] -replace ";")
$games = $($json | ConvertFrom-Json).queries.state.data[-1].catalog.searchStore.elements
$path = "$PWD\freeGames.json"
$games | Out-File $path