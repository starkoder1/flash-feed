import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'dart:async';

class YahooScienceSource {
  // Define the MRSS namespace to correctly parse 'media:content' tags.
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';

  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    const String rssUrl = "https://news.yahoo.com/rss/science";

    try {
      // 1. Fetch RSS feed
      final response = await http.get(Uri.parse(rssUrl));
      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load RSS feed. Status code: ${response.statusCode}',
        );
      }

      // 2. Parse XML
      final document = xml.XmlDocument.parse(response.body);

      // 3. Get all <item> elements
      final items = document.findAllElements('item');

      for (final item in items) {
        // helper to safely find a tag
        String getText(String tag) {
          final element = item.findElements(tag).isNotEmpty
              ? item.findElements(tag).first
              : null;
          return element?.text.trim() ?? '';
        }

        String getNamespacedText(String tag) {
          final element = item.findAllElements(tag, namespace: '*').isNotEmpty
              ? item.findAllElements(tag, namespace: '*').first
              : null;
          return element?.text.trim() ?? '';
        }

        String getMediaUrl() {
          // Use the correct namespace to find the 'content' element.
          final mediaContent = item
              .findElements('content', namespace: _mediaNamespace)
              .firstOrNull;
          return mediaContent?.getAttribute('url') ?? '';
        }

        final title = getText('title');
        final description = getText('description');
        final link = getText('link');
        final source = getText('source').isNotEmpty
            ? getText('source')
            : 'Yahoo News';
        final category = getText('category').isNotEmpty
            ? getText('category')
            : 'Science';
        final author = getNamespacedText('creator'); // handles dc:creator
        final imageUrl = getMediaUrl();

        // Parse date
        final pubDateString = getText('pubDate');
        DateTime publishedAt;
        try {
          publishedAt = DateTime.parse(pubDateString);
        } catch (_) {
          publishedAt = DateTime.now();
        }

        // Only add if title and link exist
        if (title.isNotEmpty && link.isNotEmpty) {
          newsItems.add(
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
      }

      if (newsItems.isEmpty) {
        print("⚠️ No news items found in feed.");
      }

      return newsItems;
    } catch (e) {
      print('❌ Error in fetchNews: $e');
      throw Exception('Could not fetch or parse news: $e');
    }
  }
}

// Helper extension to safely get the first element or null.
extension _IterableX<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
