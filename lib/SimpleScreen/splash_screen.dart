import 'package:flutter/material.dart';
import 'package:github_trending_repos/Constants/assets_constants.dart';
import 'package:github_trending_repos/Constants/string_constants.dart';
import 'package:github_trending_repos/dashboard/view.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      navigateAfterSeconds: const DashboardPage(),
      title: const Text(
        splashScreenTitle,
        textScaleFactor: 2,
      ),
      image: Image.asset(logoImageAsset),
      photoSize: 100.0,
      loaderColor: Colors.blue,
    );
  }
}
