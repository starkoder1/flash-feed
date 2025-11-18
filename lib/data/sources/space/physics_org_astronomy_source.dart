import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;

// A new class name for this separate file
class PhysicsOrgAstronomySource {
  // Define constants for XML namespaces
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';

  // The specific URL for this service
  final String _feedUrl = "https://phys.org/rss-feed/space-news/astronomy/";

  /// Fetches and parses the Astronomy RSS feed.
  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    final Set<String> uniqueLinks = {}; // To track unique article URLs

    try {
      // 1. Fetch the data
      final response = await http.get(
        Uri.parse(_feedUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load RSS feed: ${response.statusCode}');
      }

      // 2. Parse the XML string
      final body = response.body.trim();
      if (body.isEmpty) throw Exception('Empty RSS response from $_feedUrl');

      final document = xml.XmlDocument.parse(body);

      // 3. Find the source name from the channel
      final channel = document.findAllElements('channel').firstOrNull;
      final sourceName =
          _findElementText(channel, 'title') ?? 'Phys.org Astronomy';

      // 4. Find all <item> elements and map them
      final items = document.findAllElements('item');

      for (final item in items) {
        final newsItem = _parseItem(item, sourceName);
        // Add to list only if the link is unique
        if (uniqueLinks.add(newsItem.link)) {
          newsItems.add(newsItem);
        }
      }

      debugPrint(
        '✅ Successfully fetched and parsed ${newsItems.length} items from $_feedUrl',
      );

      // Sort by date, newest first
      newsItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return newsItems;
    } catch (e) {
      debugPrint('❌ Error fetching or parsing news from $_feedUrl: $e');
      rethrow;
    }
  }

  /// Helper function to parse a single <item> element into a NewsItem.
  NewsItem _parseItem(xml.XmlElement item, String sourceName) {
    final title = _findElementText(item, 'title') ?? 'No title';
    final description =
        _findElementText(item, 'description') ?? 'No description';
    final link = _findElementText(item, 'link') ?? '';
    final category = _findElementText(item, 'category')?.trim() ?? 'Astronomy';

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
      // Format: "Tue, 18 Nov 2025 13:12:05 EST"
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
