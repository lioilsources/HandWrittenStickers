import 'package:ol1n_telemetry/ol1n_telemetry.dart';

/// The app version this build reports; `test/telemetry_test.dart` keeps it
/// equal to `version:` in `pubspec.yaml`.
const kAppVersion = '1.0.1';

/// Id of the app at the collector (`apps.yaml` in StoreMetrics).
const kTelemetryApp = 'handwrittenstickers';

/// Route name → screen. The grid tool is a tab, reported by hand.
const kScreenRoutes = {
  '/': 'editor',
  '/packs': 'packs',
  '/licences': 'licences',
};

/// Every sheet id in `assets/glyphs/sheets.json` (the test keeps them in
/// step). Catalogue constants, never anything the user typed.
const kSheetIds = {
  'laurinka',
  'caveat',
  'patrick_hand',
  'kalam',
  'indie_flower',
  'playpen_sans',
  'reenie_beanie',
  'comforter',
  'estonia',
  'give_you_glory',
  'grape_nuts',
  'ingrid_darling',
  'la_belle_aurore',
  'love_light',
  'oooh_baby',
  'over_the_rainbow',
  'puppies_play',
  'send_flowers',
  'smooch',
  'square_peg',
  'twinkle_star',
  'whisper',
  'jessie_1',
  'dancing_script',
  'sacramento',
  'pacifico',
  'great_vibes',
  'alex_brush',
  'parisienne',
  'pinyon_script',
  'kaushan_script',
  'allura',
  'arizonia',
  'babylonica',
  'ballet',
  'beau_rivage',
  'berkshire_swash',
  'birthstone',
  'birthstone_bounce',
  'bonheur_royale',
  'carattere',
  'charm',
  'cherish',
  'clicker_script',
  'comforter_brush',
  'corinthia',
  'damion',
  'devonshire',
  'dynalight',
  'engagement',
  'ephesis',
  'explora',
  'festive',
  'fleur_de_leah',
  'grand_hotel',
  'hurricane',
  'imperial_script',
  'inspiration',
  'island_moments',
  'italianno',
  'jim_nightshade',
  'kolker_brush',
  'lavishly_yours',
  'licorice',
  'lovers_quarrel',
  'luxurious_script',
  'mea_culpa',
  'meddon',
  'moon_dance',
  'my_soul',
  'neonderthaw',
  'norican',
  'ole',
  'passions_conflict',
  'petemoss',
  'petit_formal_script',
  'playball',
  'praise',
  'quintessential',
  'qwigley',
  'qwitcher_grypen',
  'ruthie',
  'sassy_frass',
  'shalimar',
  'splash',
  'stalemate',
  'style_script',
  'tapestry',
  'the_nautigal',
  'vujahday_script',
  'water_brush',
  'waterfall',
  'yesteryear',
  'amatic_sc',
  'playfair_display',
  'cinzel',
  'bebas_neue',
  'abril_fatface',
  'courier_prime',
  'medieval_sharp',
  'dela_gothic_one',
  'eagle_lake',
  'englebert',
  'fondamento',
  'fruktur',
  'grenze_gotisch',
  'julee',
  'kings',
  'lobster',
  'metamorphous',
  'new_rocker',
  'oldenburg',
  'shojumaru',
  'uncial_antiqua',
  'wellfleet',
  'kid_bubble_peach',
  'kid_bubble_mint',
  'kid_bubble_lavender',
  'kid_bubble_lemon',
  'kid_bubble_sky',
  'kid_bubble_italic',
  'kid_dynapuff',
  'kid_grandstander',
  'kid_baloo',
  'mat_plasticine',
  'mat_neon',
  'mat_gingerbread',
};

/// Sheet categories (`SheetCategory`).
const kSheetCategories = {
  'handwriting',
  'calligraphy',
  'typography',
  'kids',
  'material',
};

/// Pack ids in `assets/packs/packs.json` (the test keeps them in step).
const kPackIds = {
  'handwriting',
  'calligraphy',
  'poster',
  'kids',
  'materials',
  'presets',
  'all',
};

/// Built-in preset ids in `assets/presets/presets.json` without the
/// `builtin:` prefix (the test keeps them in step).
const kBuiltInPresetIds = {
  'neat',
  'casual',
  'fast',
  'chaotic',
  'love_letter',
  'wedding',
  'greeting',
  'diary',
  'grandma',
  'sticky',
  'poster',
  'cake',
  'sign',
  'kid_note',
  'school',
  'gingerbread',
  'neon',
  'plasticine',
};

/// Where the paywall was opened from.
const kPaywallSources = {'export', 'preset_save', 'badge', 'packs'};

/// A sheet id as reported: the catalogue id, or `other`.
String telemetrySheet(String? id) => kSheetIds.contains(id) ? id! : 'other';

/// A pack id as reported: the catalogue id, `free` for none, or `other`.
String telemetryPack(String? id) =>
    id == null ? 'free' : (kPackIds.contains(id) ? id : 'other');

/// A preset as reported: the built-in id, `user` for the user's own, or
/// `none`. Never the name the user gave it.
String telemetryPreset({required String? id, required bool builtIn}) {
  if (id == null) return 'none';
  if (!builtIn) return 'user';
  final bare = id.startsWith('builtin:') ? id.substring(8) : id;
  return kBuiltInPresetIds.contains(bare) ? bare : 'other';
}

/// The one event dictionary of the app, mirrored in `docs/telemetry.md`.
final appDictionary = TelemetryDictionary(
  appVersion: kAppVersion,
  languages: {'cs', 'en'},
  screens: {...kScreenRoutes.values, 'grid'},
  features: {
    'sheet_change',
    'preset_apply',
    'preset_save',
    'emoji',
    'style_adjust',
    'save_gallery',
    'share',
    'packs_open',
    'grid_tool',
  },
  errorKinds: {'save', 'share', 'purchase', 'preset_sheet'},
  lockedTargets: kPackIds,
  events: {
    ...TelemetryDictionary.flow(
      'export',
      start: {
        'target': const EnumProp({'gallery', 'share'}),
        'animated': const BoolProp(),
        'sheet': const EnumProp({...kSheetIds, 'other'}),
        'category': const EnumProp(kSheetCategories),
        'pack': const EnumProp({...kPackIds, 'free', 'other'}),
        'preset': const EnumProp({
          ...kBuiltInPresetIds,
          'user',
          'none',
          'other',
        }),
        'modified': const BoolProp(),
        'chars': const IntProp(10000),
      },
      end: {
        'target': const EnumProp({'gallery', 'share'}),
        'animated': const BoolProp(),
      },
    ),
    ...TelemetryDictionary.flow(
      'paywall',
      start: {
        'pack': const EnumProp({...kPackIds, 'other'}),
        'source': const EnumProp(kPaywallSources),
      },
      end: {
        'pack': const EnumProp({...kPackIds, 'other'}),
        'source': const EnumProp(kPaywallSources),
      },
    ),
    ...TelemetryDictionary.flow(
      'purchase',
      results: {'pending', 'unavailable'},
      start: {
        'pack': const EnumProp({...kPackIds, 'other'}),
      },
      end: {
        'pack': const EnumProp({...kPackIds, 'other'}),
      },
    ),
    'purchases_restore': {
      'from': const EnumProp({'packs', 'paywall'}),
      'owned': const IntProp(100),
    },
  },
);
