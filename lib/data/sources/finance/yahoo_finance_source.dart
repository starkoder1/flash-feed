import 'dart:io';

import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;

/// A data source for fetching finance news from Yahoo.
class YahooFinanceNewsSource {
  // Define constants for XML namespaces to robustly parse the feed
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  /// Fetches and parses the Yahoo Finance RSS feed.
  /// Returns a List NewsItem or throws an exception if it fails.
  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    final Set<String> uniqueLinks = {};

    // URL for the Finance feed
    const String rssUrl = "https://finance.yahoo.com/news/rss";

    try {
      // 1. Make the HTTP request
      final response = await http.get(
        Uri.parse(rssUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load RSS feed. Status code: ${response.statusCode}',
        );
      }

      // 2. Parse the XML string
      final document = xml.XmlDocument.parse(response.body.trim());

      // 3. Find all <item> elements
      final items = document.findAllElements('item');

      // 4. Loop through each <item> and extract data
      for (final item in items) {
        final link = item.getElement('link')?.innerText.trim() ?? '';

        // Skip if the link is empty or already processed (deduplication)
        if (link.isEmpty || !uniqueLinks.add(link)) {
          continue;
        }

        // Extract data matching the NewsItem model
        final title = item.getElement('title')?.innerText.trim() ?? 'No Title';
        final description =
            item.getElement('description')?.innerText.trim() ?? '';
        final publishedAt = _parseDate(item.getElement('pubDate')?.innerText);

        // Find <source> tag's text, default to 'Yahoo Finance'
        final source =
            item.getElement('source')?.innerText.trim() ?? 'Yahoo Finance';

        // Find <category> tag's text, default to 'Finance'
        final category =
            item.getElement('category')?.innerText.trim() ?? 'Finance';

        // Find author (often in 'dc:creator')
        final author =
            item
                .findElements('creator', namespace: _dcNamespace)
                .firstOrNull
                ?.innerText
                .trim() ??
            '';

        // Find image URL (in 'media:content' tag)
        final mediaContent = item
            .findElements('content', namespace: _mediaNamespace)
            .firstOrNull;
        final imageUrl = mediaContent?.getAttribute('url') ?? '';

        // 5. Create the NewsItem object and add to list
        newsItems.add(
          NewsItem(
            title: title,
            description: description,
            link: link,
            imageUrl: imageUrl,
            author: author.isNotEmpty ? author : source,
            publishedAt: publishedAt,
            source: 'Yahoo Finance',
            category: 'finance',
          ),
        );
      }
      debugPrint(
        '✅ Successfully fetched and parsed ${newsItems.length} items from $rssUrl',
      );
      // Sort by date, newest first
      newsItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return newsItems;
    } catch (e) {
      debugPrint('❌ Error in YahooFinanceNewsSource.fetchNews: $e');
      // Re-throw the error so the caller can handle it
      throw Exception('Could not fetch or parse Yahoo finance news: $e');
    }
  }

  /// Parses RSS date strings safely using the intl package.
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint(
        '⚠️ Date string was null/empty for Yahoo Finance. Using DateTime.now().',
      );
      return DateTime.now();
    }

    final trimmedDate = dateStr.trim();

    try {
      // Try ISO 8601 format first (e.g., "2025-11-18T17:40:19Z")
      // This is the most common format in the <item> tags.
      return DateTime.parse(trimmedDate);
    } catch (e) {
      try {
        // Fallback to RFC-1123 format (e.g., "Tue, 18 Nov 2025 12:43:11 -0500")
        final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
        return formatter.parse(trimmedDate);
      } catch (e) {
        debugPrint(
          '⚠️ Failed to parse date "$trimmedDate" for Yahoo Finance. Using DateTime.now(). Error: $e',
        );
        return DateTime.now();
      }
    }
  }
}
