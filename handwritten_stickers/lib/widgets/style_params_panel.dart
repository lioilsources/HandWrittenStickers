import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../models/style_params.dart';

/// Panel with sliders for adjusting style parameters
class StyleParamsPanel extends StatelessWidget {
  final StyleParams params;
  final ValueChanged<StyleParams> onChanged;
  final bool expanded;

  /// The current sheet can join its letters: offer the switch.
  final bool canJoinLetters;

  const StyleParamsPanel({
    super.key,
    required this.params,
    required this.onChanged,
    this.expanded = true,
    this.canJoinLetters = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canJoinLetters)
          SwitchListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(l10n.joinLetters, style: const TextStyle(fontSize: 13)),
            value: params.joinLetters,
            onChanged: (v) => onChanged(params.copyWith(joinLetters: v)),
          ),
        _buildSlider(
          label: l10n.letterSpacing,
          value: params.letterSpacing,
          min: -10,
          max: 20,
          onChanged: (v) => onChanged(params.copyWith(letterSpacing: v)),
        ),
        _buildSlider(
          label: l10n.baselineWobble,
          value: params.baselineWobble,
          min: 0,
          max: 1,
          onChanged: (v) => onChanged(params.copyWith(baselineWobble: v)),
        ),
        _buildSlider(
          label: l10n.sizeVariance,
          value: params.sizeVariance,
          min: 0,
          max: 1,
          onChanged: (v) => onChanged(params.copyWith(sizeVariance: v)),
        ),
        _buildSlider(
          label: l10n.rotationVariance,
          value: params.rotationVariance,
          min: 0,
          max: 1,
          onChanged: (v) => onChanged(params.copyWith(rotationVariance: v)),
        ),
        _buildSlider(
          label: l10n.opacityVariance,
          value: params.opacityVariance,
          min: 0,
          max: 0.5,
          onChanged: (v) => onChanged(params.copyWith(opacityVariance: v)),
        ),
      ],
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13)),
          ),
          Expanded(
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 45,
            child: Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
