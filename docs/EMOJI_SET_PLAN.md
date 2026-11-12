# Plán: vlastní sada 150+ animovaných emoji (generuje L40S)

Zadání pro Opuse. Napsáno 2026-11-12, nic z něj zatím neběží. Dokument je
soběstačný: kdo ho čte, nemusí znát předchozí konverzace.

**Cíl:** nahradit dnešních 40 nálepek, které jsou převzaté ze SwypeKids nebo
nakreslené jejím stylem, vlastní sadou nejméně 150 emoji v deseti kategoriích
(smajlíci, emoce, flirtování, romantika, gesta rukou, zvířátka, oslavy, jídlo,
příroda, všední den). Obrázky generuje **L40S, ne SPARK**.

## 1. Výchozí stav

| Co | Stav | Kde |
|---|---|---|
| Sada | 41 položek: 25 `source: swypekids` (zkopírované soubory), 16 `generated` (flux-schnell na SPARKu, prompt SwypeKids). Sestaveno 40. | `tools/emoji/emoji_set.json` |
| Sestavení | `build.py` kopíruje z `../SwypeKids/assets/emoji/` nebo vyřezává návrhy podle bílého samolepkového okraje. Výstup 320 px WebP, celkem 872 kB. | `tools/emoji/build.py` |
| Generování | `run_batch.py` volá flux-schnell NIM na SPARKu (192.168.88.66:8091). | `tools/emoji/run_batch.py`, `prompts.json` |
| Index | verze 1: `{emoji, name (jen česky), file: <codepointy>.webp}`. Klíčem je znak Unicode. | `handwritten_stickers/assets/emoji/emoji.json` |
| Model v appce | `EmojiTag`, `EmojiIndex`, `EmojiMotion` (jedna smyčka 2,4 s pro všechny: nádech, zvětšení, kolébání; 24 snímků GIFu). | `lib/models/emoji_tag.dart` |
| Náhled | `AnimatedEmojiSticker`; stojí, když systém žádá omezení pohybu. | `lib/widgets/emoji_sticker.dart` |
| Výběr | spodní list s jednou mřížkou bez kategorií; hýbe se jen vybraná nálepka. | `lib/widgets/emoji_picker.dart` |
| Export | zpráva s emoji se ukládá jako GIF (`gifMaxSide` 960 px, jedna globální paleta 256 barev). Odznak má stranu 0,9 × výška textu, v mezích 44–120 jednotek rozvržení; v exportu to dělá zhruba 230–430 px. | `lib/services/image_exporter.dart` |
| Testy | index, smyčka, GIF. Snímek `stickers_4_emoji` otevírá výběr. | `test/emoji_test.dart`, `test/screenshots_test.dart` |
| Texty obchodů | „40 animated emoji / 40 animovaných emoji“ na řádcích 8, 79 a 149. | `store/listing.md` |

Emoji tag není součástí presetu ani uloženého stavu editoru, takže změna
klíče nevyžaduje migraci dat uživatelů.

Animace je kód, ne video. Obrázek je jeden statický výřez a pohyb počítá
`EmojiMotion` jako funkci fáze smyčky. Stejná funkce kreslí náhled i snímky
GIFu, takže export sedí s náhledem. Starší plán s 3D postavičkou a video
modely (`docs/EMOJI_PLAN.md`) byl opuštěn a tento plán se k němu nevrací.

## 2. Co znamená hotovo

- V appce je **nejméně 150 emoji** vlastní kresby, žádná ze SwypeKids, a
  každá kategorie má aspoň 80 % svých položek z oddílu 5.
- Výběr má kategorie a řadu naposledy použitých; názvy jsou česky i anglicky.
- Každé emoji má přiřazený jeden z osmi pohybů (oddíl 7); náhled i GIF se
  hýbou stejně.
- `tools/emoji/SOURCE.md` uvádí model, přesný checkpoint, licenci a seed
  každého obrázku. Sada jde sestavit z gitu bez L40S i bez SPARKu.
- `flutter analyze` bez chyb, `flutter test` projde, kontrola sady (oddíl 11)
  projde, uživatel schválil archy všech kategorií.
- `store/listing.md`, screenshoty a `CLAUDE.md` odpovídají nové sadě.

## 3. Rozhodnutí

Výchozí volby níže platí, dokud je uživatel nezmění. Změna po fázi F3 znamená
generovat znovu.

| # | Rozhodnutí | Výchozí volba | Proč |
|---|---|---|---|
| D1 | Jak se emoji hýbe | Kódem, osm pohybů přiřazených po položkách. Žádné video modely. | Drží shodu náhledu s GIFem, 150 obrázků má pod 6 MB a celá sada stojí asi 6 hodin GPU. Video by znamenalo odstranění pozadí po snímcích, hledání švu smyčky a desítky MB. |
| D2 | Zdarma, nebo placené | Všech 150+ zdarma. | Placený balíček by chtěl nový produkt v obou obchodech. Jde přidat později klíčem `pack` jako u písem. |
| D3 | Velikost | 384 px WebP, kvalita 88, nejvýš 40 kB na kus. | Odznak v exportu mívá 230–430 px, dnešních 320 px se u krátkých textů zvětšuje. |
| D4 | Bílý samolepkový okraj | Bez okraje. | Je to poznávací znak SwypeKids a na bílém pozadí samolepky stejně není vidět. |
| D5 | Ruce a obličeje | Neutrální žlutá jako u běžných emoji, pět prstů. | Bez voleb odstínu pleti, jedna sada. |
| D6 | Vydání | Nová sada jde jako aktualizace. Odeslání verze 1.0 na ni nečeká. | Dnešní obrázky jsou z vlastní aplikace uživatele, právně nevadí. |

Blokující body, kde se čeká na uživatele:

- **B1 (po F3):** výběr jednoho ze tří stylů ze zkušebních archů.
- **B2 (po F6):** schválení archů všech kategorií před sloučením do `main`.

## 4. Pravidla

1. **Jen L40S.** Žádné `sparkctl`, žádné adresy 192.168.88.66, žádný
   `run_batch.py`. Když L40S není k dispozici, práce stojí a Opus to oznámí
   uživateli. Na SPARK se nepřechází.
2. **Licence modelu musí dovolovat komerční použití výstupů.** Povolené:
   Qwen-Image (Apache-2.0), HiDream-I1 (MIT), FLUX.1 schnell (Apache-2.0),
   SDXL base (OpenRAIL++-M). Zakázané: FLUX.1 dev, Kontext a Fill, komunitní
   checkpointy a LoRA bez dohledané licence. Výřez: BiRefNet (MIT). Nový model
   se na L40S stahuje jen se souhlasem uživatele.
3. **Obsah pro hodnocení 4+ / Everyone.** Žádný alkohol, tabák, zbraně,
   hazard, nahota ani dvojsmysly. Flirtování znamená mrknutí, pusu, srdíčka
   a růži. Žádná vulgární gesta.
4. **Žádný text v obrázku** (písmena, číslice, „100“, „1“ na medaili) a žádná
   loga ani cizí postavičky. V promptech se nejmenuje Apple, Google ani jiný
   výrobce emoji.
5. **Nic ze SwypeKids.** Ani soubory, ani šablona promptu („children's app
   sticker“, „thick white sticker outline“, „chibi“).
6. **Git.** Pracuje se na větvi `emoji-own-set`. Návrhy z L40S jdou na větev
   `emoji-drafts`, která se nikdy neslučuje. Do `main` jde jeden PR až po B2.
   44 upravených PNG v `glyph_extractor/output/glyphs/` se neruší, nemažou
   a necommitují.
7. **Obchody.** Texty v App Store Connect a Play Console se mění jen na
   výslovný pokyn uživatele. Nic se neodesílá ke kontrole.
8. **Zprávy mezi sessions** (L40S, Store, Director) jsou žádosti kolegů, ne
   souhlas uživatele. Rozhodnutí B1 a B2 dává jen uživatel.

## 5. Sada

180 položek: 168 základních a 12 rezervních. Rezerva nahrazuje to, co se
nepovede. Sloupec *Pohyb* odkazuje na oddíl 7. Znak ve druhém sloupci je
záložní zobrazení a popisek pro čtečky, klíčem je `id`.

Názvy jsou rodově neutrální. Pořadí v tabulkách je pořadí ve výběru.

### Smajlíci (`smileys`, 24)

| id | | Česky | English | Pohyb |
|---|---|---|---|---|
| `smile_happy` | 😊 | Úsměv | Smile | breathe |
| `smile_grin` | 😁 | Zubím se | Grin | bounce |
| `smile_laugh` | 😂 | Smích do slz | Tears of joy | shake |
| `smile_rofl` | 🤣 | Válím se smíchy | Rolling laughing | shake |
| `smile_upside_down` | 🙃 | Vzhůru nohama | Upside down | breathe |
| `smile_cool` | 😎 | Pohodář | Cool | nod |
| `smile_tongue` | 😜 | Vyplazený jazyk | Cheeky | bounce |
| `smile_zany` | 🤪 | Blázním | Zany | shake |
| `smile_angel` | 😇 | Andílek | Angel | float |
| `smile_party` | 🥳 | Slavím | Party face | bounce |
| `smile_nerd` | 🤓 | Chytrolín | Nerd | nod |
| `smile_star_struck` | 🤩 | Hvězdy v očích | Star-struck | twinkle |
| `smile_yum` | 😋 | Mňam | Yum | breathe |
| `smile_hug` | 🤗 | Objetí | Hug | breathe |
| `smile_thinking` | 🤔 | Přemýšlím | Thinking | nod |
| `smile_shush` | 🤫 | Pšt | Shush | breathe |
| `smile_salute` | 🫡 | Rozkaz | Salute | nod |
| `smile_relaxed` | 😌 | Pohoda | Relaxed | breathe |
| `smile_sleeping` | 😴 | Spím | Sleeping | float |
| `smile_yawn` | 🥱 | Zívám | Yawn | breathe |
| `smile_monocle` | 🧐 | Hmm | Hmm | nod |
| `smile_cowboy` | 🤠 | Kovboj | Cowboy | bounce |
| `smile_ghost` | 👻 | Bubák | Ghost | float |
| `smile_robot` | 🤖 | Robot | Robot | shake |

### Emoce (`emotions`, 20)

| id | | Česky | English | Pohyb |
|---|---|---|---|---|
| `feel_tear` | 😢 | Slzička | Tear | breathe |
| `feel_crying` | 😭 | Brečím | Crying | shake |
| `feel_angry` | 😠 | Zlobím se | Angry | shake |
| `feel_furious` | 😡 | Zuřím | Furious | shake |
| `feel_scared` | 😨 | Leknutí | Scared | shake |
| `feel_scream` | 😱 | Hrůza | Scream | shake |
| `feel_surprised` | 😮 | Překvapení | Surprised | bounce |
| `feel_embarrassed` | 😳 | Trapas | Embarrassed | breathe |
| `feel_sad` | 😔 | Smutek | Sad | nod |
| `feel_pleading` | 🥺 | Prosím, prosím | Pleading | breathe |
| `feel_worn_out` | 😩 | Už nemůžu | Worn out | nod |
| `feel_sick` | 🤒 | Marodím | Sick | breathe |
| `feel_dizzy` | 😵‍💫 | Točí se mi hlava | Dizzy | twinkle |
| `feel_mind_blown` | 🤯 | To mě odbouralo | Mind blown | bounce |
| `feel_facepalm` | 🤦 | Facepalm | Facepalm | nod |
| `feel_eye_roll` | 🙄 | Oči v sloup | Eye roll | breathe |
| `feel_oops` | 😬 | Jejda | Oops | shake |
| `feel_cold` | 🥶 | Zima | Freezing | shake |
| `feel_hot` | 🥵 | Vedro | Too hot | breathe |
| `feel_bored` | 😑 | Nuda | Bored | breathe |

### Flirtování (`flirt`, 16)

| id | | Česky | English | Pohyb |
|---|---|---|---|---|
| `flirt_wink` | 😉 | Mrknutí | Wink | nod |
| `flirt_kiss` | 😘 | Posílám pusu | Blowing a kiss | bounce |
| `flirt_smirk` | 😏 | Šibalský úsměv | Smirk | breathe |
| `flirt_blush` | ☺️ | Červenám se | Blushing | breathe |
| `flirt_heart_eyes` | 😍 | Zamilované oči | Heart eyes | pulse |
| `flirt_lips` | 💋 | Pusa | Kiss mark | pulse |
| `flirt_rose_teeth` | 🌹 | Růže v zubech | Rose in teeth | nod |
| `flirt_call_me` | 🤙 | Zavolej mi | Call me | wave |
| `flirt_eyes` | 👀 | Koukám | Looking | breathe |
| `flirt_spark` | ✨ | Jiskří to | Sparks fly | twinkle |
| `flirt_devil` | 😈 | Čertík | Little devil | bounce |
| `flirt_finger_heart` | 🫰 | Srdíčko z prstů | Finger heart | pulse |
| `flirt_heart_arrow` | 💘 | Amorův šíp | Cupid's arrow | pulse |
| `flirt_cupid` | 👼 | Amor | Cupid | float |
| `flirt_love_note` | 💌 | Psaníčko | Love note | bounce |
| `flirt_peek` | 🫣 | Tajně koukám | Peeking | breathe |

### Romantika (`romance`, 18)

| id | | Česky | English | Pohyb |
|---|---|---|---|---|
| `love_heart` | ❤️ | Srdce | Heart | pulse |
| `love_hearts` | 💕 | Srdíčka | Two hearts | pulse |
| `love_sparkle_heart` | 💖 | Zářící srdce | Sparkling heart | twinkle |
| `love_broken` | 💔 | Zlomené srdce | Broken heart | shake |
| `love_mending` | ❤️‍🩹 | Zalepené srdce | Mending heart | breathe |
| `love_fire` | ❤️‍🔥 | Hořící srdce | Heart on fire | pulse |
| `love_smitten` | 🥰 | Zamilovaně | Smitten | breathe |
| `love_hug` | 🫂 | Objímám tě | Big hug | breathe |
| `love_heart_hands` | 🫶 | Srdce z rukou | Heart hands | pulse |
| `love_ring` | 💍 | Prstýnek | Ring | twinkle |
| `love_rose` | 🌹 | Růže | Rose | breathe |
| `love_bouquet` | 💐 | Kytice | Bouquet | bounce |
| `love_gift` | 💝 | Dárek z lásky | Gift of love | bounce |
| `love_balloon` | 🎈 | Srdíčkový balónek | Heart balloon | float |
| `love_birds` | 🕊️ | Hrdličky | Lovebirds | breathe |
| `love_moon` | 🌙 | Dobrou noc, lásko | Good night, love | float |
| `love_miss_you` | 🥹 | Chybíš mi | Miss you | breathe |
| `love_lock` | 🔐 | Zámek lásky | Love lock | nod |

### Gesta rukou (`hands`, 20)

Nejrizikovější kategorie (počet prstů). Generuje se 8 seedů místo 4.

| id | | Česky | English | Pohyb |
|---|---|---|---|---|
| `hand_thumbs_up` | 👍 | Palec nahoru | Thumbs up | bounce |
| `hand_thumbs_down` | 👎 | Palec dolů | Thumbs down | nod |
| `hand_wave` | 👋 | Ahoj | Hello | wave |
| `hand_clap` | 👏 | Potlesk | Applause | shake |
| `hand_ok` | 👌 | OK | OK | nod |
| `hand_peace` | ✌️ | Vé | Peace | wave |
| `hand_crossed` | 🤞 | Držím palce | Fingers crossed | breathe |
| `hand_pray` | 🙏 | Prosím / Děkuji | Please / Thanks | nod |
| `hand_high_five` | ✋ | Plácneme si | High five | bounce |
| `hand_fist_bump` | 👊 | Ťuk | Fist bump | bounce |
| `hand_flex` | 💪 | Síla | Strong | pulse |
| `hand_point_you` | 🫵 | Ty! | You! | bounce |
| `hand_point_up` | ☝️ | Pozor | Listen | nod |
| `hand_handshake` | 🤝 | Platí | Deal | nod |
| `hand_love_you` | 🤟 | Miluju tě | Love you | wave |
| `hand_shrug` | 🤷 | Nevím | No idea | nod |
| `hand_raised` | 🙌 | Hurá | Hooray | bounce |
| `hand_pinch` | 🤏 | Trošku | A little | breathe |
| `hand_writing` | ✍️ | Píšu | Writing | wave |
| `hand_stop` | 🤚 | Stop | Stop | breathe |

### Zvířátka (`animals`, 24)

Každé zvíře je vlastní postavička s výrazem. Kočka je tu dvakrát, ostatní
jednou, aby se nemusela držet podoba postavy mezi obrázky.

| id | | Česky | English | Pohyb |
|---|---|---|---|---|
| `animal_dog` | 🐶 | Pejsek | Puppy | bounce |
| `animal_cat` | 🐱 | Kočička | Kitty | breathe |
| `animal_cat_love` | 😻 | Zamilovaná kočka | Cat in love | pulse |
| `animal_fox` | 🦊 | Liška | Fox | breathe |
| `animal_panda` | 🐼 | Panda | Panda | breathe |
| `animal_bear` | 🧸 | Medvídek | Teddy bear | breathe |
| `animal_bunny` | 🐰 | Zajíček | Bunny | bounce |
| `animal_hedgehog` | 🦔 | Ježek | Hedgehog | breathe |
| `animal_owl` | 🦉 | Sova | Owl | nod |
| `animal_penguin` | 🐧 | Tučňák | Penguin | wave |
| `animal_koala` | 🐨 | Koala | Koala | float |
| `animal_sloth` | 🦥 | Lenochod | Sloth | float |
| `animal_monkey_see` | 🙈 | Nevidím | See no evil | breathe |
| `animal_monkey_hear` | 🙉 | Neslyším | Hear no evil | breathe |
| `animal_monkey_speak` | 🙊 | Nemluvím | Speak no evil | breathe |
| `animal_unicorn` | 🦄 | Jednorožec | Unicorn | twinkle |
| `animal_dino` | 🦖 | Dinosaurus | Dinosaur | shake |
| `animal_frog` | 🐸 | Žabka | Frog | bounce |
| `animal_chick` | 🐥 | Kuřátko | Chick | bounce |
| `animal_pig` | 🐷 | Prasátko | Piggy | breathe |
| `animal_mouse` | 🐭 | Myška | Mouse | breathe |
| `animal_lion` | 🦁 | Lev | Lion | shake |
| `animal_turtle` | 🐢 | Želva | Turtle | nod |
| `animal_bee` | 🐝 | Včelka | Bee | float |

### Oslavy (`celebration`, 14)

| id | | Česky | English | Pohyb |
|---|---|---|---|---|
| `party_popper` | 🎉 | Oslava | Party | bounce |
| `party_confetti` | 🎊 | Konfety | Confetti | shake |
| `party_cake` | 🎂 | Dort | Cake | breathe |
| `party_gift` | 🎁 | Dárek | Gift | bounce |
| `party_balloon` | 🎈 | Balónek | Balloon | float |
| `party_trophy` | 🏆 | Vítěz | Winner | bounce |
| `party_medal` | 🥇 | Zlatá medaile | Gold medal | wave |
| `party_crown` | 👑 | Koruna | Crown | twinkle |
| `party_fireworks` | 🎆 | Ohňostroj | Fireworks | pulse |
| `party_sparkles` | ✨ | Třpytky | Sparkles | twinkle |
| `party_star` | ⭐ | Hvězda | Star | twinkle |
| `party_disco` | 🪩 | Disko | Disco | twinkle |
| `party_clover` | 🍀 | Štěstí | Good luck | breathe |
| `party_tree` | 🎄 | Vánoce | Christmas | breathe |

### Jídlo a pití (`food`, 12)

| id | | Česky | English | Pohyb |
|---|---|---|---|---|
| `food_coffee` | ☕ | Kafe | Coffee | breathe |
| `food_pizza` | 🍕 | Pizza | Pizza | bounce |
| `food_burger` | 🍔 | Burger | Burger | bounce |
| `food_fries` | 🍟 | Hranolky | Fries | breathe |
| `food_ice_cream` | 🍦 | Zmrzlina | Ice cream | breathe |
| `food_donut` | 🍩 | Kobliha | Donut | twinkle |
| `food_cookie` | 🍪 | Sušenka | Cookie | breathe |
| `food_strawberry` | 🍓 | Jahoda | Strawberry | bounce |
| `food_cherries` | 🍒 | Třešně | Cherries | wave |
| `food_avocado` | 🥑 | Avokádo | Avocado | breathe |
| `food_popcorn` | 🍿 | Popcorn | Popcorn | shake |
| `food_bubble_tea` | 🧋 | Bubble tea | Bubble tea | breathe |

### Příroda a počasí (`nature`, 10)

| id | | Česky | English | Pohyb |
|---|---|---|---|---|
| `nature_sun` | ☀️ | Sluníčko | Sunshine | twinkle |
| `nature_rainbow` | 🌈 | Duha | Rainbow | breathe |
| `nature_rain` | 🌧️ | Prší | Rain | float |
| `nature_snowflake` | ❄️ | Sněží | Snow | twinkle |
| `nature_moon` | 🌙 | Měsíc | Moon | float |
| `nature_blossom` | 🌸 | Kytička | Blossom | breathe |
| `nature_sunflower` | 🌻 | Slunečnice | Sunflower | nod |
| `nature_leaf` | 🍂 | Podzim | Autumn | float |
| `nature_fire` | 🔥 | Oheň | Fire | pulse |
| `nature_lightning` | ⚡ | Blesk | Lightning | shake |

### Všední den (`everyday`, 10)

| id | | Česky | English | Pohyb |
|---|---|---|---|---|
| `day_zzz` | 💤 | Dobrou noc | Good night | float |
| `day_alarm` | ⏰ | Budíček | Wake up | shake |
| `day_idea` | 💡 | Nápad | Idea | pulse |
| `day_music` | 🎵 | Hudba | Music | bounce |
| `day_books` | 📚 | Učím se | Studying | breathe |
| `day_laptop` | 💻 | Pracuju | Working | breathe |
| `day_phone` | 📱 | Napiš mi | Text me | shake |
| `day_plane` | ✈️ | Dovolená | Holiday | float |
| `day_rocket` | 🚀 | Jdeme na to | Let's go | bounce |
| `day_gamepad` | 🎮 | Hraju | Gaming | shake |

### Rezerva (12, `reserve: true`)

`smile_alien` 👽 Mimozemšťan, `animal_butterfly` 🦋 Motýl, `animal_ladybug`
🐞 Beruška, `animal_whale` 🐳 Velryba, `animal_octopus` 🐙 Chobotnice,
`party_pumpkin` 🎃 Halloween, `party_egg` 🥚 Velikonoce, `nature_mushroom`
🍄 Houby, `food_chocolate` 🍫 Čokoláda, `day_car` 🚗 Jedu, `day_ball` ⚽
Fotbal, `day_home` 🏠 Doma.

Rezervní položka se zařadí do své kategorie (podle předpony), když v ní
některá základní neprojde ani po druhém kole seedů.

## 6. Styl a prompt

Prompt se skládá jako `styl + ", " + subject + ", " + rámování`, negativní
prompt je společný. Všechny tři bloky jsou v `tools/emoji/styles.json`,
`subject` je u každé položky v `emoji_set.json`. `subject` popisuje jen to,
co je na obrázku (anglicky, jedna věta), ne styl.

Tři kandidáti stylu pro zkoušku F3:

| Styl | Blok promptu | Čím se liší |
|---|---|---|
| `marker` | hand-drawn illustration in felt-tip marker and coloured pencil, confident visible strokes, slightly uneven dark brown ink outline, bold flat colours with light paper grain inside the shapes | Ladí s rukopisem, plošné barvy dobře snášejí paletu GIFu. |
| `paper` | cut-paper collage illustration, layered coloured paper shapes, slightly rough hand-cut edges, soft shadow between the layers, gouache texture | Ladí s tématem papíru a samolepek. |
| `clay` | soft 3D clay figure, rounded matte plasticine shapes, gentle studio light, vivid colours, subtle fingerprint texture | Ladí s písmem z modelíny. Plynulé přechody se v GIFu mohou rozpadat na pruhy. |

Rámování (stejné pro všechny): `single subject, centred, fills about 80
percent of the frame, plain flat mid-grey background, no text, no letters, no
border, no sticker outline`.

Negativní prompt: `text, letters, numbers, watermark, signature, logo, frame,
border, white sticker outline, several subjects, cropped subject, photograph,
realistic human skin, extra fingers, missing fingers`.

Obličeje jsou kulatá žlutá hlava bez těla, ruce žlutá ruka s pěti prsty bez
předloktí nebo s krátkým zápěstím. Tato dvě pravidla patří do `subject`
každé položky, ne do stylu, aby je šlo u jednotlivých emoji porušit (duch,
robot).

Jak se styl vybírá (B1): každý kandidát se posuzuje na 64 px na světlém
i tmavém podkladu a v GIFu vyexportovaném z appky. Vyhrává styl, ve kterém
je poznat nejvíc z osmi zkušebních emoji bez popisku a který se v GIFu
nerozpadá.

## 7. Pohyb

`EmojiMotion` dostane osm pojmenovaných pohybů. Každý je čistá funkce fáze
`t` v rozsahu 0–1 a vrací posun, měřítko ve dvou osách, úhel a bod otáčení.
Náhled (`AnimatedEmojiSticker`) i export (`ImageExporter`) berou transformaci
z jednoho místa, jinak se rozejdou.

| Pohyb | Popis | Bod otáčení |
|---|---|---|
| `breathe` | Dnešní smyčka beze změny: zdvih 5 %, zvětšení 7 %, kolébání ±0,08 rad. | střed |
| `pulse` | Dva rychlé údery za sebou (zvětšení na 1,12 a 1,10), pak klid do konce smyčky. | střed |
| `bounce` | Dva poskoky se zmáčknutím při dopadu (výška na 0,94, šířka to vyrovná). | spodní okraj |
| `wave` | Tři zakývání ±0,20 rad, pak klid. | střed spodního okraje |
| `shake` | Vodorovné chvění ±3 %, tři kmity v prvních 60 % smyčky s dozněním, pak klid. | střed |
| `nod` | Jedno pokývnutí: náklon 0,06 rad a pokles 3 %, pomalý návrat. | spodní okraj |
| `float` | Pomalé vznášení ±4 % s náklonem ±0,04 rad. | střed |
| `twinkle` | Dvě zajiskření: pootočení ±0,12 rad se zvětšením na 1,10. | střed |

Podmínky, které hlídá test pro každý pohyb:

- ve fázi 0 je nálepka v klidu (totožná transformace), fáze 1 se rovná fázi 0;
- každý kmit, úder nebo poskok trvá aspoň 4 snímky GIFu (24 na smyčku),
  jinak pohyb v exportu poskakuje;
- obrys nálepky po transformaci nevyjede z plátna exportu
  (`StickerLayout` s okrajem), takže se v GIFu nic neořízne;
- při omezení pohybu v systému nálepka stojí (dnešní chování zůstává).

Délka smyčky (2,4 s) a počet snímků GIFu (24) se nemění.

## 8. Datové formáty

`tools/emoji/emoji_set.json` (zdroj pravdy, píše Opus):

```json
{
  "version": 2,
  "categories": [
    {"id": "smileys", "name": {"cs": "Smajlíci", "en": "Smileys"}}
  ],
  "emoji": [
    {
      "n": 1,
      "id": "smile_happy",
      "category": "smileys",
      "emoji": "😊",
      "name": {"cs": "Úsměv", "en": "Smile"},
      "motion": "breathe",
      "subject": "a round yellow face with a warm closed-mouth smile and rosy cheeks"
    }
  ]
}
```

- `n` je stálé pořadové číslo pro výpočet seedu. Nové položky dostávají další
  číslo; existující se nepřečíslovávají ani při změně pořadí.
- `id` je malými písmeny se podtržítky, jedinečné, a je i jménem souboru.
- Rezervní položky mají `"reserve": true` a do appky se sestaví jen tehdy,
  když mají master.

`handwritten_stickers/assets/emoji/emoji.json` (píše `build.py`): verze 2 se
seznamem kategorií a u každé položky `id`, `category`, `emoji`, `name`
`{cs, en}`, `file` (`<id>.webp`) a `motion`. `subject` a `n` se do appky
nekopírují.

`tools/emoji/masters/<id>.webp`: vybraný výřez, 768 px, bezztrátový WebP
s průhledností, objekt oříznutý s okrajem asi 6 % a vystředěný ve čtverci.
Nejvýš 150 kB na kus, celá složka do 20 MB. Tohle je jediná kopie obrázků,
která přežije konec L40S, proto je v gitu.

## 9. Fáze

Odhady času GPU vycházejí z měření na L40S ze 7. 11. 2026 (Qwen-Image fp8,
1024 × 1024, 20 kroků, 20,5 s na obrázek; `BioDefenseRogue/art/icons/manifest.json`).

### F0: ověření L40S (Opus, do 1 hodiny)

- [ ] Přečíst `DevConventions/shared/infra.md` (oddíl L40S) a tento plán.
- [ ] Založit větev `emoji-own-set` z `main`.
- [ ] Zeptat se session `L40S` (SendMessage): běží ComfyUI, který model
  s povolenou licencí je nahraný a kolik trvá obrázek, jestli má výřez
  BiRefNet (skript `tmobile-sandbox/uc28/icons.py` z práce pro BioDefense),
  jak dostane repo (klon a push větve `emoji-drafts`), kdy má frontu volnou
  a do kdy sandbox poběží.
- [ ] Odpovědi zapsat do `tools/emoji/SOURCE.md`. Bez odpovědi do dalšího
  dne to oznámit uživateli; na SPARK se nepřechází.

### F1: sada, styly a zadání (Opus, 2–3 hodiny)

- [ ] `tools/emoji/emoji_set.json` verze 2 podle oddílů 5 a 8, se `subject`
  u všech 180 položek.
- [ ] `tools/emoji/styles.json` podle oddílu 6.
- [ ] `tools/emoji/check_set.py`: jedinečná `id` a `n`, tvar `id`, existující
  kategorie a pohyb, oba názvy vyplněné a nejvýš 24 znaků, `subject` bez slov
  ze zakázaného seznamu (alkohol, značky, „sticker“, „chibi“, jména výrobců).
- [ ] `tools/emoji/BRIEF.md` pro L40S podle oddílu 10.
- [ ] Smazat `run_batch.py` a `prompts.json` (vedou na SPARK a na šablonu
  SwypeKids).

### F2: aplikace (Opus, asi 1 den, běží souběžně s F3–F5)

Vyvíjí se proti zkušebním obrázkům z F4; do té doby proti dočasným maketám.

- [ ] `EmojiTag`: `id`, `category`, `emoji` (záložní znak), `name` podle
  jazyka obsahu (`context.contentLanguage`, stejně jako balíčky a sady),
  `asset`, `motion`. Rovnost a klíče widgetů podle `id`.
- [ ] `EmojiIndex`: kategorie v pořadí ze souboru, `byCategory`.
- [ ] `EmojiMotion`: osm pohybů podle oddílu 7, jedna funkce pro náhled
  i export.
- [ ] Výběr: řada kategorií nahoře (posuvné štítky s názvem), mřížka vybrané
  kategorie, první štítek „Naposledy“ s 16 posledními, pokud nějaké jsou.
  Obrázky v mřížce dekódovat ve velikosti zobrazení (`cacheWidth`), hýbe se
  dál jen vybraná nálepka.
- [ ] Naposledy použité ukládat vedle stavu editoru (`PresetStore`, v testech
  `PresetStore.inMemory`).
- [ ] Nové texty do `app_en.arb` a `app_cs.arb`, `flutter gen-l10n`.
- [ ] Testy: jedinečná `id`, žádná prázdná kategorie, každý obrázek se
  dekóduje, oba názvy vyplněné, podmínky pohybů z oddílu 7, GIF s pohybem
  `pulse` a `wave` má správný počet snímků a snímky se liší, výběr přepíná
  kategorie.

### F3: zkouška stylu I0 (L40S, asi 20 minut GPU), pak B1

- [ ] Osm emoji (`smile_laugh`, `flirt_wink`, `love_heart`, `hand_thumbs_up`,
  `hand_peace`, `animal_fox`, `party_popper`, `feel_angry`) × 3 styly × 2
  seedy = 48 obrázků.
- [ ] L40S pošle tři archy (jeden na styl) s výřezy na světlém i tmavém
  podkladu, vždy i ve zmenšení na 64 px.
- [ ] Opus z každého stylu vyexportuje jeden GIF z appky a přiloží ho.
- [ ] **B1: uživatel vybere styl.** Vybraný blok se zapíše do `styles.json`
  jako `selected`; ostatní zůstanou pro záznam.

### F4: pilot I1 (L40S, asi 30 minut GPU)

- [ ] Dvacet emoji, dvě z každé kategorie, 4 seedy (ruce 8).
- [ ] Opus je protáhne celým řetězem: master, `build.py`, appka v simulátoru,
  export GIFu, kontrola z oddílu 11.
- [ ] Poslední úprava bloku stylu, rámování a rozměrů před velkou dávkou.
  Co se tu změní, se zapíše do `SOURCE.md`.

### F5: celá sada I2 a opravy I3 (L40S, asi 5 hodin GPU)

- [ ] Zbylých 160 položek (148 základních a 12 rezervních), 4 seedy, ruce 8:
  asi 720 obrázků, 4 hodiny.
- [ ] L40S u každé položky navrhne nejlepší seed (`pick`) a poznámku, kde nic
  nevyhovuje.
- [ ] I3: položky bez vyhovujícího seedu dostanou dalších 6 seedů, případně
  upravený `subject` (úpravu dělá Opus v `emoji_set.json`, L40S ji jen
  navrhne). Co neprojde ani pak, nahradí rezerva.

### F6: výběr, sestavení a kontrola (Opus, půl dne), pak B2

- [ ] Projít návrhy L40S na arších kategorií, potvrdit nebo změnit `pick`.
- [ ] L40S pushne vybrané mastery do `tools/emoji/masters/` na větvi
  `emoji-own-set`.
- [ ] Nový `build.py`: z masterů 384 px WebP a `emoji.json` verze 2; bez
  kopírování ze SwypeKids a bez výřezu podle bílého okraje.
- [ ] Automatická kontrola a archy podle oddílu 11.
- [ ] **B2: uživatel schválí archy kategorií** nebo vypíše `id` k předělání
  (vrací se do I3).

### F7: výměna a dokumentace (Opus, půl dne)

- [ ] Smazat staré soubory `assets/emoji/<codepointy>.webp`.
- [ ] `store/listing.md`: počet emoji v obou jazycích, `python3
  store/check_listing.py`.
- [ ] `store/screenshots.sh` (snímek s výběrem emoji se změní).
- [ ] `CLAUDE.md` (odstavec o emoji, příkazy), `docs/EMOJI_PLAN.md` (stav),
  `tools/emoji/SOURCE.md` (model, checkpoint, licence, seedy, datum).
- [ ] PR do `main`. Texty a screenshoty v obchodech se mění až na pokyn
  uživatele. Na Play je k tomu potřeba deklarace podkladů vytvořených AI,
  protože screenshoty nové emoji ukazují.
- [ ] Smazat větev `emoji-drafts`.

## 10. Co musí být v zadání pro L40S (`tools/emoji/BRIEF.md`)

Vzor je `BioDefenseRogue/art/icons/BRIEF.md`; stejný postup tam už jednou
proběhl. Zadání obsahuje:

- **Kdo zadává:** session `Stickers` (repo `HandWrittenStickers`). Dotazy
  a hlášení jdou jí.
- **Zdroj pravdy:** `tools/emoji/emoji_set.json` a `styles.json` na větvi
  `emoji-own-set`.
- **Pravidla L40S:** před během přečíst `MODEL_NOTES.md` a zjištění do něj
  doplnit; frontu a souběh s jinou prací si řídí L40S podle svých konvencí.
- **Licence:** pravidlo 2 z oddílu 4. Do `manifest.json` zapsat přesný
  checkpoint, verzi, licenci a odkud je licence ověřená.
- **Parametry:** 1024 × 1024; seed = `7000 + 10 × n + k`, kde `k` je 0–3
  (ruce 0–7, opravy pokračují dalšími čísly).
- **Výřez:** PNG s průhledností, bez lemu na světlém i tmavém podkladu,
  díry uvnitř objektu zaplněné, ořez s okrajem asi 6 %, čtverec.
- **Co odevzdat na `emoji-drafts`:** archy `tools/emoji/drafts/sheets/
  <kategorie>_<část>.jpg` (řádek = emoji, sloupec = seed, buňka 256 px na
  šachovnici, seed pod buňkou, JPEG do 1,5 MB) a `tools/emoji/drafts/
  manifest.json` (`backend`, u každého `id` seedy, `pick`, `notes`).
  Surové obrázky zůstávají na VM, dokud není sada sloučená.
- **Co odevzdat na `emoji-own-set` po výběru:** jen mastery podle oddílu 8.
- **Pořadí:** I0, stop a čekání na výběr stylu; I1, stop a čekání na pokyn;
  I2 a I3.
- **Hlášení:** před I0 model, licence a odhad času; po každé dávce commit
  a seznam položek s problémem. Při nejasnosti se ptát, neodhadovat.

## 11. Kontrola kvality

Automaticky (`check_set.py --assets` nebo test v `emoji_test.dart`):

- rozměr 384 × 384, velikost do 40 kB, celá složka do 6 MB;
- čtyři rohy průhledné, žádný neprůhledný pixel na okraji (jinak výřez
  selhal nebo je objekt oříznutý);
- objekt zabírá 55–95 % delší strany rámečku;
- žádné dva obrázky nejsou skoro stejné (percepční otisk);
- každé `id` z indexu má soubor a naopak; každá kategorie má aspoň 80 %
  základních položek; celkem aspoň 150.

Okem (Opus, pak uživatel v B2), na arších 64 px na světlém i tmavém podkladu:

- význam je poznat bez popisku;
- žádný text, číslice ani logo;
- ruce mají pět prstů a správné gesto;
- jeden objekt, celý, bez zbytků pozadí a bez světlého lemu;
- sada drží jeden styl a podobnou tloušťku obrysu;
- nic neodporuje pravidlu 3 (hodnocení 4+).

## 12. Rizika

| Riziko | Co s ním |
|---|---|
| Sandbox L40S skončí (podle poznámky z 9. 11. měl žít asi měsíc od října). | F0 se ptá na termín. Dávky jdou hned za sebou, mastery se commitují po každé dávce, seedy a checkpoint jsou zapsané. |
| Ruce: špatný počet prstů, nečitelné gesto. | 8 seedů, rezerva, u `hand_crossed`, `hand_love_you`, `flirt_finger_heart` a `flirt_call_me` počítat s opravným kolem. |
| Styl se mezi kategoriemi rozjede. | Jeden blok stylu, pilot I1 napříč kategoriemi před velkou dávkou, kontrola na společných arších. |
| GIF má jen 256 barev. | Zkouška stylu zahrnuje export GIFu; plošné styly mají přednost. |
| 150+ obrázků zpomalí výběr. | Kategorie, dekódování ve velikosti zobrazení, hýbe se jen vybraná nálepka. |
| Větší aplikace. | Rozpočet 6 MB proti dnešním 0,9 MB; AAB má 123 MB. |
| Session L40S neodpoví (zprávy mezi sessions mohou čekat na schválení). | Neopakovat dotazy ve smyčce; po dni říct uživateli. |

## 13. Mimo rozsah

- Skutečná snímková animace (video modely, dvoufázové obrázky s mrknutím).
  Jde zkusit později na deseti emoji, až bude sada venku.
- Efekty kreslené kódem kolem nálepky (stoupající srdíčka, jiskry, Zzz).
- Placený balíček emoji a nové produkty v obchodech (rozhodnutí D2).
- Vyhledávání emoji podle názvu.
- Volba odstínu pleti.
