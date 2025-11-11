import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/data/sources/nasa/nasa_image_source.dart';
import 'package:flash_feed/data/sources/nasa/nasa_jpl_source.dart';
import 'package:flash_feed/data/sources/nasa/nasa_news_source.dart';
import 'package:flash_feed/data/sources/nasa/nasa_technology_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final nasaListProvider = FutureProvider<List<NewsItem>>((ref) async {
  List<NewsItem> onError(Object error, StackTrace? stackTrace, String source) {
    debugPrint(error.toString());
    debugPrint(source);
    return <NewsItem>[];
  }

  final allNasaList = await Future.wait([
    NasaImageSource().fetchNews().catchError(
      (error, stackTrace) => onError(error, stackTrace, 'NASA Image Failed'),
    ),
    JplNewsService().fetchNews().catchError(
      (error, stackTrace) => onError(error, stackTrace, 'JPLNEWS Failed'),
    ),
    NasaNewsSource().fetchNews().catchError(
      (error, stackTrace) => onError(error, stackTrace, 'NASA News Failed'),
    ),
    NasaTechnologySource().fetchNews().catchError(
      (error, stackTrace) => onError(error, stackTrace, 'NASA Tech Failed'),
    ),
  ]);
  final combinedNasalist = allNasaList.expand((element) {
    return element;
  }).toList();
  debugPrint(combinedNasalist.length.toString());
  combinedNasalist.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  return combinedNasalist;
});
