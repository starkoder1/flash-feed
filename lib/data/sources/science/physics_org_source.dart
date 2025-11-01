import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:xml/xml.dart';

class PhysOrgSource {
  final String _rssUrl = 'https://phys.org/rss-feed/';

  Future<List<NewsItem>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(_rssUrl));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch Phys.org feed: ${response.statusCode}',
        );
      }

      final xmlDoc = XmlDocument.parse(response.body);
      final items = xmlDoc.findAllElements('item');

      if (items.isEmpty) {
        throw Exception('No items found in the RSS feed.');
      }

      final List<NewsItem> articles = [];

      for (final item in items) {
        // --- Title ---
        final title = item.getElement('title')?.text.trim() ?? 'No title';

        // --- Link ---
        final link = item.getElement('link')?.text.trim() ?? '';

        // --- Description (cleaned) ---
        String description = item.getElement('description')?.text.trim() ?? '';
        description = description.replaceAll(RegExp(r'<[^>]+>'), '').trim();

        // --- Category ---
        final category = item.getElement('category')?.text.trim() ?? 'Science';

        // --- Published Date ---
        final pubDateStr = item.getElement('pubDate')?.text.trim();
        DateTime publishedAt;
        try {
          publishedAt = pubDateStr != null
              ? parseHttpDate(pubDateStr)
              : DateTime.now();
        } catch (_) {
          publishedAt = DateTime.now();
        }

        // --- Author (dc:creator or fallback) ---
        final creatorElement = item.findElements('dc:creator').firstOrNull;
        final author = creatorElement != null
            ? creatorElement.text.trim()
            : 'Phys.org';

        // --- Image Extraction ---
        String imageUrl = 'https://via.placeholder.com/600x340?text=No+Image';

        // Try media:thumbnail
        final mediaThumb = item.findElements('media:thumbnail').firstOrNull;
        if (mediaThumb != null) {
          imageUrl = mediaThumb.getAttribute('url') ?? imageUrl;
        } else {
          // Try media:content
          final mediaContent = item.findElements('media:content').firstOrNull;
          if (mediaContent != null) {
            imageUrl = mediaContent.getAttribute('url') ?? imageUrl;
          } else {
            // Try to find <img> inside description
            final descHtml = item.getElement('description')?.text ?? '';
            final match = RegExp(
              r'<img[^>]+src="([^">]+)"',
            ).firstMatch(descHtml);
            if (match != null) {
              imageUrl = match.group(1)!;
            }
          }
        }

        // --- Source ---
        const source = 'Phys.org';

        // --- Add to List ---
        articles.add(
          NewsItem(
            title: title,
            description: description,
            link: link,
            imageUrl: imageUrl,
            author: author,
            publishedAt: publishedAt,
            source: source,
            category: category,
          ),
        );
      }

      return articles;
    } catch (e) {
      throw Exception('Error parsing Phys.org RSS feed: $e');
    }
  }
}

// --- Helper Extension ---
extension IterableX<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
