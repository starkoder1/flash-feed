import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

/// Backend service to fetch and merge multiple RSS feeds from CNET dynamically
class AutomotiveCnetSource {
  // 👇 FIX: Define constants for XML namespaces to parse tags like <dc:creator>
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  // 👇 FIX: Updated URLs (original ones were 301 redirects)
  final List<String> feedUrls = [
    'http://feed.cnet.com/feed/roadshow/cartech',
    'http://feed.cnet.com/feed/roadshow/news',
  ];

  Future<List<NewsItem>> fetchNews() async {
    List<NewsItem> allNews = [];

    for (final url in feedUrls) {
      try {
        final items = await _fetchFeed(url);
        allNews.addAll(items);
      } catch (e) {
        print('❌ Error fetching feed from $url: $e');
      }
    }

    allNews.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    return allNews;
  }

  Future<List<NewsItem>> _fetchFeed(String url) async {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
        'Accept': 'application/rss+xml, application/xml, text/xml, */*',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load feed: ${response.statusCode}');
    }

    final body = response.body.trim();

    if (body.isEmpty) throw Exception('Empty RSS response from $url');

    final document = XmlDocument.parse(body);

    // 👇 FIX: Find the <channel> element robustly. All items are inside this.
    final channelElement =
        document.getElement('channel') ??
        document.getElement('rss')?.getElement('channel');

    if (channelElement == null) {
      throw Exception('Invalid RSS: <channel> tag not found in $url');
    }

    // 👇 FIX: Get title and items from the <channel> element, not the whole document.
    final sourceTitle =
        channelElement.getElement('title')?.innerText.trim() ?? 'CNET';
    final items = channelElement.findAllElements('item');

    List<NewsItem> newsList = [];

    for (final item in items) {
      final title = item.getElement('title')?.innerText.trim() ?? 'No title';
      final description =
          item.getElement('description')?.innerText.trim() ?? 'No description';
      final link = item.getElement('link')?.innerText.trim() ?? '';
      final pubDate = _parseDate(item.getElement('pubDate')?.innerText);
      final category =
          item.getElement('category')?.innerText.trim() ?? 'General';

      // 👇 FIX: Use namespace-aware search to robustly find the author.
      final author =
          item
              .findElements('creator', namespace: _dcNamespace)
              .firstOrNull
              ?.innerText
              .trim() ??
          item.getElement('dc:creator')?.innerText.trim() ?? // Fallback
          'Unknown';

      // 👇 FIX: Use namespace-aware search to robustly find media elements.
      String imageUrl = '';
      final mediaContentEl =
          item
              .findElements('content', namespace: _mediaNamespace)
              .firstOrNull ??
          item.findElements('media:content').firstOrNull; // Fallback

      final mediaThumbnailEl =
          item
              .findElements('thumbnail', namespace: _mediaNamespace)
              .firstOrNull ??
          item.findElements('media:thumbnail').firstOrNull; // Fallback

      // Prioritize media:content, then media:thumbnail
      imageUrl =
          mediaContentEl?.getAttribute('url') ??
          mediaThumbnailEl?.getAttribute('url') ??
          '';

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

    return newsList;
  }

  /// Parse different RSS date formats safely
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      // HttpDate.parse is great for RFC-1123 dates (e.g., "Tue, 03 Jun 2008 11:05:30 GMT")
      return HttpDate.parse(dateStr);
    } catch (_) {
      try {
        // Fallback for ISO 8601 dates (e.g., "2008-06-03T11:05:30Z")
        return DateTime.parse(dateStr);
      } catch (_) {
        // If all parsing fails, return now
        return DateTime.now();
      }
    }
  }
}
