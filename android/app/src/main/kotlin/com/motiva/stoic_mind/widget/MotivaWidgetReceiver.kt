package com.motiva.stoic_mind.widget

import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver

/**
 * Widget receiver for the Motiva Quote widget.
 * Updates are triggered when:
 * - Widget is first added to home screen
 * - System triggers update (once per day via updatePeriodMillis)
 * - Flutter app calls HomeWidget.updateWidget()
 */
class MotivaWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = MotivaWidget()
}
