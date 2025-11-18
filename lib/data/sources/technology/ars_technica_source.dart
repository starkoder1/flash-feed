import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';

class ArsTechnicaSource {
  // Define constants for XML namespaces
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  static const String _feedUrl = 'https://arstechnica.com/feed/';

  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> allNews = [];
    final Set<String> uniqueLinks = {}; // To track unique article URLs

    try {
      final response = await http.get(
        Uri.parse(_feedUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load Ars Technica feed: ${response.statusCode}',
        );
      }
      final body = response.body.trim();
      if (body.isEmpty) throw Exception('Empty RSS response from $_feedUrl');

      final document = XmlDocument.parse(body);
      final channelElement =
          document.getElement('channel') ??
          document.getElement('rss')?.getElement('channel');

      if (channelElement == null) {
        throw Exception('Invalid RSS: <channel> tag not found in $_feedUrl');
      }

      final sourceTitle =
          channelElement.getElement('title')?.innerText.trim() ??
          'Ars Technica';
      final items = channelElement.findAllElements('item');

      for (final item in items) {
        final title = item.getElement('title')?.innerText.trim() ?? 'No title';
        final link = item.getElement('link')?.innerText.trim() ?? '';

        // Use the simple description, not the full <content:encoded>
        final description =
            item.getElement('description')?.innerText.trim() ??
            'No description';

        final publishedAt = _parseDate(item.getElement('pubDate')?.innerText);

        // Get the first category
        final category =
            item.getElement('category')?.innerText.trim() ?? 'Technology';

        // Extract author (dc:creator)
        final author =
            item
                .findElements('creator', namespace: _dcNamespace)
                .firstOrNull
                ?.innerText
                .trim() ??
            'Unknown';

        // Extract image (media:content or media:thumbnail)
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

        final newsItem = NewsItem(
          title: title,
          description: description,
          link: link,
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
        '✅ Successfully fetched and parsed ${allNews.length} items from $_feedUrl',
      );

      // Sort by date, newest first
      allNews.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return allNews;
    } catch (e) {
      debugPrint('Error fetching Ars Technica feed: $e');
      throw Exception('Could not fetch or parse Ars Technica feed: $e');
    }
  }

  /// Parse different RSS date formats safely
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint(
        '⚠️ Date string was null/empty for Ars Technica. Using DateTime.now().',
      );
      return DateTime.now();
    }
    try {
      // Ars Technica uses RFC-2822 format (e.g., "Tue, 18 Nov 2025 16:32:58 +0000")
      // The 'Z' pattern in DateFormat handles numeric timezones like +0000.
      final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
      return formatter.parse(dateStr.trim());
    } catch (_) {
      try {
        // Fallback for other common formats like RFC-1123 or ISO 8601
        return HttpDate.parse(dateStr.trim());
      } catch (_) {
        debugPrint(
          '⚠️ Failed to parse date "$dateStr" for Ars Technica. Using DateTime.now().',
        );
        return DateTime.now();
      }
    }
  }
}
