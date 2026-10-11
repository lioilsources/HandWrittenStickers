# Archivní zdroje rukopisů a tisků (R1 + R2)

Průzkum pro plán `Prompts/02-GLYPH_SOURCES_PLAN.md`, sekce 4. Stav k 30. 9. 2026. Každé URL níže bylo ověřeno (HTTP 200, u API skutečná odpověď). Rozměry obrázků jsou naměřené z `info.json` nebo z API, ne převzaté z popisu.

Platí zásada R5: **volné dílo neznamená volný sken.** Proto se u každého zdroje licence skenu uvádí zvlášť.

## 1. Souhrnná tabulka

| Zdroj | Formát | Rozlišení (naměřeno) | Licence skenu | Strojové stažení | Poznámka |
|---|---|---|---|---|---|
| **Manuscriptorium** (NK ČR) | JPEG přes IIIF Image API 2 (server Loris `imagines.manuscriptorium.com/loris/…`); manifest IIIF | 1400×2346 (rukopis NUK), 3243×2293 (Pražská konzervatoř); běžně 2–3 tis. px na delší straně | **Creative Commons, varianta je uvedena u každého záznamu** („The image data published in Manuscriptorium is protected by the Creative Commons licence – the specific licence variant is always stated in the relevant record.“). Katalogové záznamy jsou public domain. Viděli jsme PDM 1.0 (NUK Lublaň) a CC BY 4.0 (Pražská konzervatoř). | Ano. IIIF Image API bez klíče, `…/full/full/0/default.jpg` vrací plné rozlišení. Metadata přes OAI-PMH (profily DC, DCQ, ESE). Vyhledávací API (`/apis/resolver-api/`) není veřejně dokumentované, je to SPA. Nejjednodušší je hledat přes Europeana API (`PROVIDER:"Manuscriptorium"`). | Obsah je hlavně středověk a raný novověk (liturgie, hudebniny). Pro 19. století a češtinu je výběr malý. Podmínky: <https://www.manuscriptorium.com/conditions-of-use> |
| **Kramerius** (NK ČR `kramerius5.nkp.cz` = K5; MZK `api.kramerius.mzk.cz` = K7; portál `digitalniknihovna.cz`) | JPEG z IIPImage. MZK (K7) má nativní IIIF Image API 3 (`/search/iiif/{pid}/info.json`). NK (K5) má Zoomify a `img?…&stream=IMG_FULL`. Pro obě knihovny existuje brána IIIF Presentation 3 `iiif.digitalniknihovna.cz/{knihovna}/{uuid}`. | MZK 1848×2910, 2358×3326; NK 1934×2963 (typicky kolem 300 dpi u formátu A5) | **Bez explicitní licence.** U „veřejných“ děl (70 let od smrti všech autorů + 50 let od vydání) MZK uvádí: „Můžete je volně prohlížet, stahovat i tisknout.“ NDK uvádí: „dokumenty si můžete tisknout nebo uložit na počítač“. Není tam CC0 ani PDM a není výslovně povoleno komerční šíření. | Technicky ano, bez klíče: K7 search API, IIIF, `/items/{pid}/image`; K5 `search/api/v5.0`. **Pozor:** Všeobecné podmínky DK MZK zakazují „strojově vytěžovat Digitální knihovnu MZK“. Stahujeme proto jen jednotky stránek, ručně nebo pomalým skriptem. | Nejlepší zdroj pro české tisky 18.–20. století (švabach, fraktura, slabikáře, předlohy písma). Licenční text: `https://www.digitalniknihovna.cz/assets/shared/licences/mzk/public.cs.html` |
| **Europeana** (API) | Agregátor. Náhled `api.europeana.eu/thumbnail/v3/…` (max 400 px). Plné rozlišení je vždy u poskytovatele (`edmIsShownBy`). IIIF Presentation `iiif.europeana.eu/presentation/{ds}/{id}/manifest` (v2). | Podle poskytovatele. Europeana sama drží jen náhledy. | Pole `edmRights` u každého záznamu. Filtr `reusability=open` vrací jen PDM, CC0, CC BY a CC BY-SA. | Search/Record API **vyžaduje `wskey`** (bez něj 401; na testy funguje veřejný `api2demo`, pro produkci je potřeba vlastní klíč zdarma). IIIF API klíč nevyžaduje. | Výborné pro filtrování licencí a pro hledání v Manuscriptoriu nebo eSbírkách. Pozor na mrtvé odkazy u poskytovatelů: dopis A. Dvořáka z eSbírek (CC BY 4.0) má `esbirky.cz/img.php` → „File not found“, dostupný je jen náhled 400 px. |
| **Wikimedia Commons** | Originální soubor (JPEG, PNG, GIF, SVG, PDF) na `upload.wikimedia.org`; zmenšeniny přes `Special:FilePath/…?width=N` | Kolísá: 600×201 (GIF) až 4391×2834. Dopisy kolem 1700×2600. | Licence u každého souboru (`extmetadata.LicenseShortName`). Pro skeny 2D volných děl platí na Commons politika PD-Art (věrná reprodukce nevytváří nové právo), ale někteří uploadeři přesto přidávají CC BY-SA na vlastní fotku. | Ano, MediaWiki API bez klíče (`action=query&prop=imageinfo&iiprop=url|size|extmetadata`). Je potřeba slušný `User-Agent`, jinak přichází rate-limit. | Kategorie „Letters in Czech“ **neexistuje**. Použitelné jsou kategorie `Handwriting in Czech`, `German Kurrent`, `German Kurrent letters`, `Schwabacher` a `Autograph manuscripts`. |

## 2. Kandidáti pro R2

### A. Kurent (německá novogotická kurziva), 19. století

1. **Bedřich Smetana, dopis z Jabkenic, 4. 3. 1881 (poslední strana), německy, kurentem.** Wikimedia Commons, 1675×2588 JPEG, **`{{PD-old}}`** (autor † 1884).
   <https://commons.wikimedia.org/wiki/File:Smetana_dopis.jpg>
   Čistý jednotný rukopis, 17 řádků plus podpis. Nevýhoda: němčina, takže chybí háčky a čárky a české diakritiky se musí skládat (varianty A2).
2. **F. Rössler: „Cantate auf W. A. Mozarts Tod“, 1798, titulní list.** Kurent kombinovaný s latinkou. Manuscriptorium / Pražská konzervatoř, sig. 2932. IIIF 3243×2293, **CC BY 4.0**.
   Záznam: <https://www.manuscriptorium.com/hub/catalog/default/detail/single/manuscriptorium%7CPK____-PK____2932________1HDC1ID-en?lang=cs>
   IIIF obraz: `https://imagines.manuscriptorium.com/loris/PK____-PK____2932________1HDC1ID-en/id_0001/full/full/0/default.jpg`
   Europeana: <https://www.europeana.eu/cs/item/92004/object_PK____2932________1HDC1ID>
   Znaků je málo (jen titulní list), hodí se spíš jako doplněk.
3. (Referenční vzor, nejde o archivní originál) **Kurrentschrift Tafel Bremen**, fotografie tabule s abecedou, 4391×2834, **CC BY 4.0**, autor Thirunavukkarasye-Raveendran.
   <https://commons.wikimedia.org/wiki/File:Kurrentschrift_Tafel_Bremen.jpg>
   Kompletní abeceda poslouží jako předloha pro označování, ale je to moderní fotka.

### B. Školní krasopis (psací písmo)

1. **Slabikář pro školy obecné, Praha 1899** (sestavili A. Frumar a J. Jursa, ilustroval M. Aleš), kapitoly „Malá písmena psací“ a „Velká písmena psací“ (s. 55–86). Rytá školní kurziva s kompletní českou diakritikou (Č, Š, Ř, ě, ů…), vysoký kontrast, bílé pozadí. NK ČR / Kramerius, stav „public“, 1934×2963 JPEG.
   Prohlížeč: <https://www.digitalniknihovna.cz/nkp/uuid/uuid:e03feca0-54f5-11de-bb47-000d606f5dc6>
   IIIF manifest: <https://iiif.digitalniknihovna.cz/nkp/uuid:e03feca0-54f5-11de-bb47-000d606f5dc6>
   Např. s. 58: `https://kramerius5.nkp.cz/search/img?pid=uuid:a321e83d-a5de-48ef-8c2c-99790ec19a22&stream=IMG_FULL&action=GETRAW`
   Licence: veřejné dílo, sken je „k tisku a uložení“ a nemá explicitní open licenci. Kniha pochází z doby před první republikou, ale jde o stejnou školní kurzivu, jaká se učila i po roce 1918.
2. **Jan Šembera: Předlohy písma, Bílovec: Massag, 1938** (prvorepublikové školní písmo perem: hůlkové písmo, kurzíva, abecedy s Č Ř Š Ů Ý, ukázky „Ráz písma“). MZK / Kramerius 7, „public“ (autor † 1939), 44 stran, 2358×3326.
   Prohlížeč: <https://www.digitalniknihovna.cz/mzk/uuid/uuid:e32ee810-275c-11ed-9c80-005056827e51>
   IIIF manifest: <https://iiif.digitalniknihovna.cz/mzk/uuid:e32ee810-275c-11ed-9c80-005056827e51>
   Stránka s abecedou (s. 12): `https://api.kramerius.mzk.cz/search/iiif/uuid:fa07d78f-5bc9-4086-ba24-07328ebd2f3d/full/max/0/default.jpg`
   Licence: stejná situace jako u NK (MZK: „volně prohlížet, stahovat i tisknout“). Jde spíš o kaligrafické „písmo perem“ než o kurzivu, takže kandidát spadá do kategorie `calligraphy`.
3. **Psací písmo.gif**, česká školní kurziva (pravděpodobně V. Penc), **Public domain**, jen 600×201.
   <https://commons.wikimedia.org/wiki/File:Psac%C3%AD_p%C3%ADsmo.gif>
   Pro glyfy je příliš malé, hodí se jen jako tvarová reference.

### C. Dopisy spisovatelů a osobností (autor zemřel před více než 70 lety)

1. **Bedřich Smetana: dopis spolku Dobroslav v Kolíně, 8. 5. 1882**, česky, latinkou (krasopisná kurziva, patrně psal písař, Smetana jen podepsal). Diakritika ř, ů, č, ě. Commons, 1800×2300 (SOkA Kolín), **Public domain**.
   <https://commons.wikimedia.org/wiki/File:Dopis_B._Smetany_spolku_Dobroslav_1882_(SOkA_Kol%C3%ADn).jpg>
2. **Karel Havlíček Borovský: dopis (1846)**, česky, osobní kurziva, 2 strany vedle sebe, 3408×2496. Commons: dílo je PD (autor † 1856), ale **fotka je nahraná jako CC BY-SA 4.0** (vlastní dílo uploadera). SA by se mohlo přenést na sadu, a proto kandidát do App Store nejde bez právního posouzení.
   <https://commons.wikimedia.org/wiki/File:Havlicek_dopis2.jpg>
3. (Nepoužitelné, jen pro úplnost) **Antonín Dvořák: dopis A. Göblovi, 20. 6. 1891**, Europeana / České muzeum hudby, CC BY 4.0. Zdrojový obrázek na eSbírkách ale vrací „File not found“, zbývá jen náhled 400 px.
   <https://www.europeana.eu/cs/item/483/https___www_esbirky_cz_detail_89159>
   Pro úplnost: K. H. Mácha, Máj (rukopis, PD, 1217×1520 a 1600×1371) je na Commons jako `File:Máj (rukopis)-01.jpg` a `-02.jpg`.

### D. Tištěná fraktura a švabach (česky)

1. **Kancionál církwe reformowané, 1876** (Brno / Vsetín), česká **fraktura** s diakritikou (Ž, ř, ů, š) ve tvaru tehdejšího „bratrského“ pravopisu (w, ſſ). MZK Kramerius, „public“, 770 stran, 1178×2006.
   Prohlížeč: <https://www.digitalniknihovna.cz/mzk/uuid/uuid:d4a00500-b50c-11e5-9ab7-005056827e52>
   IIIF manifest: <https://iiif.digitalniknihovna.cz/mzk/uuid:d4a00500-b50c-11e5-9ab7-005056827e52>
   Rozlišení je spíš nižší. Pro kvalitní glyfy vybrat strany s větším písmem (nadpisy, žalmy).
2. **Cithara Sanctorum (Třanovský), Lubań 1745**, česky, **švabach**, výborná kvalita tisku. MZK Kramerius, „public“, 1464 stran, 1848×2910.
   Prohlížeč: <https://www.digitalniknihovna.cz/mzk/uuid/uuid:c687b876-80c9-4450-8bbf-5c5a72f137a1>
   Např. strana: `https://api.kramerius.mzk.cz/search/iiif/uuid:6380ceb2-6bd2-4a2d-ba32-d629865e84de/full/max/0/default.jpg`
3. **Cithara sanctorum, Pešť 1828**, fotka dvoustrany, švabach, Commons, **PD-self**, jen 1024×757.
   <https://commons.wikimedia.org/wiki/File:Cithara_sanctorum_1828.JPG>
   Explicitně volné, ale nízké rozlišení. Další ukázky jsou v <https://commons.wikimedia.org/wiki/Category:Schwabacher>.

## 3. Doporučení pro R4

- **Psaná sada: Slabikář pro školy obecné (1899, NK ČR), kapitoly „psací písmena“.** Jako jediný kandidát má kompletní českou abecedu včetně všech háčků a čárek, rytý tvar má vysoký kontrast a na stránce je hodně textu, takže jde o nejlevnější segmentaci i označování. Kategorie `calligraphy` („krasopis“).
- **Tištěná sada: Cithara Sanctorum 1745 (MZK), švabach.** Nejostřejší a nejvyšší rozlišení z českých tisků, tisíce stran, a díky tomu je z čeho vybírat každý znak. Kategorie `typography`. Alternativou pro frakturu je Kancionál 1876, má ale nižší rozlišení.

**Právní podmínka (R5):** Oba doporučené skeny pocházejí z Krameria a mají jen formulaci „volně stahovat/tisknout“, ne open licenci. Před vydáním do App Store je potřeba jedno z těchto dvou:
(a) písemně si vyžádat potvrzení komerčního užití (NK: info@ndk.cz, MZK: digitalniknihovna@mzk.cz) a zapsat ho do `SOURCE.md`, nebo
(b) použít explicitně volné náhrady: pro psané písmo Smetanův kurent (Commons, PD-old) nebo dopis Dobroslavu (Commons, PD), pro tisk Kancionál/Cithara nahrané na Commons s PD-old-70 + PD-Art. Na Commons ale sken nahrajeme jen tehdy, když to NK/MZK výslovně nevylučuje.

Do dokončení bodu (a) nebo (b) sady ponechat jen pro vývoj a nebalit je do release.
