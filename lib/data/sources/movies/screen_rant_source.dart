import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flash_feed/data/models/news_item.dart'; // Make sure this path is correct

/// Fetches and parses Screen Rant RSS feed dynamically
class ScreenRantSource {
  final String feedUrl;

  ScreenRantSource([this.feedUrl = 'https://screenrant.com/feed/movie-news/']);

  Future<List<NewsItem>> fetchNews() async {
    try {
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
        throw HttpException('Failed to load RSS feed: ${response.statusCode}');
      }

      final body = response.body.trim();
      if (!body.contains('<rss')) {
        print(
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
      final sourceTitle = _getText(
        channel,
        'title',
        defaultValue: 'Screen Rant',
      );

      final items = channel.findElements('item');
      if (items.isEmpty) {
        print('⚠️ No <item> tags found in the RSS feed.');
        return [];
      }

      final List<NewsItem> newsList = [];

      for (final item in items) {
        final title = _getText(item, 'title');
        final link = _getText(item, 'link');
        final description = _getText(item, 'description');
        final pubDate = _parseDate(_getText(item, 'pubDate'));

        // This feed uses <dc:creator> for author
        final author = _getText(item, 'dc:creator', defaultValue: sourceTitle);

        // This feed provides multiple categories, we'll take the first one
        final category = _getText(item, 'category', defaultValue: 'Movies');

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

      print(
        '✅ Successfully fetched ${newsList.length} articles from $sourceTitle.',
      );
      return newsList;
    } catch (e, stackTrace) {
      print('❌ Error fetching Screen Rant feed: $e');
      print(stackTrace);
      return [];
    }
  }

  /// Helper to get text from XML safely (handles CDATA)
  String _getText(
    xml.XmlElement parent,
    String tag, {
    String defaultValue = '',
  }) {
    try {
      final element = parent.findElements(tag).firstOrNull;
      return element?.text.trim() ?? defaultValue;
    } catch (_) {
      return defaultValue;
    }
  }

  /// Helper to find image URL from <enclosure> (used by this feed)
  /// or <media:content> (fallback)
  String _parseImageUrl(xml.XmlElement item) {
    // 1. Try <enclosure> first (used by Screen Rant)
    final enclosure = item.findElements('enclosure').firstOrNull;
    if (enclosure != null) {
      final url = enclosure.getAttribute('url');
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }

    // 2. Fallback to <media:content>
    final media = item.findElements('media:content').firstOrNull;
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
    try {
      // Try RFC 822 (e.g., "Tue, 11 Nov 2025 17:53:29 GMT")
      return HttpDate.parse(dateStr);
    } catch (_) {
      try {
        // Try RFC 3339 / ISO 8601 (e.g., "2025-10-03T20:36:09Z")
        return DateTime.parse(dateStr).toLocal();
      } catch (_) {
        return DateTime.now();
      }
    }
  }
}
