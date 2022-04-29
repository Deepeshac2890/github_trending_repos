import 'dart:async';
import 'dart:convert';

import 'package:github_trending_repos/Constants/string_constants.dart';
import 'package:github_trending_repos/Model/github_model.dart';
import 'package:github_trending_repos/Services/cache_github_service.dart';
import 'package:http/http.dart' as http;

class Api {
  static const String _url = "https://api.github.com";

  Future<List<Items>> getTrendingRepositories() async {
    try {
      const String url = "$_url/search/repositories?q=user:octokit";

      final jsonResponse = await http.get(Uri.parse(url));
      if (jsonResponse.statusCode == 200) {
        await CacheGithubService()
            .addCacheData(jsonResponse.body, cacheTrendingDataKey);
        var gtm = GithubModel.fromJson(jsonDecode(jsonResponse.body));
        return gtm.items;
      }
    } catch (e) {
      print("The Exception is : $e");
    }
    return [];
  }

  Future<List<Items>?> getSortByStarItems() async {
    try {
      const String url =
          "$_url/search/repositories?q=user:octokit&sort=stars&order=desc";

      final jsonResponse = await http.get(Uri.parse(url));
      if (jsonResponse.statusCode == 200) {
        await CacheGithubService()
            .addCacheData(jsonResponse.body, cacheSortByStarDataKey);
        var gtm = GithubModel.fromJson(jsonDecode(jsonResponse.body));
        return gtm.items;
      }
    } catch (e) {
      print("The Exception is : $e");
    }

    return null;
  }

  Future<List<Items>?> getSortByNameItems() async {
    try {
      const String url =
          "$_url/search/repositories?q=user:octokit&sort=name&order=desc";

      final jsonResponse = await http.get(Uri.parse(url));
      if (jsonResponse.statusCode == 200) {
        await CacheGithubService()
            .addCacheData(jsonResponse.body, cacheSortByNameDataKey);
        var gtm = GithubModel.fromJson(jsonDecode(jsonResponse.body));
        return gtm.items;
      }
    } catch (e) {
      print("The Exception is : $e");
    }

    return null;
  }
}
