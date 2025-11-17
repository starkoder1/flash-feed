import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class NasaTechnologySource {
  // NASA Technology RSS feed URL
  final String feedUrl = "https://www.nasa.gov/technology/feed/";

  /// Fetches and parses RSS feed into List<NewsItem>
  Future<List<NewsItem>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(feedUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to load feed: ${response.statusCode}');
      }

      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');

      List<NewsItem> newsList = [];

      for (var item in items) {
        String getText(String tag) =>
            item.getElement(tag)?.innerText.trim() ?? '';

        // Extract image from <media:content> or inside <content:encoded>
        String imageUrl = '';
        final media = item.findElements('media:content');
        if (media.isNotEmpty && media.first.getAttribute('url') != null) {
          imageUrl = media.first.getAttribute('url')!;
        } else {
          final encoded = item.getElement('content:encoded')?.innerText ?? '';
          final imgMatch = RegExp(
            r'<img[^>]+src="([^">]+)"',
          ).firstMatch(encoded);
          if (imgMatch != null) imageUrl = imgMatch.group(1)!;
        }

        // Extract author
        String author = getText('dc:creator');
        if (author.isEmpty) author = 'NASA';

        // Extract category
        String category = '';
        final categories = item.findElements('category');
        if (categories.isNotEmpty) {
          category = categories.first.innerText;
        }

        // Parse date
        DateTime pubDate = DateTime.now();
        try {
          pubDate = DateTime.parse(
            DateTime.parse(getText('pubDate')).toUtc().toIso8601String(),
          );
        } catch (_) {
          // fallback if parsing fails
        }

        newsList.add(
          NewsItem(
            title: getText('title'),
            description: getText('description'),
            link: getText('link'),
            imageUrl: imageUrl,
            author: author,
            publishedAt: pubDate,
            source: "NASA",
            category: category,
          ),
        );
      }

      return newsList;
    } catch (e) {
      throw Exception('Error fetching feed: $e');
    }
  }
}
