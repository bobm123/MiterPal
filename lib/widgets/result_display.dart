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
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
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
        ),
        if (!frame) ...<Widget>[
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
              value,
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryResult extends StatelessWidget {
  const _SecondaryResult({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: Column(
          children: <Widget>[
            Text(value, style: theme.textTheme.titleLarge),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _LeanBanner extends StatelessWidget {
  const _LeanBanner({required this.lean});

  final LeanDirection lean;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, String text) = switch (lean) {
      LeanDirection.outward => (Icons.unfold_more, 'Splays outward (top wider)'),
      LeanDirection.inward => (Icons.unfold_less, 'Slopes inward (top narrower)'),
    