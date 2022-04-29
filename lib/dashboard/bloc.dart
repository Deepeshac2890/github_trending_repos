import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:bloc/bloc.dart';
import 'package:github_trending_repos/Constants/string_constants.dart';
import 'package:github_trending_repos/Model/github_model.dart';
import 'package:github_trending_repos/Services/cache_github_service.dart';
import 'package:github_trending_repos/Services/github_service.dart';

import 'event.dart';
import 'state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this.githubApi, this.cacheGithubService, this.apiCacheManager)
      : super(DashboardState().init());
  final Api githubApi;
  final CacheGithubService cacheGithubService;
  final APICacheManager apiCacheManager;
  List<Items> items = [];
  bool isInternetGone = false;

  @override
  Stream<DashboardState> mapEventToState(DashboardEvent event) async* {
    yield DashboardLoadingState();
    if (event is InitEvent) {
      yield await init();
    } else if (event is LoadDashboardEvent) {
      isInternetGone = false;
      await getData();
    } else if (event is SortByStarsEvent) {
      if (isInternetGone) {
        bool isCachePresent =
            await apiCacheManager.isAPICacheKeyExist(cacheTrendingDataKey);
        if (isCachePresent) {
          items =
              await cacheGithubService.getCachedData(cacheTrendingDataKey) ??
                  [];
          sortByStar();
          yield InternetGoneState(items);
        } else {
          yield InternetGoneState([]);
        }
      } else {
        await sortByStar();
      }
    } else if (event is SortByNameEvent) {
      if (isInternetGone) {
        bool isCachePresent =
            await apiCacheManager.isAPICacheKeyExist(cacheTrendingDataKey);
        if (isCachePresent) {
          items =
              await cacheGithubService.getCachedData(cacheTrendingDataKey) ??
                  [];
          sortByName();
          yield InternetGoneState(items);
        } else {
          yield InternetGoneState(const []);
        }
      } else {
        await sortByName();
      }
    } else if (event is InternetGoneEvent) {
      isInternetGone = true;
      bool isCachePresent =
          await apiCacheManager.isAPICacheKeyExist(cacheTrendingDataKey);
      if (isCachePresent) {
        items =
            await cacheGithubService.getCachedData(cacheTrendingDataKey) ?? [];

        yield InternetGoneState(items);
      } else {
        yield InternetGoneState(const []);
      }
    } else if (event is RefreshDashboardEvent) {
      if (!isInternetGone) {
        await getData();
        yield RefreshDashboardState(items);
      } else {
        bool isCachePresent =
            await apiCacheManager.isAPICacheKeyExist(cacheTrendingDataKey);
        if (isCachePresent) {
          items =
              await cacheGithubService.getCachedData(cacheTrendingDataKey) ??
                  [];
          yield RefreshDashboardState(items);
        } else {
          yield InternetGoneState([]);
        }
      }
    }

    // reuse the code
    if (event is SortByNameEvent ||
        event is SortByStarsEvent ||
        event is LoadDashboardEvent) {
      if (items.isNotEmpty && isInternetGone == false) {
        yield DashboardLoadedState(true, items);
      } else if (isInternetGone == false) {
        yield DashboardItemsLoadFailedState();
      }
    }
  }

  Future<void> sortByStar() async {
    if (items.isNotEmpty) {
      items = cacheGithubService.sortByStarsFromCache(items);
    } else {
      items = await githubApi.getSortByStarItems() ?? [];
    }
  }

  Future<void> sortByName() async {
    if (items.isNotEmpty) {
      items = cacheGithubService.sortByNameFromCache(items);
    } else {
      items = await githubApi.getSortByNameItems() ?? [];
    }
  }

  Future<void> getData() async {
    items = await githubApi.getTrendingRepositories();
  }

  Future<DashboardState> init() async {
    return state.clone();
  }
}
