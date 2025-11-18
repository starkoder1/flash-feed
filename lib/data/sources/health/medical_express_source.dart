import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:io';

class MedicalExpressSource {
  // Define constants for XML namespaces to robustly parse the feed
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  final String _feedUrl = "https://medicalxpress.com/rss-feed/health-news/";

  /// Fetches and parses the RSS feed into a list of NewsItem objects.
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

      // 3. Find all <item> elements
      final items = document.findAllElements('item');

      for (final item in items) {
        final link = item.getElement('link')?.innerText.trim() ?? '';

        // Skip if the link is empty or already processed (deduplication)
        if (link.isEmpty || !uniqueLinks.add(link)) {
          continue;
        }

        final newsItem = _parseItem(item);
        newsItems.add(newsItem);
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
  NewsItem _parseItem(xml.XmlElement item) {
    // Extract data using the helper
    final title = item.getElement('title')?.innerText.trim() ?? 'No Title';
    final description =
        item.getElement('description')?.innerText.trim() ?? 'No Description';
    final link = item.getElement('link')?.innerText.trim() ?? '';
    final publishedAt = _parseDate(item.getElement('pubDate')?.innerText);

    // Handle the namespaced <media:thumbnail>
    final mediaThumbnail = item
        .findElements('thumbnail', namespace: _mediaNamespace)
        .firstOrNull;
    final imageUrl = mediaThumbnail?.getAttribute('url') ?? '';

    return NewsItem(
      title: title,
      description: description,
      link: link,
      imageUrl: imageUrl,
      author: 'Medical Xpress', // This feed does not provide an author
      publishedAt: publishedAt,
      source: 'Medical Xpress',
      category: 'HEALTH',
    );
  }

  /// Parses RSS date strings safely using the intl package.
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint(
        '⚠️ Date string was null/empty for Medical Xpress. Using DateTime.now().',
      );
      return DateTime.now();
    }
    try {
      // Format "E, dd MMM yyyy HH:mm:ss zzz" handles "Tue, 18 Nov 2025 13:22:03 EST"
      final formatter = DateFormat("E, dd MMM yyyy HH:mm:ss zzz");
      return formatter.parse(dateStr.trim());
    } catch (e) {
      debugPrint(
        '⚠️ Failed to parse date "$dateStr" for Medical Xpress. Using DateTime.now(). Error: $e',
      );
      return DateTime.now();
    }
  }
}
