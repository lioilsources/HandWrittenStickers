# Plán: presety nastavení a monetizace

Stav k 2026-10-22, větev `main` (po PR #10). Zadání pro Opuse.

> **Stav 2026-10-22: implementováno** ve větvích `presets` (PR 1) a
> `content-packs` (PR 2). Odchylky od plánu: služby se předávají
> konstruktorem editoru (`presetStore`, `entitlements`), ne přes `provider`;
> ukládání vlastních presetů je placený balíček `presets` (rozhodnutí
> vlastníka); kategorie Materiály nemá sadu zdarma. Zbývá ruční část
> „Obchody“ (smlouvy a produkty v App Store Connect a Play Console) a
> obrazovka O aplikaci (T10) s tlačítkem Obnovit nákupy. Dvě navazující
funkce, každá jako samostatný PR; druhá staví na první. Položky mají
hotovo-kritérium, aby se daly odškrtnout.

## 0. Výchozí stav (co v kódu je a co ne)

- `StyleParams` (`lib/models/style_params.dart`): 9 polí (`letterSpacing`,
  `wordSpacing`, `lineHeight`, `baselineWobble`, `sizeVariance`,
  `rotationVariance`, `opacityVariance`, `inkColor`, `joinLetters`), `copyWith`,
  `==`. **Nemá JSON serializaci.** `inkColor` se nikde nepoužívá – barvu bere
  renderer ze sady (`GlyphLoader.inkColor`).
- `StylePreset` je `enum` se 4 vestavěnými styly (neat/casual/chaotic/fast)
  + `custom`. Preset = jen `StyleParams`, **bez sady**. `PresetSelector` je
  řádek `ChoiceChip`ů. Editor drží `_selectedPreset`, po ručním pohybu
  slideru přepne na `custom`.
- Sada (`GlyphSheet`, `assets/glyphs/sheets.json`): `id, name, path, source,
  category, bundle`. 127 záznamů, 124 bundlovaných. Editor má jeden
  `GlyphLoader` na sadu, přepnutí přes `_onSheetChanged`.
- Velikost písma je konstanta `_baseGlyphHeight = 30` (T4a z RELEASE_PLAN
  není hotové), průhledné pozadí má exporter, ale UI ho nenabízí (T2 není
  hotové). Lokalizace není (T9), UI je anglicky s českými tooltipy.
- Závislosti: `provider` je v pubspec, ale nepoužívá se. Žádné
  `shared_preferences`, žádné IAP. Bundle ID `com.ol1n.handwrittenStickers`
  (iOS i Android).
- Testy načítají reálné assety (`glyph_sheets_test.dart`,
  `editor_layout_test.dart` s `tester.runAsync` smyčkou `settle()`).

## 1. Produktová rozhodnutí

### Co je preset

Preset = **sada + styl**, tj. vše, co určuje vzhled textu, bez textu
samotného a bez emoji tagu (emoji je „ke zprávě“, ne ke stylu).

```
Preset {
  id        : String   // uuid pro uživatelské, "builtin:<slug>" pro vestavěné
  name      : String
  sheetId   : String   // id z sheets.json
  style     : StyleParams
  builtIn   : bool
  pack      : String?  // id balíčku (část 3), null = zdarma; uživatelské vždy null
  createdAt : DateTime?        // jen uživatelské
}
```

Až přibudou T2 (barva inkoustu, průhledné pozadí) a T4a (velikost písma),
patří do `StyleParams`, a tím automaticky do presetu. Proto se v tomto PR
rovnou přidá `fontScale` (1.0 = dnešních 30 px) a `transparentBackground`
do `StyleParams`, i když je UI zatím nenabízí – ať se formát presetů
nemění za měsíc.

### Chování v editoru

- Řádek presetů nahradí dnešní `PresetSelector`: nejdřív **vestavěné**, pak
  **uživatelské**, na konci chip „+ Uložit aktuální“.
- Klepnutí na preset: přepne sadu (`_onSheetChanged`) **a** styl, text
  zůstane, layout se přepočítá. Když preset odkazuje na sadu, která není
  v indexu (odstraněná, `bundle: false` v release), použije se výchozí sada
  a zobrazí se SnackBar „Písmo *X* není k dispozici, použito výchozí“.
- Po ruční změně slideru nebo sady preset zůstane zvýrazněný, ale s tečkou
  („upraveno“); v menu chipu je „Uložit změny“ (přepíše) a „Uložit jako
  nový“. Vestavěné presety jdou jen „Uložit jako nový“.
- Dlouhé stisknutí uživatelského chipu: **Přejmenovat / Přepsat aktuálním
  nastavením / Smazat** (smazání s potvrzením). Vestavěné nelze mazat.
- Název presetu: dialog s `TextField`, předvyplněno `"<název sady> – <datum>"`,
  prázdný název nejde uložit, duplicitní názvy jsou dovolené (rozlišuje `id`).
- Pořadí uživatelských presetů: podle `createdAt`, nejnovější vpravo.
  Přetahování neřešit.
- **Poslední stav**: při startu se obnoví naposledy použitý preset (nebo
  sada + styl, pokud byl „upraveno“). Dnes editor startuje vždy s `casual`
  a výchozí sadou.

### Vestavěné presety (data, ne kód)

Dnešní 4 styly se přesunou do `assets/presets/presets.json` a dostanou sadu.
Návrh (Opus může sady vyměnit podle náhledů v `docs/glyph_sheets_*.png`,
ale každá musí být v `sheets.json` s `bundle: true`):

| id | název | sada | styl | pack |
|----|-------|------|------|------|
| `builtin:neat` | Úhledně | `laurinka` | dnešní `neat` | – |
| `builtin:casual` | Běžně | `caveat` | dnešní `casual` | – |
| `builtin:fast` | Rychlý vzkaz | `reenie_beanie` | dnešní `fast` | – |
| `builtin:chaotic` | Chaos | `indie_flower` | dnešní `chaotic` | – |
| `builtin:love_letter` | Milostný dopis | kaligrafická sada s joins, `joinLetters: true`, wobble 0.1 | `calligraphy` |
| `builtin:kid_note` | Dětský vzkaz | `kids` barevná sada, wobble 0.5, size 0.25 | `kids` |
| `builtin:poster` | Plakát | `typography` sada, letterSpacing 6, rotace 0 | `poster` |
| `builtin:gingerbread` | Perník | `mat_gingerbread` | `materials` |

Preset v balíčku odkazuje jen na sady ze stejného balíčku nebo zdarma
(test to hlídá), jinak by koupě balíčku nestačila k jeho použití.

Formát souboru:

```json
{
  "version": 1,
  "presets": [
    {"id": "builtin:neat", "name": {"cs": "Úhledně", "en": "Neat"},
     "sheet": "laurinka", "pack": null,
     "style": {"letterSpacing": 2, "wordSpacing": 1.2, "lineHeight": 1.3,
               "baselineWobble": 0.1, "sizeVariance": 0.05,
               "rotationVariance": 0.1, "opacityVariance": 0.05,
               "inkColor": "#000000", "joinLetters": true,
               "fontScale": 1.0, "transparentBackground": true}}
  ]
}
```

`name` je mapa jazyků (připravené na T9), při absenci `cs` se vezme `en`.

### Úložiště

Soubor `presets.json` v `getApplicationSupportDirectory()` (balík
`path_provider` už je v projektu, žádný nový plugin, žádný nový privacy
manifest). Zápis atomicky: temp soubor + `rename`. Druhý soubor
`editor_state.json` s `{presetId, sheetId, style}` pro obnovení posledního
stavu. `shared_preferences` nepřidávat – jeden formát, snadný export/import
presetů v budoucnu.

Verze souboru `"version": 1`; neznámé klíče ve `style` ignorovat, chybějící
doplnit z `StyleParams()` (dopředná kompatibilita, až přibudou pole).

## 2. PR 1 – presety

- [x] **S1 `StyleParams` JSON + nová pole.** `toJson()`/`fromJson()`, barva
  jako `#rrggbb`; přidat `fontScale` (výchozí 1.0, zatím bez UI) a
  `transparentBackground` (výchozí `true`, zatím bez UI). `fromJson` toleruje
  chybějící klíče. Hotovo: unit test round-trip včetně barvy; test, že
  `fromJson({})` == `StyleParams()`.
- [x] **S2 Model `Preset` + `PresetStore`.** `lib/models/preset.dart`,
  `lib/services/preset_store.dart` (`ChangeNotifier`, adresář injektovatelný
  kvůli testům; `load()`, `save(Preset)`, `rename`, `delete`, `builtIns`,
  `userPresets`, `lastState`). Vestavěné z `assets/presets/presets.json`.
  Hotovo: testy s temp adresářem (uložit, znovu načíst, smazat, poškozený
  soubor → prázdný seznam bez pádu); test, že každý vestavěný preset
  odkazuje na existující sadu v `sheets.json` (stejný styl jako
  `glyph_sheets_test`).
- [x] **S3 Odstranit `enum StylePreset`.** Statické `StyleParams.neat()` atd.
  zůstanou (používají je testy a vestavěné presety se z nich dají
  vygenerovat), enum a `toStyleParams()` zmizí. Editor místo
  `_selectedPreset` drží `_appliedPreset: Preset?` a `_modified: bool`
  (= aktuální sada/styl ≠ preset).
- [x] **S4 UI řádku presetů** (`preset_selector.dart` přepsat). Chip =
  název + ikona sady (`draw`/`text_fields`/`palette` jako v
  `SheetSelector`) + tečka při „upraveno“ + zámek u presetu s `pack` (v
  tomto PR jen ikona, nic negatuje). Chip „+ Uložit aktuální“ otevře dialog názvu.
  Dlouhé stisknutí → `showModalBottomSheet` s akcemi. Hotovo: widget test
  „uložit → chip přibude → klepnout → sada i slidery odpovídají“; „smazat“
  s potvrzením.
- [x] **S5 Aplikace presetu v editoru.** `_applyPreset(Preset)`: najdi sadu
  (`_sheetIndex.byId`), fallback na `defaultSheet` + SnackBar, pak
  `_onSheetChanged` a `_styleParams = preset.style`, `_updateGlyphs()`.
  `joinLetters` se **nepřenáší** z předchozího stavu (dnes
  `_onPresetChanged` ho zachovává – to u presetu se sadou nedává smysl, preset
  ho nese sám). Hotovo: widget test s `Ahoj` – po aplikaci presetu
  s jinou sadou se změní `HandwrittenCanvas.glyphs` (jiný `cellHeightPx`).
- [x] **S6 Obnovení posledního stavu.** `editor_state.json` ukládat
  debounced (500 ms) po každé změně stylu/sady/presetu; při startu načíst
  před `_initializeSheets` a použít místo `defaultSheet`. Hotovo: test
  `PresetStore.lastState` round-trip; ruční ověření na simulátoru.
- [x] **S7 Dokumentace.** `CLAUDE.md` (sekce Flutter App: `Preset`,
  `PresetStore`, `assets/presets/presets.json`), `pubspec.yaml`
  `assets: - assets/presets/`.

Mimo rozsah PR 1: slidery pro `fontScale` a `transparentBackground` (T2,
T4a – samostatně), lokalizace (T9), náhled „Ahoj“ v chipu (hezké, ale 8
loaderů navíc při startu; nechat na později, případně jen pro vestavěné
presety s cache PNG v assetech).

## 3. Monetizace: aplikace zdarma, platí se za obsahové balíčky

**Zásada:** funkce aplikace jsou zdarma – editor, všechny slidery,
vestavěné presety zdarma, export PNG i GIF, emoji tag, spojování písmen,
obnovení posledního stavu. Jediná placená funkce je **ukládání vlastních
presetů** (balíček `presets`, rozhodnutí vlastníka 2026-10-22).
Platí se jen za **obsah navíc**, který uživatele „posune dál“: tematické
balíčky písem s presety ušitými na míru (a později i emoji). Nikdy
nezamykat něco, co uživatel dnes má.

### Proč balíčky, a ne Pro nebo předplatné

| varianta | verdikt |
|----------|---------|
| **Obsahové balíčky** (non-consumable, každý zvlášť) | **ano**: nízká cena na vstupu, motivace k druhému nákupu, obsah se dá přidávat po balíčcích bez změny kódu; Apple i Google to u kreativních aplikací přijímají bez řečí |
| Jednorázové Pro „odemkni vše“ | jen jako **sleva za všechno** (bundle), ne jako brána pro funkce |
| Předplatné | ne, bez pravidelného nového obsahu neobhajitelné |
| Reklamy | ne, SDK sbírá data (L3) a kids obsah = ATT/COPPA starosti |

### Návrh balíčků

Balíček je kurátorovaný výběr, ne „celá kategorie“ (70 kaligrafických sad
v jednom balíčku je neprodejné – nikdo je nepřehlédne). Raději víc menších
balíčků s jasným tématem a 2–3 presety, které ukážou, k čemu písma jsou.

| id | název | obsah | cena |
|----|-------|-------|------|
| – | **Zdarma** | `laurinka`, `jessie_1`, 4 sady `handwriting`, 4 `calligraphy`, 3 `typography`, 2 `kids`; 4 vestavěné presety | 0 |
| `calligraphy` | Kaligrafie | ~15 nejhezčích kaligrafických sad (joins kde jsou) + presety Milostný dopis, Svatební oznámení, Přání | 0,99 USD |
| `handwriting` | Rukopisy | ~15 rukopisných sad + presety Rychlý vzkaz 2, Deník, Dopis babičce | 0,99 USD |
| `poster` | Plakát a nápisy | ~15 typografických/display sad + presety Plakát, Nápis na dort, Cedule | 0,99 USD |
| `kids` | Pro děti | 7 zbylých `kids` sad (barevné bubliny) + presety Dětský vzkaz, Do školy | 0,99 USD |
| `materials` | Materiály | `mat_plasticine`, `mat_neon`, `mat_gingerbread` + presety Perník, Neonový nápis, Modelína (v M6 přepnout na `bundle: true`, licence ověřena, viz níže) | 0,99 USD |
| `presets` | Vlastní presety | ukládání, přejmenování a přepsání vlastních presetů (bez limitu); už uložené presety jdou použít vždy | 0,99 USD |
| `all` | Komplet | všechny balíčky, i budoucí | 100 Kč |

Zbylých ~40 sad (ty, které nejsou nejhezčí v žádné kategorii) se buď
přidají do balíčků jako „bonus“, nebo z release buildu vypadnou (`bundle:
false`) – úspora ~15 MB (R0 v RELEASE_PLAN). Konkrétní rozdělení udělá
Opus podle `docs/glyph_sheets_*.png`, finální výběr v PR review.

Licence materiálových sad (ověřeno 2026-10-22): všechny tři vznikly
z SDXL base 1.0 (CreativeML Open RAIL++-M – komerční použití i prodej
výstupů povolen, bez attribution, jen zákaz klamavého/nezákonného použití),
ControlNet Union od xinsir (Apache 2.0) a vodicího fontu Kalam (SIL OFL,
stejně jako ostatní fontové sady). Nic nebrání bundlování ani prodeji;
`bundle: false` v `sheets.json` byl jen pojistka do ověření. Výstup AI
nemá v ČR/EU autorskou ochranu, což prodeji nebrání, jen nejde bránit
kopírování.

Sezónní balíčky (Vánoce = perník + sněhové emoji, Valentýn) jsou stejný
mechanismus s jiným `packs.json`; emoji nálepky dostanou pole `pack` ve
stejném duchu, až jich bude víc než jedna sada. Teď jsou všechna emoji
zdarma.

Ceny: balíček = nejnižší Apple tier (0,99 USD, v ČR ~25 Kč), Komplet =
100 Kč (v App Store Connect nastavit CZ cenu ručně na 99 Kč, ostatní měny
nechat přepočítat z tieru ~3,99 USD). Kód cenu vždy čte z obchodu, nikde
natvrdo. Komplet je samostatný non-consumable (Apple nepočítá slevu za už
koupené balíčky), takže v paywallu se nabízí jen tomu, kdo nemá nic nebo
jeden balíček; od dvou balíčků už by se nevyplatil.

### Zamčený obsah jde vyzkoušet

Zamčenou sadu nebo preset lze v editoru zvolit a vidět živý náhled; paywall
balíčku se otevře při **Uložit / Sdílet**. Náhled má v rohu štítek s názvem
balíčku. Varianta „zamčeno už při klepnutí na chip“ hůř konvertuje – nedělat.

### Implementace: `in_app_purchase`, ne RevenueCat

Oficiální plugin `in_app_purchase` (StoreKit 2 na iOS přes
`in_app_purchase_storekit`, Play Billing na Androidu). Důvody:

- pár non-consumable produktů bez předplatného – RevenueCat je navíc SDK,
  účet a položka v privacy nutrition label;
- zachová tvrzení privacy policy „aplikace neposílá data“;
- bez serveru: iOS ověřuje transakci lokálně (StoreKit 2 JWS), Android
  vrací podepsaný `purchaseToken`; ověření děláme jen lokálně. Riziko
  podvodu u produktů za desítky korun bez serveru akceptujeme – **napsat do
  kódu komentář, ať to nikdo nepovažuje za bezpečné**.

Kdyby se někdy přidalo předplatné nebo paywall A/B testy, přejít na
RevenueCat: proto je obchodní backend za rozhraním.

```
abstract class PurchaseBackend {           // lib/services/purchases/
  Future<List<StoreProduct>> products(Set<String> ids);
  Future<void> buy(StoreProduct p);
  Future<void> restore();
  Stream<Set<String>> owned;               // id produktů, které uživatel má
}
class StorePurchaseBackend implements PurchaseBackend  // in_app_purchase
class FakePurchaseBackend  implements PurchaseBackend  // testy + --dart-define

class EntitlementService extends ChangeNotifier {
  Set<String> get ownedPacks;              // "all" rozbaluje na všechny
  bool ownsPack(String? packId) => packId == null || ownedPacks.contains(packId);
  bool canUseSheet(GlyphSheet s)  => ownsPack(s.pack);
  bool canUsePreset(Preset p)     => ownsPack(p.pack);
  Future<PurchaseOutcome> buy(String packId);
  Future<void> restore();
}
```

Vlastněné balíčky se **cachují** v souboru `entitlements.json` vedle
`editor_state.json` (`{"packs": ["calligraphy"], "checkedAt": …}`), takže
offline start nezamyká obsah. Při startu se jen naslouchá `purchaseStream`;
**tiché `restore` na iOS při startu nedělat** (může vyvolat přihlášení
k Apple ID, Apple to v review vrací). Tlačítko „Obnovit nákupy“ je povinné
(guideline 3.1.1) – do paywallu i na obrazovku O aplikaci (T10).

`provider` je už v pubspecu: `EntitlementService` a `PresetStore` poskytnout
přes `MultiProvider` v `main.dart`, editor si je bere `context.watch`, testy
je podstrčí.

### Datový model

- `assets/packs/packs.json`: `{id, product: "com.ol1n.handwrittenStickers.pack.<id>",
  name: {cs, en}, description: {cs, en}, sampleText, order}`. Produkt
  `…pack.all` má `includes: "*"`.
- `sheets.json`: každá sada dostane `"pack": "<id>"` nebo nic (= zdarma).
  `GlyphSheet.pack` (`String?`). Test: každý `pack` existuje v `packs.json`,
  každá kategorie má ≥ 1 sadu zdarma, každý balíček má ≥ 1 sadu a ≥ 1 preset.
- `presets.json`: `pack` už je (část 1).
- Produkt ID je stejné v App Store Connect i Play Console.

### UI

- `PaywallSheet` (`lib/widgets/paywall_sheet.dart`, `showModalBottomSheet`,
  `isScrollControlled`) pro **jeden balíček**: název, popis, řádek
  `sampleText` vyrenderovaný ve 3 sadách balíčku, seznam presetů, cena
  z obchodu, tlačítka **Koupit za 25 Kč** / **Komplet za 99 Kč** (jen pokud
  uživatel nevlastní ≥ 2 balíčky) / **Obnovit nákupy**, odkaz na privacy
  policy. Stavy: načítání produktu, chyba obchodu (SnackBar), zrušení (nic).
- `SheetSelector` a řádek presetů: zámek na chipu u obsahu z nevlastněného
  balíčku; po nákupu zámky zmizí bez restartu.
- Obrazovka **Balíčky** (`PacksScreen`, z AppBaru editoru ikonou
  `storefront`): karty všech balíčků s náhledem, cenou nebo „Vlastníte“;
  odtud i Obnovit nákupy. Je to zároveň jediné místo, kde Apple vidí
  „obchod“ při review.
- Editor: `_exportImage`/`_shareImage` nejdřív `_ensureOwned()`; když
  aktuální sada nebo preset je z nevlastněného balíčku, otevře
  `PaywallSheet` toho balíčku a po úspěšném nákupu export pokračuje.
- Debug: `--dart-define=HWS_PACKS=all` → `FakePurchaseBackend` se vším;
  `screenshots_test.dart` ho používá, aby snímky ukazovaly odemčený obsah
  (plus jeden snímek obrazovky Balíčky).

### Obchody (ruční kroky, mimo kód)

1. App Store Connect: *Agreements* – Paid Apps smlouva, daňové a bankovní
   údaje. 5–6 non-consumable produktů `…pack.<id>`, lokalizace cs/en,
   screenshot pro review, ceny CZ ručně (ne automatický přepočet).
2. Xcode: `Configuration.storekit` do `ios/` a do schématu Runner pro
   lokální test bez sandboxu; sandbox tester pro TestFlight.
3. Play Console: aplikace alespoň v interním testu, stejné produkty,
   licencovaní testeři; nákup funguje až s podepsaným buildem (P7 –
   keystore).
4. Privacy nutrition label: s `in_app_purchase` bez serveru zůstává „Data
   Not Collected“; ověřit v `flutter pub deps`, že plugin nepřidává nic.
5. Review notes: popsat, že balíčky jsou jen obsah, všechny funkce zdarma,
   a že náhled zamčeného obsahu je záměrný.

## 4. PR 2 – balíčky a paywall

- [x] **M1 `pack` v datech.** `packs.json`, `sheets.json` + `GlyphSheet.pack`,
  `presets.json` už má. Hotovo: testy z „Datový model“ (balíček existuje,
  každá kategorie má sadu zdarma, balíček neprázdný, preset balíčku
  odkazuje jen na své/free sady).
- [x] **M2 `PurchaseBackend` + `EntitlementService`** s cache souborem a
  `FakePurchaseBackend`. Přidat `in_app_purchase` (aktuální major), na iOS
  StoreKit 2. Hotovo: unit testy s fake backendem (koupit balíček →
  `ownsPack`, koupit `all` → vše, restore, cache přežije restart, chyba
  obchodu → `PurchaseOutcome.error` a nic se neodemkne).
- [x] **M3 Gating v editoru** (zámky, `_ensureOwned`). Hotovo: widget test
  „zamčená sada + Sdílet → paywall; po fake nákupu Sdílet projde“; „preset
  z balíčku → paywall“; „vlastní preset se uloží i bez nákupu“.
- [x] **M4 `PaywallSheet` + `PacksScreen`** + Obnovit nákupy + řádek v O
  aplikaci. Hotovo: widget test s fake backendem (cena se zobrazí, Koupit
  volá `buy` se správným produktem, „Komplet“ se skryje při ≥ 2 balíčcích),
  snímky do `screenshots_test`.
- [x] **M5 Provider wiring** v `main.dart`, `HWS_PACKS` dart-define.
- [x] **M6 Rozdělení sad do balíčků** – návrh podle náhledů, přebytečné
  sady `bundle: false`. Hotovo: tabulka v PR popisu, `sheets.json` upraven.
- [x] **M7 Dokumentace**: `CLAUDE.md` (pack, EntitlementService, debug
  odemknutí), `RELEASE_PLAN.md` – nová položka T16 (smlouvy a produkty).

Ruční ověření před merge: TestFlight build se sandbox účtem – koupit
balíček, smazat appku, nainstalovat, Obnovit nákupy → balíček zpět.
Android interní test s licencovaným testerem totéž.

## 5. Pořadí a odhady

1. **PR 1 presety** (S1–S7): ~1 den práce Opuse; nezávisí na ničem,
   nejvíc rizika je v editoru (`_appliedPreset`/`_modified` vs. stávající
   `custom` logika). S1+S2 nejdřív s testy, UI až potom.
2. **PR 2 balíčky** (M1–M7): ~1,5 dne; obchodní nastavení (část 3,
   „Obchody“) paralelně ručně, jinak se M2 nedá otestovat na zařízení.
3. Navázat na T2/T4a z RELEASE_PLAN: slidery pro `fontScale`,
   `inkColor`, `transparentBackground` – formát presetu je na ně připravený.

Otevřené otázky (rozhodne vlastník, výchozí volba v závorce):

- Materiály jít do první verze (ano, licence je čistá).
- Zda ~40 nezařazených sad vyhodit z release buildu (ano, kvůli velikosti).
- Zda Laurinčina sada (L1 v RELEASE_PLAN) smí být zdarma výchozí (zatím
  ano, dokud se nerozhodne o souhlasu).
