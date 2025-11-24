import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_feed/data/features/bookmarks_provider.dart';
import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/ui/widgets/app_snackbar.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NewsCard extends ConsumerWidget {
  const NewsCard({super.key, required this.newsItem});

  final NewsItem newsItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctx = context;
    final notifier = ref.read(bookMarksProvider.notifier);
    final isDarkMode = ref.watch(themeProvider);
    final bookmarks = ref.watch(bookMarksProvider);
    bool isBookmarked = notifier.isBookmarked(newsItem);

    final defaultIconColor = Theme.of(context).iconTheme.color ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  "assets/error.png",
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
                    color: isDarkMode ? darkmodeShade : secondaryShade,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(newsItem.category.toUpperCase()),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
            ).copyWith(top: 10, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Conditionally display the author if it's available and not empty.
                if (newsItem.author.isNotEmpty) ...[
                  Text(
                    newsItem.author.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
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

          // ------------------------------
          // FIXED META ROW (source + date)
          // ------------------------------
          Padding(
            padding: const EdgeInsets.only(right: 20, bottom: 15, left: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final style = Theme.of(context).textTheme.bodySmall!;
                final combined =
                    "${newsItem.source} • ${newsItem.publishedAt.day} ${_monthString(newsItem.publishedAt.month)} ${newsItem.publishedAt.year}";

                final fits = _fitsInOneLine(
                  combined,
                  style,
                  constraints.maxWidth - 90, // space for buttons
                );

                return Row(
                  children: [
                    // Left dynamic section
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

                    IconButton(
                      onPressed: () {
                        if (isBookmarked) {
                          notifier.removeBookmark(newsItem);
                          showCustomSnackBar(
                            backgroundColor: primaryShade,
                            context: ctx,
                            message: "Bookmark Removed",
                            duration: const Duration(seconds: 3),
                            trailing: TextButton(
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.all(0),
                              ),
                              onPressed: () {
                                notifier.addBookmark(newsItem);
                                ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
                              },
                              child: Text(
                                'UNDO',
                                style: TextStyle(color: Colors.orange[300]),
                              ),
                            ),
                          );
                        } else {
                          notifier.addBookmark(newsItem);
                          showCustomSnackBar(
                            backgroundColor: primaryShade,
                            context: ctx,
                            message: "Bookmark Added",
                            duration: const Duration(seconds: 2),
                          );
                        }
                      },
                      icon: TweenAnimationBuilder<Color?>(
                        duration: 300.ms,
                        tween: ColorTween(
                          begin: defaultIconColor,
                          end: isBookmarked ? primaryShade : defaultIconColor,
                        ),
                        builder: (_, color, __) {
                          return Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_outline,
                                color: color,
                              )
                              .animate(target: isBookmarked ? 1 : 0)
                              .shake(duration: 300.ms, hz: 4);
                        },
                      ),
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

  // Helper: does combined text fit in one line?
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
