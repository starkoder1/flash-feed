import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flash_feed/utils/string_cleaner.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;

class NasaImageSource {
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  final String _feedUrl = "https://www.nasa.gov/feeds/iotd-feed/";

  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    final Set<String> uniqueLinks = {};

    try {
      final response = await http.get(
        Uri.parse(_feedUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load feed: ${response.statusCode}');
      }

      final body = getBody(response).trim();
      if (body.isEmpty) throw Exception('Empty RSS response');

      final document = xml.XmlDocument.parse(body);
      final channel = document.findAllElements('channel').firstOrNull;

      final sourceName =
          _findElementText(channel, 'title') ?? 'NASA Image of the Day';

      final items = document.findAllElements('item');

      for (final item in items) {
        final newsItem = _parseItem(item, sourceName);
        if (uniqueLinks.add(newsItem.link)) {
          newsItems.add(newsItem);
        }
      }

      newsItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return newsItems;
    } catch (e) {
      debugPrint('❌ NASA IOTD error: $e');
      throw Exception('NASA feed error: $e');
    }
  }

  NewsItem _parseItem(xml.XmlElement item, String sourceName) {
    final title = _findElementText(item, 'title') ?? 'No title';
    final description =
        _findElementText(item, 'description') ?? 'No description';
    final link = _findElementText(item, 'link') ?? '';

    final pubDateStr = _findElementText(item, 'pubDate');
    final publishedAt = _parseDate(pubDateStr);

    final author =
        _findElementText(item, 'creator', namespace: _dcNamespace) ?? 'NASA';

    final enclosure = item.findElements('enclosure').firstOrNull;
    final imageUrl = enclosure?.getAttribute('url') ?? '';

    return NewsItem(
      title: title,
      description: description,
      link: link,
      imageUrl: imageUrl,
      author: author,
      publishedAt: publishedAt,
      source: sourceName,
      category: 'nasa',
    );
  }

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

  /// UNIVERSAL DATE PARSER — will never fail
  DateTime _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return DateTime.now();
    }

    // CLEAN hidden unicode characters
    final dateStr = raw
        .replaceAll(RegExp(r'[\u200B-\u200F\uFEFF]'), '') // zero-width chars
        .replaceAll(RegExp(r'\u00A0'), ' ') // non-breaking space
        .replaceAll('&nbsp;', ' ')
        .trim();

    // Try standard RFC1123 (Mon, 17 Nov 2025 20:35 GMT)
    try {
      return HttpDate.parse(dateStr);
    } catch (_) {}

    // Try common RSS formats
    final formats = [
      "EEE, dd MMM yyyy HH:mm:ss Z",
      "EEE, dd MMM yyyy HH:mm Z",
      "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
      "EEE, dd MMM yyyy HH:mm 'GMT'",
      "dd MMM yyyy HH:mm:ss Z",
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy-MM-dd",
    ];

    for (var f in formats) {
      try {
        return DateFormat(f, 'en_US').parse(dateStr, true).toLocal();
      } catch (_) {}
    }

    debugPrint('⚠️ Could not parse NASA date: "$raw"');
    return DateTime.now();
  }
}
