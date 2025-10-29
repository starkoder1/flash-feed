import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/material.dart';
import 'package:flash_feed/utils/util.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({super.key, required this.newsItem});

  final NewsItem newsItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(roundedBoxRadius),
        ),
        elevation: 1.25,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(roundedBoxRadius),
                    topRight: Radius.circular(roundedBoxRadius),
                  ),
                  child: Image.network(
                    newsItem.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      "assets/logo.png",
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 15,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: secondaryShade,
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    newsItem.description,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                    maxLines: 2,
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
