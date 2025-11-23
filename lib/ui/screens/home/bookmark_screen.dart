import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_feed/ui/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';

import 'package:flash_feed/data/features/bookmarks_provider.dart';
import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flash_feed/ui/screens/news_webview_screen.dart';

class BookmarkScreen extends ConsumerWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookMarksProvider);
    final notifier = ref.read(bookMarksProvider.notifier);

    if (bookmarks.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("No bookmarks yet.", style: TextStyle(fontSize: 16)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Bookmarks")),
      body: ListView.builder(
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final item = bookmarks[index];

          return Dismissible(
            key: ValueKey(item.link),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft, // Icon for left-to-right swipe
              padding: const EdgeInsets.only(left: 24),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight, // Icon for right-to-left swipe
              padding: const EdgeInsets.only(right: 24),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction:
                DismissDirection.horizontal, // Allow swipe from both directions
            onDismissed: (_) {
              notifier.removeBookmark(item);

              AppSnackBar.show(
                context,
                "Bookmark removed",
                actionLabel: "UNDO",
                onAction: () => notifier.addBookmark(item),
              );
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
              child: BookmarkCard(newsItem: item),
            ),
          );
        },
      ),
    );
  }
}

class BookmarkCard extends ConsumerWidget {
  const BookmarkCard({super.key, required this.newsItem});

  final NewsItem newsItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(bookMarksProvider.notifier);
    final isDarkMode = ref.watch(themeProvider);

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
                    child: Container(color: Colors.white),
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
                Text(
                  newsItem.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Text(
                  newsItem.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 15, left: 12),
              child: Row(
                children: [
                  Text(
                    "${newsItem.source} • ${newsItem.publishedAt.day} "
                    "${_monthString(newsItem.publishedAt.month)} "
                    "${newsItem.publishedAt.year}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),

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

                  const SizedBox(width: 15),

                  /// DELETE FROM BOOKMARKS
                  IconButton(
                    tooltip: 'Remove Bookmark',
                    onPressed: () {
                      notifier.removeBookmark(newsItem);

                      AppSnackBar.show(
                        context,
                        "Bookmark removed",
                        actionLabel: "UNDO",
                        onAction: () => notifier.addBookmark(newsItem),
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
