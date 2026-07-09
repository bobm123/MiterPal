import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A +/- stepper for the number of sides N.
class SidesStepper extends StatelessWidget {
  const SidesStepper({
    super.key,
    required this.value,
    required this.minValue,
    required this.onChanged,
  });

  final int value;
  final int minValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text('Sides (N)', style: theme.textTheme.labelLarge),
            ),
            SizedBox(
              width: 88,
              child: Text(
                '$value',
                textAlign: TextAlign.right,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            const SizedBox(width: 16), // unit slot — matches the '°' on S
            const SizedBox(width: 12), // space before the buttons
            IconButton.filledTonal(
              onPressed: value > minValue ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove),
            ),
            const SizedBox(width: 8),
            IconButton.filledTonal(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}

/// A numeric angle field (accepts negative and decimal values).
///
/// Defaults to the side angle S but is reusable for other angles (e.g. the
/// fixed bevel-bit angle) via [label] and [hint]. Keeps its own
/// [TextEditingController] so typing is smooth, and re-syncs the text when
/// [value] changes from outside (e.g. loading a saved project).
class SideAngleField extends StatefulWidget {
  const SideAngleField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Side angle (S)',
    this.hint = '0 = upright · + splays out · − slopes in',
  });

  final double value;
  final ValueChanged<double> onChanged;
  final String label;
  final String hint;

  @override
  State<SideAngleField> createState() => _SideAngleFieldState();
}

class _SideAngleFieldState extends State<SideAngleField> {
  late final TextEditingController _controller =
      TextEditingController(text: _format(widget.value));

  static String _format(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  void didUpdateWidget(SideAngleField old) {
    super.didUpdateWidget(old);
    // Only overwrite the text if the external value diverged from what's typed
    // (avoids fighting the cursor while the user edits).
    final double? typed = double.tryParse(_controller.text);
    if (typed != widget.value) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Changes the ones digit by [delta], preserving any decimal fraction.
  /// Uses the currently-typed value if present, else the incoming value.
  void _nudge(double delta) {
    final double base = double.tryParse(_controller.text) ?? widget.value;
    widget.onChanged(base + delta);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child:
                      Text(widget.label, style: theme.textTheme.labelLarge),
                ),
                SizedBox(
                  width: 88,
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.right,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true, signed: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
                    ],
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                    ),
                    style: theme.textTheme.headlineSmall,
                    onChanged: (String text) {
                      final double? parsed = double.tryParse(text);
                      if (parsed != null) {
                        widget.onChanged(parsed);
                      } else if (text.isEmpty || text == '-') {
                        widget.onChanged(0);
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 16,
                  child: Text('°', style: theme.textTheme.headlineSmall),
                ),
                const SizedBox(width: 12), // space before the buttons
                IconButton.filledTonal(
                  onPressed: () => _nudge(-1),
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () => _nudge(1),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              widget.hint,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
