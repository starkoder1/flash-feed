import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/data/sources/automotive/ars_technica_cars_source.dart';
import 'package:flash_feed/data/sources/automotive/automotive_cnet_source.dart';
import 'package:flash_feed/data/sources/science/physics_org_source.dart';
import 'package:flash_feed/data/sources/science/yahoo_science_source.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final scienceListProvider = FutureProvider<List<NewsItem>>((ref) async {
  List<NewsItem> onError(String source, e) {
    debugPrint(e.toString());
    debugPrint(source);
    return <NewsItem>[];
  }

  final allScienceList = await Future.wait([
    PhysOrgSource().fetchNews().catchError(
      (error, stackTrace) =>
          onError('Ars Technica Automotive News Source Failed', error),
    ),
    YahooScienceSource().fetchNews().catchError(
      (error, stackTrace) =>
          onError('CNET Automotive News Source Failed', error),
    ),
  ]);
  final combinedScienceList = allScienceList.expand((element) {
    return element;
  }).toList();
  debugPrint(combinedScienceList.length.toString());
  combinedScienceList.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  return combinedScienceList;
});
