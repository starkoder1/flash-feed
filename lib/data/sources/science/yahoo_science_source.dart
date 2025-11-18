import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:async';

class YahooScienceSource {
  // Define constants for XML namespaces
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    final Set<String> uniqueLinks = {}; // To track unique article URLs
    const String rssUrl = "https://news.yahoo.com/rss/science";

    try {
      // 1. Fetch RSS feed
      final response = await http.get(
        Uri.parse(rssUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load RSS feed. Status code: ${response.statusCode}',
        );
      }

      // 2. Parse XML
      final body = response.body.trim();
      if (body.isEmpty) throw Exception('Empty RSS response from $rssUrl');

      final document = xml.XmlDocument.parse(body);
      final channel = document.findAllElements('channel').firstOrNull;
      final sourceName = _findElementText(channel, 'title') ?? 'Yahoo Science';

      // 3. Get all <item> elements
      final items = document.findAllElements('item');

      for (final item in items) {
        final newsItem = _parseItem(item, sourceName);
        // Add to list only if the link is unique
        if (uniqueLinks.add(newsItem.link)) {
          newsItems.add(newsItem);
        }
      }

      debugPrint(
        '✅ Successfully fetched and parsed ${newsItems.length} items from $rssUrl',
      );

      // Sort by date, newest first
      newsItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return newsItems;
    } catch (e) {
      debugPrint('❌ Error in YahooScienceSource.fetchNews: $e');
      throw Exception('Could not fetch or parse news: $e');
    }
  }

  /// Helper function to parse a single <item> element into a NewsItem.
  NewsItem _parseItem(xml.XmlElement item, String sourceName) {
    final title = _findElementText(item, 'title') ?? 'No title';
    final description =
        _findElementText(item, 'description') ?? 'No description';
    final link = _findElementText(item, 'link') ?? '';
    final category = _findElementText(item, 'category') ?? 'Science';

    final pubDateStr = _findElementText(item, 'pubDate');
    final publishedAt = _parseDate(pubDateStr);

    final author =
        _findElementText(item, 'creator', namespace: _dcNamespace) ?? '';

    final mediaContent = item
        .findElements('content', namespace: _mediaNamespace)
        .firstOrNull;
    final imageUrl = mediaContent?.getAttribute('url') ?? '';

    return NewsItem(
      title: title,
      description: description,
      link: link,
      imageUrl: imageUrl,
      author: author,
      publishedAt: publishedAt,
      source: sourceName,
      category: category,
    );
  }

  /// Safely finds an element and returns its text, or null.
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

  /// Parse different RSS date formats safely
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint(
        '⚠️ Date string was null/empty for Yahoo Science. Using DateTime.now().',
      );
      return DateTime.now();
    }
    try {
      // Handles ISO 8601 format like "2025-11-18T17:19:44Z"
      return DateTime.parse(dateStr.trim());
    } catch (_) {
      try {
        // Fallback for RFC formats like "Tue, 18 Nov 2025 13:27:54 -0500"
        return HttpDate.parse(dateStr.trim());
      } catch (_) {
        debugPrint(
          '⚠️ Failed to parse date "$dateStr" for Yahoo Science. Using DateTime.now().',
        );
        return DateTime.now();
      }
    }
  }
}
