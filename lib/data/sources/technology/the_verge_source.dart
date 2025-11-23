import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class TheVergeSource {
  final String feedUrl = 'https://www.theverge.com/rss/full.xml';

  Future<List<NewsItem>> fetchNews() async {
    final List<NewsItem> allNews = [];
    final Set<String> uniqueLinks = {}; // To track unique article URLs

    try {
      final response = await http.get(
        Uri.parse(feedUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          'Accept': 'application/atom+xml, application/xml, text/xml, */*',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch Verge feed: ${response.statusCode}');
      }

      final body = response.body.trim();
      if (body.isEmpty) throw Exception('Empty Atom response from $feedUrl');

      final document = XmlDocument.parse(body);
      // The Verge now uses an Atom feed format, so we look for 'entry' tags.
      final items = document.findAllElements('entry'); // Atom uses 'entry'

      if (items.isEmpty && document.findAllElements('item').isEmpty) {
        // Check for 'item' as a fallback for RSS
        throw Exception('Invalid Atom/RSS: <entry> or <item> not found');
      }

      for (final element in items) {
        final title = element.getElement('title')?.text.trim() ?? 'No title';
        // In Atom, the content is in the 'content' tag.
        final content =
            element.getElement('content')?.text.trim() ?? 'No description';
        final link =
            element.getElement('link')?.getAttribute('href')?.trim() ?? '';
        // Author is nested inside <author><name>
        final author =
            element.getElement('author')?.getElement('name')?.text.trim() ??
            'The Verge';
        final publishedAt = _parseDate(
          element.getElement('published')?.innerText,
        );
        // Extract image URL from <img> tag inside <content>
        String imageUrl = '';
        final imgRegex = RegExp(r'<img.*?src="(.*?)"', caseSensitive: false);
        final match = imgRegex.firstMatch(content);
        imageUrl =
            match?.group(1) ??
            'https://platform.theverge.com/wp-content/uploads/sites/2/2025/01/verge-rss-large_80b47e.png?w=150&h=150&crop=1';

        // Extract category (take first one)
        final categories = element
            .findElements('category')
            .map((e) => e.getAttribute('term'))
            .where((term) => term != null)
            .cast<String>()
            .toList();
        final category = categories.isNotEmpty ? categories.first : 'General';

        final newsItem = NewsItem(
          title: title,
          description: _stripHtml(content),
          link: link,
          imageUrl: imageUrl,
          author: author,
          publishedAt: publishedAt,
          source: 'The Verge',
          category: 'technology',
        );

        // Add only unique items to the list
        if (uniqueLinks.add(newsItem.link)) {
          allNews.add(newsItem);
        }
      }

      debugPrint(
        '✅ Successfully fetched and parsed ${allNews.length} items from $feedUrl',
      );

      // Sort by date, newest first
      allNews.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      return allNews;
    } catch (e) {
      debugPrint('❌ Error fetching The Verge feed: $e');
      throw Exception('Could not fetch or parse The Verge feed: $e');
    }
  }

  /// Parse different RSS/Atom date formats safely
  DateTime _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      debugPrint(
        '⚠️ Date string was null/empty for The Verge. Using DateTime.now().',
      );
      return DateTime.now();
    }
    try {
      // The Verge uses ISO 8601 format (e.g., "2025-11-18T13:00:00-05:00")
      return DateTime.parse(dateStr.trim());
    } catch (_) {
      try {
        // Fallback for other common formats like RFC-1123
        return HttpDate.parse(dateStr.trim());
      } catch (_) {
        debugPrint(
          '⚠️ Failed to parse date "$dateStr" for The Verge. Using DateTime.now().',
        );
        return DateTime.now();
      }
    }
  }

  // Utility to remove HTML tags from the description
  String _stripHtml(String htmlText) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(regex, '').trim();
  }
}
