import 'package:flutter/material.dart';

/// The workshop reminders from docs/compound-miter-angles.md, as a
/// checkable list. State is local — it's a pre-cut sanity check, not data
/// worth persisting.
class CutChecklist extends StatefulWidget {
  const CutChecklist({super.key});

  @override
  State<CutChecklist> createState() => _CutChecklistState();
}

class _CutChecklistState extends State<CutChecklist> {
  static const List<String> _items = <String>[
    'Mark the "outside face" on every blank before cutting.',
    'Cut a test piece on scrap first — catch sign / edge-up mistakes.',
    'Both edges get the same bevel and miter; flip the board end-for-end '
        'between cuts.',
    'If your saw measures miter from the blade, use the complement (M\').',
  ];

  late final List<bool> _checked = List<bool>.filled(_items.length, false);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: ExpansionTile(
          shape: const Border(),
          title: const Text('In the workshop'),
          subtitle: const Text('Pre-cut checklist'),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          children: <Widget>[
            for (int i = 0; i < _items.length; i++)
              CheckboxListTile(
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                value: _checked[i],
                onChanged: (bool? v) =>
                    setState(() => _checked[i] = v ?? false),
                title: Text(_items[i]),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _checked.any((bool c) => c)
                    ? () => setState(() => _checked.fillRange(
                        0, _checked.length, false))
                    : null,
                child: const Text('Reset'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
