import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/data/sources/movies/movieweb_source.dart';
import 'package:flash_feed/data/sources/movies/screen_rant_source.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final movieListProvider = FutureProvider<List<NewsItem>>((ref) async {
  List<NewsItem> onError(String source, dynamic e) {
    debugPrint('$source: $e');
    return <NewsItem>[];
  }

  final allMovieLists = await Future.wait<List<NewsItem>>([
    MovieWebSource().fetchNews().catchError(
      (error, StackTrace) => onError('MoviesWebSource Failed', error),
    ),
    ScreenRantSource().fetchNews().catchError(
      (error, StackTrace) => onError('screenRant Failed', error),
    ),
  ]);
  final combinedMovieList = allMovieLists.expand((element) {
    return element;
  }).toList();
  debugPrint(combinedMovieList.length.toString());
  combinedMovieList.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  return combinedMovieList;
});
