import WidgetKit
import SwiftUI

@main
struct MotivaWidgetBundle: WidgetBundle {
    var body: some Widget {
        // Main widget - supports all home screen and lock screen sizes
        MotivaWidget()
    }
}
