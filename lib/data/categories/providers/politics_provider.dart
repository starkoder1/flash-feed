import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/data/sources/politics/politics_yahoo_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final politicsListProvider = FutureProvider<List<NewsItem>>((ref) {
  final politicsList = PoliticsYahooSource();
  return politicsList.fetchNews();
});


