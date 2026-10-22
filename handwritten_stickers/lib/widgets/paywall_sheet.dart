import 'package:flutter/material.dart';

import '../models/content_pack.dart';
import '../models/glyph_sheet.dart';
import '../models/preset.dart';
import '../services/entitlement_service.dart';
import '../services/glyph_loader.dart';
import 'sheet_sample.dart';

/// What a pack contains, for the paywall and the pack list.
class PackContents {
  final List<GlyphSheet> sheets;
  final List<Preset> presets;

  const PackContents({this.sheets = const [], this.presets = const []});

  static PackContents of(
    ContentPack pack, {
    required List<GlyphSheet> sheets,
    required List<Preset> presets,
  }) {
    bool inPack(String? id) => pack.includesAll ? id != null : id == pack.id;
    return PackContents(
      sheets: [
        for (final s in sheets)
          if (inPack(s.pack)) s,
      ],
      presets: [
        for (final p in presets)
          if (inPack(p.pack)) p,
      ],
    );
  }
}

/// Offers [pack] for sale. Completes with true once the user owns it
/// (bought or restored), false or null otherwise.
Future<bool?> showPaywall(
  BuildContext context, {
  required EntitlementService entitlements,
  required ContentPack pack,
  required PackContents contents,
  Future<GlyphLoader> Function(GlyphSheet sheet)? loaderFor,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => PaywallSheet(
      entitlements: entitlements,
      pack: pack,
      contents: contents,
      loaderFor: loaderFor,
    ),
  );
}

class PaywallSheet extends StatefulWidget {
  final EntitlementService entitlements;
  final ContentPack pack;
  final PackContents contents;
  final Future<GlyphLoader> Function(GlyphSheet sheet)? loaderFor;

  const PaywallSheet({
    super.key,
    required this.entitlements,
    required this.pack,
    required this.contents,
    this.loaderFor,
  });

  @override
  State<PaywallSheet> createState() => _PaywallSheetState();
}

class _PaywallSheetState extends State<PaywallSheet> {
  bool _busy = false;
  bool _closed = false;

  EntitlementService get _e => widget.entitlements;

  @override
  void initState() {
    super.initState();
    _e.addListener(_onEntitlements);
  }

  @override
  void dispose() {
    _e.removeListener(_onEntitlements);
    super.dispose();
  }

  /// A restore (or a purchase finished elsewhere) unlocks the pack.
  void _onEntitlements() {
    if (!mounted) return;
    if (_e.ownsPack(widget.pack.id)) {
      _close(true);
    } else {
      setState(() {});
    }
  }

  void _close(bool owned) {
    if (_closed) return;
    _closed = true;
    Navigator.of(context).pop(owned);
  }

  Future<void> _buy(String packId) async {
    setState(() => _busy = true);
    final outcome = await _e.buy(packId);
    if (!mounted) return;
    setState(() => _busy = false);
    final messenger = ScaffoldMessenger.of(context);
    switch (outcome) {
      case PurchaseOutcome.purchased:
        if (_e.ownsPack(widget.pack.id)) _close(true);
      case PurchaseOutcome.pending:
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Nákup čeká na schválení. Odemkne se sám.'),
          ),
        );
      case PurchaseOutcome.cancelled:
        break;
      case PurchaseOutcome.error:
      case PurchaseOutcome.unavailable:
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Nákup se nepodařil. Zkus to prosím znovu.'),
          ),
        );
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    await _e.restore();
    if (!mounted || _closed) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nákupy obnoveny. Co jsi koupil(a), je odemčené.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pack = widget.pack;
    final contents = widget.contents;
    final price = _e.price(pack.id);
    final all = _e.packs.all;
    final allPrice = all == null ? null : _e.price(all.id);
    final offerAll =
        all != null && all != pack && _e.offerAll && allPrice != null;
    final sample = pack.sampleText;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(pack.name, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(pack.description, style: theme.textTheme.bodyMedium),
            if (sample != null && contents.sheets.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (final sheet in contents.sheets.take(3))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: SheetSample(
                    sheet: sheet,
                    text: sample,
                    loaderFor: widget.loaderFor,
                  ),
                ),
            ],
            const SizedBox(height: 16),
            if (contents.sheets.isNotEmpty)
              _Bullet('${contents.sheets.length} písem'),
            if (contents.presets.isNotEmpty)
              _Bullet(
                'Presety: ${contents.presets.map((p) => p.name).join(', ')}',
              ),
            if (pack.feature == ContentPack.savePresetsFeature)
              const _Bullet('Neomezeně vlastních presetů'),
            const _Bullet('Jednou koupíš, máš navždy, i na dalších zařízeních'),
            const _Bullet('Všechny funkce aplikace zůstávají zdarma'),
            const SizedBox(height: 20),
            if (!_e.storeAvailable)
              Text(
                'Obchod teď není dostupný. Zkus to později.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              )
            else
              FilledButton(
                key: const ValueKey('paywall-buy'),
                onPressed: _busy || price == null ? null : () => _buy(pack.id),
                child: Text(
                  price != null
                      ? 'Koupit za $price'
                      : _e.productsLoaded
                      ? 'Zatím není v prodeji'
                      : 'Načítám cenu…',
                ),
              ),
            if (offerAll && _e.storeAvailable) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                key: const ValueKey('paywall-buy-all'),
                onPressed: _busy ? null : () => _buy(all.id),
                child: Text('${all.name}: všechny balíčky za $allPrice'),
              ),
            ],
            const SizedBox(height: 4),
            TextButton(
              key: const ValueKey('paywall-restore'),
              onPressed: _busy ? null : _restore,
              child: const Text('Obnovit nákupy'),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;

  const _Bullet(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
