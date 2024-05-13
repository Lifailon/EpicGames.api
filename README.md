# Epic Games Radar

This repository contains an up-to-date list of free games, discounts, and giveaways in the Epic Games store, updated with **GitHub Actions**. You can get game lists on the project 🌐 [web page](https://lifailon.github.io/epic-games-radar) or in JSON format via any REST API client.

### Static API (examples of requests)

- Endpoint: `/epic-games-radar/api/giveaway`

`$(Invoke-WebRequest "https://lifailon.github.io/epic-games-radar/api/giveaway").Content`

or 

`curl "https://lifailon.github.io/epic-games-radar/api/giveaway"`

```json
{
  "Title": "Circus Electrique",
  "Developer": "Zen Studios",
  "publisher": "Saber Interactive",
  "Description": "Circus Electrique — это отчасти сюжетная ролевая игра, отчасти боевая тактика, отчасти симулятор управления цирком. Но, самое главное, это игра, от которой невозможно оторваться. Когда лондонские обыватели ни с того, ни с сего вдруг начинают превращаться в безжалостных убийц, судьба города оказывается в умелых руках талантливых цирковых артистов. ",
  "Url": "https://store.epicgames.com/ru/p/",
  "ReleaseDate": "2022-09-06T15:00:00Z",
  "FullPrice": "19,99 $",
  "CurrentPrice": "0"
}
```

- Endpoint: `/epic-games-radar/api/free`

`$(Invoke-WebRequest "https://lifailon.github.io/epic-games-radar/api/free").Content`

or 

`curl "https://lifailon.github.io/epic-games-radar/api/free"`

```json
[
  {
    "Title": "Crosshair V2",
    "Developer": "CenterPoint Gaming",
    "publisher": "CenterPoint Gaming",
    "Description": "Выберите из различных размеров, форм и неоновых цветов, чтобы найти прицел, который даст вам наибольшее преимущество в вашей любимой игре.",
    "Url": "https://store.epicgames.com/ru/p/crosshair-v2-d58322",
    "ReleaseDate": "2024-05-10T16:00:00Z",
    "FullPrice": "0",
    "CurrentPrice": "0"
  },
  {
    "Title": "Ivorfall",
    "Developer": "Inquiry Games LLC",
    "publisher": "Inquiry Games LLC",
    "Description": "Ivorfall City is in danger and only you have what it takes to save it! Ivorfall is a Steampunk, roguelike, twin-stick shooter where you take up the mantle of Detective Flintlock who must face off against hordes of enemies in destructible environments.",
    "Url": "https://store.epicgames.com/ru/p/ivorfall-5a38c0",
    "ReleaseDate": "2024-05-10T06:00:00Z",
    "FullPrice": "0",
    "CurrentPrice": "0"
  },
  ...
]
```