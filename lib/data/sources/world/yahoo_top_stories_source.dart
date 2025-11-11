import 'package:flash_feed/data/models/news_item.dart';

import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:http_parser/http_parser.dart';
import 'dart:async';

/// A data source for fetching top news from Yahoo.
class YahooTopNewsSource {
  /// Fetches and parses the main Yahoo News RSS feed.
  /// Returns a List<NewsItem> or throws an exception if it fails.
  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];

    // Updated URL based on your new link
    const String rssUrl = "https://news.yahoo.com/rss";

    try {
      // 1. Make the HTTP request
      final response = await http.get(Uri.parse(rssUrl));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load RSS feed. Status code: ${response.statusCode}',
        );
      }

      // 2. Parse the XML string
      final document = xml.XmlDocument.parse(response.body);

      // 3. Find all <item> elements
      final items = document.findAllElements('item');

      // 4. Loop through each <item> and extract data
      for (final item in items) {
        // Helper to safely get text from an element
        String safeFind(xml.XmlElement el, String tag) {
          return el.findElements(tag).firstOrNull?.text.trim() ?? '';
        }

        // Extract data matching the NewsItem model
        final title = safeFind(item, 'title');
        final description = safeFind(item, 'description');
        final link = safeFind(item, 'link');

        final pubDateString = safeFind(item, 'pubDate');
        DateTime publishedAt;
        try {
          publishedAt = parseHttpDate(pubDateString);
        } catch (e) {
          publishedAt = DateTime.now();
        }

        // Find <source> tag's text, default to 'Yahoo News'
        final source =
            item.findElements('source').firstOrNull?.text ?? 'Yahoo News';

        // Find <category> tag's text, default to 'General'
        final category =
            item.findElements('category').firstOrNull?.text ?? 'General';

        // Find author (often in 'dc:creator')
        final author = safeFind(item, 'dc:creator');

        // Find image URL (in 'media:content' tag)
        final mediaContent = item.findElements('media:content').firstOrNull;
        final imageUrl = mediaContent?.getAttribute('url') ?? '';

        // 5. Create the NewsItem object and add to list
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

      return newsItems;
    } catch (e) {
      print('Error in YahooTopNewsSource.fetchNews: $e');
      // Re-throw the error so the caller can handle it
      throw Exception('Could not fetch or parse Yahoo top news: $e');
    }
  }
}
