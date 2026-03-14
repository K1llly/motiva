import WidgetKit
import SwiftUI

// MARK: - Embedded Quotes Data

struct StoicQuote {
    let text: String
    let author: String
}

/// All 30 Stoic quotes embedded in the widget for offline access
let stoicQuotes: [StoicQuote] = [
    StoicQuote(text: "The happiness of your life depends upon the quality of your thoughts.", author: "Marcus Aurelius"),
    StoicQuote(text: "He who fears death will never do anything worthy of a man who is alive.", author: "Seneca"),
    StoicQuote(text: "No man is free who is not master of himself.", author: "Epictetus"),
    StoicQuote(text: "Waste no more time arguing about what a good man should be. Be one.", author: "Marcus Aurelius"),
    StoicQuote(text: "We suffer more often in imagination than in reality.", author: "Seneca"),
    StoicQuote(text: "It is not death that a man should fear, but he should fear never beginning to live.", author: "Marcus Aurelius"),
    StoicQuote(text: "First say to yourself what you would be; and then do what you have to do.", author: "Epictetus"),
    StoicQuote(text: "The best revenge is to be unlike him who performed the injury.", author: "Marcus Aurelius"),
    StoicQuote(text: "Luck is what happens when preparation meets opportunity.", author: "Seneca"),
    StoicQuote(text: "Man is not worried by real problems so much as by his imagined anxieties about real problems.", author: "Epictetus"),
    StoicQuote(text: "You have power over your mind - not outside events. Realize this, and you will find strength.", author: "Marcus Aurelius"),
    StoicQuote(text: "Difficulties strengthen the mind, as labor does the body.", author: "Seneca"),
    StoicQuote(text: "If you want to improve, be content to be thought foolish and stupid.", author: "Epictetus"),
    StoicQuote(text: "The soul becomes dyed with the color of its thoughts.", author: "Marcus Aurelius"),
    StoicQuote(text: "It is not that we have a short time to live, but that we waste a lot of it.", author: "Seneca"),
    StoicQuote(text: "Make the best use of what is in your power, and take the rest as it happens.", author: "Epictetus"),
    StoicQuote(text: "Very little is needed to make a happy life; it is all within yourself, in your way of thinking.", author: "Marcus Aurelius"),
    StoicQuote(text: "True happiness is to enjoy the present, without anxious dependence upon the future.", author: "Seneca"),
    StoicQuote(text: "Wealth consists not in having great possessions, but in having few wants.", author: "Epictetus"),
    StoicQuote(text: "The object of life is not to be on the side of the majority, but to escape finding oneself in the ranks of the insane.", author: "Marcus Aurelius"),
    StoicQuote(text: "Begin at once to live, and count each separate day as a separate life.", author: "Seneca"),
    StoicQuote(text: "There is only one way to happiness and that is to cease worrying about things which are beyond the power of our will.", author: "Epictetus"),
    StoicQuote(text: "Never esteem anything as of advantage to you that will make you break your word or lose your self-respect.", author: "Marcus Aurelius"),
    StoicQuote(text: "As is a tale, so is life: not how long it is, but how good it is, is what matters.", author: "Seneca"),
    StoicQuote(text: "Any person capable of angering you becomes your master.", author: "Epictetus"),
    StoicQuote(text: "How much more grievous are the consequences of anger than the causes of it.", author: "Marcus Aurelius"),
    StoicQuote(text: "Life is long if you know how to use it.", author: "Seneca"),
    StoicQuote(text: "He is a wise man who does not grieve for the things which he has not, but rejoices for those which he has.", author: "Epictetus"),
    StoicQuote(text: "Do not act as if you had ten thousand years to throw away. Death stands at your elbow. Be good for something while you live and it is in your power.", author: "Marcus Aurelius"),
    StoicQuote(text: "We are more often frightened than hurt; and we suffer more from imagination than from reality.", author: "Seneca"), 
]

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
            backgroundColor
        }
        .widgetAccentable()
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
    let backgroundColor: Color
    let textColor: Color
    let isGlassMode: Bool
    let fontDesign: Font.Design

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
        backgroundColor: Color(argb: 0xFF1A1A1A),
        textColor: .white,
        isGlassMode: false,
        fontDesign: .serif
    )
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    let userDefaults = UserDefaults(suiteName: "group.com.motiva.stoicmind")

    private let defaultBackgroundColor = 0xFF1A1A1A
    private let defaultTextColor = 0xFFFFFFFF

    private let userSeedKey = "widget_user_seed"

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
        guard let defaults = userDefaults else {
            return QuoteEntry.placeholder
        }

        // Batch read all values using dictionaryRepresentation for fewer I/O calls
        let dict = defaults.dictionaryRepresentation()

        // Check if Flutter's data is from today
        let isDataFresh = isLastUpdateFromToday(dict)

        let finalQuoteText: String
        let finalAuthor: String
        if isDataFresh, let qt = dict["quote_text"] as? String, let a = dict["quote_author"] as? String, !qt.isEmpty {
            // Flutter data is fresh (from today) — use it directly (already translated)
            finalQuoteText = qt
            finalAuthor = a
        } else if let (cachedText, cachedAuthor) = getQuoteFromTranslatedCache(dict) {
            // Flutter data is stale, but we have a pre-cached translated quote for today
            finalQuoteText = cachedText
            finalAuthor = cachedAuthor
        } else {
            // No cache available — fall back to embedded English quotes
            let (fallbackText, fallbackAuthor) = getQuoteForDay(from: dict, defaults: defaults)
            finalQuoteText = fallbackText
            finalAuthor = fallbackAuthor
        }

        let backgroundColorValue = getColorFromDict(dict, forKey: "widget_background_color", default: defaultBackgroundColor)
        let textColorValue = getColorFromDict(dict, forKey: "widget_text_color", default: defaultTextColor)
        let isGlassMode = dict["widget_glass_mode"] as? Bool ?? false
        let fontDesign = mapFontDesign(dict["widget_font"] as? String)

        return QuoteEntry(
            date: Date(),
            quoteText: finalQuoteText,
            author: finalAuthor,
            backgroundColor: Color(argb: backgroundColorValue),
            textColor: Color(argb: textColorValue),
            isGlassMode: isGlassMode,
            fontDesign: fontDesign
        )
    }

    /// Map font key string to SwiftUI Font.Design
    private func mapFontDesign(_ fontKey: String?) -> Font.Design {
        switch fontKey {
        case "classic": return .serif
        case "modern": return .default
        case "rounded": return .rounded
        case "elegantSerif": return .serif
        case "monospace": return .monospaced
        default: return .serif
        }
    }

    /// Check if the last_updated timestamp is from today
    private func isLastUpdateFromToday(_ dict: [String: Any]) -> Bool {
        guard let lastUpdated = dict["last_updated"] as? String else { return false }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let updateDate = formatter.date(from: lastUpdated) ?? ISO8601DateFormatter().date(from: lastUpdated) else { return false }
        return Calendar.current.isDateInToday(updateDate)
    }

    /// Try to get today's translated quote from the pre-cached JSON
    private func getQuoteFromTranslatedCache(_ dict: [String: Any]) -> (String, String)? {
        guard let cacheJson = dict["widget_translated_cache"] as? String,
              let cacheData = cacheJson.data(using: .utf8),
              let cache = try? JSONSerialization.jsonObject(with: cacheData) as? [String: [String: String]] else {
            return nil
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayKey = formatter.string(from: Date())

        guard let entry = cache[todayKey],
              let text = entry["text"],
              let author = entry["author"] else {
            return nil
        }

        return (text, author)
    }

    /// Get the quote for today using date + user seed for deterministic randomness
    private func getQuoteForDay(from dict: [String: Any], defaults: UserDefaults) -> (String, String) {
        let seed = getUserSeed(from: dict, defaults: defaults)
        let calendar = Calendar.current
        let today = Date()
        let year = calendar.component(.year, from: today)
        let month = calendar.component(.month, from: today)
        let day = calendar.component(.day, from: today)

        // Same formula as the Flutter side: dateKey ^ seed
        let dateKey = year * 10000 + month * 100 + day
        let combined = dateKey ^ seed

        // Same formula as Flutter: abs(combined) % 1000 gives quoteIndex (0-999)
        // But we only have 30 embedded quotes, so map to our embedded array
        let index = abs(combined) % stoicQuotes.count
        let quote = stoicQuotes[index]
        return (quote.text, quote.author)
    }

    /// Get user seed synced from Flutter, or create a fallback
    private func getUserSeed(from dict: [String: Any], defaults: UserDefaults) -> Int {
        if let seed = dict[userSeedKey] as? Int {
            return seed
        }
        if let seed = dict[userSeedKey] as? NSNumber {
            return seed.intValue
        }
        // Fallback: create a local seed
        let newSeed = Int.random(in: 0..<Int(Int32.max))
        defaults.set(newSeed, forKey: userSeedKey)
        return newSeed
    }

    /// Extract color from dictionary with type conversion handling
    private func getColorFromDict(_ dict: [String: Any], forKey key: String, default defaultValue: Int) -> Int {
        guard let value = dict[key] else { return defaultValue }
        if let intValue = value as? Int {
            return intValue
        } else if let int64Value = value as? Int64 {
            return Int(truncatingIfNeeded: int64Value)
        } else if let numberValue = value as? NSNumber {
            return numberValue.intValue
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
                .font(.system(size: fontSize, design: entry.fontDesign))
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
                .font(.system(size: fontSize, design: entry.fontDesign))
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
                .font(.system(size: fontSize, design: entry.fontDesign))
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
        VStack(alignment: .center, spacing: 20) {
            Spacer()
            Text("\"\(entry.quoteText)\"")
                .font(.system(size: fontSize, design: entry.fontDesign))
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
            Image(systemName: "quote.opening")
                .font(.system(size: 20, weight: .bold))
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
        Text("\(entry.author) - \(entry.quoteText)")
            .containerBackground(for: .widget) { AccessoryWidgetBackground() }
    }
}

// MARK: - Widget Configuration

struct MotivaWidget: Widget {
    let kind: String = "MotivaWidget"

    private var supportedFamilies: [WidgetFamily] {
        #if os(iOS)
        return [
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ]
        #else
        return [
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge
        ]
        #endif
    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MotivaWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Quote")
        .description("Your daily wisdom on your home screen")
        .supportedFamilies(supportedFamilies)
        .contentMarginsDisabled()
    }
}
