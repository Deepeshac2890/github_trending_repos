import 'package:api_cache_manager/utils/cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_trending_repos/Constants/string_constants.dart';
import 'package:github_trending_repos/Model/github_model.dart';
import 'package:github_trending_repos/Services/cache_github_service.dart';
import 'package:github_trending_repos/Services/github_service.dart';
import 'package:github_trending_repos/dashboard/bloc.dart';
import 'package:github_trending_repos/dashboard/event.dart';
import 'package:github_trending_repos/dashboard/state.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

class CacheGithubServiceMock extends Mock implements CacheGithubService {}

class ApiMock extends Mock implements Api {}

class APICacheManagerMock extends Mock implements APICacheManager {}

class ItemsMock extends Mock implements Items {}

@GenerateMocks([ApiMock])
void main() {
  late CacheGithubServiceMock cacheServiceMock;
  late ApiMock apiMock;
  late DashboardBloc bloc;
  late APICacheManagerMock apiCacheManagerMock;
  List<Items> fakeData = [
    Items(
        id: 10,
        name: 'octokit.js',
        description: 'some description',
        watchersCount: 10,
        language: 'C#',
        forksCount: 4),
    Items(
        id: 11,
        name: 'octokit.ps',
        description: 'some description2',
        watchersCount: 12,
        language: 'C++',
        forksCount: 5),
  ];

  setUp(() {
    apiMock = ApiMock();
    cacheServiceMock = CacheGithubServiceMock();
    apiCacheManagerMock = APICacheManagerMock();
    bloc = DashboardBloc(apiMock, cacheServiceMock, apiCacheManagerMock);
  });

  group("Test dashboard loading", () {
    test('Pass case', () async {
      when(apiMock.getTrendingRepositories()).thenAnswer(
        (_) async {
          return fakeData;
        },
      );
      bloc.add(LoadDashboardEvent());
      expectLater(
        bloc,
        emitsInOrder(
          [DashboardLoadingState(), DashboardLoadedState(true, fakeData)],
        ),
      );
    });

    test(
      'Fail case',
      () async {
        when(apiMock.getTrendingRepositories()).thenAnswer(
          (_) async {
            return [];
          },
        );
        bloc.add(LoadDashboardEvent());
        expectLater(
          bloc,
          emitsInOrder(
            [DashboardLoadingState(), DashboardItemsLoadFailedState()],
          ),
        );
      },
    );
  });

  group("Test dashboard sortByStar", () {
    test('Pass case', () async {
      when(apiMock.getSortByStarItems()).thenAnswer(
        (_) async {
          return fakeData;
        },
      );
      bloc.add(SortByStarsEvent());
      expectLater(
        bloc,
        emitsInOrder(
          [DashboardLoadingState(), DashboardLoadedState(true, fakeData)],
        ),
      );
    });

    test('Fail case', () async {
      when(apiMock.getSortByStarItems()).thenAnswer(
        (_) async {
          return [];
        },
      );
      bloc.add(SortByStarsEvent());
      expectLater(
        bloc,
        emitsInOrder(
          [DashboardLoadingState(), DashboardItemsLoadFailedState()],
        ),
      );
    });
  });

  group("Test dashboard sortByName", () {
    test('Pass case', () async {
      when(apiMock.getSortByNameItems()).thenAnswer(
        (_) async {
          return fakeData;
        },
      );
      bloc.add(SortByNameEvent());
      expectLater(
        bloc,
        emitsInOrder(
          [DashboardLoadingState(), DashboardLoadedState(true, fakeData)],
        ),
      );
    });

    test('Fail case', () async {
      when(apiMock.getSortByStarItems()).thenAnswer(
        (_) async {
          return [];
        },
      );
      bloc.add(SortByNameEvent());
      expectLater(
        bloc,
        emitsInOrder(
          [DashboardLoadingState(), DashboardItemsLoadFailedState()],
        ),
      );
    });
  });

  group("No Internet Scenario", () {
    test('Case to test scenario where data is not cached', () async {
      when(apiCacheManagerMock.isAPICacheKeyExist(cacheTrendingDataKey))
          .thenAnswer(
        (_) async {
          return false;
        },
      );
      bloc.add(InternetGoneEvent());
      expectLater(
        bloc,
        emitsInOrder(
          [DashboardLoadingState(), InternetGoneState([])],
        ),
      );
    });

    test(
      'Case to test when caching occurred before Internet went down',
      () async {
        when(apiCacheManagerMock.isAPICacheKeyExist(cacheTrendingDataKey))
            .thenAnswer(
          (_) async {
            return true;
          },
        );
        when(cacheServiceMock.getCachedData(cacheTrendingDataKey))
            .thenAnswer((realInvocation) async => fakeData);
        bloc.add(InternetGoneEvent());
        expectLater(
          bloc,
          emitsInOrder(
            [DashboardLoadingState(), InternetGoneState(fakeData)],
          ),
        );
      },
    );

    test('''Case to test when internet went down in between after caching 
            then we try to sort by stars''', () async {
      when(apiMock.getTrendingRepositories())
          .thenAnswer((realInvocation) async => fakeData);
      when(cacheServiceMock.sortByStarsFromCache(fakeData))
          .thenReturn(fakeData);
      when(apiCacheManagerMock.isAPICacheKeyExist(cacheTrendingDataKey))
          .thenAnswer(
        (_) async {
          return true;
        },
      );
      when(cacheServiceMock.getCachedData(cacheTrendingDataKey))
          .thenAnswer((realInvocation) async => fakeData);
      bloc.add(LoadDashboardEvent());
      bloc.add(InternetGoneEvent());
      bloc.add(SortByStarsEvent());
      expectLater(
        bloc,
        emitsInOrder(
          [
            DashboardLoadingState(),
            DashboardLoadedState(true, fakeData),
            DashboardLoadingState(),
            InternetGoneState(fakeData),
            DashboardLoadingState(),
            InternetGoneState(fakeData)
          ],
        ),
      );
    });

    test(
      '''Case to test when internet went down in between after caching 
            then we try to sort by names''',
      () async {
        when(apiMock.getTrendingRepositories())
            .thenAnswer((realInvocation) async => fakeData);
        when(cacheServiceMock.sortByNameFromCache(fakeData))
            .thenReturn(fakeData);
        when(apiCacheManagerMock.isAPICacheKeyExist(cacheTrendingDataKey))
            .thenAnswer(
          (_) async {
            return true;
          },
        );
        when(cacheServiceMock.getCachedData(cacheTrendingDataKey))
            .thenAnswer((realInvocation) async => fakeData);
        bloc.add(LoadDashboardEvent());
        bloc.add(InternetGoneEvent());
        bloc.add(SortByNameEvent());
        expectLater(
          bloc,
          emitsInOrder(
            [
              DashboardLoadingState(),
              DashboardLoadedState(true, fakeData),
              DashboardLoadingState(),
              InternetGoneState(fakeData),
              DashboardLoadingState(),
              InternetGoneState(fakeData)
            ],
          ),
        );
      },
    );

    test(
      "When Nothing is cached and no Internet is there",
      () {
        when(apiCacheManagerMock.isAPICacheKeyExist(cacheTrendingDataKey))
            .thenAnswer(
          (_) async {
            return false;
          },
        );
        bloc.add(InternetGoneEvent());
        expectLater(
          bloc,
          emitsInOrder(
            [
              DashboardLoadingState(),
              InternetGoneState([]),
            ],
          ),
        );
      },
    );
  });
}
