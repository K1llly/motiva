import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class ColorPickerTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color currentColor;
  final bool enabled;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currentColor,
    required this.enabled,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        enabled: enabled,
        onTap: enabled ? () => _showColorPicker(context) : null,
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ColorPickerSheet(
        currentColor: currentColor,
        onColorSelected: onColorChanged,
      ),
    );
  }
}

class _ColorPickerSheet extends StatefulWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerSheet({
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  State<_ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<_ColorPickerSheet> {
  late Color _selectedColor;

  // Masculine, stoic-themed color palette
  static const List<Color> _presetColors = [
    // Dark foundations
    Color(0xFF000000), // Pure black
    Color(0xFF0D0D0D), // Near black
    Color(0xFF1A1A1A), // Charcoal
    Color(0xFF262626), // Dark gray
    Color(0xFF333333), // Gunmetal

    // Muted neutrals
    Color(0xFF4A4A4A), // Slate
    Color(0xFF5C5C5C), // Storm gray
    Color(0xFF737373), // Steel
    Color(0xFF8C8C8C), // Ash
    Color(0xFFE8E8E8), // Off-white

    // Deep blues & teals
    Color(0xFF0A1628), // Midnight navy
    Color(0xFF1A2F4A), // Deep navy
    Color(0xFF1E3A5F), // Steel blue
    Color(0xFF0F4C5C), // Dark teal
    Color(0xFF134E4A), // Deep teal

    // Reds & burgundy
    Color(0xFF1A0000), // Blood black
    Color(0xFF3D0000), // Dark blood
    Color(0xFF5C0000), // Blood red
    Color(0xFF8B0000), // Dark red
    Color(0xFF722F37), // Wine

    // Deep greens
    Color(0xFF0D1F0D), // Forest black
    Color(0xFF1A3320), // Dark forest
    Color(0xFF2D4A32), // Hunter green
    Color(0xFF3D5C45), // Sage dark
    Color(0xFF2E4A3E), // Evergreen

    // Accent metallics
    Color(0xFFC9A227), // Antique gold
    Color(0xFFB8860B), // Dark goldenrod
    Color(0xFF8B7355), // Bronze
    Color(0xFFA0A0A0), // Silver
    Color(0xFFFFFFFF), // White
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                l10n.selectColor,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _presetColors.length,
            itemBuilder: (context, index) {
              final color = _presetColors[index];
              final isSelected = color == _selectedColor;

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedColor = color);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        )
                      : null,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              widget.onColorSelected(_selectedColor);
              Navigator.pop(context);
            },
            child: Text(l10n.apply),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
