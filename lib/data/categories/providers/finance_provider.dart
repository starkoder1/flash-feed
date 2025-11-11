import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/data/sources/finance/yahoo_finance_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final financeListProvider = FutureProvider<List<NewsItem>>((ref) {
  final financeList = YahooFinanceNewsSource();
  return financeList.fetchNews();
});


