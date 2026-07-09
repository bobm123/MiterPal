import 'package:flutter/material.dart';

import '../models/compound_miter.dart';
import '../util/formatting.dart';

/// Shows the calculated saw settings for the current [mode].
///
/// Box modes show bevel and miter, with the dihedral and miter complement
/// behind [showAdvanced]. Picture Frame mode is flat, so the bevel, lean
/// banner, and dihedral are omitted.
class ResultDisplay extends StatelessWidget {
  const ResultDisplay({
    super.key,
    required this.result,
    required this.mode,
    required this.exact,
    required this.showAdvanced,
  });

  final MiterResult result;
  final JointMode mode;
  final bool exact;
  final bool showAdvanced;

  @override
  Widget build(BuildContext context) {
    final bool frame = mode == JointMode.pictureFrame;
    final bool bit = mode == JointMode.fixedBevelBit;

    if (bit && !result.feasible) {
      return _NoFitBanner(n: result.n);
    }

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            if (bit)
              Expanded(
                child: _PrimaryResult(
                  label: 'Side lean (S)',
                  value: formatAngle(result.sideAngle, exact: exact),
                ),
              )
            else ...<Widget>[
              if (!frame) ...<Widget>[
                Expanded(
                  child: _PrimaryResult(
                    label: 'Bevel (blade tilt)',
                    value: formatAngle(result.bladeTilt, exact: exact),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: _PrimaryResult(
                  label: 'Miter (from fence)',
                  value: formatAngle(result.miter, exact: exact),
                ),
              ),
            ],
          ],
        ),
        if (bit) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.swap_horiz,
                  size: 18, color: Theme.of(context).colorScheme.secondary),
              const SizedBox(width: 6),
              Text('Works splayed outward or sloped inward (±S)',
                  style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ] else if (!frame) ...<Widget>[
          const SizedBox(height: 12),
          _LeanBanner(lean: result.lean),
        ],
        if (showAdvanced) ...<Widget>[
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              if (!frame) ...<Widget>[
                Expanded(
                  child: _SecondaryResult(
                    label: 'Dihedral (D)',
                    value: formatAngle(result.dihedral, exact: exact),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              if (!bit)
                Expanded(
                  child: _SecondaryResult(
                    label: "Miter complement (M')",
                    value: formatAngle(result.miterComplement, exact: exact),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Shown in Fixed Bevel Bit mode when the bit is too steep for N sides.
class _NoFitBanner extends StatelessWidget {
  const _NoFitBanner({required this.n});

  final int n;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
            Icon(Icons.warning_amber_rounded,
                color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No fit: with $n sides the bit angle must be at most '
                '${formatAngle(180.0 / n)} (B = 180/N). Use a shallower '
                'bit or fewer sides.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryResult extends StatelessWidget {
  const _PrimaryResult({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        child: Column(
          children: <Widget>[
            Text(
              value