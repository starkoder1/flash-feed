import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;

class PhysOrgSource {
  // Define constants for XML namespaces
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';

  final String _rssUrl = 'https://phys.org/rss-feed/';

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
          'Failed to fetch Phys.org feed: ${response.statusCode}',
        );
      }
      final body = response.body.trim();
      if (body.isEmpty) throw Exception('Empty RSS response from $_rssUrl');

      final xmlDoc = xml.XmlDocument.parse(body);
      final channel = xmlDoc.findAllElements('channel').firstOrNull;
      final sourceName =
          _findElementText(channel, 'title') ?? 'Phys.org Science';

      final items = xmlDoc.findAllElements('item');

      for (final item in items) {
        final newsItem = _parseItem(item, sourceName);
        // Add to list only if the link is unique
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
      debugPrint('❌ Error fetching or parsing news from $_rssUrl: $e');
      throw Exception('Could not fetch or parse Phys.org feed: $e');
    }
  }

  /// Helper function to parse a single <item> element into a NewsItem.
  NewsItem _parseItem(xml.XmlElement item, String sourceName) {
    final title = _findElementText(item, 'title') ?? 'No title';
    final description =
        _findElementText(item, 'description') ?? 'No description';
    final link = _findElementText(item, 'link') ?? '';
    final category = _findElementText(item, 'category')?.trim() ?? 'Science';

    final pubDateStr = _findElementText(item, 'pubDate');
    final publishedAt = _parseDate(pubDateStr);

    // Find the <media:thumbnail> image
    final mediaThumbnail = item
        .findElements('thumbnail', namespace: _mediaNamespace)
        .firstOrNull;
    final imageUrl = mediaThumbnail?.getAttribute('url') ?? '';

    // Check for different author formats
    final author =
        _findElementText(item, 'author') ??
        _findElementText(item, 'creator', namespace: _dcNamespace) ??
        '';

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
        '⚠️ Date string was null/empty for Phys.org. Using DateTime.now().',
      );
      return DateTime.now();
    }
    try {
      // Format: "Tue, 18 Nov 2025 13:29:37 EST"
      // 'z' handles named time zones like EST.
      final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss z');
      return formatter.parse(dateStr.trim());
    } catch (_) {
      try {
        // Fallback for other common formats
        return HttpDate.parse(dateStr.trim());
      } catch (_) {
        debugPrint(
          '⚠️ Failed to parse date "$dateStr" for Phys.org. Using DateTime.now().',
        );
        return DateTime.now();
      }
    }
  }
}
