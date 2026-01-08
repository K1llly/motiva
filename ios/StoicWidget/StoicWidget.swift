import WidgetKit
import SwiftUI

// IMPORTANT: This widget requires Apple Developer Program enrollment to work.
// You must:
// 1. Enroll in Apple Developer Program ($99/year)
// 2. Add Widget Extension target via Xcode (File > New > Target > Widget Extension)
// 3. Configure App Groups on both Runner and Widget Extension targets
// 4. The App Group ID must be: group.com.motiva.stoicmind

struct Provider: TimelineProvider {
    let userDefaults = UserDefaults(suiteName: "group.com.motiva.stoicmind")

    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(
            date: Date(),
            quoteText: "The happiness of your life depends upon the quality of your thoughts.",
            author: "Marcus Aurelius",
            dayNumber: 1
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        let entry = loadCurrentQuote()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        let entry = loadCurrentQuote()

        // Refresh at midnight when quote changes
        let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let timeline = Timeline(entries: [entry], policy: .after(midnight))

        completion(timeline)
    }

    private func loadCurrentQuote() -> QuoteEntry {
        let quoteText = userDefaults?.string(forKey: "quote_text")
            ?? "The happiness of your life depends upon the quality of your thoughts."
        let author = userDefaults?.string(forKey: "quote_author") ?? "Marcus Aurelius"
        let dayNumber = userDefaults?.integer(forKey: "day_number") ?? 1

        return QuoteEntry(
            date: Date(),
            quoteText: quoteText,
            author: author,
            dayNumber: dayNumber
        )
    }
}

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quoteText: String
    let author: String
    let dayNumber: Int
}

struct MotivaWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        case .accessoryInline:
            InlineWidgetView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Home Screen Widgets

// Small Widget (2x2)
struct SmallWidgetView: View {
    let entry: QuoteEntry
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var secondaryColor: Color {
        colorScheme == .dark ? .gray : .gray
    }

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Spacer()

            Text("\"\(entry.quoteText)\"")
                .font(.caption)
                .fontWeight(.regular)
                .italic()
                .foregroundColor(textColor)
                .lineLimit(5)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)

            Spacer()

            Text("- \(entry.author)")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(secondaryColor)
        }
        .padding(12)
        .containerBackground(backgroundColor, for: .widget)
    }
}

// Medium Widget (4x2)
struct MediumWidgetView: View {
    let entry: QuoteEntry
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var secondaryColor: Color {
        colorScheme == .dark ? .gray : .gray
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Spacer()

            Text("\"\(entry.quoteText)\"")
                .font(.body)
                .fontWeight(.regular)
                .italic()
                .foregroundColor(textColor)
                .lineLimit(4)
                .minimumScaleFactor(0.8)
                .multilineTextAlignment(.center)

            Spacer()

            Text("- \(entry.author)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(secondaryColor)
        }
        .padding(16)
        .containerBackground(backgroundColor, for: .widget)
    }
}

// Large Widget (4x4)
struct LargeWidgetView: View {
    let entry: QuoteEntry
    @Environment(\.colorScheme) var colorScheme

    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }

    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }

    var secondaryColor: Color {
        colorScheme == .dark ? .gray : .gray
    }

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()

            Text("\"\(entry.quoteText)\"")
                .font(.title3)
                .fontWeight(.regular)
                .italic()
                .foregroundColor(textColor)
                .lineLimit(8)
                .minimumScaleFactor(0.7)
                .multilineTextAlignment(.center)

            Spacer()

            Text("- \(entry.author)")
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(secondaryColor)

            Text("Tap to see meaning")
                .font(.caption2)
                .foregroundColor(secondaryColor.opacity(0.7))
        }
        .padding(20)
        .containerBackground(backgroundColor, for: .widget)
    }
}

// MARK: - Lock Screen Widgets

// Lock Screen - Circular (shows Motiva icon)
struct CircularWidgetView: View {
    let entry: QuoteEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text("M")
                .font(.title)
                .fontWeight(.bold)
        }
    }
}

// Lock Screen - Rectangular (shows short quote)
struct RectangularWidgetView: View {
    let entry: QuoteEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.quoteText)
                .font(.caption)
                .lineLimit(2)
            Text("- \(entry.author)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// Lock Screen - Inline (text only, above clock)
struct InlineWidgetView: View {
    let entry: QuoteEntry

    var body: some View {
        Text("Motiva - \(entry.author)")
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
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    MotivaWidget()
} timeline: {
    QuoteEntry(date: .now, quoteText: "The happiness of your life depends upon the quality of your thoughts.", author: "Marcus Aurelius", dayNumber: 1)
}

#Preview(as: .systemMedium) {
    MotivaWidget()
} timeline: {
    QuoteEntry(date: .now, quoteText: "The happiness of your life depends upon the quality of your thoughts.", author: "Marcus Aurelius", dayNumber: 1)
}

#Preview(as: .systemLarge) {
    MotivaWidget()
} timeline: {
    QuoteEntry(date: .now, quoteText: "The happiness of your life depends upon the quality of your thoughts.", author: "Marcus Aurelius", dayNumber: 1)
}

#Preview(as: .accessoryRectangular) {
    MotivaWidget()
} timeline: {
    QuoteEntry(date: .now, quoteText: "The happiness of your life depends upon the quality of your thoughts.", author: "Marcus Aurelius", dayNumber: 1)
}
