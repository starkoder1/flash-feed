import 'dart:io';

import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class NasaNewsSource {
  final String feedUrl = "https://www.nasa.gov/news-release/feed/";

  // Define constants for XML namespaces to robustly parse the feed
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _contentNamespace =
      'http://purl.org/rss/1.0/modules/content/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  /// Fetches and parses the NASA RSS feed
  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    final Set<String> uniqueLinks = {};

    try {
      final response = await http.get(
        Uri.parse(feedUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load feed (status: ${response.statusCode})');
      }

      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      for (final item in items) {
        final title = item.getElement('title')?.innerText.trim() ?? 'No Title';
        final link = item.getElement('link')?.innerText.trim() ?? '';

        // Skip if the link is empty or already processed
        if (link.isEmpty || !uniqueLinks.add(link)) {
          continue;
        }

        final description =
            item.getElement('description')?.innerText.trim() ?? '';
        final pubDate = _parseDate(item.getElement('pubDate')?.innerText);

        // Extract author from <dc:creator>
        final author =
            item
                .findElements('creator', namespace: _dcNamespace)
                .firstOrNull
                ?.innerText
                .trim() ??
            'NASA';

        // Extract image from <media:content> or parse from <content:encoded>
        String imageUrl = '';
        final mediaContent = item
            .findElements('content', namespace: _mediaNamespace)
            .firstOrNull;
        imageUrl = mediaContent?.getAttribute('url') ?? '';

        if (imageUrl.isEmpty) {
          final contentEncoded = item
              .findElements('encoded', namespace: _contentNamespace)
              .firstOrNull
              ?.innerText;
          if (contentEncoded != null) {
            final imgMatch = RegExp(
              r'<img[^>]+src="([^">]+)"',
            ).firstMatch(contentEncoded);
            if (imgMatch != null) {
              imageUrl = imgMatch.group(1)!;
            }
          }
        }

        newsItems.add(
          NewsItem(
            title: title,
            description: description,
            link: link,
            imageUrl: imageUrl,
            author: author,
            publishedAt: pubDate,
            source: 'NASA',
            category: 'nasa',
          ),
        );
      }

      debugPrint(
        '✅ Successfully fetched and parsed ${newsItems.length} items from $feedUrl',
      );

      // Sort by date, newest first
      newsItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return newsItems;
    } catch (e) {
      debugPrint('❌ Error fetching or parsing NASA feed: $e');
      throw Exception('Error fetching feed: $e');
    }
  }

  /// Parses RSS date strings safely using the intl package.
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint(
        '⚠️ Date string was null/empty for NASA. Using DateTime.now().',
      );
      return DateTime.now();
    }
    try {
      // Format for "Tue, 18 Nov 2025 10:00:00 +0000"
      final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
      return formatter.parse(dateStr.trim());
    } catch (_) {
      try {
        // Fallback for other common formats
        return HttpDate.parse(dateStr.trim());
      } catch (e) {
        debugPrint(
          '⚠️ Failed to parse date "$dateStr" for NASA. Using DateTime.now(). Error: $e',
        );
        return DateTime.now();
      }
    }
  }
}
