import 'package:flutter/material.dart';

import '../models/style_params.dart';

/// Panel with sliders for adjusting style parameters
class StyleParamsPanel extends StatelessWidget {
  final StyleParams params;
  final ValueChanged<StyleParams> onChanged;
  final bool expanded;

  const StyleParamsPanel({
    super.key,
    required this.params,
    required this.onChanged,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!expanded) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSlider(
          label: 'Letter Spacing',
          value: params.letterSpacing,
          min: -10,
          max: 20,
          onChanged: (v) => onChanged(params.copyWith(letterSpacing: v)),
        ),
        _buildSlider(
          label: 'Baseline Wobble',
          value: params.baselineWobble,
          min: 0,
          max: 1,
          onChanged: (v) => onChanged(params.copyWith(baselineWobble: v)),
        ),
        _buildSlider(
          label: 'Size Variance',
          value: params.sizeVariance,
          min: 0,
          max: 1,
          onChanged: (v) => onChanged(params.copyWith(sizeVariance: v)),
        ),
        _buildSlider(
          label: 'Rotation Variance',
          value: params.rotationVariance,
          min: 0,
          max: 1,
          onChanged: (v) => onChanged(params.copyWith(rotationVariance: v)),
        ),
        _buildSlider(
          label: 'Opacity Variance',
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
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
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
