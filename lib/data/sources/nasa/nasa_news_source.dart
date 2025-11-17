import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class NasaNewsSource {
  final String feedUrl = "https://www.nasa.gov/news-release/feed/";

  /// Fetches and parses the NASA RSS feed
  Future<List<NewsItem>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(feedUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to load feed (status: ${response.statusCode})');
      }

      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      return items.map((item) {
        // Extract text safely
        String text(String tag) =>
            item.getElement(tag)?.innerText.trim() ?? '';

        // Parse pubDate → DateTime
        DateTime parseDate(String date) {
          try {
            return DateTime.parse(date);
          } catch (_) {
            return DateTime.now();
          }
        }

        // Try to extract image from <media:content> or <content:encoded> if available
        String imageUrl = '';
        final media = item.findElements('media:content').firstOrNull;
        if (media != null && media.getAttribute('url') != null) {
          imageUrl = media.getAttribute('url')!;
        } else {
          final encoded = item.getElement('content:encoded')?.innerText ?? '';
          final imgMatch = RegExp(
            r'<img[^>]+src="([^">]+)"',
          ).firstMatch(encoded);
          if (imgMatch != null) imageUrl = imgMatch.group(1)!;
        }

        return NewsItem(
          title: text('title'),
          description: text('description'),
          link: text('link'),
          imageUrl: imageUrl,
          author: text('dc:creator').isNotEmpty ? text('dc:creator') : 'NASA',
          publishedAt: parseDate(text('pubDate')),
          source: 'NASA',
          category: 'SPACE',
        );
      }).toList();
    } catch (e) {
      throw Exception('Error fetching feed: $e');
    }
  }
}
