import 'package:flash_feed/data/models/news_item.dart';
import 'package:flash_feed/data/sources/environment/physics_org_environment_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final environmentListProvider = FutureProvider<List<NewsItem>>((ref) {
  final environmentList = PhysicsOrgEnvironmentSource();
  return environmentList.fetchNews();
});


