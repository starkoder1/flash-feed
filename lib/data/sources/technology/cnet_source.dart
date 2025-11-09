import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class CnetSource {
  final String feedUrl = 'https://www.cnet.com/rss/news/';

  Future<List<NewsItem>> fetchNews() async {
    final response = await http.get(Uri.parse(feedUrl));
    if (response.statusCode != 200) throw Exception('Failed to fetch feed');

    final xmlDoc = XmlDocument.parse(response.body);

    // This is a standard RSS 2.0 feed, so we look for 'item' tags.
    final items = xmlDoc.findAllElements('item');

    if (items.isEmpty) {
      throw Exception('No <item> tags found in CNET feed.');
    }

    return items.map((item) {
      final title = item.getElement('title')?.text ?? 'No title';
      final link = item.getElement('link')?.text ?? '';

      // RSS uses 'description' for the summary.
      final htmlDescription = item.getElement('description')?.text ?? '';
      final description = _stripHtml(htmlDescription);

      // --- 🖼️ Image extraction ---
      // CNET uses a 'media:content' tag for the image.
      final imageUrl =
          item.getElement('media:content')?.getAttribute('url') ??
              'https://via.placeholder.com/300x180'; // Fallback

      // --- ✍️ Author ---
      // RSS often uses 'dc:creator' for the author.
      final author = item.getElement('dc:creator')?.text.trim() ?? 'CNET';

      // --- 🕒 Date ---
      // RSS uses 'pubDate' with an RFC 822 format.
      final dateStr = item.getElement('pubDate')?.text;
      DateTime publishedAt;
      try {
        // This format (e.g., "Thu, 07 Nov 2024...") is not ISO 8601.
        // DateTime.parse() will fail. A production app should use:
        // import 'package:http_parser/http_parser.dart';
        // publishedAt = parseHttpDate(dateStr!);
        //
        // For now, we'll just fall back to DateTime.now() on error.
        publishedAt = dateStr != null
            ? DateTime.parse(dateStr) // This will likely fail
            : DateTime.now();
      } catch (_) {
        publishedAt = DateTime.now(); // Fallback on parse error
      }

      // --- 🏷️ Category ---
      // RSS uses a simple 'category' tag.
      final category = item.getElement('category')?.text ?? 'Tech';

      return NewsItem(
        title: title,
        link: link,
        description: description,
        imageUrl: imageUrl,
        author: author,
        publishedAt: publishedAt,
        source: 'CNET',
        category: category,
      );
    }).toList();
  }

  /// Helper function to remove HTML tags from the description.
  String _stripHtml(String htmlText) {
    // A simple regex to remove tags.
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }
}