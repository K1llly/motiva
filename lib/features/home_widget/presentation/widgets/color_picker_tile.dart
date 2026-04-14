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
    final dividerColor = Theme.of(context).dividerColor;

    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: dividerColor),
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
  static const BorderRadius _tileRadius = BorderRadius.all(Radius.circular(12));
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

    // Deep purples
    Color(0xFF0D0015), // Void purple
    Color(0xFF1A0033), // Dark plum
    Color(0xFF2D1B4E), // Deep violet
    Color(0xFF4A2D6B), // Muted purple
    Color(0xFF3C1F5C), // Dusk purple

    // Dark pinks & mauves
    Color(0xFF1F0A14), // Black rose
    Color(0xFF3D1028), // Dark magenta
    Color(0xFF5C1A3D), // Deep berry
    Color(0xFF6B3A5C), // Muted mauve
    Color(0xFF4A2038), // Plum wine

    // Accent metallics
    Color(0xFFC9A227), // Antique gold
    Color(0xFFB8860B), // Dark goldenrod
    Color(0xFF8B7355), // Bronze
    Color(0xFFA0A0A0), // Silver
    Color(0xFFFFFFFF), // White
  ];

  // Pre-computed luminance cache to avoid calculating in itemBuilder
  static final Map<Color, bool> _isLightColor = {
    for (final color in _presetColors) color: color.computeLuminance() > 0.5
  };

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Cache theme references once
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final dividerColor = theme.dividerColor;

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
                style: theme.textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Flexible(
            child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
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
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: _tileRadius,
                    border: Border.all(
                      color: isSelected ? primaryColor : dividerColor,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          // Use cached luminance instead of computing per item
                          color: _isLightColor[color]!
                              ? Colors.black
                              : Colors.white,
                        )
                      : null,
                ),
              );
            },
          ),
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
