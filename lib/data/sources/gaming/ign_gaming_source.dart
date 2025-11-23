import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:async';

/// A data source for fetching gaming news from IGN.
class IgnGamesNewsSource {
  // Define constants for XML namespaces to robustly parse the feed
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';
  static const String _contentNamespace =
      'http://purl.org/rss/1.0/modules/content/';

  /// Fetches and parses the IGN Games RSS feed.
  /// Returns a List<NewsItem> or throws an exception if it fails.
  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    final Set<String> uniqueLinks = {};

    // URL for the IGN Games feed
    const String rssUrl = "https://feeds.feedburner.com/ign/games-all";

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

        // Source is not in the <item>, so we set it from the channel info
        const String source = 'IGN.com';

        // Find <category> tag's text, default to 'Games'
        // IGN feed doesn't seem to have <category> per item, so we'll default
        const String category = 'GAMING';

        // Find author (in 'dc:creator')
        final author =
            item
                .findElements('creator', namespace: _dcNamespace)
                .firstOrNull
                ?.innerText
                .trim() ??
            '';

        // --- Image Extraction Logic ---
        String imageUrl = '';

        // 1. Try finding <media:content> first (best quality)
        final mediaContent = item
            .findElements('content', namespace: _mediaNamespace)
            .firstOrNull;
        if (mediaContent != null) {
          imageUrl = mediaContent.getAttribute('url') ?? '';
        }

        // 2. If not found, try <media:thumbnail>
        if (imageUrl.isEmpty) {
          final mediaThumbnail = item
              .findElements('thumbnail', namespace: _mediaNamespace)
              .firstOrNull;
          if (mediaThumbnail != null) {
            imageUrl =
                mediaThumbnail.getAttribute('url') ??
                mediaThumbnail.innerText.trim();
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
        // --- END OF MODIFIED LOGIC ---

        // 5. Create the NewsItem object and add to list
        newsItems.add(
          NewsItem(
            title: title,
            description: description,
            link: link,
            imageUrl: imageUrl,
            author: author.isNotEmpty ? author : source,
            publishedAt: publishedAt,
            source: source,
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
      debugPrint('❌ Error in IgnGamesNewsSource.fetchNews: $e');
      // Re-throw the error so the caller can handle it
      throw Exception('Could not fetch or parse IGN games news: $e');
    }
  }

  /// Parses RSS date strings safely using the intl package.
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint(
        '⚠️ Date string was null/empty for IGN. Using DateTime.now().',
      );
      return DateTime.now();
    }

    final trimmedDate = dateStr.trim();
    try {
      // Format for "Tue, 18 Nov 2025 17:08:58 +0000"
      final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
      return formatter.parse(trimmedDate);
    } catch (e) {
      debugPrint(
        '⚠️ Failed to parse date "$trimmedDate" for IGN. Using DateTime.now(). Error: $e',
      );
      return DateTime.now();
    }
  }
}
