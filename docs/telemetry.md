# Anonymous usage statistics

Handwritten Stickers sends a small set of anonymous usage events through
the shared `ol1n_telemetry` package
(<https://github.com/lioilsources/Ol1nTelemetry>), so the owner can see what
new users do after the first launch, whether they get to their first saved
or shared sticker, which fonts and packs are used, and where the paywall and
the purchase lose people. This file is the **event dictionary**: the
constant `appDictionary`
(`handwritten_stickers/lib/telemetry/telemetry_dictionary.dart`) and this
document list exactly the same events and properties, and
`handwritten_stickers/test/telemetry_test.dart` fails when they drift apart.
The plan behind it is `DevConventions/Prompts/04-PLAN-analytika.md`.

Adding an event or a property is a change to the privacy policy
(`site/privacy/index.html`) and to the store privacy answers. Ask the owner
first.

## Rules

The rules of `ol1n_telemetry` apply unchanged (see its README):

- **No persistent identifier.** No install, device or advertising id. Each
  session has a random 128-bit id that lives in memory; unsent events in the
  offline queue carry it and are deleted once sent.
- **Cohorts are computed on the device.** Only bands leave it.
- **Only enums, bands and numbers.** Never the text the user types, never a
  preset name the user gave, no device model. Sheet, pack and preset ids are
  catalogue constants from the app's assets; anything else is sent as
  `other`. The only number about the message is its length (`chars`).
- **No key, no network.** Without `TELEMETRY_KEY` and an `https`
  `TELEMETRY_HOST` nothing is recorded, stored or sent, and the statistics
  switch is hidden.
- **The app never waits**, **bounded offline queue** (500 events), **off
  means off at once** (the switch wipes the queue), **measuring never
  steers the app**.

## Configuration

| `--dart-define` | Meaning |
|---|---|
| `TELEMETRY_KEY` | the app's key at the collector; empty → nothing is sent |
| `TELEMETRY_HOST` | the collector's base address, `https`; empty → nothing is sent |
| `TELEMETRY_DEBUG` | `true` prints events to the console instead of sending them |

All release workflows (`release-ios`, `release-android`, `release-macos`,
`release-windows`, `release-linux`) pass both from the GitHub secrets of the
same names. Builds with a fake store (`HWS_PACKS`) report `tester: true`.
The key and the collector's address never go into this repository.

The collector is run by the developer on their own server in the EU (Czech
Republic); nobody else receives the events. It stores the country derived
from the connection, not the IP address. App id at the collector:
`handwrittenstickers`.

## Switch

ⓘ in the editor's top bar opens a sheet with *About and licences* and
*Anonymous usage statistics* (on by default). Without a key the button opens
the licences directly, as before.

## Screens

`editor` (route `/`, the whole app on a phone), `packs` (`/packs`),
`licences` (`/licences`), `grid` (the Grid Alignment tab on desktop, reported
by hand). Dialogs and bottom sheets (paywall, emoji picker, preset actions)
do not change the screen.

## Activation

The first sticker saved to the gallery or handed to the share sheet
(`export_end` with `result: ok`). Answers: how many new installs get to a
first real sticker, and how fast.

## Features

For `feature_use` and `feature_snapshot` (which features advanced users use,
and which nobody does):

| Feature | When |
|---|---|
| `sheet_change` | another font picked in the sheet selector |
| `preset_apply` | a preset tapped |
| `preset_save` | the user's own preset saved |
| `emoji` | an animated emoji tagged onto the message |
| `style_adjust` | a slider or switch under Advanced settings moved |
| `save_gallery` | Save to gallery |
| `share` | Share |
| `packs_open` | the pack list opened |
| `grid_tool` | the Grid Alignment tab opened (desktop) |

## Error kinds and locked targets

`error_shown.kind`: `save` (saving to the gallery failed), `share` (sharing
failed), `purchase` (a purchase failed or the product is unavailable),
`preset_sheet` (a preset's font is missing, the default font was used).

`locked_tap.target` is the pack of a paid font or preset the user tapped
without owning it, or the pack of the lock badge on the preview.

## Common properties

Sent with every event.

| Property | Type | Values |
|---|---|---|
| `app_version` | enum | the app version (`kAppVersion`, checked against `pubspec.yaml`) |
| `platform` | enum | `ios`, `android`, `macos`, `windows`, `linux`, `other` |
| `lang` | enum | the app's language: `cs`, `en` |
| `session_band` | band | session number: `1`, `2`, `3-5`, `6-10`, `11+` |
| `days_band` | band | days since measuring began: `0`, `1`, `2-6`, `7-29`, `30+`, `pre` |
| `first_session` | bool | the very first session of a new install |
| `tester` | bool | tester build or tester device |

## Events

### `app_open`

Cold start, or a new session after more than 30 minutes in the background.
Answers: how many installs come back for a 2nd, 3rd, 6th and 11th session,
and on day 1, 2, 7 and 30.

| Property | Type | Values |
|---|---|---|
| `start` | enum | `cold`, `resume` |
| `session_band_first` | bool | the first session of this install in its `session_band` |
| `days_band_first` | bool | the first session of this install in its `days_band` |
| `campaign` | campaign | optional; QR campaign of a new install, `^[a-z0-9-]{1,24}$` |

### `screen_view`

A screen appeared. Answers: the path of a first session, and back-and-forth
between screens.

| Property | Type | Values |
|---|---|---|
| `screen` | enum | `editor`, `packs`, `licences`, `grid`, `other` |
| `prev` | enum | the previous screen, or `none` |

### `screen_leave`

A screen was left. Answers: how long people stay on which screen, and
whether they do anything there.

| Property | Type | Values |
|---|---|---|
| `screen` | enum | as in `screen_view` |
| `secs` | int | foreground seconds on the screen |
| `actions` | int | app events, feature uses and locked taps during the stay |

### `session_pause`

The app went to the background or is closing. Sent at once. Answers: when
and where people stop.

| Property | Type | Values |
|---|---|---|
| `active_secs` | int | foreground seconds in this session |
| `screen` | enum | the screen at the time, or `none` |
| `screen_secs` | int | foreground seconds on that screen |

### `activation`

The first sticker saved or shared on this install. Once per install.
Answers: how many new users get to a first real sticker, and how fast.

| Property | Type | Values |
|---|---|---|
| `secs` | int | seconds since this session's `app_open` |

### `feature_use`

The first use of a feature in a session (list above). Answers: which
features are used, in which session band.

| Property | Type | Values |
|---|---|---|
| `feature` | enum | `sheet_change`, `preset_apply`, `preset_save`, `emoji`, `style_adjust`, `save_gallery`, `share`, `packs_open`, `grid_tool` |

### `feature_snapshot`

After `app_open` of the 3rd, 6th and 11th session: which features this
install has ever used. Answers: what advanced users never touch.

| Property | Type | Values |
|---|---|---|
| `f_sheet_change` | bool | another font picked |
| `f_preset_apply` | bool | a preset applied |
| `f_preset_save` | bool | an own preset saved |
| `f_emoji` | bool | an emoji tagged |
| `f_style_adjust` | bool | advanced settings changed |
| `f_save_gallery` | bool | saved to the gallery |
| `f_share` | bool | shared |
| `f_packs_open` | bool | pack list opened |
| `f_grid_tool` | bool | Grid Alignment used |
| `features_used` | int | how many of them |

### `error_shown`

The user saw an error (kinds above). Answers: where people struggle.

| Property | Type | Values |
|---|---|---|
| `kind` | enum | `save`, `share`, `purchase`, `preset_sheet` |
| `screen` | enum | the screen at the time, or `none` |

### `locked_tap`

A tap on a font or preset from a pack the user does not own, or on the
lock badge of the preview. Answers: which paid content draws interest.

| Property | Type | Values |
|---|---|---|
| `target` | enum | `handwriting`, `calligraphy`, `poster`, `kids`, `materials`, `presets`, `all` |

### `export_start`

Save to gallery or Share was tapped and the content is owned (after a
paywall, if one was needed). Answers: which fonts, categories, packs and
presets people actually send, how often with an emoji, how long messages
are; together with `export_end`, how often exporting fails and how long the
animated GIF takes.

| Property | Type | Values |
|---|---|---|
| `target` | enum | `gallery`, `share` |
| `animated` | bool | with an emoji tag (a GIF) |
| `sheet` | enum | the font: a sheet id from `assets/glyphs/sheets.json` (`kSheetIds`), or `other` |
| `category` | enum | `handwriting`, `calligraphy`, `typography`, `kids`, `material` |
| `pack` | enum | the font's pack: `handwriting`, `calligraphy`, `poster`, `kids`, `materials`, `presets`, `all`, `free`, `other` |
| `preset` | enum | the applied built-in preset (`neat`, `casual`, `fast`, `chaotic`, `love_letter`, `wedding`, `greeting`, `diary`, `grandma`, `sticky`, `poster`, `cake`, `sign`, `kid_note`, `school`, `gingerbread`, `neon`, `plasticine`), `user` for an own preset, `none`, `other` |
| `modified` | bool | the look was changed since the preset |
| `chars` | int | length of the message in characters (never the text) |

### `export_end`

The export finished: `ok` (saved, or the share sheet opened), `error`
(failed, the user saw the error), `cancel` (another export was still
running), `background`.

| Property | Type | Values |
|---|---|---|
| `result` | enum | `ok`, `cancel`, `error`, `background` |
| `secs` | int | foreground seconds |
| `target` | enum | `gallery`, `share` |
| `animated` | bool | with an emoji tag |

### `paywall_start`

The purchase sheet for a pack opened. Answers: what makes people meet the
paywall (export of a paid font, saving a preset, the lock badge, the pack
list) and for which packs.

| Property | Type | Values |
|---|---|---|
| `pack` | enum | `handwriting`, `calligraphy`, `poster`, `kids`, `materials`, `presets`, `all`, `other` |
| `source` | enum | `export`, `preset_save`, `badge`, `packs` |

### `paywall_end`

The purchase sheet closed: `ok` when the user now owns the pack (bought or
restored), `cancel` otherwise. Answers: how many paywalls turn into an
owned pack, and how long people look before deciding.

| Property | Type | Values |
|---|---|---|
| `result` | enum | `ok`, `cancel`, `error`, `background` |
| `secs` | int | foreground seconds |
| `pack` | enum | as in `paywall_start` |
| `source` | enum | as in `paywall_start` |

### `purchase_start`

Buy was tapped on the purchase sheet (the pack itself or the bundle).
Answers: together with `purchase_end`, where the store purchase fails.

| Property | Type | Values |
|---|---|---|
| `pack` | enum | `handwriting`, `calligraphy`, `poster`, `kids`, `materials`, `presets`, `all`, `other` |

### `purchase_end`

The store answered: `ok` (purchased), `cancel`, `error`, `pending` (waiting
for approval), `unavailable` (product not found), `background`.

| Property | Type | Values |
|---|---|---|
| `result` | enum | `ok`, `cancel`, `error`, `background`, `pending`, `unavailable` |
| `secs` | int | foreground seconds |
| `pack` | enum | as in `purchase_start` |

### `purchases_restore`

Restore purchases finished. Answers: whether people use restore, and from
where.

| Property | Type | Values |
|---|---|---|
| `from` | enum | `packs`, `paywall` |
| `owned` | int | packs owned after the restore |

## Reading the data

`store-metrics report handwrittenstickers` on the collector's host (plan
§5.4). Tester builds are left out of the default report.
