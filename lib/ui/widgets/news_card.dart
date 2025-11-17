import 'package:cached_network_image/cached_network_image.dart';
import 'package:flash_feed/data/features/theme_provider.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/material.dart';
import 'package:flash_feed/utils/util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewsCard extends ConsumerWidget {
  const NewsCard({super.key, required this.newsItem});

  final NewsItem newsItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    return Card(
      margin: EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      // elevation: 1.25,
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
                filterQuality: FilterQuality.low, // keeps scroll smooth
                placeholder: (_, __) => const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
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
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                    "${newsItem.source} • ${newsItem.publishedAt.day} ${_monthString(newsItem.publishedAt.month)} ${newsItem.publishedAt.year}",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Spacer(),
                  Icon(Icons.share),
                  SizedBox(width: 15),
                  Icon(Icons.bookmark_border),
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
