import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flash_feed/data/models/news_item.dart'; // Make sure this path is correct

/// Fetches and parses MovieWeb RSS feed dynamically
class MovieWebSource {
  // Define constants for XML namespaces to robustly parse the feed
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  final String feedUrl;

  MovieWebSource([this.feedUrl = 'https://movieweb.com/feed/movie-news/']);

  Future<List<NewsItem>> fetchNews() async {
    try {
      final List<NewsItem> newsList = [];
      final Set<String> uniqueLinks = {};
      final response = await http.get(
        Uri.parse(feedUrl),
        headers: {
          // Use a standard browser User-Agent
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load RSS feed: ${response.statusCode}');
      }

      final body = response.body.trim();
      if (!body.contains('<rss')) {
        debugPrint(
          '❌ Non-XML response. Body starts with: ${body.substring(0, 150)}',
        );
        return [];
      }

      final document = xml.XmlDocument.parse(body);

      // Find the channel element safely
      final channel = document.findAllElements('channel').firstOrNull;
      if (channel == null) {
        throw Exception('Could not find <channel> element in the feed.');
      }

      // Get the main source title from the channel
      final sourceTitle = _getText(channel, 'title', defaultValue: 'MovieWeb');

      final items = channel.findElements('item');
      if (items.isEmpty) {
        debugPrint('⚠️ No <item> tags found in the RSS feed.');
        return [];
      }

      for (final item in items) {
        final link = _getText(item, 'link');
        // Skip if the link is empty or already processed (deduplication)
        if (link.isEmpty || !uniqueLinks.add(link)) {
          continue;
        }

        final title = _getText(item, 'title');
        final description = _getText(item, 'description');
        final pubDate = _parseDate(_getText(item, 'pubDate'));

        // This feed uses <dc:creator> for author
        final author =
            _getText(item, 'creator', namespace: _dcNamespace) ?? sourceTitle;

        // This feed provides multiple categories, we'll take the first one.
        final category = _getText(item, 'category', defaultValue: 'Movie News');

        // This feed uses <enclosure> for the image
        final imageUrl = _parseImageUrl(item);

        newsList.add(
          NewsItem(
            title: title,
            description: description,
            link: link,
            imageUrl: imageUrl,
            author: author,
            publishedAt: pubDate,
            source: sourceTitle,
            category: category,
          ),
        );
      }

      // Sort by newest first
      newsList.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

      debugPrint(
        '✅ Successfully fetched ${newsList.length} articles from $sourceTitle.',
      );
      return newsList;
    } catch (e, stackTrace) {
      debugPrint('❌ Error fetching MovieWeb feed: $e\n$stackTrace');
      // Re-throw so the caller (e.g., a provider) can handle the error state.
      throw Exception('Could not fetch or parse MovieWeb news: $e');
    }
  }

  /// Helper to get text from XML safely
  String _getText(
    xml.XmlElement parent,
    String tag, {
    String? namespace,
    String defaultValue = '',
  }) {
    try {
      final element = parent
          .findElements(tag, namespace: namespace)
          .firstOrNull;
      // .text handles CDATA sections automatically
      return element?.innerText.trim() ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  /// Helper to find image URL from <enclosure> (used by this feed)
  /// or <media:content> (used by other feeds)
  String _parseImageUrl(xml.XmlElement item) {
    // 1. Try <enclosure> first (used by MovieWeb)
    final enclosure = item.findElements('enclosure').firstOrNull;
    if (enclosure != null) {
      final url = enclosure.getAttribute('url');
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }

    // 2. Fallback to <media:content> (used by Yahoo, Reuters)
    final media = item
        .findElements('content', namespace: _mediaNamespace)
        .firstOrNull;
    if (media != null) {
      final url = media.getAttribute('url');
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }

    // 3. No image found
    return '';
  }

  /// Safely parse various date formats
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();

    final trimmedDate = dateStr.trim();
    try {
      // Format for "Tue, 18 Nov 2025 18:06:54 GMT"
      final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
      return formatter.parse(trimmedDate);
    } catch (e) {
      debugPrint(
        '⚠️ Failed to parse date "$trimmedDate" for MovieWeb. Using DateTime.now(). Error: $e',
      );
      return DateTime.now();
    }
  }
}
