package com.motiva.stoic_mind.widget

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.LocalSize
import androidx.glance.action.ActionParameters
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.ActionCallback
import androidx.glance.appwidget.action.actionRunCallback
import androidx.glance.appwidget.provideContent
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.color.ColorProvider
import androidx.glance.ImageProvider
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.layout.wrapContentHeight
import androidx.glance.layout.wrapContentWidth
import androidx.glance.text.FontStyle
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import com.motiva.stoic_mind.R

/**
 * Data class to hold widget appearance settings
 * Using Int color values for compatibility with Glance ColorProvider
 */
data class WidgetAppearance(
    val backgroundColor: Int,
    val textColor: Int,
    val secondaryTextColor: Int,
    val isGlassMode: Boolean
)

class MotivaWidget : GlanceAppWidget() {

    // Use Exact mode to support all widget sizes dynamically
    override val sizeMode = SizeMode.Exact

    // Default colors
    companion object {
        private const val DEFAULT_BACKGROUND_COLOR = 0xFF1A1A1A.toInt()
        private const val DEFAULT_TEXT_COLOR = 0xFFFFFFFF.toInt()
    }

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

        provideContent {
            val size = LocalSize.current
            GlanceContent(context, prefs, size.width, size.height)
        }
    }

    /**
     * Read widget appearance settings from SharedPreferences
     * Colors may be stored as Long by Flutter's HomeWidget package
     */
    private fun getWidgetAppearance(prefs: SharedPreferences): WidgetAppearance {
        // Read colors - they may be stored as Long or Int depending on the value
        val backgroundColor = getColorFromPrefs(prefs, "widget_background_color", DEFAULT_BACKGROUND_COLOR)
        val textColor = getColorFromPrefs(prefs, "widget_text_color", DEFAULT_TEXT_COLOR)
        val isGlassMode = prefs.getBoolean("widget_glass_mode", false)

        // Create secondary text color with reduced alpha (70% opacity)
        val alpha = (textColor shr 24) and 0xFF
        val reducedAlpha = ((alpha * 0.7f).toInt() and 0xFF) shl 24
        val secondaryTextColor = (textColor and 0x00FFFFFF) or reducedAlpha

        return WidgetAppearance(
            backgroundColor = backgroundColor,
            textColor = textColor,
            secondaryTextColor = secondaryTextColor,
            isGlassMode = isGlassMode
        )
    }

    /**
     * Safely read color from SharedPreferences
     * Handles both Int and Long storage types
     */
    private fun getColorFromPrefs(prefs: SharedPreferences, key: String, default: Int): Int {
        return try {
            // First try to get as Long (Flutter may store as Long)
            prefs.getLong(key, default.toLong()).toInt()
        } catch (e: ClassCastException) {
            try {
                // Fall back to Int
                prefs.getInt(key, default)
            } catch (e2: Exception) {
                default
            }
        }
    }

    /**
     * Calculate dynamic font size based on quote length
     * Longer quotes get smaller fonts to fit more text
     * Increased base sizes for better readability
     */
    private fun calculateDynamicFontSize(
        quoteLength: Int,
        baseFontSize: Float,
        minFontSize: Float = 12f
    ): Float {
        return when {
            quoteLength < 50 -> baseFontSize
            quoteLength < 100 -> baseFontSize - 2f
            quoteLength < 150 -> baseFontSize - 3f
            quoteLength < 200 -> baseFontSize - 4f
            quoteLength < 300 -> baseFontSize - 5f
            else -> minFontSize.coerceAtLeast(baseFontSize - 6f)
        }.coerceAtLeast(minFontSize)
    }

    @Composable
    private fun GlanceContent(
        context: Context,
        prefs: SharedPreferences,
        width: androidx.compose.ui.unit.Dp,
        height: androidx.compose.ui.unit.Dp
    ) {
        val quoteText = prefs.getString("quote_text", null)
            ?: context.getString(R.string.widget_default_quote)
        val author = prefs.getString("quote_author", null)
            ?: context.getString(R.string.widget_default_author)

        // Get appearance settings
        val appearance = getWidgetAppearance(prefs)

        // Determine widget layout based on aspect ratio and size
        val aspectRatio = if (height.value > 0) width.value / height.value else 1f
        val isNarrow = width < 120.dp  // 1xN formats (narrow vertical)
        val isTall = height > 250.dp   // 1x4 or similar tall formats

        // 4x1: very wide (aspect ratio > 2.5 OR width > 300dp with short height)
        val isWide = (aspectRatio > 2.5f && height < 120.dp) || (width > 300.dp && height < 100.dp)
        // 3x1 or similar short horizontal
        val isShort = height < 100.dp && !isWide

        val padding = if (isShort || isNarrow || isWide) 12.dp else 16.dp

        GlanceTheme {
            if (appearance.isGlassMode) {
                // Glass mode - frosted glass effect
                GlassContainer(
                    modifier = GlanceModifier
                        .fillMaxSize()
                        .cornerRadius(20.dp)
                        .clickable(actionRunCallback<OpenAppAction>())
                        .padding(padding),
                    appearance = appearance
                ) {
                    WidgetContent(
                        quoteText = quoteText,
                        author = author,
                        appearance = appearance,
                        isWide = isWide,
                        isShort = isShort,
                        isNarrow = isNarrow,
                        isTall = isTall,
                        height = height
                    )
                }
            } else {
                // Solid color background
                Box(
                    modifier = GlanceModifier
                        .fillMaxSize()
                        .background(ColorProvider(day = Color(appearance.backgroundColor), night = Color(appearance.backgroundColor)))
                        .cornerRadius(20.dp)
                        .clickable(actionRunCallback<OpenAppAction>())
                        .padding(padding),
                    contentAlignment = Alignment.Center
                ) {
                    WidgetContent(
                        quoteText = quoteText,
                        author = author,
                        appearance = appearance,
                        isWide = isWide,
                        isShort = isShort,
                        isNarrow = isNarrow,
                        isTall = isTall,
                        height = height
                    )
                }
            }
        }
    }

    /**
     * Glass container with iOS 26-style frosted glass effect
     * Uses drawable background with gradient overlay for glass appearance
     */
    @Composable
    private fun GlassContainer(
        modifier: GlanceModifier,
        appearance: WidgetAppearance,
        content: @Composable () -> Unit
    ) {
        // Use drawable background for frosted glass effect
        // The drawable contains layered gradients that simulate the frosted appearance
        Box(
            modifier = modifier
                .background(ImageProvider(R.drawable.glass_frosted_background)),
            contentAlignment = Alignment.Center
        ) {
            content()
        }
    }

    /**
     * Main widget content dispatcher
     */
    @Composable
    private fun WidgetContent(
        quoteText: String,
        author: String,
        appearance: WidgetAppearance,
        isWide: Boolean,
        isShort: Boolean,
        isNarrow: Boolean,
        isTall: Boolean,
        height: androidx.compose.ui.unit.Dp
    ) {
        when {
            isWide -> WideHorizontalContent(quoteText, author, appearance)
            isShort -> HorizontalContent(quoteText, author, height < 60.dp, appearance)
            isNarrow -> NarrowVerticalContent(quoteText, author, isTall, height, appearance)
            else -> StandardContent(quoteText, author, height, appearance)
        }
    }

    @Composable
    private fun WideHorizontalContent(
        quoteText: String,
        author: String,
        appearance: WidgetAppearance
    ) {
        // Dynamic font size based on quote length - increased base size
        val quoteFontSize = calculateDynamicFontSize(quoteText.length, 18f, 14f).sp
        // More lines for longer quotes
        val maxLines = when {
            quoteText.length > 150 -> 4
            quoteText.length > 100 -> 3
            else -> 2
        }

        Row(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.Start
        ) {
            // Quote takes most space
            Text(
                text = "\"$quoteText\"",
                modifier = GlanceModifier.defaultWeight(),
                style = TextStyle(
                    fontSize = quoteFontSize,
                    fontWeight = FontWeight.Normal,
                    fontStyle = FontStyle.Italic,
                    color = ColorProvider(day = Color(appearance.textColor), night = Color(appearance.textColor)),
                    textAlign = TextAlign.Start
                ),
                maxLines = maxLines
            )

            Spacer(modifier = GlanceModifier.width(16.dp))

            // Author on the right
            Text(
                text = "— $author",
                modifier = GlanceModifier.wrapContentWidth(),
                style = TextStyle(
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Medium,
                    color = ColorProvider(day = Color(appearance.secondaryTextColor), night = Color(appearance.secondaryTextColor)),
                    textAlign = TextAlign.End
                ),
                maxLines = 1
            )
        }
    }

    @Composable
    private fun HorizontalContent(
        quoteText: String,
        author: String,
        isVerySmall: Boolean,
        appearance: WidgetAppearance
    ) {
        // Dynamic font size based on quote length - increased base sizes
        val baseFontSize = if (isVerySmall) 14f else 16f
        val quoteFontSize = calculateDynamicFontSize(quoteText.length, baseFontSize, 12f).sp
        // More lines for longer quotes
        val maxLines = when {
            isVerySmall -> if (quoteText.length > 80) 3 else 2
            quoteText.length > 150 -> 4
            quoteText.length > 100 -> 3
            else -> 2
        }

        // Quote and author stacked vertically
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.Start
        ) {
            Text(
                text = "\"$quoteText\"",
                style = TextStyle(
                    fontSize = quoteFontSize,
                    fontWeight = FontWeight.Normal,
                    fontStyle = FontStyle.Italic,
                    color = ColorProvider(day = Color(appearance.textColor), night = Color(appearance.textColor)),
                    textAlign = TextAlign.Start
                ),
                maxLines = maxLines
            )

            Spacer(modifier = GlanceModifier.height(4.dp))

            Text(
                text = "— $author",
                style = TextStyle(
                    fontSize = if (isVerySmall) 12.sp else 13.sp,
                    fontWeight = FontWeight.Medium,
                    color = ColorProvider(day = Color(appearance.secondaryTextColor), night = Color(appearance.secondaryTextColor)),
                    textAlign = TextAlign.Start
                ),
                maxLines = 1
            )
        }
    }

    @Composable
    private fun NarrowVerticalContent(
        quoteText: String,
        author: String,
        isTall: Boolean,
        height: androidx.compose.ui.unit.Dp,
        appearance: WidgetAppearance
    ) {
        // Dynamic font size based on quote length - increased base sizes
        val baseFontSize = if (isTall) 16f else 14f
        val quoteFontSize = calculateDynamicFontSize(quoteText.length, baseFontSize, 12f).sp

        // Calculate max lines based on height - increased for longer quotes
        val baseMaxLines = when {
            height > 350.dp -> 16
            height > 300.dp -> 14
            height > 250.dp -> 12
            height > 200.dp -> 10
            height > 150.dp -> 8
            else -> 6
        }
        // Add extra lines for long quotes
        val maxQuoteLines = if (quoteText.length > 150) baseMaxLines + 3 else baseMaxLines

        // Use Box with stacked children - quote centered, author at bottom
        Box(
            modifier = GlanceModifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            // Quote text - centered in the box (ignoring author)
            Text(
                text = "\"$quoteText\"",
                modifier = GlanceModifier.fillMaxWidth(),
                style = TextStyle(
                    fontSize = quoteFontSize,
                    fontWeight = FontWeight.Normal,
                    fontStyle = FontStyle.Italic,
                    color = ColorProvider(day = Color(appearance.textColor), night = Color(appearance.textColor)),
                    textAlign = TextAlign.Center
                ),
                maxLines = maxQuoteLines
            )

            // Author at bottom - positioned absolutely within the same Box
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.Bottom,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "— $author",
                    modifier = GlanceModifier.padding(bottom = 4.dp),
                    style = TextStyle(
                        fontSize = if (isTall) 13.sp else 12.sp,
                        fontWeight = FontWeight.Medium,
                        color = ColorProvider(day = Color(appearance.secondaryTextColor), night = Color(appearance.secondaryTextColor)),
                        textAlign = TextAlign.Center
                    ),
                    maxLines = 1
                )
            }
        }
    }

    @Composable
    private fun StandardContent(
        quoteText: String,
        author: String,
        height: androidx.compose.ui.unit.Dp,
        appearance: WidgetAppearance
    ) {
        // Increased base font sizes for better readability
        val baseQuoteFontSize = when {
            height > 250.dp -> 20f
            height > 200.dp -> 18f
            height > 150.dp -> 16f
            else -> 15f
        }
        // Dynamic font size based on quote length
        val quoteFontSize = calculateDynamicFontSize(quoteText.length, baseQuoteFontSize, 13f).sp

        val authorFontSize = when {
            height > 250.dp -> 15.sp
            height > 200.dp -> 14.sp
            height > 150.dp -> 13.sp
            else -> 12.sp
        }
        // Calculate max lines based on height - increased for longer quotes
        val baseMaxLines = when {
            height > 300.dp -> 14
            height > 250.dp -> 12
            height > 200.dp -> 10
            height > 150.dp -> 8
            height > 120.dp -> 6
            else -> 5
        }
        // Add extra lines for long quotes
        val maxQuoteLines = if (quoteText.length > 150) baseMaxLines + 3 else baseMaxLines

        val spacing = when {
            height > 250.dp -> 16.dp
            height > 200.dp -> 12.dp
            height > 150.dp -> 10.dp
            else -> 8.dp
        }

        // Use Box with stacked children - quote centered, author at bottom
        Box(
            modifier = GlanceModifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            // Quote text - centered in the box (ignoring author)
            Text(
                text = "\"$quoteText\"",
                modifier = GlanceModifier.fillMaxWidth(),
                style = TextStyle(
                    fontSize = quoteFontSize,
                    fontWeight = FontWeight.Normal,
                    fontStyle = FontStyle.Italic,
                    color = ColorProvider(day = Color(appearance.textColor), night = Color(appearance.textColor)),
                    textAlign = TextAlign.Center
                ),
                maxLines = maxQuoteLines
            )

            // Author at bottom - positioned absolutely within the same Box
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.Bottom,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "— $author",
                    modifier = GlanceModifier.padding(bottom = 4.dp),
                    style = TextStyle(
                        fontSize = authorFontSize,
                        fontWeight = FontWeight.Medium,
                        color = ColorProvider(day = Color(appearance.secondaryTextColor), night = Color(appearance.secondaryTextColor)),
                        textAlign = TextAlign.Center
                    ),
                    maxLines = 1
                )
            }
        }
    }
}

/**
 * Action to open the main Flutter app when widget is tapped
 */
class OpenAppAction : ActionCallback {
    override suspend fun onAction(
        context: Context,
        glanceId: GlanceId,
        parameters: ActionParameters
    ) {
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        intent?.let {
            it.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            context.startActivity(it)
        }
    }
}
