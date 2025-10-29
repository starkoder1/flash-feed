import 'package:flash_feed/data/models/news_item.dart';
import 'package:xml/xml.dart';
import 'package:http/http.dart' as http;

class CnetSource {
  final String feedUrl = 'https://feed.cnet.com/feed/news';

  Future<List<NewsItem>> fetchNews() async {
    final response = await http.get(Uri.parse(feedUrl));
    if (response.statusCode != 200) throw Exception('Failed to fetch feed');

    final xmlDoc = XmlDocument.parse(response.body);
    final items = xmlDoc.findAllElements('item');

    return items.map((item) {
      final title = item.getElement('title')?.text ?? 'No title';
      final link = item.getElement('link')?.text ?? '';
      final description = item.getElement('description')?.text ?? '';

      // --- 🖼️ Image extraction ---
      final thumbnail = item
          .findElements('thumbnail', namespace: 'http://search.yahoo.com/mrss/')
          .map((e) => e.getAttribute('url'))
          .firstWhere((url) => url != null, orElse: () => null);

      final mediaContent = item
          .findElements('content', namespace: 'http://search.yahoo.com/mrss/')
          .map((e) => e.getAttribute('url'))
          .firstWhere((url) => url != null, orElse: () => null);

      final imageUrl =
          thumbnail ?? mediaContent ?? 'https://via.placeholder.com/300x180';

      // --- ✍️ Author ---
      final author = item
          .findElements('creator', namespace: 'http://purl.org/dc/elements/1.1/')
          .map((e) => e.text)
          .firstWhere((text) => text.isNotEmpty, orElse: () => '');

      // --- 🕒 Date ---
      final pubDateStr = item.getElement('pubDate')?.text;
      DateTime publishedAt;
      try {
        publishedAt =
            pubDateStr != null ? DateTime.parse(pubDateStr) : DateTime.now();
      } catch (_) {
        publishedAt = DateTime.now();
      }

      // --- 🏷️ Extract category from URL ---
      // Example link: https://www.cnet.com/tech/mobile/some-article/
      String category = 'General';
      try {
        final uri = Uri.parse(link);
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          // usually category is first part like 'tech', 'science', etc.
          category = segments.first;
        }
      } catch (_) {}

      return NewsItem(
        title: title,
        link: link,
        description: description,
        imageUrl: imageUrl,
        author: author,
        publishedAt: publishedAt,
        source: 'CNET',
        category: category, // ✅ include category here
      );
    }).toList();
  }
}
