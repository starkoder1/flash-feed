import 'dart:io';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';

class ArsTechnicaSource {
  static const String _feedUrl = 'https://arstechnica.com/feed/';

   Future<List<NewsItem>> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(_feedUrl));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load Ars Technica feed: ${response.statusCode}',
        );
      }

      final document = XmlDocument.parse(response.body);
      final items = document.findAllElements('item');
      List<NewsItem> articles = [];

      for (var item in items) {
        final title = item.getElement('title')?.innerText.trim() ?? 'No Title';
        final link = item.getElement('link')?.innerText.trim() ?? '';
        final category = item
            .findAllElements('category')
            .map((e) => e.innerText)
            .join(', ');

        // --- Author ---
        final author =
            item.getElement('dc:creator')?.innerText.trim() ??
            item.getElement('creator')?.innerText.trim() ??
            'Unknown';

        // --- Date ---
        DateTime publishedAt = DateTime.now();
        final pubDateRaw = item.getElement('pubDate')?.innerText.trim();
        if (pubDateRaw != null) {
          try {
            publishedAt = HttpDate.parse(pubDateRaw);
          } catch (_) {}
        }

        // --- Description ---
        final descHtml = item.getElement('description')?.innerText ?? '';
        final descText = _stripHtml(descHtml);
        final shortDesc = descText.length > 180
            ? '${descText.substring(0, 180)}...'
            : descText;

        // --- Image ---
        String imageUrl = 'https://via.placeholder.com/300x180?text=No+Image';
        final mediaThumb = item
            .findElements('media:thumbnail')
            .firstWhere(
              (e) => e.getAttribute('url') != null,
              orElse: () => XmlElement(XmlName('')),
            );
        if (mediaThumb.getAttribute('url') != null) {
          imageUrl = mediaThumb.getAttribute('url')!;
        } else {
          final mediaContent = item
              .findElements('media:content')
              .firstWhere(
                (e) => e.getAttribute('url') != null,
                orElse: () => XmlElement(XmlName('')),
              );
          if (mediaContent.getAttribute('url') != null) {
            imageUrl = mediaContent.getAttribute('url')!;
          } else {
            final imgMatch = RegExp(
              "<img[^>]+src=[\"']([^\"']+)[\"']",
              caseSensitive: false,
            ).firstMatch(descHtml);
            if (imgMatch != null) {
              imageUrl = imgMatch.group(1)!;
            }
          }
        }

        articles.add(
          NewsItem(
            title: title,
            description: shortDesc,
            link: link,
            imageUrl: imageUrl,
            author: author,
            publishedAt: publishedAt,
            source: 'Ars Technica',
            category: category,
          ),
        );
      }

      return articles;
    } catch (e) {
      debugPrint('Error fetching Ars Technica feed: $e');
      return [];
    }
  }

  static String _stripHtml(String htmlString) {
    final regex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);
    return htmlString.replaceAll(regex, '').trim();
  }
}
