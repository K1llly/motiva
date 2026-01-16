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

    // Keys for storing widget-specific data
    private let startDateKey = "widget_start_date"
    private let shuffledOrderKey = "widget_shuffled_order"

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

        // Calculate the current day number based on start date
        let dayNumber = calculateDayNumber(from: dict, defaults: defaults)

        // Get the quote for today using shuffled order
        let (quoteText, author) = getQuoteForDay(dayNumber: dayNumber, from: dict, defaults: defaults)

        let backgroundColorValue = getColorFromDict(dict, forKey: "widget_background_color", default: defaultBackgroundColor)
        let textColorValue = getColorFromDict(dict, forKey: "widget_text_color", default: defaultTextColor)
        let isGlassMode = dict["widget_glass_mode"] as? Bool ?? false

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

    /// Calculate the day number based on start date
    private func calculateDayNumber(from dict: [String: Any], defaults: UserDefaults) -> Int {
        let startDate: Date

        if let storedTimestamp = dict[startDateKey] as? Double {
            startDate = Date(timeIntervalSince1970: storedTimestamp)
        } else {
            // First time: set start date to today
            startDate = Calendar.current.startOfDay(for: Date())
            defaults.set(startDate.timeIntervalSince1970, forKey: startDateKey)
        }

        let today = Calendar.current.startOfDay(for: Date())
        let days = Calendar.current.dateComponents([.day], from: startDate, to: today).day ?? 0
        return days + 1 // Day 1 is the first day
    }

    /// Get the quote for a specific day using the shuffled order
    private func getQuoteForDay(dayNumber: Int, from dict: [String: Any], defaults: UserDefaults) -> (String, String) {
        let shuffledOrder = getOrCreateShuffledOrder(from: dict, defaults: defaults)

        // Use modulo to cycle through quotes (for users past day 30)
        let index = (dayNumber - 1) % shuffledOrder.count
        let quoteIndex = shuffledOrder[index]

        // Get the quote from embedded data (0-indexed)
        guard quoteIndex >= 0 && quoteIndex < stoicQuotes.count else {
            return (stoicQuotes[0].text, stoicQuotes[0].author)
        }

        let quote = stoicQuotes[quoteIndex]
        return (quote.text, quote.author)
    }

    /// Get existing shuffled order or create a new one
    private func getOrCreateShuffledOrder(from dict: [String: Any], defaults: UserDefaults) -> [Int] {
        // Check if shuffled order already exists (stored as comma-separated string from Flutter)
        if let savedOrderString = dict[shuffledOrderKey] as? String, !savedOrderString.isEmpty {
            let parsedOrder = savedOrderString.components(separatedBy: ",").compactMap { Int($0) }
            if !parsedOrder.isEmpty {
                return parsedOrder
            }
        }

        // Create new shuffled order (0 to 29 for array indexing)
        var order = Array(0..<stoicQuotes.count)
        order.shuffle()

        // Save the shuffled order as comma-separated string for consistency
        let orderString = order.map { String($0) }.joined(separator: ",")
        defaults.set(orderString, forKey: shuffledOrderKey)

        return order
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
