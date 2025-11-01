// File: lib/services/news_service.dart

import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class MedicalExpressSource {
  final String _feedUrl = "https://medicalxpress.com/rss-feed/health-news/";

  /// Fetches and parses the RSS feed into a list of NewsItem objects.
  Future<List<NewsItem>> fetchNews() async {
    try {
      // 1. Fetch the data
      final response = await http.get(Uri.parse(_feedUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to load RSS feed: ${response.statusCode}');
      }

      // 2. Parse the XML string
      final document = xml.XmlDocument.parse(response.body);

      // Find the <rss> element, then the <channel> element inside it.
      final rss = document.findElements('rss').firstOrNull;
      final channel = rss?.findElements('channel').firstOrNull;
      if (channel == null) {
        throw Exception('Invalid RSS feed: missing <channel> element');
      }

      // 3. Find all <item> elements and map them to NewsItem objects
      final newsItems = channel.findElements('item').map((itemElement) {
        return _parseItem(itemElement);
      }).toList();

      return newsItems;
    } catch (e) {
      // In a real app, you'd want more robust error handling
      print('Error fetching news: $e');
      rethrow; // Re-throw the exception to be handled by the UI
    }
  }

  /// Helper function to parse a single <item> element into a NewsItem.
  NewsItem _parseItem(xml.XmlElement item) {
    // Extract data using the helper
    final title = _findElementText(item, 'title') ?? 'No Title';
    final description =
        _findElementText(item, 'description') ?? 'No Description';
    final link = _findElementText(item, 'link') ?? '';
    final category = _findElementText(item, 'category') ?? 'General';
    final pubDateStr = _findElementText(item, 'pubDate');

    // Parse the publication date, defaulting to now if parsing fails
    final publishedAt = DateTime.tryParse(pubDateStr ?? '') ?? DateTime.now();

    // Handle the namespaced <media:thumbnail>
    final mediaThumbnail = item.findElements('media:thumbnail').firstOrNull;
    final imageUrl = mediaThumbnail?.getAttribute('url') ?? '';

    // --- Handling Missing Data ---
    // The RSS feed you provided does NOT contain an <author> tag.
    // We must provide a value for your 'required' model field.
    final author = ''; // Default to empty string

    return NewsItem(
      title: title,
      description: description,
      link: link,
      imageUrl: imageUrl,
      author: author,
      publishedAt: publishedAt,
      source: 'Medical Xpress',
      category: category,
    );
  }

  /// Safely finds an element and returns its text, or null.
  String? _findElementText(xml.XmlElement element, String name) {
    return element.findElements(name).firstOrNull?.innerText;
  }
}

// Helper extension for safety, similar to other source files.
extension _IterableX<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
