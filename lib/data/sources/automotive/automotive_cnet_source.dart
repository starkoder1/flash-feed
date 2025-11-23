import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:xml/xml.dart';
import 'package:intl/intl.dart';

/// Backend service to fetch and merge multiple RSS feeds from CNET dynamically
class AutomotiveCnetSource {
  // 👇 FIX: Define constants for XML namespaces to parse tags like <dc:creator>
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  // 👇 FIX: Updated URLs (original ones were 301 redirects)
  final List<String> feedUrls = [
    'http://feed.cnet.com/feed/roadshow/cartech',
    'http://feed.cnet.com/feed/roadshow/news',
  ];

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
          // The 'add' method on a Set returns true if the item was added,
          // and false if it was already present.
          if (uniqueLinks.add(item.link)) {
            allNews.add(item);
          }
        }
      } catch (e) {
        debugPrint('❌ Error fetching feed from $url: $e');
      }
    }

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

    final body = response.body.trim();

    if (body.isEmpty) throw Exception('Empty RSS response from $url');

    final document = XmlDocument.parse(body);

    // 👇 FIX: Find the <channel> element robustly. All items are inside this.
    final channelElement =
        document.getElement('channel') ??
        document.getElement('rss')?.getElement('channel');

    if (channelElement == null) {
      throw Exception('Invalid RSS: <channel> tag not found in $url');
    }

    // 👇 FIX: Get title and items from the <channel> element, not the whole document.
    final sourceTitle =
        channelElement.getElement('title')?.innerText.trim() ?? 'CNET';
    final items = channelElement.findAllElements('item');

    List<NewsItem> newsList = [];

    for (final item in items) {
      final title = item.getElement('title')?.innerText.trim() ?? 'No title';
      final description =
          item.getElement('description')?.innerText.trim() ?? 'No description';
      final link = item.getElement('link')?.innerText.trim() ?? '';
      final pubDate = _parseDate(
        item.getElement('pubDate')?.innerText,
        sourceTitle,
      );
      final category =
          item.getElement('category')?.innerText.trim() ?? 'General';

      // 👇 FIX: Use namespace-aware search to robustly find the author.
      final author =
          item
              .findElements('creator', namespace: _dcNamespace)
              .firstOrNull
              ?.innerText
              .trim() ??
          item.getElement('dc:creator')?.innerText.trim() ?? // Fallback
          'Unknown';

      // 👇 FIX: Use namespace-aware search to robustly find media elements.
      String imageUrl = '';
      final mediaContentEl =
          item
              .findElements('content', namespace: _mediaNamespace)
              .firstOrNull ??
          item.findElements('media:content').firstOrNull; // Fallback

      final mediaThumbnailEl =
          item
              .findElements('thumbnail', namespace: _mediaNamespace)
              .firstOrNull ??
          item.findElements('media:thumbnail').firstOrNull; // Fallback

      // Prioritize media:content, then media:thumbnail
      imageUrl =
          mediaContentEl?.getAttribute('url') ??
          mediaThumbnailEl?.getAttribute('url') ??
          '';

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
  DateTime _parseDate(String? dateStr, String sourceName) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint(
        '⚠️ Date string was null/empty for $sourceName. Using DateTime.now().',
      );
      return DateTime.now();
    }
    try {
      // CNET uses RFC 2822 format (e.g., "Wed, 12 Nov 2025 16:00:00 +0000")
      // The 'Z' pattern in DateFormat handles numeric timezones like +0000.
      final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
      return formatter.parse(dateStr.trim());
    } catch (_) {
      try {
        // Fallback for other common formats
        return HttpDate.parse(dateStr.trim());
      } catch (_) {
        debugPrint(
          '⚠️ Failed to parse date "$dateStr" for $sourceName. Using DateTime.now().',
        );
        return DateTime.now();
      }
    }
  }
}
