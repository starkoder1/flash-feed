import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

// A new class name for this separate file
class PhysicsOrgSource {
  // The specific URL for this service
  final String _feedUrl = "https://phys.org/rss-feed/space-news/astronomy/";

  /// Fetches and parses the Astronomy RSS feed.
  Future<List<NewsItem>> fetchNews() async {
    try {
      // 1. Fetch the data
      final response = await http.get(Uri.parse(_feedUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to load RSS feed: ${response.statusCode}');
      }

      // 2. Parse the XML string
      final document = xml.XmlDocument.parse(response.body);

      // 3. Find the source name from the channel
      final channel = document.findAllElements('channel').firstOrNull;
      final sourceName = _findElementText(channel, 'title') ?? 'Astronomy News';

      // 4. Find all <item> elements and map them
      final newsItems = document.findAllElements('item').map((itemElement) {
        return _parseItem(itemElement, sourceName);
      }).toList();

      if (newsItems.isEmpty) {
        print('Warning: No <item> elements found in feed $_feedUrl');
      }

      return newsItems;
    } catch (e) {
      print('Error fetching or parsing news from $_feedUrl: $e');
      rethrow;
    }
  }

  /// Helper function to parse a single <item> element into a NewsItem.
  NewsItem _parseItem(xml.XmlElement item, String sourceName) {
    // Extract standard RSS tags
    final title = _findElementText(item, 'title') ?? 'No Title';
    final description = _findElementText(item, 'description') ?? 'No Description';
    final link = _findElementText(item, 'link') ?? '';
    final category = _findElementText(item, 'category')?.trim() ?? 'General';

    // Check for different date formats
    final pubDateStr = _findElementText(item, 'pubDate') ?? _findElementText(item, 'dc:date');
    final publishedAt = DateTime.tryParse(pubDateStr ?? '') ?? DateTime.now();

    // Find the <media:thumbnail> image
    final mediaThumbnail = item.findElements('media:thumbnail').firstOrNull;
    final imageUrl = mediaThumbnail?.getAttribute('url') ?? '';

    // Check for different author formats
    final author = _findElementText(item, 'author') ?? _findElementText(item, 'dc:creator') ?? '';

 

    return NewsItem(
      title: title,
      description: description,
      link: link,
      imageUrl: imageUrl,
      author: author,
      publishedAt: publishedAt,
      source: "Phys.org",
      category: category,
    );
  }

  /// Safely finds an element and returns its text, or null.
  String? _findElementText(xml.XmlElement? element, String name) {
    if (element == null) return null;
    return element.findAllElements(name).firstOrNull?.innerText;
  }
}