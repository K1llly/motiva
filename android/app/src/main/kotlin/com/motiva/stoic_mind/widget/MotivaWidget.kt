package com.motiva.stoic_mind.widget

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import androidx.compose.runtime.Composable
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

class MotivaWidget : GlanceAppWidget() {

    // Use Exact mode to support all widget sizes dynamically
    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

        provideContent {
            val size = LocalSize.current
            GlanceContent(context, prefs, size.width, size.height)
        }
    }

    /**
     * Calculate dynamic font size based on quote length
     * Longer quotes get smaller fonts to fit more text
     */
    private fun calculateDynamicFontSize(
        quoteLength: Int,
        baseFontSize: Float,
        minFontSize: Float = 9f
    ): Float {
        return when {
            quoteLength < 50 -> baseFontSize
            quoteLength < 100 -> baseFontSize - 1f
            quoteLength < 150 -> baseFontSize - 2f
            quoteLength < 200 -> baseFontSize - 3f
            else -> minFontSize.coerceAtLeast(baseFontSize - 4f)
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

        // Determine widget layout based on aspect ratio and size
        val aspectRatio = if (height.value > 0) width.value / height.value else 1f
        val isNarrow = width < 120.dp  // 1xN formats (narrow vertical)
        val isTall = height > 250.dp   // 1x4 or similar tall formats

        // 4x1: very wide (aspect ratio > 2.5 OR width > 300dp with short height)
        val isWide = (aspectRatio > 2.5f && height < 120.dp) || (width > 300.dp && height < 100.dp)
        // 3x1 or similar short horizontal
        val isShort = height < 100.dp && !isWide

        GlanceTheme {
            Box(
                modifier = GlanceModifier
                    .fillMaxSize()
                    .background(GlanceTheme.colors.background)
                    .cornerRadius(16.dp)
                    .clickable(actionRunCallback<OpenAppAction>())
                    .padding(if (isShort || isNarrow || isWide) 8.dp else 12.dp),
                contentAlignment = Alignment.Center
            ) {
                when {
                    isWide -> {
                        // Wide horizontal (4x1) - more space for quote
                        WideHorizontalContent(quoteText, author)
                    }
                    isShort -> {
                        // Short horizontal (3x1, etc.)
                        HorizontalContent(quoteText, author, height < 60.dp)
                    }
                    isNarrow -> {
                        // Narrow vertical (1x2, 1x3, 1x4, etc.)
                        NarrowVerticalContent(quoteText, author, isTall, height)
                    }
                    else -> {
                        // Standard square/rectangular (2x2, 3x2, 4x4, etc.)
                        StandardContent(quoteText, author, height)
                    }
                }
            }
        }
    }

    @Composable
    private fun WideHorizontalContent(
        quoteText: String,
        author: String
    ) {
        // Dynamic font size based on quote length
        val quoteFontSize = calculateDynamicFontSize(quoteText.length, 13f, 10f).sp
        // More lines for longer quotes
        val maxLines = if (quoteText.length > 100) 3 else 2

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
                    color = GlanceTheme.colors.onBackground,
                    textAlign = TextAlign.Start
                ),
                maxLines = maxLines
            )

            Spacer(modifier = GlanceModifier.width(12.dp))

            // Author on the right
            Text(
                text = "- $author",
                modifier = GlanceModifier.wrapContentWidth(),
                style = TextStyle(
                    fontSize = 11.sp,
                    fontWeight = FontWeight.Medium,
                    color = GlanceTheme.colors.secondary,
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
        isVerySmall: Boolean
    ) {
        // Dynamic font size based on quote length
        val baseFontSize = if (isVerySmall) 10f else 12f
        val quoteFontSize = calculateDynamicFontSize(quoteText.length, baseFontSize, 9f).sp
        // More lines for longer quotes
        val maxLines = when {
            isVerySmall -> if (quoteText.length > 80) 2 else 1
            quoteText.length > 120 -> 3
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
                    color = GlanceTheme.colors.onBackground,
                    textAlign = TextAlign.Start
                ),
                maxLines = maxLines
            )

            Text(
                text = "- $author",
                style = TextStyle(
                    fontSize = if (isVerySmall) 9.sp else 10.sp,
                    fontWeight = FontWeight.Medium,
                    color = GlanceTheme.colors.secondary,
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
        height: androidx.compose.ui.unit.Dp
    ) {
        // Dynamic font size based on quote length
        val baseFontSize = if (isTall) 11f else 10f
        val quoteFontSize = calculateDynamicFontSize(quoteText.length, baseFontSize, 8f).sp

        // Calculate max lines based on height - increased for longer quotes
        val baseMaxLines = when {
            height > 300.dp -> 12
            height > 200.dp -> 10
            height > 150.dp -> 8
            else -> 6
        }
        // Add extra lines for long quotes
        val maxQuoteLines = if (quoteText.length > 150) baseMaxLines + 2 else baseMaxLines

        Column(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Quote text (main content)
            Text(
                text = "\"$quoteText\"",
                style = TextStyle(
                    fontSize = quoteFontSize,
                    fontWeight = FontWeight.Normal,
                    fontStyle = FontStyle.Italic,
                    color = GlanceTheme.colors.onBackground,
                    textAlign = TextAlign.Center
                ),
                maxLines = maxQuoteLines
            )

            Spacer(modifier = GlanceModifier.height(if (isTall) 12.dp else 6.dp))

            // Author at bottom
            Text(
                text = "- $author",
                style = TextStyle(
                    fontSize = 9.sp,
                    fontWeight = FontWeight.Medium,
                    color = GlanceTheme.colors.secondary,
                    textAlign = TextAlign.Center
                ),
                maxLines = 1
            )
        }
    }

    @Composable
    private fun StandardContent(
        quoteText: String,
        author: String,
        height: androidx.compose.ui.unit.Dp
    ) {
        val baseQuoteFontSize = when {
            height > 200.dp -> 15f
            height > 150.dp -> 14f
            else -> 13f
        }
        // Dynamic font size based on quote length
        val quoteFontSize = calculateDynamicFontSize(quoteText.length, baseQuoteFontSize, 11f).sp

        val authorFontSize = when {
            height > 200.dp -> 12.sp
            height > 150.dp -> 11.sp
            else -> 10.sp
        }
        // Calculate max lines based on height - increased for longer quotes
        val baseMaxLines = when {
            height > 250.dp -> 10
            height > 180.dp -> 8
            height > 120.dp -> 6
            else -> 5
        }
        // Add extra lines for long quotes
        val maxQuoteLines = if (quoteText.length > 150) baseMaxLines + 2 else baseMaxLines

        val spacing = when {
            height > 200.dp -> 10.dp
            height > 150.dp -> 8.dp
            else -> 6.dp
        }

        Column(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Quote text
            Text(
                text = "\"$quoteText\"",
                style = TextStyle(
                    fontSize = quoteFontSize,
                    fontWeight = FontWeight.Normal,
                    fontStyle = FontStyle.Italic,
                    color = GlanceTheme.colors.onBackground,
                    textAlign = TextAlign.Center
                ),
                maxLines = maxQuoteLines
            )

            Spacer(modifier = GlanceModifier.height(spacing))

            // Author
            Text(
                text = "- $author",
                style = TextStyle(
                    fontSize = authorFontSize,
                    fontWeight = FontWeight.Medium,
                    color = GlanceTheme.colors.secondary,
                    textAlign = TextAlign.Center
                ),
                maxLines = 1
            )
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
