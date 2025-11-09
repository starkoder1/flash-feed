import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import 'package:flash_feed/data/models/news_item.dart';

class PoliticsYahooSource {
  final String feedUrl = 'https://news.yahoo.com/rss/';

  Future<List<NewsItem>> fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse(feedUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      );

      print('🔗 Fetching: $feedUrl');
      print('Status: ${response.statusCode}');
      print('Body preview: ${response.body.substring(0, 300)}');

      if (response.statusCode != 200) {
        throw Exception('Failed to load Yahoo feed: ${response.statusCode}');
      }

      final body = response.body.trim();
      if (body.isEmpty || !body.startsWith('<?xml')) {
        throw Exception('Invalid or empty feed from Yahoo');
      }

      final document = XmlDocument.parse(body);
      final items = document.findAllElements('item');
      final sourceTitle = 'Yahoo news';

      List<NewsItem> newsList = [];

      for (final item in items) {
        final title = item.getElement('title')?.innerText.trim() ?? 'No title';
        final description =
            item.getElement('description')?.innerText.trim() ?? '';
        final link = item.getElement('link')?.innerText.trim() ?? '';
        final author =
            item.getElement('dc:creator')?.innerText.trim() ?? 'Yahoo News';
        final pubDate = _parseDate(item.getElement('pubDate')?.innerText);
        final category =
            item.getElement('category')?.innerText.trim() ?? 'Politics';

        String imageUrl = '';
        final media = item.findElements('media:content');
        if (media.isNotEmpty) {
          final url = media.first.getAttribute('url');
          if (url != null && url.isNotEmpty) imageUrl = url;
        }

        newsList.add(
          NewsItem(
            title: title,
            description: description,
            link: link,
            imageUrl: imageUrl,
            author: author,
            publishedAt: pubDate,
            source: sourceTitle,
            category: category,
          ),
        );
      }

      return newsList;
    } catch (e) {
      print('❌ Error fetching Yahoo feed: $e');
      return [];
    }
  }

  DateTime _parseDate(String? dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr).toLocal();
    } catch (_) {
      try {
        return HttpDate.parse(dateStr);
      } catch (_) {
        return DateTime.now();
      }
    }
  }
}
