// We need this new import
import 'package:intl/intl.dart';

// We no longer need dart:io for HttpDate
// import 'dart:io'; 

import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class JplNewsService {
  // The specific URL for this service
  final String _feedUrl = "https://www.jpl.nasa.gov/feeds/news/";

  /// Fetches and parses the JPL RSS feed.
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
      final sourceName = _findElementText(channel, 'title') ?? 'JPL News';

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
    final link = _findElementText(item, 'link') ?? '';

    final pubDateStr = _findElementText(item, 'pubDate');
    DateTime publishedAt;
    try {
      // --- THIS IS THE FIX ---
      // We use the 'intl' package's DateFormat.
      // The format "E, dd MMM yyyy HH:mm:ss Z"
      // correctly parses "Mon, 13 Oct 2025 10:00:00 -0700"
      final format = DateFormat("E, dd MMM yyyy HH:mm:ss Z");
      publishedAt = pubDateStr != null
          ? format.parse(pubDateStr)
          : DateTime.now();
    } catch (e) {
      print('JPL Date Parse Error for string: "$pubDateStr". Error: $e');
      publishedAt = DateTime.now(); // Fallback if parsing still fails.
    }

    // --- Description from content:encoded and clean HTML ---
    final contentEncoded = _findElementText(item, 'content:encoded') ?? '';
    final description = contentEncoded.isNotEmpty
        ? _stripHtml(contentEncoded)
        : _findElementText(item, 'description') ?? 'No Description';

    // --- Image Extraction ---
    // This feed uses <media:content> but can also have images in <content:encoded>
    final mediaContent = item.findElements('media:content').firstOrNull;
    String imageUrl = mediaContent?.getAttribute('url') ?? '';

    if (imageUrl.isEmpty && contentEncoded.isNotEmpty) {
      // Fallback to parsing <img> from the content
      final imgMatch = RegExp(
        r'<img[^>]+src="([^">]+)"',
      ).firstMatch(contentEncoded);
      if (imgMatch != null) {
        imageUrl = imgMatch.group(1)!;
      }
    }

    // This feed does not seem to provide an author per item
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
      source: 'NASA JPL', // Your hardcoded value
      category: 'SPACE', // Your hardcoded value
    );
  }

  /// Utility to remove HTML tags from a string.
  String _stripHtml(String htmlText) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(regex, '').trim();
  }

  /// Safely finds an element and returns its text, or null.
  String? _findElementText(xml.XmlElement? element, String name) {
    if (element == null) return null;
    return element.findAllElements(name).firstOrNull?.innerText;
  }
}