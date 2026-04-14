import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/quote_translation_service.dart';
import '../../../../core/theme/app_font.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../di/injection_container.dart' as di;
import '../../../../l10n/app_localizations.dart';
import '../../../quote/domain/entities/quote.dart';
import 'share_card.dart';

class ShareBottomSheet extends StatefulWidget {
  final Quote quote;

  const ShareBottomSheet({super.key, required this.quote});

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  final GlobalKey _repaintKey = GlobalKey();
  bool _isSharing = false;

  // Customization state
  Color _backgroundColor = const Color(0xFF1A1A1A);
  Color _primaryColor = const Color(0xFFFFFFFF);
  Color _accentColor = const Color(0xFFC9A227);
  late AppFont _selectedFont;

  static const List<Color> _backgroundColors = [
    Color(0xFF000000),
    Color(0xFF0D0D0D),
    Color(0xFF1A1A1A),
    Color(0xFF262626),
    Color(0xFF333333),
    Color(0xFF0A1628),
    Color(0xFF1A2F4A),
    Color(0xFF1E3A5F),
    Color(0xFF0F4C5C),
    Color(0xFF134E4A),
    Color(0xFF1A0000),
    Color(0xFF3D0000),
    Color(0xFF5C0000),
    Color(0xFF722F37),
    Color(0xFF0D1F0D),
    Color(0xFF1A3320),
    Color(0xFF2D4A32),
    Color(0xFF2E4A3E),
    Color(0xFF0D0015),
    Color(0xFF1A0033),
    Color(0xFF2D1B4E),
    Color(0xFF3C1F5C),
    Color(0xFF1F0A14),
    Color(0xFF3D1028),
    Color(0xFF5C1A3D),
    Color(0xFF4A2038),
    Color(0xFFE8E8E8),
    Color(0xFFFFFFFF),
  ];

  static const List<Color> _textColors = [
    Color(0xFFFFFFFF),
    Color(0xFFE8E8E8),
    Color(0xFFA0A0A0),
    Color(0xFFC9A227),
    Color(0xFFB8860B),
    Color(0xFF8B7355),
    Color(0xFF1DA1F2),
    Color(0xFF4A9EBF),
    Color(0xFFE4405F),
    Color(0xFF25D366),
    Color(0xFF000000),
    Color(0xFF1A1A1A),
    Color(0xFF333333),
    Color(0xFF4A4A4A),
  ];

  static const List<Color> _accentColors = [
    Color(0xFFC9A227),
    Color(0xFFB8860B),
    Color(0xFFD4AF37),
    Color(0xFFE6C65C),
    Color(0xFFFFFFFF),
    Color(0xFFE8E8E8),
    Color(0xFFA0A0A0),
    Color(0xFF8B7355),
    Color(0xFFE4405F),
    Color(0xFF1DA1F2),
    Color(0xFF25D366),
    Color(0xFF9B59B6),
    Color(0xFF000000),
    Color(0xFF333333),
  ];

  @override
  void initState() {
    super.initState();
    _selectedFont = AppTypography.currentFontFromContext(context);
  }

  /// Capture the share card as a PNG image and save to temp file
  Future<File?> _captureImage() async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));

      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/motiva_quote.png');
      await file.writeAsBytes(bytes);
      return file;
    } catch (_) {
      return null;
    }
  }

  /// Share via system share sheet
  Future<void> _shareViaSystem() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final file = await _captureImage();
      if (file == null || !mounted) return;

      final navigator = Navigator.of(context);
      final box = context.findRenderObject() as RenderBox?;
      final origin = box != null
          ? box.localToGlobal(Offset.zero) & box.size
          : null;

      navigator.pop();

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Motiva - Daily Stoic Wisdom',
        sharePositionOrigin: origin,
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final handleColor = colorScheme.onSurface.withValues(alpha: 0.2);
    final dividerColor = theme.dividerColor;

    final translator = di.sl<QuoteTranslationService>();
    final translatedText =
        translator.getText(widget.quote.id, widget.quote.text);

    final maxHeight = MediaQuery.of(context).size.height * 0.9;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                l10n.shareQuote,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Share card preview.
              // The ClipRRect only affects the in-app preview. The captured
              // PNG is the RepaintBoundary's full rect — we wrap the card
              // in a same-color matte so exported images have no transparent
              // corners (which otherwise show black on dark chat backgrounds).
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: Container(
                    color: _backgroundColor,
                    padding: const EdgeInsets.all(24),
                    child: ShareCard(
                      quoteText: translatedText,
                      author: widget.quote.author,
                      backgroundColor: _backgroundColor,
                      primaryColor: _primaryColor,
                      accentColor: _accentColor,
                      font: _selectedFont,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Font picker
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppFont.values.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final font = AppFont.values[index];
                    final isSelected = font == _selectedFont;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFont = font),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          font.displayName,
                          style: font.primaryStyle.copyWith(
                            fontSize: 13,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // Background color row
              _buildColorRow(
                label: l10n.backgroundColor,
                colors: _backgroundColors,
                selected: _backgroundColor,
                dividerColor: dividerColor,
                primaryColor: colorScheme.primary,
                onSelected: (c) => setState(() => _backgroundColor = c),
              ),
              const SizedBox(height: 10),

              // Text color row
              _buildColorRow(
                label: l10n.textColor,
                colors: _textColors,
                selected: _primaryColor,
                dividerColor: dividerColor,
                primaryColor: colorScheme.primary,
                onSelected: (c) => setState(() => _primaryColor = c),
              ),
              const SizedBox(height: 10),

              // Detail color row
              _buildColorRow(
                label: l10n.detailColor,
                colors: _accentColors,
                selected: _accentColor,
                dividerColor: dividerColor,
                primaryColor: colorScheme.primary,
                onSelected: (c) => setState(() => _accentColor = c),
              ),
              const SizedBox(height: 18),

              // Share button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _isSharing ? null : _shareViaSystem,
                      icon: _isSharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.share),
                      label: Text(
                        l10n.share,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorRow({
    required String label,
    required List<Color> colors,
    required Color selected,
    required Color dividerColor,
    required Color primaryColor,
    required ValueChanged<Color> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final color = colors[index];
              final isSelected = color == selected;
              return GestureDetector(
                onTap: () => onSelected(color),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? primaryColor : dividerColor,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          size: 16,
                          color: color.computeLuminance() > 0.5
                              ? Colors.black
                              : Colors.white,
                        )
                      : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

