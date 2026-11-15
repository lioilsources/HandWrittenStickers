# Privacy answers for the stores

Answers for the first build with anonymous usage statistics
(`docs/telemetry.md`). **Fill them in before that build is submitted, and
only after the new privacy policy (`site/privacy/index.html`, published by
`.github/workflows/pages.yml`) is live.** They match the app's own
`handwritten_stickers/ios/Runner/PrivacyInfo.xcprivacy` and
`handwritten_stickers/macos/Runner/PrivacyInfo.xcprivacy`. Check the current
wording of both forms before filling them in.

Order: policy live → these forms → `TELEMETRY_KEY` / `TELEMETRY_HOST`
secrets → release. A build without the secrets sends nothing.

**Privacy Policy URL** (both stores), unchanged:
`https://lioilsources.github.io/HandWrittenStickers/privacy/`

## App Store Connect → App Privacy

**Do you or your third-party partners collect data from this app?** **Yes.**

**Data types collected** (tick exactly these):

| Category → type | Linked to the user? | Used for tracking? | Purpose |
|---|---|---|---|
| Usage Data → **Product Interaction** | **No** | **No** | **Analytics** |
| Diagnostics → **Performance Data** | **No** | **No** | **Analytics** |
| Location → **Coarse Location** | **No** | **No** | **Analytics** |

Why each:

- *Product Interaction*: launches, screens and seconds on them, features
  used, stickers saved or shared (font, pack and built-in preset ids, length
  in characters, never the text), paywall, purchase and restore outcomes,
  errors, taps on locked content.
- *Performance Data*: how many seconds saving or sharing a sticker took
  (`export_end.secs`; the animated GIF is encoded on the device).
- *Coarse Location*: the developer's own collector derives the country from
  the connection's IP address, keeps only the country and does not store the
  IP. If the country is ever turned off on the collector, untick this row and
  remove `NSPrivacyCollectedDataTypeCoarseLocation` from both privacy
  manifests.

Not collected (leave unticked): Contact Info, Health & Fitness, Financial
Info, Precise Location, Sensitive Info, Contacts, User Content (the text and
the stickers never leave the device except when the user shares them),
Browsing History, Search History, Identifiers (no User ID and no Device ID:
the session id is random, lives in memory and is never reused), Purchases
(what the store reports stays on the device; the statistics only say a
purchase ended and how), Other Usage Data, Crash Data, Other Diagnostic Data,
Other Data.

**Linked to the user: No**, for every type: no account, no identifier; two
sessions cannot be connected to each other.

**Tracking: No.** Nothing is combined with other companies' data or shared
with data brokers, and there are no ads. No App Tracking Transparency prompt
is needed (`NSPrivacyTracking` is `false`).

## Google Play Console → Data safety

- Does your app collect or share any of the required user data types?
  **Yes.**
- Is all of the user data collected by your app encrypted in transit?
  **Yes** (the statistics client refuses a non-`https` host).
- Do you provide a way for users to request that their data is deleted?
  **No.** There is no account. The statistics carry no identifier, so no
  record can be found for a person; they can be switched off in the app
  (which deletes the unsent ones on the device) and are deleted after 12
  months. (Deletion is required only for apps with account creation.)
- Data types, all **Collected**, **not shared** (they go only to the
  developer's own server in the EU, Czech Republic; no third party receives
  them):

| Data type | Purpose | Ephemeral? | Required or optional |
|---|---|---|---|
| App activity → **App interactions** | **Analytics** | No | **Optional** (switch under ⓘ in the editor) |
| App info and performance → **Diagnostics** | **Analytics** | No | **Optional** (same switch) |
| Location → **Approximate location** | **Analytics** | No | **Optional** (same switch) |

If the country is ever turned off on the collector, drop the *Approximate
location* row.

Not collected: precise location, personal info, financial info (purchases
are Google Play Billing's data, not ours), messages, photos and videos (the
app only adds the sticker to the gallery when asked and never reads it), files
and docs, contacts, web browsing, device or other IDs.

## Places outside this repository

- App Store Connect → App Privacy: the answers above.
- Google Play Console → Data safety: the answers above.
- The app's page on olin.now (every language it exists in): replace any
  "collects no data" / "sends nothing" with the anonymous, switchable
  statistics; "no ads, no account, no third-party analytics" stays true.
- App Store Connect → App Review notes and the store descriptions: from
  `store/listing.md` (updated in the same change as this file).
