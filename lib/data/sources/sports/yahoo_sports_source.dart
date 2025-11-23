import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flash_feed/utils/string_cleaner.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart' as xml;

class YahooSportsNewsSource {
  static const String _dcNamespace = 'http://purl.org/dc/elements/1.1/';
  static const String _mediaNamespace = 'http://search.yahoo.com/mrss/';
  static const String _contentNamespace =
      'http://purl.org/rss/1.0/modules/content/';

  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> newsItems = [];
    final Set<String> uniqueLinks = {};

    const String rssUrl = "https://sports.yahoo.com/rss/";

    try {
      final response = await http.get(
        Uri.parse(rssUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load feed: ${response.statusCode}');
      }

      final document = xml.XmlDocument.parse(getBody(response));
      final items = document.findAllElements('item');

      for (final item in items) {
        String safeFind(xml.XmlElement el, String tag) {
          return el.findElements(tag).firstOrNull?.text.trim() ?? '';
        }

        final title = safeFind(item, 'title');
        final description = safeFind(item, 'description');
        final link = safeFind(item, 'link');
        final pubDate = safeFind(item, 'pubDate');
        final publishedAt = _parseDate(pubDate);

        final source =
            item.findElements('source').firstOrNull?.text ?? 'Yahoo Sports';
        final category =
            item.findElements('category').firstOrNull?.text ?? 'Sports';

        final author =
            item
                .findElements('creator', namespace: _dcNamespace)
                .firstOrNull
                ?.innerText
                .trim() ??
            '';

        // -------- IMAGE LOGIC --------
        String imageUrl = '';

        final mediaContent = item
            .findElements('content', namespace: _mediaNamespace)
            .firstOrNull;

        if (mediaContent != null) {
          imageUrl = mediaContent.getAttribute('url') ?? '';
        }

        if (imageUrl.isEmpty) {
          final contentEncoded = item
              .findElements('encoded', namespace: _contentNamespace)
              .firstOrNull
              ?.text;

          if (contentEncoded != null) {
            final regex = RegExp(
              r'<img[^>]+src="([^"]+)"',
              caseSensitive: false,
            );
            final match = regex.firstMatch(contentEncoded);
            if (match != null) imageUrl = match.group(1) ?? '';
          }
        }
        // --------------------------------

        final newsItem = NewsItem(
          title: title,
          description: description,
          link: link,
          imageUrl: imageUrl,
          author: author,
          publishedAt: publishedAt,
          source: 'Yahoo! Sports',
          category: 'sports',
        );

        if (uniqueLinks.add(newsItem.link)) {
          newsItems.add(newsItem);
        }
      }

      newsItems.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return newsItems;
    } catch (e) {
      debugPrint('❌ Error: $e');
      throw Exception('Could not fetch Yahoo Sports: $e');
    }
  }

  // -------- UNIVERSAL DATE PARSER --------
  DateTime _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return DateTime.now();
    }

    // Clean invisible characters
    String dateStr = raw
        .replaceAll(RegExp(r'[\u200B-\u200F\uFEFF]'), '')
        .replaceAll(RegExp(r'\u00A0'), ' ')
        .replaceAll('&nbsp;', ' ')
        .trim();

    // Convert "+0000" → "GMT" for HttpDate
    final numericTZ = RegExp(r'(\+|\-)\d{4}$');
    if (numericTZ.hasMatch(dateStr)) {
      dateStr = dateStr.replaceFirst(numericTZ, ' GMT');
    }

    // Try HttpDate first
    try {
      return HttpDate.parse(dateStr);
    } catch (_) {}

    // Try fallback formats
    final formats = [
      "EEE, dd MMM yyyy HH:mm:ss Z",
      "EEE, dd MMM yyyy HH:mm:ss",
      "EEE, dd MMM yyyy HH:mm Z",
      "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
      "EEE, dd MMM yyyy HH:mm 'GMT'",
      "yyyy-MM-dd'T'HH:mm:ss'Z'",
      "yyyy-MM-dd HH:mm:ss",
      "yyyy-MM-dd",
    ];

    for (var f in formats) {
      try {
        return DateFormat(f, 'en_US').parse(dateStr, true).toLocal();
      } catch (_) {}
    }

    debugPrint('⚠️ Could not parse Yahoo date: "$raw"');
    return DateTime.now();
  }
}
