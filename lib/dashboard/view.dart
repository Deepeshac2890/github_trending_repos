import 'dart:ui';

import 'package:api_cache_manager/api_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_trending_repos/Constants/assets_constants.dart';
import 'package:github_trending_repos/Constants/string_constants.dart';
import 'package:github_trending_repos/Services/cache_github_service.dart';
import 'package:github_trending_repos/Services/github_service.dart';
import 'package:github_trending_repos/Widgets/github_widget.dart';
import 'package:github_trending_repos/dashboard/bloc.dart';
import 'package:github_trending_repos/dashboard/state.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'event.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final DashboardBloc db =
      DashboardBloc(Api(), CacheGithubService(), APICacheManager());

  RefreshController controller = RefreshController();

  @override
  void initState() {
    InternetConnectionChecker().onStatusChange.listen((event) async {
      bool isInternet = await InternetConnectionChecker().hasConnection;
      if (!isInternet) {
        db.add(InternetGoneEvent());
      } else {
        db.add(LoadDashboardEvent());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
        cubit: db,
        builder: (context, state) {
          if (state is DashboardLoadedState) {
            return buildDashboardWithData(state);
          } else if (state is DashboardItemsLoadFailedState) {
            return Scaffold(
              appBar: buildAppBar(),
              body: const Center(child: Text(itemsNotLoadingError)),
            );
          } else if (state is InternetGoneState) {
            if (state.items.isNotEmpty) {
              return buildDashboardWithData(state);
            } else {
              return buildNoInternetPage();
            }
          } else if (state is RefreshDashboardState) {
            if (state.items.isNotEmpty) {
              controller.refreshCompleted();
            } else {
              controller.refreshFailed();
            }
            return buildDashboardWithData(state);
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
        listener: (context, state) {});
  }

  Scaffold buildDashboardWithData(dynamic state) {
    return Scaffold(
      appBar: buildAppBar(),
      body: SmartRefresher(
        controller: controller,
        onRefresh: () {
          db.add(RefreshDashboardEvent());
        },
        child: ListView.builder(
          itemBuilder: (context, index) {
            return GithubItem(
              repo: state.items[index],
            );
          },
          itemCount: state.items.length,
        ),
      ),
    );
  }

  Scaffold buildNoInternetPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text(appBarTitle)),
        automaticallyImplyLeading: false,
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(
          height: 40,
        ),
        Image.asset(internetGone),
        const SizedBox(
          height: 10,
        ),
        const Text(
          somethingWentWrongText,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(
          height: 10,
        ),
        const Text(
          somethingWentWrongDesc,
          style: TextStyle(color: Colors.grey),
        ),
        const Expanded(child: SizedBox()),
        Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.all(30),
          child: TextButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                    side: const BorderSide(
                        color: Colors.green,
                        width: 1,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(5)),
              ),
            ),
            onPressed: () async {
              bool isInternetBack =
                  await InternetConnectionChecker().hasConnection;
              if (isInternetBack) {
                db.add(LoadDashboardEvent());
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(snackBarNoInternet)));
              }
            },
            child:
                const Text(retryString, style: TextStyle(color: Colors.green)),
          ),
        ),
        const SizedBox(
          height: 30,
        )
      ]),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      title: const Center(
        child: Text(
          appBarTitle,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      actions: [
        PopupMenuButton(
          offset: const Offset(0, 50),
          onSelected: (val) {
            if (val == 1) {
              db.add(SortByStarsEvent());
            } else {
              db.add(SortByNameEvent());
            }
          },
          icon: const Icon(
            Icons.more_vert,
            color: Colors.black,
          ),
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              child: Text("Sort by stars"),
              value: 1,
            ),
            const PopupMenuItem(
              child: Text("Sort by name"),
              value: 2,
            )
          ],
        )
      ],
    );
  }
}
