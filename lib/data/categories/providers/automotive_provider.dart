import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/data/sources/automotive/ars_technica_cars_source.dart';
import 'package:flash_feed/data/sources/automotive/automotive_cnet_source.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final automotiveListProvider = FutureProvider<List<NewsItem>>((ref) async {
  List<NewsItem> onError(String source, e) {
    debugPrint(e.toString());
    debugPrint(source);
    return <NewsItem>[];
  }

  final allAutoMotiveList = await Future.wait([
    AutomotiveArsTechnicaSource().fetchNews().catchError(
      (error, stackTrace) =>
          onError('Ars Technica Automotive News Source Failed', error),
    ),
    // AutomotiveCnetSource().fetchNews().catchError(
    //   (error, stackTrace) =>
    //       onError('CNET Automotive News Source Failed', error),
    // ),
  ]);
  final combinedAutomotiveList = allAutoMotiveList.expand((element) {
    return element;
  }).toList();
  debugPrint(combinedAutomotiveList.length.toString());
  combinedAutomotiveList.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  return combinedAutomotiveList;
});
