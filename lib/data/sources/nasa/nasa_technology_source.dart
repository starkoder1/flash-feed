// We need these new imports for date parsing, debugging, and HttpDate
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:flash_feed/utils/string_cleaner.dart';
import 'package:xml/xml.dart' as xml;

class NasaTechnologySource {
  // Define constants for XML namespaces for consistency and readability
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';
  static const String _contentNamespace =
      'http://purl.org/rss/1.0/modules/content/';

  // NASA Technology RSS feed URL
  final String _feedUrl = "https://www.nasa.gov/technology/feed/";

  /// Fetches and parses RSS feed into List<NewsItem>
  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    final Set<String> uniqueLinks = {}; // To track unique article URLs

    try {
      // Fetch the data with appropriate headers
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
          'Failed to load NASA Technology feed: ${response.statusCode}',
        );
      }

      final body = getBody(response).trim();
      if (body.isEmpty) throw Exception('Empty RSS response from $_feedUrl');

      final document = xml.XmlDocument.parse(body);

      // Extract channel info
      final channel = document.findAllElements('channel').firstOrNull;
      final sourceName =
          _findElementText(channel, 'title') ?? 'NASA Technology';

      // Parse all items
      final items = document.findAllElements('item');

      for (final item in items) {
        final newsItem = _parseItem(item, sourceName);
        if (uniqueLinks.add(newsItem.link)) {
          newsItems.add(newsItem);
        }
      }

      debugPrint(
        '✅ Successfully fetched and parsed ${newsItems.length} items from $_feedUrl',
      );

      // Sort newest first
      newsItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      return newsItems;
    } catch (e) {
      debugPrint('❌ Error fetching or parsing NASA feed: $e');
      throw Exception('Could not fetch or parse NASA Technology feed: $e');
    }
  }

  /// Parse <item> into NewsItem
  NewsItem _parseItem(xml.XmlElement item, String sourceName) {
    final title = _findElementText(item, 'title') ?? 'No title';
    final link = _findElementText(item, 'link') ?? '';

    final pubDateStr = _findElementText(item, 'pubDate');
    final publishedAt = _parseDate(pubDateStr);

    // Content for description
    final contentEncoded =
        _findElementText(item, 'encoded', namespace: _contentNamespace) ?? '';

    final description = contentEncoded.isNotEmpty
        ? _stripHtml(contentEncoded)
        : _findElementText(item, 'description') ?? 'No description';

    // Extract image (enclosure or fallback)
    final enclosure = item.findElements('enclosure').firstOrNull;
    String imageUrl = enclosure?.getAttribute('url') ?? '';

    if (imageUrl.isEmpty && contentEncoded.isNotEmpty) {
      final imgMatch = RegExp(
        r'<img[^>]+src="([^">]+)"',
      ).firstMatch(contentEncoded);
      if (imgMatch != null) imageUrl = imgMatch.group(1)!;
    }

    final author =
        _findElementText(item, 'creator', namespace: _dcNamespace) ?? 'NASA';
    final category = _findElementText(item, 'category') ?? 'Technology';

    return NewsItem(
      title: title,
      description: description,
      link: link,
      imageUrl: imageUrl,
      author: author,
      publishedAt: publishedAt,
      source: 'Technology - NASA',
      category: 'nasa',
    );
  }

  /// Removes HTML tags
  String _stripHtml(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>', multiLine: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Get text from element
  String? _findElementText(
    xml.XmlElement? element,
    String name, {
    String? namespace,
  }) {
    if (element == null) return null;
    return element
        .findElements(name, namespace: namespace)
        .firstOrNull
        ?.innerText
        .trim();
  }

  /// FIXED — Correct RSS date parsing for NASA feeds
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint('⚠️ Empty date, using now()');
      return DateTime.now();
    }

    // NASA uses: Mon, 17 Nov 2025 18:53:26 +0000
    try {
      final format = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US");
      return format.parse(dateStr.trim());
    } catch (e) {
      debugPrint('⚠️ Intl parse failed for "$dateStr": $e');
    }

    // Fallback #1
    try {
      return DateTime.parse(dateStr.trim());
    } catch (_) {}

    // Fallback #2
    try {
      return HttpDate.parse(dateStr.trim());
    } catch (_) {}

    debugPrint('⚠️ All date parsing failed for "$dateStr". Using now().');
    return DateTime.now();
  }
}
