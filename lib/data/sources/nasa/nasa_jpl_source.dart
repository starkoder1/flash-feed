// We need this new import
import 'dart:io';
import 'package:intl/intl.dart';

import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class JplNewsService {
  // Define constants for XML namespaces
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';
  static const String _contentNamespace =
      'http://purl.org/rss/1.0/modules/content/';

  // The specific URL for this service
  final String _feedUrl = "https://www.jpl.nasa.gov/feeds/news/";

  /// Fetches and parses the JPL RSS feed.
  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    final Set<String> uniqueLinks = {}; // To track unique article URLs

    try {
      // 1. Fetch the data
      final response = await http.get(
        Uri.parse(_feedUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load RSS feed: ${response.statusCode}');
      }

      // 2. Parse the XML string
      final body = response.body.trim();
      if (body.isEmpty) throw Exception('Empty RSS response from $_feedUrl');

      final document = xml.XmlDocument.parse(body);

      // 3. Find the source name from the channel
      final channel = document.findAllElements('channel').firstOrNull;
      final sourceName = _findElementText(channel, 'title') ?? 'NASA JPL News';

      // 4. Parse all <item> tags
      final items = document.findAllElements('item');

      for (final item in items) {
        final newsItem = _parseItem(item, sourceName);

        if (uniqueLinks.add(newsItem.link)) {
          newsItems.add(newsItem);
        }
      }

      debugPrint(
        '✅ Successfully fetched and parsed ${newsItems.length} items from $_feedUrl',
      );

      // Sort newest first
      newsItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return newsItems;
    } catch (e) {
      debugPrint('❌ Error fetching or parsing news from $_feedUrl: $e');
      throw Exception('Could not fetch or parse NASA JPL feed: $e');
    }
  }

  /// Parse a single <item> into a NewsItem.
  NewsItem _parseItem(xml.XmlElement item, String sourceName) {
    final title = _findElementText(item, 'title') ?? 'No title';
    final link = _findElementText(item, 'link') ?? '';

    final pubDateStr = _findElementText(item, 'pubDate');
    final publishedAt = _parseDate(pubDateStr);

    // --- Description extraction ---
    final contentEncoded =
        _findElementText(item, 'encoded', namespace: _contentNamespace) ?? '';

    final description = contentEncoded.isNotEmpty
        ? _stripHtml(contentEncoded)
        : _findElementText(item, 'description') ?? 'No description';

    // --- Image extraction ---
    final mediaContent = item
        .findElements('content', namespace: _mediaNamespace)
        .firstOrNull;

    String imageUrl = mediaContent?.getAttribute('url') ?? '';

    // Fallback: extract image from HTML content
    if (imageUrl.isEmpty && contentEncoded.isNotEmpty) {
      final imgMatch = RegExp(
        r'<img[^>]+src="([^">]+)"',
      ).firstMatch(contentEncoded);
      if (imgMatch != null) imageUrl = imgMatch.group(1)!;
    }

    // Authors
    final author =
        _findElementText(item, 'author') ??
        _findElementText(item, 'creator', namespace: _dcNamespace) ??
        '';

    return NewsItem(
      title: title,
      description: description,
      link: link,
      imageUrl: imageUrl,
      author: author,
      publishedAt: publishedAt,
      source: ' NASA Jet Propulsion Laboratory',
      category: 'nasa', // hardcoded
    );
  }

  /// Strip HTML tags
  String _stripHtml(String htmlText) {
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>', multiLine: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Safe element finder
  String? _findElementText(
    xml.XmlElement? element,
    String name, {
    String? namespace,
  }) {
    if (element == null) return null;
    return element
        .findElements(name, namespace: namespace)
        .firstOrNull
        ?.innerText
        .trim();
  }

  /// FIXED — Proper date parsing for JPL RSS format
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint('⚠️ Empty date for JPL. Using now().');
      return DateTime.now();
    }

    // Correct format example: Fri, 14 Nov 2025 12:00:00 -0800
    try {
      final format = DateFormat("EEE, dd MMM yyyy HH:mm:ss Z", "en_US");
      return format.parse(dateStr.trim());
    } catch (e) {
      debugPrint('⚠️ Intl parse failed "$dateStr": $e');
    }

    // Fallback 1
    try {
      return DateTime.parse(dateStr.trim());
    } catch (_) {}

    // Fallback 2
    try {
      return HttpDate.parse(dateStr.trim());
    } catch (_) {}

    debugPrint('⚠️ All date parsing failed for "$dateStr". Using now().');
    return DateTime.now();
  }
}
