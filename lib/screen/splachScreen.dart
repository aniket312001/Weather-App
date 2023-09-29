import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';

import '../app_route/app_route.dart';
import '../utils/shared_pref.dart';
import 'dashboard.dart';
import 'login.dart';

Size? mq;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  void _navigate() async {
    dynamic userId = await SharedPrefUtils.readPrefStr('isLogin');

    _timer = Timer(const Duration(seconds: 3), () {
      if (userId.toString() == "yes") {
        nextPagewithReplacement(context, DashboardScreen());
      } else {
        nextPagewithReplacement(context, LoginScreen());
      }
    });
  }

  @override
  void dispose() {
    log("dispose called on splash");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.sizeOf(context);
    return SafeArea(
        child: Scaffold(
            backgroundColor: Colors.lightBlue[100],
            body: Center(
              child: Container(
                  width: double.infinity,
                  // height: mq.height * 0.18,
                  child: Image.asset(
                    'assets/images/cloudy.png',
                    fit: BoxFit.cover,
                  )),
            )));
  }
}
