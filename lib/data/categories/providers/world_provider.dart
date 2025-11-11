import 'package:flash_feed/data/models/news_item.dart';

import 'package:flash_feed/data/sources/world/yahoo_top_stories_source.dart';
import 'package:flash_feed/data/sources/world/yahoo_world_news_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final worldListProvider = FutureProvider<List<NewsItem>>((ref) async {
  List<NewsItem> onError(String source, e) {
    debugPrint(e.toString());
    debugPrint(source);
    return <NewsItem>[];
  }

  final allWorldList = await Future.wait([
    YahooTopNewsSource().fetchNews().catchError(
      (error, stackTrace) => onError('Yahoo Top News Source Failed', error),
    ),
    YahooWorldNewsSource().fetchNews().catchError(
      (error, stackTrace) => onError('Yahoo World News Source Failed', error),
    ),
    // YahooHealthNewsSource().fetchNews().catchError(
    //   (error, stackTrace) => onError('Yahoo Health News Source Failed', error),
    // ),
  ]);
  final combinedWorldNewsList = allWorldList.expand((element) {
    return element;
  }).toList();
  debugPrint(combinedWorldNewsList.length.toString());
  combinedWorldNewsList.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  return combinedWorldNewsList;
});
