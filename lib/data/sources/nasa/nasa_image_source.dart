import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class NasaImageSource {
  final String feedUrl = "https://www.nasa.gov/feeds/iotd-feed/";

  Future<List<NewsItem>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(feedUrl));

      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');

        return items.map((item) {
          final title = item.getElement('title')?.text ?? 'No title';
          final link = item.getElement('link')?.text ?? '';
          final description = item.getElement('description')?.text ?? '';
          final pubDateStr = item.getElement('pubDate')?.text ?? '';
          final publishedAt = DateTime.tryParse(pubDateStr) ?? DateTime.now();
          final imageUrl =
              item.getElement('enclosure')?.getAttribute('url') ??
              ''; // image from enclosure tag
          final author =
              item.getElement('dc:creator')?.text ?? 'NASA'; // fallback author

          return NewsItem(
            title: title,
            link: link,
            description: description,
            publishedAt: publishedAt,
            imageUrl: imageUrl,
            author: author,
            source: 'NASA',
            category: 'SPACE',
          );
        }).toList();
      } else {
        throw Exception('Failed to load feed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading feed: $e');
    }
  }
}
