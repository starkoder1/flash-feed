import 'package:flash_feed/data/categories/providers/automotive_provider.dart';
import 'package:flash_feed/data/categories/providers/environment_provider.dart';
import 'package:flash_feed/data/categories/providers/finance_provider.dart';
import 'package:flash_feed/data/categories/providers/gaming_provider.dart';
import 'package:flash_feed/data/categories/providers/health_provider.dart';
import 'package:flash_feed/data/categories/providers/movie_provider.dart';
import 'package:flash_feed/data/categories/providers/nasa_provider.dart';
import 'package:flash_feed/data/categories/providers/politics_provider.dart';
import 'package:flash_feed/data/categories/providers/sports_provider.dart';
import 'package:flash_feed/data/categories/providers/tech_provider.dart';
import 'package:flash_feed/data/models/news_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForYouProivder extends AsyncNotifier<List<NewsItem>> {
  @override
  Future<List<NewsItem>> build() async {
    final results = await Future.wait([
      ref.watch(techListProvider.future),
      ref.watch(sportsListProvider.future),
      ref.watch(gameListProvider.future),
      ref.watch(automotiveListProvider.future),
      ref.watch(financeListProvider.future),
      ref.watch(healthListProvider.future),
      ref.watch(movieListProvider.future),
      ref.watch(nasaListProvider.future),
      ref.watch(environmentListProvider.future),
      ref.watch(financeListProvider.future),
      ref.watch(automotiveListProvider.future),
      ref.watch(politicsListProvider.future),
    ]);
    final mergedList = results
        .expand((element) => element)
        .toList(); //exapanding the list
    debugPrint(mergedList.length.toString());
    mergedList.sort(
      (a, b) => b.publishedAt.compareTo(a.publishedAt),
    ); //comparing the list

    final topLatestNewsList = mergedList.take(60).toList();
    final remainingNewsList = mergedList.skip(60).toList();
    remainingNewsList.shuffle();

    return [...topLatestNewsList, ...remainingNewsList];
  }
}

final forYouProivder = AsyncNotifierProvider<ForYouProivder, List<NewsItem>>(
  (ForYouProivder.new),
);
