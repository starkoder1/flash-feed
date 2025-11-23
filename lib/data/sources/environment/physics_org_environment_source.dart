import 'dart:io';

import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class PhysicsOrgEnvironmentSource {
  // Define constants for XML namespaces to robustly parse the feed
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  // The specific URL for this service
  final String _feedUrl = "https://phys.org/rss-feed/earth-news/environment/";

  /// Fetches and parses the Environment RSS feed.
  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    final Set<String> uniqueLinks = {};

    try {
      // 1. Fetch the data
      final response = await http.get(
        Uri.parse(_feedUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load RSS feed: ${response.statusCode}');
      }

      // 2. Parse the XML string
      final document = xml.XmlDocument.parse(response.body.trim());

      // 3. Find the source name from the channel
      final channel = document.findAllElements('channel').firstOrNull;
      final sourceName =
          _findElementText(channel, 'title') ?? 'Environmental News';

      // 4. Find all <item> elements
      final items = document.findAllElements('item');

      for (final item in items) {
        final newsItem = _parseItem(item, sourceName);

        // Skip if the link is empty or already processed (deduplication)
        if (newsItem.link.isNotEmpty && uniqueLinks.add(newsItem.link)) {
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
      throw Exception('Error fetching feed: $e');
    }
  }

  /// Helper function to parse a single <item> element into a NewsItem.
  NewsItem _parseItem(xml.XmlElement item, String sourceName) {
    // Extract standard RSS tags
    final title = item.getElement('title')?.innerText.trim() ?? 'No Title';
    final description =
        item.getElement('description')?.innerText.trim() ?? 'No Description';
    final link = item.getElement('link')?.innerText.trim() ?? '';
    final pubDate = _parseDate(item.getElement('pubDate')?.innerText);

    // Extract image from <media:thumbnail>
    final mediaThumbnail = item
        .findElements('thumbnail', namespace: _mediaNamespace)
        .firstOrNull;
    final imageUrl = mediaThumbnail?.getAttribute('url') ?? '';

    // This feed does not provide an author per item
    final author =
        item
            .findElements('creator', namespace: _dcNamespace)
            .firstOrNull
            ?.innerText
            .trim() ??
        '';

    return NewsItem(
      title: title,
      description: description,
      link: link,
      imageUrl: imageUrl,
      author: author.isNotEmpty ? author : 'Phys.org',
      publishedAt: pubDate,
      source: 'Phys.org',
      category: 'environment',
    );
  }

  /// Parses RSS date strings safely using the intl package.
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint(
        '⚠️ Date string was null/empty for Phys.org. Using DateTime.now().',
      );
      return DateTime.now();
    }
    try {
      // Format "E, dd MMM yyyy HH:mm:ss zzz" handles "Tue, 18 Nov 2025 11:30:01 EST"
      final formatter = DateFormat("E, dd MMM yyyy HH:mm:ss zzz");
      return formatter.parse(dateStr.trim());
    } catch (_) {
      try {
        // Fallback for other common formats like RFC-1123
        return HttpDate.parse(dateStr.trim());
      } catch (e) {
        debugPrint(
          '⚠️ Failed to parse date "$dateStr" for Phys.org. Using DateTime.now(). Error: $e',
        );
        return DateTime.now();
      }
    }
  }

  /// Safely finds an element and returns its text, or null.
  String? _findElementText(xml.XmlElement? element, String name) {
    if (element == null) return null;
    return element.findAllElements(name).firstOrNull?.innerText.trim();
  }
}
