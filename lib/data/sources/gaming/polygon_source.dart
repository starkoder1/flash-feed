import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:async';

/// A data source for fetching gaming news from Polygon.
class PolygonGamingNewsSource {
  // Define constants for XML namespaces to robustly parse the feed
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';
  static const String _contentNamespace =
      'http://purl.org/rss/1.0/modules/content/';

  /// Fetches and parses the Polygon Gaming RSS feed.
  /// Returns a List<NewsItem> or throws an exception if it fails.
  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    final Set<String> uniqueLinks = {};

    // URL for the Polygon Gaming feed
    const String rssUrl = "https://www.polygon.com/rss/gaming/index.xml";

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
      final document = xml.XmlDocument.parse(response.body);

      // 3. Find all <item> elements
      final items = document.findAllElements('entry').isNotEmpty
          ? document.findAllElements('entry')
          : document.findAllElements('item');

      // 4. Loop through each <item> and extract data
      for (final item in items) {
        final link =
            item.getElement('link')?.getAttribute('href') ??
            item.getElement('link')?.innerText.trim() ??
            '';

        // Skip if the link is empty or already processed (deduplication)
        if (link.isEmpty || !uniqueLinks.add(link)) {
          continue;
        }

        // Extract data matching the NewsItem model
        final title = item.getElement('title')?.innerText.trim() ?? 'No Title';
        final description =
            item.getElement('description')?.innerText.trim() ?? '';
        final publishedAt = _parseDate(
          item.getElement('published')?.innerText ??
              item.getElement('pubDate')?.innerText,
        );

        // Source is not in the <item>, so we set it from the channel info
        const String source = 'Polygon';

        // Default category
        const String category = 'GAMING';

        // Find author (in 'dc:creator')
        final author =
            item
                .findElements('creator', namespace: _dcNamespace)
                .firstOrNull
                ?.innerText
                .trim() ??
            item.getElement('author')?.getElement('name')?.innerText.trim() ??
            '';

        // --- Image Extraction Logic ---
        String imageUrl = '';

        // 1. Try finding <enclosure> first (Polygon's primary method)
        final enclosure = item.findElements('enclosure').firstOrNull;
        if (enclosure != null) {
          imageUrl = enclosure.getAttribute('url') ?? '';
        }

        // 2. If not found, try <media:content> (common in other feeds)
        if (imageUrl.isEmpty) {
          final mediaContent = item
              .findElements('content', namespace: _mediaNamespace)
              .firstOrNull;
          if (mediaContent != null) {
            imageUrl = mediaContent.getAttribute('url') ?? '';
          }
        }

        // 3. If still not found, parse <content:encoded> (last resort)
        if (imageUrl.isEmpty) {
          final contentEncoded = item
              .findElements('encoded', namespace: _contentNamespace)
              .firstOrNull
              ?.innerText;
          if (contentEncoded != null && contentEncoded.isNotEmpty) {
            final match = RegExp(
              r'<img[^>]+src="([^">]+)"',
            ).firstMatch(contentEncoded);
            if (match != null) {
              imageUrl = match.group(1) ?? '';
            }
          }
        }

        // 5. Create the NewsItem object and add to list
        newsItems.add(
          NewsItem(
            title: title,
            description: description,
            link: link,
            imageUrl: imageUrl,
            author: author.isNotEmpty ? author : source,
            publishedAt: publishedAt,
            source: 'Polygon.com - Gaming',
            category: 'gaming',
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
      debugPrint('❌ Error in PolygonGamingNewsSource.fetchNews: $e');
      // Re-throw the error so the caller can handle it
      throw Exception('Could not fetch or parse Polygon gaming news: $e');
    }
  }

  /// Parses RSS date strings safely using the intl package.
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint(
        '⚠️ Date string was null/empty for Polygon. Using DateTime.now().',
      );
      return DateTime.now();
    }

    final trimmedDate = dateStr.trim();
    try {
      // Format for "Tue, 18 Nov 2025 18:16:52 GMT"
      final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
      return formatter.parse(trimmedDate);
    } catch (e) {
      try {
        // Fallback for ISO 8601 format
        return DateTime.parse(trimmedDate);
      } catch (e2) {
        debugPrint(
          '⚠️ Failed to parse date "$trimmedDate" for Polygon. Using DateTime.now(). Error: $e2',
        );
        return DateTime.now();
      }
    }
  }
}
