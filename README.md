# Epic Games Radar

This repository contains an up-to-date list of free games, discounts, and giveaways in the Epic Games store, updated with **GitHub Actions**. You can get game lists on the project 🌐 [Web Page](https://lifailon.github.io/epic-games-radar) or in `json` format via any REST API client.

![Image alt](https://github.com/Lifailon/epic-games-radar/blob/rsa/image/web-page.jpg)

### 🚀 Static API (examples of requests)

- 🔹 Endpoint: `/epic-games-radar/api/giveaway`

▶️ `$(Invoke-WebRequest "https://lifailon.github.io/epic-games-radar/api/giveaway").Content`

or 

▶️ `curl "https://lifailon.github.io/epic-games-radar/api/giveaway"`

```json
{
  "Title": "Circus Electrique",
  "Developer": "Zen Studios",
  "Publisher": "Saber Interactive",
  "Description": "Circus Electrique is part story-driven RPG, part tactics, part circus management, and completely enthralling. When everyday Londoners mysteriously turn into vicious killers, only the show’s talented performers possess the skills necessary to save the city. ",
  "Url": "https://store.epicgames.com/en-US/p/circus-electrique",
  "ReleaseDate": "2022-09-06T15:00:00Z",
  "FullPrice": "$19.99",
  "CurrentPrice": "0",
  "DiscountEndDate": "2024-05-16T15:00:00Z"
}
```

- 🔹 Endpoint: `/epic-games-radar/api/discount`

▶️ `$(Invoke-WebRequest "https://lifailon.github.io/epic-games-radar/api/discount").Content`

or 

▶️ `curl "https://lifailon.github.io/epic-games-radar/api/discount"`

```json
[
  {
    "Title": "Cryptmaster",
    "Developer": "Paul Hart, Lee Williams, Akupara Games",
    "Publisher": "Akupara Games",
    "Description": "SAY ANYTHING in this bizarre dungeon adventure where words control everything. Fill in the blanks with text or voice to uncover lost abilities, solve strange quests, and play unexpected mini-games. Use your words to conquer the crypt and unleash a whole new kind of spell casting.",
    "Url": "https://store.epicgames.com/en-US/p/cryptmaster-6468dc",
    "ReleaseDate": "2024-05-09T16:00:00Z",
    "FullPrice": "RUB 749.00",
    "Discount": "10 %",
    "CurrentPrice": "RUB 674.10",
    "DiscountEndDate": "2024-05-16T16:00:00Z"
  },
  {
    "Title": "1000xRESIST",
    "Developer": "sunset visitor 斜陽過客",
    "Publisher": "Fellow Traveller",
    "Description": "1000xRESIST is a thrilling sci-fi adventure. The year is unknown, and a disease spread by an alien invasion keeps you underground. You are Watcher. You dutifully fulfil your purpose in serving the ALLMOTHER, until the day you discover a shocking secret that changes everything.",
    "Url": "https://store.epicgames.com/en-US/p/1000xresist-fd0537",
    "ReleaseDate": "2024-05-09T15:00:00Z",
    "FullPrice": "RUB 599.00",
    "Discount": "10 %",
    "CurrentPrice": "RUB 539.10",
    "DiscountEndDate": "2024-05-16T05:59:00Z"
  },
  ...
]
```

- 🔹 Endpoint: `/epic-games-radar/api/free`

▶️ `$(Invoke-WebRequest "https://lifailon.github.io/epic-games-radar/api/free").Content`

or 

▶️ `curl "https://lifailon.github.io/epic-games-radar/api/free"`

```json
[
  {
    "Title": "Crosshair V2",
    "Developer": "CenterPoint Gaming",
    "Publisher": "CenterPoint Gaming",
    "Description": "Crosshair V2 is a crosshair overlay technology that improves aim, response time, and hip fire accuracy for gamers. Choose from a variety of sizes, shapes, and neon colors to find the crosshair that gives you the greatest advantage in your favorite game.",
    "Url": "https://store.epicgames.com/en-US/p/crosshair-v2-d58322",
    "ReleaseDate": "2024-05-10T16:00:00Z",
    "FullPrice": "0",
    "CurrentPrice": "0",
    "DiscountEndDate": null
  },
  {
    "Title": "Ivorfall",
    "Developer": "Inquiry Games LLC",
    "Publisher": "Inquiry Games LLC",
    "Description": "Ivorfall City is in danger and only you have what it takes to save it! Ivorfall is a Steampunk, roguelike, twin-stick shooter where you take up the mantle of Detective Flintlock who must face off against hordes of enemies in destructible environments.",
    "Url": "https://store.epicgames.com/en-US/p/ivorfall-5a38c0",
    "ReleaseDate": "2024-05-10T06:00:00Z",
    "FullPrice": "0",
    "CurrentPrice": "0",
    "DiscountEndDate": null
  },
  ...
]
```