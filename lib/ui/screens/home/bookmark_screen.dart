import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';

// Keep your existing imports
import 'package:flash_feed/data/features/bookmarks_provider.dart';
import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flash_feed/ui/screens/news_webview_screen.dart';
import 'package:flash_feed/ui/widgets/app_snackbar.dart';

class BookmarkScreen extends ConsumerWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookMarksProvider);
    final notifier = ref.read(bookMarksProvider.notifier);

    // -----------------------------------------------------------------
    // HELPER: The Safe Way to Delete & Undo without crashing
    // -----------------------------------------------------------------
    void handleDelete(BuildContext ctx, NewsItem item) {
      // 1. Remove the item (This updates the list)
      notifier.removeBookmark(item);

      // 2. Show the custom snackbar which will auto-dismiss
      showCustomSnackBar(
        context: ctx,
        backgroundColor: primaryShade,
        message: "Bookmark Removed",
        duration: const Duration(seconds: 3),
        trailing: TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.all(0)),
          onPressed: () {
            HapticFeedback.lightImpact(); // Add haptic feedback on undo
            notifier.addBookmark(item);
            ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
          },
          child: const Text('UNDO', style: TextStyle(color: Colors.amber)),
        ),
      ); // This was already here, just cleaning up the surrounding code.
    }

    // EMPTY STATE
    if (bookmarks.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            "Bookmarks",
            style: GoogleFonts.manrope(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        body: const Center(child: Text("No bookmarks added yet.")),
      );
    }

    // LIST STATE
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bookmarks",
          style: GoogleFonts.manrope(fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView.builder(
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final item = bookmarks[index];

          return Dismissible(
            key: ValueKey(item.link),
            direction: DismissDirection.horizontal,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 24),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              HapticFeedback.lightImpact(); // Add haptic feedback on dismiss
              // Call the safe helper function
              handleDelete(context, item);
            },
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewsWebViewScreen(news: item),
                  ),
                );
              },
              child: BookmarkCard(
                newsItem: item,
                // Pass the delete logic down to the button
                onDeletePressed: () {
                  HapticFeedback.lightImpact(); // Add haptic feedback on delete button press
                  handleDelete(context, item);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class BookmarkCard extends ConsumerWidget {
  const BookmarkCard({
    super.key,
    required this.newsItem,
    required this.onDeletePressed, // Receive the function
  });

  final NewsItem newsItem;
  final VoidCallback onDeletePressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    // Fallback colors if your util variables aren't found
    final tagBgColor = isDarkMode ? darkmodeShade : secondaryShade;

    return Card(
      margin: const EdgeInsets.only(bottom: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE SECTION
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: newsItem.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                placeholder: (_, __) => SizedBox(
                  height: 200,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Image.asset(
                  "assets/logo.png",
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 10,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: tagBgColor, // Use local var or your util vars
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(newsItem.category.toUpperCase()),
                ),
              ),
            ],
          ),

          // TITLE & DESCRIPTION
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ).copyWith(top: 10, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  newsItem.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  newsItem.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w100,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // META ROW (Date, Source, Buttons)
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 15, left: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final style = Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontWeight: FontWeight.w100,
                  fontSize: 14,
                );

                final combined =
                    "${newsItem.source} • ${newsItem.publishedAt.day} ${_monthString(newsItem.publishedAt.month)} ${newsItem.publishedAt.year}";

                // Reserve 96px for the two IconButtons
                final fits = _fitsInOneLine(
                  combined,
                  style,
                  constraints.maxWidth - 96,
                );

                return Row(
                  children: [
                    Expanded(
                      child: fits
                          ? Text(
                              combined,
                              style: style,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  newsItem.source,
                                  style: style,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "${newsItem.publishedAt.day} ${_monthString(newsItem.publishedAt.month)} ${newsItem.publishedAt.year}",
                                  style: style,
                                ),
                              ],
                            ),
                    ),

                    // Share Button
                    IconButton(
                      tooltip: 'Share',
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(
                            uri: Uri.parse(newsItem.link),
                            title: newsItem.title,
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                    ),

                    // Delete Button
                    IconButton(
                      color: const Color(0xFFE53935),
                      tooltip: 'Remove Bookmark',
                      onPressed: onDeletePressed, // Uses the safe helper
                      icon: const Icon(Icons.delete_outline),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _fitsInOneLine(String text, TextStyle style, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return !tp.didExceedMaxLines;
  }

  String _monthString(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }
}
