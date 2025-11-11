import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/data/sources/health/medical_express_source.dart';
import 'package:flash_feed/data/sources/health/yahoo_health_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final healthListProvider = FutureProvider<List<NewsItem>>((ref) async {
  List<NewsItem> onError(String source, e) {
    debugPrint(e.toString());
    debugPrint(source);
    return <NewsItem>[];
  }

  final allHealthList = await Future.wait(({
    MedicalExpressSource().fetchNews().catchError(
      (error, StackTrace) => onError('MedicalExprees Failed', error),
    ),
    YahooHealthNewsSource().fetchNews().catchError(
      (error, StackTrace) => onError('YahooNews Failed', error),
    ),
  }));
  final combinedHealthNews = allHealthList.expand((element) {
    return element;
  }).toList();
  debugPrint(combinedHealthNews.length.toString());
  combinedHealthNews.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  return combinedHealthNews;
});
