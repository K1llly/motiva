import 'package:flutter/material.dart';
import '../../domain/entities/widget_settings.dart';

// Cached painter instance to avoid repeated allocations
const _patternPainter = _PatternPainter();

// Cached border radius to avoid repeated allocations
const _outerRadius = BorderRadius.all(Radius.circular(24));
const _innerRadius = BorderRadius.all(Radius.circular(20));

// Cached gradient for background
final _backgroundGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.blue.shade900,
    Colors.purple.shade900,
  ],
);

// Cached gradient for glass effect (simulated without BackdropFilter)
final _glassGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white.withValues(alpha: 0.2),
    Colors.white.withValues(alpha: 0.08),
  ],
);

class WidgetPreview extends StatelessWidget {
  final WidgetSettings settings;
  final bool forceDisableGlass;
  final String? quoteText;
  final String? author;

  const WidgetPreview({
    super.key,
    required this.settings,
    this.forceDisableGlass = false,
    this.quoteText,
    this.author,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Center(
          child: Container(
            width: 300,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: _outerRadius,
              gradient: _backgroundGradient,
            ),
            child: ClipRRect(
              borderRadius: _outerRadius,
              child: Stack(
                children: [
                  // Background pattern - uses cached painter
                  const Positioned.fill(
                    child: CustomPaint(
                      painter: _patternPainter,
                    ),
                  ),
                  // Widget content
                  Positioned.fill(
                    child: (settings.isGlassModeEnabled && !forceDisableGlass)
                        ? _buildGlassPreview(context)
                        : _buildSolidPreview(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassPreview(BuildContext context) {
    // Simulated glass effect without BackdropFilter to save GPU memory
    // Simplified to avoid nested ClipRRect which causes IOSurface allocations
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: _glassGradient,
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: _innerRadius,
      ),
      child: _buildQuoteContent(),
    );
  }

  Widget _buildSolidPreview(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(settings.backgroundColor),
        borderRadius: _innerRadius,
      ),
      child: _buildQuoteContent(),
    );
  }

  Widget _buildQuoteContent() {
    final textColor = Color(settings.textColor);
    final secondaryTextColor = textColor.withValues(alpha: 0.7);

    final displayQuote = quoteText ?? 'The happiness of your life depends upon the quality of your thoughts.';
    final displayAuthor = author ?? 'Marcus Aurelius';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '"$displayQuote"',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Text(
            '— $displayAuthor',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  // Cached paint object - created once, reused on every paint call
  static final Paint _paint = Paint()
    ..color = Colors.white.withValues(alpha: 0.05)
    ..style = PaintingStyle.fill;

  const _PatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 5; i++) {
      for (var j = 0; j < 5; j++) {
        canvas.drawCircle(
          Offset(size.width * (i / 4), size.height * (j / 4)),
          20,
          _paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
