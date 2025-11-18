import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class EngadgetSource {
  // Define constants for XML namespaces
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  final String _rssUrl = 'https://www.engadget.com/rss.xml';

  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> allNews = [];
    final Set<String> uniqueLinks = {}; // To track unique article URLs

    try {
      final response = await http.get(
        Uri.parse(_rssUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch Engadget feed: ${response.statusCode}',
        );
      }

      final body = response.body.trim();
      if (body.isEmpty) throw Exception('Empty RSS response from $_rssUrl');

      final document = XmlDocument.parse(body);
      final channelElement =
          document.getElement('channel') ??
          document.getElement('rss')?.getElement('channel');

      if (channelElement == null) {
        throw Exception('Invalid RSS: <channel> tag not found in $_rssUrl');
      }

      final sourceTitle =
          channelElement.getElement('title')?.innerText.trim() ?? 'Engadget';
      final items = channelElement.findAllElements('item');

      for (var item in items) {
        final title = item.getElement('title')?.innerText.trim() ?? 'No title';
        final link = item.getElement('link')?.innerText.trim() ?? '';

        // Description Cleaning
        String description =
            item.getElement('description')?.innerText.trim() ??
            'No description';
        // Remove Engadget attribution line
        description = description
            .replaceAll(
              RegExp(
                r'This article originally appeared on Engadget.*',
                caseSensitive: false,
              ),
              '',
            )
            .trim();

        // Image Extraction
        String imageUrl = '';
        final mediaContentEl = item
            .findElements('content', namespace: _mediaNamespace)
            .firstOrNull;
        final mediaThumbnailEl = item
            .findElements('thumbnail', namespace: _mediaNamespace)
            .firstOrNull;

        // Prioritize media:content, then media:thumbnail
        imageUrl =
            mediaContentEl?.getAttribute('url') ??
            mediaThumbnailEl?.getAttribute('url') ??
            '';

        // Author
        final author =
            item
                .findElements('creator', namespace: _dcNamespace)
                .firstOrNull
                ?.innerText
                .trim() ??
            'Unknown';

        // Date & Category
        final publishedAt = _parseDate(item.getElement('pubDate')?.innerText);
        final category =
            item.getElement('category')?.innerText.trim() ?? 'Technology';

        final newsItem = NewsItem(
          title: title,
          link: link,
          description: description,
          imageUrl: imageUrl,
          author: author,
          publishedAt: publishedAt,
          source: sourceTitle,
          category: category,
        );

        // Add only unique items to the list
        if (uniqueLinks.add(newsItem.link)) {
          allNews.add(newsItem);
        }
      }

      debugPrint(
        '✅ Successfully fetched and parsed ${allNews.length} items from $_rssUrl',
      );

      // Sort by date, newest first
      allNews.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return allNews;
    } catch (e) {
      debugPrint('❌ Error fetching Engadget feed: $e');
      throw Exception('Could not fetch or parse Engadget feed: $e');
    }
  }

  /// Parse different RSS date formats safely
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint(
        '⚠️ Date string was null/empty for Engadget. Using DateTime.now().',
      );
      return DateTime.now();
    }
    try {
      // Engadget uses RFC-2822 format (e.g., "Tue, 18 Nov 2025 17:38:34 +0000")
      final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
      return formatter.parse(dateStr.trim());
    } catch (_) {
      try {
        // Fallback for other common formats
        return HttpDate.parse(dateStr.trim());
      } catch (_) {
        debugPrint(
          '⚠️ Failed to parse date "$dateStr" for Engadget. Using DateTime.now().',
        );
        return DateTime.now();
      }
    }
  }
}
