import WidgetKit
import SwiftUI

// MARK: - Color Extension for ARGB Conversion

extension Color {
    init(argb: Int) {
        let alpha = Double((argb >> 24) & 0xFF) / 255.0
        let red = Double((argb >> 16) & 0xFF) / 255.0
        let green = Double((argb >> 8) & 0xFF) / 255.0
        let blue = Double(argb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }

    var dimmed: Color {
        self.opacity(0.7)
    }
}

// MARK: - Glass Background Modifier

extension View {
    @ViewBuilder
    func widgetBackground(isGlassMode: Bool, backgroundColor: Color, renderingMode: WidgetRenderingMode) -> some View {
        self.containerBackground(for: .widget) {
            if #available(iOS 26, *) {
                // iOS 26: Glass mode has known issues, always use solid background
                // System handles Liquid Glass automatically based on user's Display settings
                backgroundColor
            } else {
                // iOS 17-18: Glass mode works with materials
                if isGlassMode {
                    Rectangle()
                        .fill(.thinMaterial)
                } else {
                    backgroundColor
                }
            }
        }
    }
}

// MARK: - Dynamic Font Sizing

struct DynamicFontSizer {
    static func calculateFontSize(
        quoteLength: Int,
        baseFontSize: CGFloat,
        minFontSize: CGFloat = 12
    ) -> CGFloat {
        let size: CGFloat
        switch quoteLength {
        case ..<50:
            size = baseFontSize
        case 50..<100:
            size = baseFontSize - 2
        case 100..<150:
            size = baseFontSize - 3
        case 150..<200:
            size = baseFontSize - 4
        case 200..<300:
            size = baseFontSize - 5
        default:
            size = max(minFontSize, baseFontSize - 6)
        }
        return max(minFontSize, size)
    }

    static func calculateMaxLines(quoteLength: Int, baseLines: Int) -> Int {
        return quoteLength > 150 ? baseLines + 3 : baseLines
    }
}

// MARK: - Timeline Entry

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quoteText: String
    let author: String
    let dayNumber: Int
    let backgroundColor: Color
    let textColor: Color
    let isGlassMode: Bool

    // Use white color in glass mode for better visibility on glass background
    var effectiveTextColor: Color {
        isGlassMode ? .white : textColor
    }

    var effectiveSecondaryColor: Color {
        isGlassMode ? .white.opacity(0.7) : textColor.dimmed
    }

    static let placeholder = QuoteEntry(
        date: Date(),
        quoteText: "The happiness of your life depends upon the quality of your thoughts.",
        author: "Marcus Aurelius",
        dayNumber: 1,
        backgroundColor: Color(argb: 0xFF1A1A1A),
        textColor: .white,
        isGlassMode: false
    )
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    let userDefaults = UserDefaults(suiteName: "group.com.motiva.stoicmind")

    private let defaultBackgroundColor = 0xFF1A1A1A
    private let defaultTextColor = 0xFFFFFFFF

    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        completion(loadCurrentQuote())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let entry = loadCurrentQuote()
        let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }

    private func loadCurrentQuote() -> QuoteEntry {
        let quoteText = userDefaults?.string(forKey: "quote_text")
            ?? "The happiness of your life depends upon the quality of your thoughts."
        let author = userDefaults?.string(forKey: "quote_author") ?? "Marcus Aurelius"
        let dayNumber = userDefaults?.integer(forKey: "day_number") ?? 1

        let backgroundColorValue = getColorValue(forKey: "widget_background_color", default: defaultBackgroundColor)
        let textColorValue = getColorValue(forKey: "widget_text_color", default: defaultTextColor)
        let isGlassMode = userDefaults?.bool(forKey: "widget_glass_mode") ?? false

        return QuoteEntry(
            date: Date(),
            quoteText: quoteText,
            author: author,
            dayNumber: dayNumber,
            backgroundColor: Color(argb: backgroundColorValue),
            textColor: Color(argb: textColorValue),
            isGlassMode: isGlassMode
        )
    }

    private func getColorValue(forKey key: String, default defaultValue: Int) -> Int {
        guard let defaults = userDefaults else { return defaultValue }
        if let value = defaults.object(forKey: key) {
            if let intValue = value as? Int {
                return intValue
            } else if let int64Value = value as? Int64 {
                return Int(truncatingIfNeeded: int64Value)
            } else if let numberValue = value as? NSNumber {
                return numberValue.intValue
            }
        }
        return defaultValue
    }
}

// MARK: - Widget Entry View

struct MotivaWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .systemExtraLarge:
            ExtraLargeWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        @unknown default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Home Screen Widgets

struct SmallWidgetView: View {
    let entry: QuoteEntry
    @Environment(\.widgetRenderingMode) var renderingMode

    private var fontSize: CGFloat {
        DynamicFontSizer.calculateFontSize(quoteLength: entry.quoteText.count, baseFontSize: 12, minFontSize: 10)
    }

    // Use .primary in accented mode (Liquid Glass), otherwise use entry colors
    private var textColor: Color {
        renderingMode == .accented ? .primary : entry.effectiveTextColor
    }

    private var secondaryColor: Color {
        renderingMode == .accented ? .secondary : entry.effectiveSecondaryColor
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Spacer()
            Text("\"\(entry.quoteText)\"")
                .font(.system(size: fontSize))
                .italic()
                .foregroundStyle(textColor)
                .lineLimit(5)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
            Spacer()
            Text("- \(entry.author)")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundStyle(secondaryColor)
        }
        .padding(12)
        .widgetBackground(isGlassMode: entry.isGlassMode, backgroundColor: entry.backgroundColor, renderingMode: renderingMode)
        .widgetURL(URL(string: "stoicmind://quote"))
    }
}

struct MediumWidgetView: View {
    let entry: QuoteEntry
    @Environment(\.widgetRenderingMode) var renderingMode

    private var fontSize: CGFloat {
        DynamicFontSizer.calculateFontSize(quoteLength: entry.quoteText.count, baseFontSize: 16, minFontSize: 12)
    }

    private var textColor: Color {
        renderingMode == .accented ? .primary : entry.effectiveTextColor
    }

    private var secondaryColor: Color {
        renderingMode == .accented ? .secondary : entry.effectiveSecondaryColor
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer()
            Text("\"\(entry.quoteText)\"")
                .font(.system(size: fontSize))
                .italic()
                .foregroundStyle(textColor)
                .lineLimit(4)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)
            Spacer()
            Text("- \(entry.author)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(secondaryColor)
        }
        .padding(16)
        .widgetBackground(isGlassMode: entry.isGlassMode, backgroundColor: entry.backgroundColor, renderingMode: renderingMode)
        .widgetURL(URL(string: "stoicmind://quote"))
    }
}

struct LargeWidgetView: View {
    let entry: QuoteEntry
    @Environment(\.widgetRenderingMode) var renderingMode

    private var fontSize: CGFloat {
        DynamicFontSizer.calculateFontSize(quoteLength: entry.quoteText.count, baseFontSize: 20, minFontSize: 14)
    }

    private var textColor: Color {
        renderingMode == .accented ? .primary : entry.effectiveTextColor
    }

    private var secondaryColor: Color {
        renderingMode == .accented ? .secondary : entry.effectiveSecondaryColor
    }

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            Text("\"\(entry.quoteText)\"")
                .font(.system(size: fontSize))
                .italic()
                .foregroundStyle(textColor)
                .lineLimit(8)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)
            Spacer()
            VStack(spacing: 4) {
                Text("- \(entry.author)")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(secondaryColor)
                Text("Tap to see meaning")
                    .font(.caption2)
                    .foregroundStyle(textColor.opacity(0.5))
            }
        }
        .padding(20)
        .widgetBackground(isGlassMode: entry.isGlassMode, backgroundColor: entry.backgroundColor, renderingMode: renderingMode)
        .widgetURL(URL(string: "stoicmind://quote"))
    }
}

struct ExtraLargeWidgetView: View {
    let entry: QuoteEntry
    @Environment(\.widgetRenderingMode) var renderingMode

    private var fontSize: CGFloat {
        DynamicFontSizer.calculateFontSize(quoteLength: entry.quoteText.count, baseFontSize: 28, minFontSize: 18)
    }

    private var textColor: Color {
        renderingMode == .accented ? .primary : entry.effectiveTextColor
    }

    private var secondaryColor: Color {
        renderingMode == .accented ? .secondary : entry.effectiveSecondaryColor
    }

    var body: some View {
        HStack(spacing: 32) {
            VStack(alignment: .leading, spacing: 16) {
                Text("MOTIVA")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(textColor)
                Text("Day \(entry.dayNumber)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(secondaryColor)
                Spacer()
                Text("Daily Stoic Wisdom")
                    .font(.caption)
                    .foregroundStyle(textColor.opacity(0.5))
            }
            .frame(maxWidth: 150)

            VStack(alignment: .center, spacing: 20) {
                Spacer()
                Text("\"\(entry.quoteText)\"")
                    .font(.system(size: fontSize))
                    .italic()
                    .foregroundStyle(textColor)
                    .lineLimit(10)
                    .minimumScaleFactor(0.6)
                    .multilineTextAlignment(.center)
                Spacer()
                Text("- \(entry.author)")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(secondaryColor)
            }
        }
        .padding(32)
        .widgetBackground(isGlassMode: entry.isGlassMode, backgroundColor: entry.backgroundColor, renderingMode: renderingMode)
        .widgetURL(URL(string: "stoicmind://quote"))
    }
}

// MARK: - Lock Screen Widgets

struct CircularWidgetView: View {
    let entry: QuoteEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Text("Day")
                    .font(.system(size: 8, weight: .medium))
                Text("\(entry.dayNumber)")
                    .font(.system(size: 20, weight: .bold))
            }
        }
        .containerBackground(for: .widget) { AccessoryWidgetBackground() }
    }
}

struct RectangularWidgetView: View {
    let entry: QuoteEntry

    var body: some View {
        Text(entry.quoteText)
            .font(.headline)
            .fontWeight(.semibold)
            .minimumScaleFactor(0.5)
            .containerBackground(for: .widget) { AccessoryWidgetBackground() }
            .widgetURL(URL(string: "stoicmind://quote"))
    }
}

struct InlineWidgetView: View {
    let entry: QuoteEntry

    var body: some View {
        Text("Day \(entry.dayNumber) - \(entry.author)")
            .containerBackground(for: .widget) { AccessoryWidgetBackground() }
    }
}

// MARK: - Widget Configuration

struct MotivaWidget: Widget {
    let kind: String = "MotivaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MotivaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Quote")
        .description("Your daily wisdom on your home screen")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
        .contentMarginsDisabled()
    }
}
