import 'package:flutter/material.dart';
import 'package:ol1n_telemetry/ol1n_telemetry.dart';

import '../l10n/l10n.dart';
import '../models/content_pack.dart';
import '../models/glyph_sheet.dart';
import '../models/preset.dart';
import '../services/entitlement_service.dart';
import '../services/glyph_loader.dart';
import '../widgets/paywall_sheet.dart';
import '../widgets/sheet_sample.dart';

/// Every content pack with its price or "owned", and Restore purchases.
class PacksScreen extends StatelessWidget {
  final EntitlementService entitlements;
  final List<GlyphSheet> sheets;
  final List<Preset> presets;
  final Future<GlyphLoader> Function(GlyphSheet sheet)? loaderFor;

  const PacksScreen({
    super.key,
    required this.entitlements,
    required this.sheets,
    required this.presets,
    this.loaderFor,
  });

  PackContents _contents(ContentPack pack) =>
      PackContents.of(pack, sheets: sheets, presets: presets);

  Future<void> _open(BuildContext context, ContentPack pack) async {
    if (entitlements.ownsPack(pack.id)) return;
    await showPaywall(
      context,
      entitlements: entitlements,
      pack: pack,
      contents: _contents(pack),
      source: 'packs',
      loaderFor: loaderFor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.packs),
        actions: [
          TextButton(
            key: const ValueKey('packs-restore'),
            onPressed: () async {
              await entitlements.restore();
              Telemetry.track('purchases_restore', {
                'from': 'packs',
                'owned': entitlements.ownedPacks.length.clamp(0, 100),
              });
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.purchasesRestored)));
            },
            child: Text(l10n.restorePurchases),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: entitlements,
        builder: (context, _) {
          final packs = entitlements.packs.packs;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.packsIntro,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              for (final pack in packs)
                // The bundle only while it is still worth it.
                if (!pack.includesAll ||
                    entitlements.offerAll ||
                    entitlements.ownsPack(pack.id))
                  _PackCard(
                    pack: pack,
                    contents: _contents(pack),
                    owned: entitlements.ownsPack(pack.id),
                    price: entitlements.price(pack.id),
                    loaderFor: loaderFor,
                    onTap: () => _open(context, pack),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  final ContentPack pack;
  final PackContents contents;
  final bool owned;
  final String? price;
  final Future<GlyphLoader> Function(GlyphSheet sheet)? loaderFor;
  final VoidCallback onTap;

  const _PackCard({
    required this.pack,
    required this.contents,
    required this.owned,
    required this.price,
    required this.onTap,
    this.loaderFor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final sample = pack.sampleText;
    final details = [
      if (contents.sheets.isNotEmpty) l10n.sheetCount(contents.sheets.length),
      if (contents.presets.isNotEmpty)
        l10n.presetCount(contents.presets.length),
    ].join(' · ');
    return Card(
      key: ValueKey('pack-${pack.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: owned ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(pack.name, style: theme.textTheme.titleMedium),
                  ),
                  if (owned)
                    Chip(
                      avatar: const Icon(Icons.check, size: 16),
                      label: Text(l10n.owned),
                      visualDensity: VisualDensity.compact,
                    )
                  else if (price != null)
                    Text(price!, style: theme.textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 4),
              Text(pack.description, style: theme.textTheme.bodySmall),
              if (details.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(details, style: theme.textTheme.labelSmall),
              ],
              if (sample != null && contents.sheets.isNotEmpty) ...[
                const SizedBox(height: 8),
                SheetSample(
                  sheet: contents.sheets.first,
                  text: sample,
                  height: 32,
                  loaderFor: loaderFor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
