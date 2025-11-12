import 'package:flash_feed/data/models/news_item.dart';

import 'package:flash_feed/data/sources/space/physics_org_astronomy_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final spaceListProvider = FutureProvider<List<NewsItem>>((ref) {
  final spaceList = PhysicsOrgAstronomySource();
  return spaceList.fetchNews();
});


