import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/data/sources/gaming/ign_gaming_source.dart';
import 'package:flash_feed/data/sources/gaming/polygon_source.dart';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gameListProvider = FutureProvider<List<NewsItem>>((ref) async {
  List<NewsItem> onError(String source, e) {
    debugPrint(e.toString());
    debugPrint(source);
    return <NewsItem>[];
  }

  final allGameList = await Future.wait([
    IgnGamesNewsSource().fetchNews().catchError(
      (error, stackTrace) => onError('Yahoo Top News Source Failed', error),
    ),
    PolygonGamingNewsSource().fetchNews().catchError(
      (error, stackTrace) => onError('Yahoo World News Source Failed', error),
    ),

  ]);
  final combinedGameNewsList = allGameList.expand((element) {
    return element;
  }).toList();
  debugPrint(combinedGameNewsList.length.toString());
  combinedGameNewsList.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  return combinedGameNewsList;
});
