# Store listing

Texts for App Store Connect and Google Play Console, Czech and English.
Each field is a heading with its limit `(≤N)` and the text in a code block;
`python3 store/check_listing.py` checks the lengths.

Numbers come from the release build: 85 fonts (14 free), 18 presets (4 free),
40 animated emoji. Update them here when `sheets.json` changes.

URLs (live once `site/` is published with GitHub Pages):

- Support: `https://lioilsources.github.io/HandWrittenStickers/`
- Privacy policy: `https://lioilsources.github.io/HandWrittenStickers/privacy/`

## Common settings

| | App Store | Google Play |
|---|---|---|
| Category | Graphics & Design, secondary Utilities | Art & Design |
| Price | Free, in-app purchases | Free, in-app purchases |
| Age | 4+ | Everyone; target audience 13+ (see note) |
| Privacy | Product Interaction, Performance Data, Coarse Location; not linked, no tracking (`store/privacy-answers.md`) | Data safety: App interactions, Diagnostics, Approximate location; collected, not shared, optional (`store/privacy-answers.md`) |
| Encryption | None (`ITSAppUsesNonExemptEncryption` = NO is in Info.plist) | – |
| Ads | No | No |
| Sign-in | None | None |

Note on the audience: a Play target audience that includes children under 13
puts the app under the Families policy (teacher-approved review, stricter
SDK rules). The app qualifies, but 13+ is the quicker route for a first
release.

Screenshots: `store/screenshots.sh` renders them to
`store/screenshots/<cs|en>/<iphone69|play|ipad13|play_tablet>/`. The Google
Play feature graphic (1024×500) and icon (512×512) are in `store/graphics/`,
rendered from the app's glyphs by `store/play_graphics.py`.

## English

### App Store name / Play title (≤30)

```
Handwritten Stickers
```

### App Store subtitle (≤30)

```
Messages written by hand
```

### Play short description (≤80)

```
Type a message, send it as a handwritten sticker with an animated emoji.
```

### App Store promotional text (≤170)

```
Type a message and send it as if you had written it by hand: a child's handwriting, calligraphy, bubble letters or gingerbread, with an animated emoji.
```

### App Store keywords (≤100)

```
handwriting,sticker,calligraphy,lettering,font,text,greeting,card,note,emoji,gif,kids,bubble,message
```

### Description (≤4000)

```
Type a message. Send it as if you had written it by hand.

Handwritten Stickers turns what you type into a picture: a child's wobbly handwriting, wedding calligraphy, puffy bubble letters, or letters made of gingerbread. Add an animated emoji, then share the sticker straight to a chat or save it to your photos.

FREE
• 14 fonts: scanned real handwriting, calligraphy, typography and bubble letters for kids
• 4 ready-made looks: Neat, Casual, Quick note, Chaotic
• 40 animated emoji; a sticker with an emoji is saved as a looping GIF
• Sliders for spacing, wobble, size, rotation and ink, so no two letters look the same
• Joined-up handwriting whose letters connect the way a pen would
• Czech accents in every font (ě š č ř ž ý á í é ů ú ď ť ň)
• Every feature of the app, with no time limit

PACKS
One-time purchases, no subscription. Try any pack in the editor first; you only pay when you want to save or share.
• Handwriting: 17 more hands, from neat to casual
• Calligraphy: 25 scripts for cards, invitations and love notes
• Posters & signs: 19 bold and historic typefaces
• For kids: 7 colourful bubble and playful fonts
• Materials: letters made of gingerbread, neon and plasticine
• Your presets: save your own font and style combinations
• Everything: all packs at once

PRIVATE
No account, no ads, no third-party analytics. What you type stays on your device until you share it. Anonymous usage statistics, which never include your text, can be turned off in the app.

The fonts are licensed under the SIL Open Font License. Their authors are credited in the app.
```

### What's new (≤4000)

```
First release.
```

## Česky

### App Store name / Play title (≤30)

```
Handwritten Stickers
```

### App Store subtitle (≤30)

```
Zprávy psané rukou
```

### Play short description (≤80)

```
Napiš zprávu a pošli ji jako ručně psanou samolepku s animovaným emoji.
```

### App Store promotional text (≤170)

```
Napiš zprávu a pošli ji, jako bys ji psal(a) rukou: dětským rukopisem, kaligrafií, bublinkovým písmem nebo perníkem, s animovaným emoji.
```

### App Store keywords (≤100)

```
rukopis,samolepka,kaligrafie,písmo,font,text,přání,vzkaz,emoji,gif,děti,bublinky,zpráva,psaní,nápis
```

### Description (≤4000)

```
Napiš zprávu. Pošli ji, jako bys ji psal(a) rukou.

Handwritten Stickers udělá z napsaného textu obrázek: kostrbatý dětský rukopis, svatební kaligrafii, nafouknuté bublinkové písmo nebo písmena z perníku. Přidej animované emoji a samolepku rovnou nasdílej do chatu nebo ulož do fotek.

ZDARMA
• 14 písem: naskenovaný skutečný rukopis, kaligrafie, typografie a bublinkové písmo pro děti
• 4 hotové styly: Úhledně, Běžně, Rychlý vzkaz, Chaos
• 40 animovaných emoji; samolepka s emoji se uloží jako GIF ve smyčce
• Posuvníky pro mezery, kolísání řádku, velikost, natočení a krytí, takže žádná dvě písmena nejsou stejná
• Psací písmo, které se spojuje jako tah perem
• Česká diakritika ve všech písmech
• Všechny funkce aplikace, bez časového omezení

BALÍČKY
Jednorázové nákupy, žádné předplatné. Každý balíček si nejdřív vyzkoušíš v editoru; platíš, až když chceš ukládat nebo sdílet.
• Rukopisy: dalších 17 ručních písem, od úhledného po ležérní
• Kaligrafie: 25 písem pro přání, pozvánky a vyznání
• Plakát a nápisy: 19 výrazných a historických písem
• Pro děti: 7 barevných bublinkových a hravých písem
• Materiály: písmena z perníku, neonu a modelíny
• Vlastní presety: ukládej si vlastní kombinace písma a stylu
• Komplet: všechny balíčky najednou

SOUKROMÍ
Žádný účet, žádná reklama, žádná analytika třetích stran. Co napíšeš, zůstává v zařízení, dokud to nenasdílíš. Anonymní statistiky používání, které nikdy neobsahují tvůj text, jdou v aplikaci vypnout.

Písma mají licenci SIL Open Font License. Jejich autory najdeš v aplikaci.
```

### What's new (≤4000)

```
První vydání.
```

## In-app purchases

Seven non-consumable products. Play allows no capital letters in product
ids, so Play sells the lowercase form (`com.ol1n.handwrittenstickers.pack.kids`);
`StorePurchaseBackend` maps it back to the id below. Display names
match `assets/packs/packs.json`. The limits here are kept short enough for
both stores.

Planned prices: 0.99 USD each (25 Kč), `all` 3.99 USD (99 Kč).

| Product id | Name en (≤30) | Description en (≤45) | Name cs (≤30) | Description cs (≤45) |
|---|---|---|---|---|
| `com.ol1n.handwrittenStickers.pack.handwriting` | Handwriting | 17 more hands, from neat to casual | Rukopisy | Dalších 17 ručních písem |
| `com.ol1n.handwrittenStickers.pack.calligraphy` | Calligraphy | 25 scripts for cards and invitations | Kaligrafie | 25 písem pro přání a pozvánky |
| `com.ol1n.handwrittenStickers.pack.poster` | Posters & signs | 19 bold and historic typefaces | Plakát a nápisy | 19 výrazných a historických písem |
| `com.ol1n.handwrittenStickers.pack.kids` | For kids | 7 colourful bubble and playful fonts | Pro děti | 7 barevných a hravých dětských písem |
| `com.ol1n.handwrittenStickers.pack.materials` | Materials | Gingerbread, neon and plasticine letters | Materiály | Písmena z perníku, neonu a modelíny |
| `com.ol1n.handwrittenStickers.pack.presets` | Your presets | Save your own font and style combinations | Vlastní presety | Ukládej si vlastní kombinace písma a stylu |
| `com.ol1n.handwrittenStickers.pack.all` | Everything | All packs at once | Komplet | Všechny balíčky najednou |

## Notes for App Review

```
No account or sign-in is needed.

All features are free. In-app purchases are non-consumable content packs (fonts and presets) plus one that unlocks saving your own presets. Paid fonts can be previewed in the editor; the purchase sheet appears when you tap Save to Gallery or Share with a paid font selected.

To see all packs: tap the shop icon in the top bar. "Restore purchases" is on that screen and on every purchase sheet.

The app sends anonymous usage statistics (no identifiers, never the text the user types) to the developer's own server; they can be turned off under the info button in the editor. Apart from that and the store's purchase APIs it makes no network requests of its own.
```
