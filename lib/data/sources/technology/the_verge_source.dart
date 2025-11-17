import 'package:flash_feed/data/models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class TheVergeSource {
  final String feedUrl = 'https://www.theverge.com/rss/full.xml';

  Future<List<NewsItem>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(feedUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to fetch Verge feed: ${response.statusCode}');
      }

      final document = XmlDocument.parse(response.body);
      // The Verge now uses an Atom feed format, so we look for 'entry' tags.
      final items = document.findAllElements('entry');

      return items.map((element) {
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
        final pubDateText = element.getElement('published')?.text.trim() ?? '';
        final publishedAt =
            DateTime.tryParse(pubDateText) ??
            DateTime.now().toUtc(); // fallback

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

        return NewsItem(
          title: title,
          description: _stripHtml(content),
          link: link,
          imageUrl: imageUrl,
          author: author,
          publishedAt: publishedAt,
          source: 'The Verge',
          category: category,
        );
      }).toList();
    } catch (e) {
      print('Error fetching Verge feed: $e');
      return [];
    }
  }

  // Utility to remove HTML tags from the description
  String _stripHtml(String htmlText) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlText.replaceAll(regex, '').trim();
  }
}
