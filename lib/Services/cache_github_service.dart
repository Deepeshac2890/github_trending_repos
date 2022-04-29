import 'dart:convert';

import 'package:api_cache_manager/models/cache_db_model.dart';
import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:github_trending_repos/Model/github_model.dart';

class CacheGithubService {
  Future<List<Items>?> getCachedData(String key) async {
    var data = await APICacheManager().getCacheData(key);
    var gtm = GithubModel.fromJson(jsonDecode(data.syncData));
    return gtm.items;
  }

  Future<bool> addCacheData(dynamic data, String key) async {
    APICacheDBModel trendingDBModel = APICacheDBModel(key: key, syncData: data);
    return await APICacheManager().addCacheData(trendingDBModel);
  }

  List<Items> sortByStarsFromCache(List<Items> item) {
    item.sort((a, b) {
      return a.watchersCount.toInt() - b.watchersCount.toInt();
    });
    return item;
  }

  List<Items> sortByNameFromCache(List<Items> items) {
    items.sort((a, b) {
      return a.name.compareTo(b.name);
    });
    return items;
  }
}
