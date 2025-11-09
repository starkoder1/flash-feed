import 'package:flash_feed/data/models/news_item.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class PhysicsOrgEnvironmentSource {
  // The specific URL for this service
  final String _feedUrl = "https://phys.org/rss-feed/earth-news/environment/";

  /// Fetches and parses the Environment RSS feed.
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
      final sourceName =
          _findElementText(channel, 'title') ?? 'Environmental News';

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
    final description =
        _findElementText(item, 'description') ?? 'No Description';
    final link = _findElementText(item, 'link') ?? '';

    // --- Date Parsing ---
    // This feed uses a named timezone (e.g., "EST")
    // We use the 'intl' package with the "zzz" format
    final pubDateStr = _findElementText(item, 'pubDate');
    DateTime publishedAt;
    try {
      // Format "E, dd MMM yyyy HH:mm:ss zzz"
      // handles "Sun, 02 Nov 2025 07:00:02 EST"
      final format = DateFormat("E, dd MMM yyyy HH:mm:ss zzz");
      publishedAt = pubDateStr != null
          ? format.parse(pubDateStr)
          : DateTime.now();
    } catch (e) {
      print('Date Parse Error for string: "$pubDateStr". Error: $e');
      publishedAt = DateTime.now(); // Fallback
    }

    // --- Image Parsing ---
    // This feed uses <media:thumbnail>
    final mediaThumbnail = item.findElements('media:thumbnail').firstOrNull;
    final imageUrl = mediaThumbnail?.getAttribute('url') ?? '';

    // This feed does not provide an author per item
    final author =
        _findElementText(item, 'author') ??
        _findElementText(item, 'dc:creator') ??
        '';

    return NewsItem(
      title: title,
      description: description,
      link: link,
      imageUrl: imageUrl,
      author: author,
      publishedAt: publishedAt,
      source: 'Phys.org',
      category: 'ENVIRONMENT',
    );
  }

  /// Safely finds an element and returns its text, or null.
  String? _findElementText(xml.XmlElement? element, String name) {
    if (element == null) return null;
    return element.findAllElements(name).firstOrNull?.innerText;
  }
}
