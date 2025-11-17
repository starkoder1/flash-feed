import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class EngadgetSource {
  final String _rssUrl = 'https://www.engadget.com/rss.xml';

  /// Parse RFC 2822 date format used by Engadget RSS feed
  /// Example: "Sun, 16 Nov 2025 20:00:38 +0000"
  DateTime _parseRFC2822Date(String dateString) {
    try {
      // Clean up the date string
      final cleanDate = dateString.trim();

      // Use DateFormat to parse RFC 2822 format
      final formatter = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
      return formatter.parse(cleanDate);
    } catch (e) {
      // Fallback: try alternative formats or return current time
      try {
        // Try without timezone
        final formatter2 = DateFormat('EEE, dd MMM yyyy HH:mm:ss');
        final withoutTz = dateString.replaceAll(RegExp(r'\s+[+-]\d{4}$'), '');
        return formatter2.parse(withoutTz);
      } catch (e2) {
        print('Failed to parse date: $dateString, error: $e2');
        return DateTime.now();
      }
    }
  }

  Future<List<NewsItem>> fetchNews() async {
    final response = await http.get(Uri.parse(_rssUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch Engadget feed');
    }

    final xmlDoc = XmlDocument.parse(response.body);
    final items = xmlDoc.findAllElements('item');

    if (items.isEmpty) {
      throw Exception('No items found in the RSS feed.');
    }

    return items.map((item) {
      final title = item.getElement('title')?.text.trim() ?? 'No title';
      final link = item.getElement('link')?.text.trim() ?? '';

      // 📝 --- Description Cleaning ---
      String description = item.getElement('description')?.text ?? '';
      // Remove HTML tags
      description = description.replaceAll(RegExp(r'<[^>]+>'), '').trim();
      // Remove Engadget attribution line
      description = description
          .replaceAll(
            RegExp(
              r'This article originally appeared on Engadget.*',
              caseSensitive: false,
            ),
            '',
          )
          .trim();

      // 🖼️ --- Image Extraction (Improved) ---
      String imageUrl = 'https://via.placeholder.com/300x180';

      // Try media:content
      final mediaElement = item.findElements('media:content').firstOrNull;
      if (mediaElement != null) {
        imageUrl = mediaElement.getAttribute('url') ?? imageUrl;
      } else {
        // Try media:thumbnail
        final thumb = item.findElements('media:thumbnail').firstOrNull;
        if (thumb != null) {
          imageUrl = thumb.getAttribute('url') ?? imageUrl;
        } else {
          // Fallback: extract <img src="..."> from description HTML
          final descHtml = item.getElement('description')?.text ?? '';
          final match = RegExp(r'<img[^>]+src="([^">]+)"').firstMatch(descHtml);
          if (match != null) {
            imageUrl = match.group(1)!;
          }
        }
      }

      // ✍️ --- Author ---
      final author =
          item
              .getElement(
                'dc:creator',
                namespace: 'http://purl.org/dc/elements/1.1/',
              )
              ?.text
              .trim() ??
          'Unknown';

      // 🕒 --- Date & Category ---
      final pubDateStr = item.getElement('pubDate')?.text;
      DateTime publishedAt;
      try {
        publishedAt = pubDateStr != null
            ? _parseRFC2822Date(pubDateStr)
            : DateTime.now();
      } catch (e) {
        print('Date parsing error for Engadget: $e, using current time');
        publishedAt = DateTime.now();
      }

      final category = item.getElement('category')?.text.trim() ?? 'Technology';

      // ✅ --- Return NewsItem ---
      return NewsItem(
        title: title,
        link: link,
        description: description,
        imageUrl: imageUrl,
        author: author,
        publishedAt: publishedAt,
        source: 'Engadget',
        category: category,
      );
    }).toList();
  }
}

// 🔧 --- Helper extension for safety ---
extension IterableX<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
