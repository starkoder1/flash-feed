// ignore_for_file: avoid_print

import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/data/sources/technology/ars_technica_source.dart';
import 'package:flash_feed/data/sources/technology/cnet_source.dart';
import 'package:flash_feed/data/sources/technology/engadget_source.dart';
import 'package:flash_feed/data/sources/technology/the_verge_source.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final techListProvider = FutureProvider<List<NewsItem>>((ref) async {
  List<NewsItem> onError(String source, e) {
    debugPrint(e.toString());
    debugPrint(source);
    return <NewsItem>[];
  }

  final allTechList = await Future.wait([
    CnetSource().fetchNews().catchError(
      (error, stackTrace) => onError('CNET Failed', error),
    ),
    ArsTechnicaSource().fetchNews().catchError(
      (error, stackTrace) => onError('ArsTechnica Failed', error),
    ),
    EngadgetSource().fetchNews().catchError(
      (error, stackTrace) => onError('Engadget Failed', error),
    ),
    TheVergeSource().fetchNews().catchError(
      (error, stackTrace) => onError('TheVerge Failed', error),
    ),
  ]);
  final combinedTechList = allTechList.expand((element) {
    return element;
  }).toList();
  debugPrint(combinedTechList.length.toString());
  combinedTechList.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

  return combinedTechList;
});
