import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:flash_feed/utils/string_cleaner.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'package:xml/xml.dart';
import 'package:intl/intl.dart'; // Added for DateFormat, as requested

/// Backend service to fetch news from the Ars Technica (Cars) RSS feed
class AutomotiveArsTechnicaSource {
  // Define constants for XML namespaces
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  final List<String> feedUrls = ['https://arstechnica.com/cars/feed/'];

  Future<List<NewsItem>> fetchNews() async {
    List<NewsItem> allNews = [];
    final Set<String> uniqueLinks = {}; // To track unique article URLs

    for (final url in feedUrls) {
      try {
        final items = await _fetchFeed(url);
        debugPrint(
          '✅ Successfully fetched and parsed ${items.length} items from $url',
        );
        // Add only unique items to the list
        for (final item in items) {
          // The 'add' method on a Set returns true if the item was added (is unique)
          if (uniqueLinks.add(item.link)) {
            allNews.add(item);
          }
        }
      } catch (e) {
        debugPrint('❌ Error fetching feed from $url: $e');
      }
    }

    // Sort by date, newest first
    allNews.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return allNews;
  }

  Future<List<NewsItem>> _fetchFeed(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        'Accept': 'application/rss+xml, application/xml, text/xml, */*',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load feed: ${response.statusCode}');
    }

    final body = getBody(response).trim();
    if (body.isEmpty) throw Exception('Empty RSS response from $url');

    final document = XmlDocument.parse(body);

    // Find the <channel> element
    final channelElement =
        document.getElement('channel') ??
        document.getElement('rss')?.getElement('channel');

    if (channelElement == null) {
      throw Exception('Invalid RSS: <channel> tag not found in $url');
    }

    // Get the main source title from the channel
    final sourceTitle =
        channelElement.getElement('title')?.innerText.trim() ?? 'Ars Technica';
    final items = channelElement.findAllElements('item');

    List<NewsItem> newsList = [];

    for (final item in items) {
      // The 'xml' package automatically handles CDATA blocks for innerText
      final title = item.getElement('title')?.innerText.trim() ?? 'No title';
      final link = item.getElement('link')?.innerText.trim() ?? '';

      // Use the simple description, not the full <content:encoded>
      final description =
          item.getElement('description')?.innerText.trim() ?? 'No description';

      final pubDate = _parseDate(item.getElement('pubDate')?.innerText);

      // Get the first category
      final category =
          item.getElement('category')?.innerText.trim() ?? 'General';

      // 👤 Extract author (dc:creator)
      // The text is inside a CDATA, but innerText handles this automatically
      final author =
          item
              .findElements('creator', namespace: _dcNamespace)
              .firstOrNull
              ?.innerText
              .trim() ??
          'Unknown';

      // 🖼 Extract image (media:content or media:thumbnail)
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

      // Add to list using your NewsItem model
      newsList.add(
        NewsItem(
          title: title,
          description: description,
          link: link,
          imageUrl: imageUrl,
          author: author,
          publishedAt: pubDate,
          source: sourceTitle,
          category: 'automotive',
        ),
      );
    }

    return newsList;
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
      // Ars Technica uses RFC-2822 format (e.g., "Mon, 17 Nov 2025 14:32:23 +0000")
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
