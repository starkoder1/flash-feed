import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:intl/intl.dart';
import 'dart:async';

/// A data source for fetching world news from Yahoo.
class YahooWorldNewsSource {
  // Define constants for XML namespaces
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  /// Fetches and parses the Yahoo World News RSS feed.
  /// Returns a List of NewsItem or throws an exception if it fails.
  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    final Set<String> uniqueLinks = {}; // To track unique article URLs

    // URL for the World News feed
    const String rssUrl = "https://news.yahoo.com/rss/world";

    try {
      // 1. Make the HTTP request
      final response = await http.get(
        Uri.parse(rssUrl),
        headers: {'User-Agent': 'FlashFeed/1.0'},
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load RSS feed. Status code: ${response.statusCode}',
        );
      }

      // 2. Parse the XML string
      final body = response.body.trim();
      if (body.isEmpty) {
        throw Exception('Empty RSS response from $rssUrl');
      }

      final document = xml.XmlDocument.parse(body);

      // 3. Find all <item> elements
      final items = document.findAllElements('item');

      // 4. Loop through each <item> and extract data
      for (final item in items) {
        // Helper to safely get text from an element
        String safeFind(xml.XmlElement el, String tag) {
          return el.findElements(tag).firstOrNull?.text.trim() ?? '';
        }

        // Extract data matching the NewsItem model
        final title = safeFind(item, 'title');
        final description = safeFind(item, 'description');
        final link = safeFind(item, 'link');

        final publishedAt = _parseDate(safeFind(item, 'pubDate'));

        // Find <source> tag's text, default to 'Yahoo News'
        final source =
            item.findElements('source').firstOrNull?.text ?? 'Yahoo News';

        // Find <category> tag's text, default to 'World'
        final category =
            item.findElements('category').firstOrNull?.text ?? 'World';

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
        final newsItem = NewsItem(
          title: title,
          description: description,
          link: link,
          imageUrl: imageUrl,
          author: author,
          publishedAt: publishedAt,
          source: source,
          category: category,
        );

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
      debugPrint('❌ Error in YahooWorldNewsSource.fetchNews: $e');
      // Re-throw the error so the caller can handle it
      throw Exception('Could not fetch or parse Yahoo world news: $e');
    }
  }

  /// Parse different RSS date formats safely
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint(
        '⚠️ Date string was null/empty for Yahoo World News. Using DateTime.now().',
      );
      return DateTime.now();
    }
    try {
      // Yahoo often uses ISO 8601 (e.g., "2025-11-17T15:26:48Z")
      // DateTime.parse handles this format directly.
      return DateTime.parse(dateStr.trim());
    } catch (_) {
      try {
        // Fallback for other common formats like RFC-1123/RFC-2822
        // (e.g., "Tue, 18 Nov 2025 12:28:41 -0500")
        // The 'Z' pattern in DateFormat handles numeric timezones like -0500.
        final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
        return formatter.parse(dateStr.trim());
      } catch (e) {
        try {
          // Second fallback using the more general HttpDate parser
          return HttpDate.parse(dateStr.trim());
        } catch (_) {
          debugPrint(
            '⚠️ Failed to parse date "$dateStr" for Yahoo World News. Using DateTime.now().',
          );
          return DateTime.now();
        }
      }
    }
  }
}
