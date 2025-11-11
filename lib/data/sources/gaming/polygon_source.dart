import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'dart:async';

// Assuming 'NewsItem' class is defined elsewhere
// import 'news_model.dart'; 

/// A data source for fetching gaming news from Polygon.
class PolygonGamingNewsSource {

  /// Fetches and parses the Polygon Gaming RSS feed.
  /// Returns a List NewsItem or throws an exception if it fails.
   Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    
    // URL for the Polygon Gaming feed
    const String rssUrl = "https://www.polygon.com/rss/gaming/index.xml";

    try {
      // 1. Make the HTTP request
      final response = await http.get(Uri.parse(rssUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to load RSS feed. Status code: ${response.statusCode}');
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
        final publishedAt = DateTime.tryParse(pubDateString) ?? DateTime.now();

        // Source is not in the <item>, so we set it from the channel info
        const String source = 'Polygon';
        
        // Find <category> tag's text, default to 'Gaming'
        final category = item.findElements('category').firstOrNull?.text ?? 'Gaming';

        // Find author (in 'dc:creator')
        final author = safeFind(item, 'dc:creator');
        
        // --- MODIFIED IMAGE LOGIC ---
        String imageUrl = '';

        // 1. Try finding <enclosure> first (as seen in your example)
        final enclosure = item.findElements('enclosure').firstOrNull;
        if (enclosure != null) {
          imageUrl = enclosure.getAttribute('url') ?? '';
        }
        
        // 2. If not found, try <media:content> (common in other feeds)
        if (imageUrl.isEmpty) {
          final mediaContent = item.findElements('media:content').firstOrNull;
          if (mediaContent != null) {
            imageUrl = mediaContent.getAttribute('url') ?? '';
          }
        }

        // 3. If still not found, parse <content:encoded> (last resort)
        if (imageUrl.isEmpty) {
          final contentEncoded = item.findElements('content:encoded').firstOrNull?.text;
          if (contentEncoded != null && contentEncoded.isNotEmpty) {
            final regex = RegExp(
              r'<img[^>]+src="([^"]+)"',
              caseSensitive: false,
            );
            final match = regex.firstMatch(contentEncoded);
            if (match != null && match.groupCount >= 1) {
              imageUrl = match.group(1) ?? '';
            }
          }
        }
        // --- END OF MODIFIED LOGIC ---


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
      print('Error in PolygonGamingNewsSource.fetchNews: $e');
      // Re-throw the error so the caller can handle it
      throw Exception('Could not fetch or parse Polygon gaming news: $e');
    }
  }
}