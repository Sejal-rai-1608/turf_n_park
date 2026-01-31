import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Add this import
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:turfandpark/firebase_options.dart';

import 'auth/login_user.dart';
import 'auth/user_signup_step1.dart';
import 'helpers/helper_functions.dart';
import 'helpers/login_data.dart';
import 'owner/turf_list.dart';
import 'pages/turfList.dart';
import 'pre_login_user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  init();
  runApp(ProviderScope(child: MyApp()));
}

init() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var token;
  var userIsLoggedIn = false;
  bool screenLoaded = false;
  String userType = "";

  @override
  void initState() {
    super.initState();
    getLoggedInState();
    getLoggedInToken();

    showScreen();
  }

  getLoggedInState() async {
    await LoginData.getUserLoggedInSharedPreference().then((value) {
      if (mounted)
        setState(() {
          if (value != null) {
            userIsLoggedIn = value;
            Constants.isLoggedIn = value;
            if (value == true) {
              // getTokenSharedPreference();
            }
          } else {
            userIsLoggedIn = false;
          }
        });
    });
  }

  getLoggedInToken() async {
    await LoginData.getTokenSharedPreference().then((value) {
      if (mounted)
        setState(() {
          if (value != null) {
            Constants.token = value;
            loadAllTempData();
          } else {
            Constants.token = "";
          }
        });
    });
  }

  showScreen() async {
    await precacheImage(AssetImage('assets/rope.jpg'), context);
    await precacheImage(AssetImage('assets/user-login.jpg'), context);

    await precacheImage(
            AssetImage('assets/lesly-juarez-isWEKdSRCrA-unsplash.jpg'), context)
        .then((value) {});
    await precacheImage(AssetImage('assets/rope.jpg'), context);
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        screenLoaded = false;
      });
    });
  }

  loadAllTempData() async {
    await LoginData.getUserEmailSharedPreference().then((value) {
      if (mounted)
        setState(() {
          if (value != null) {
            Constants.email = value;
          } else {
            Constants.email = "";
          }
        });
    });

    await LoginData.getUserMobileSharedPreference().then((value) {
      if (mounted)
        setState(() {
          if (value != null) {
            Constants.mobile = value;
          } else {
            Constants.mobile = "";
          }
        });
    });

    await LoginData.getUserNameSharedPreference().then((value) {
      if (mounted)
        setState(() {
          if (value != null) {
            Constants.name = value;
          } else {
            Constants.name = "";
          }
        });
    });
    await LoginData.getUserTypeSharedPreference().then((value) {
      Future.delayed(
        Duration(seconds: 1),
        () {
          setState(() {
            if (value != null) {
              userType = value;
            } else {
              userType = "";
            }
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = {
      50: Color.fromRGBO(0, 255, 0, .1),
      100: Color.fromRGBO(0, 255, 0, .2),
      200: Color.fromRGBO(0, 255, 0, .3),
      300: Color.fromRGBO(0, 255, 0, .4),
      400: Color.fromRGBO(0, 255, 0, .5),
      500: Color.fromRGBO(0, 255, 0, .6),
      600: Color.fromRGBO(0, 255, 0, .7),
      700: Color.fromRGBO(0, 255, 0, .8),
      800: Color.fromRGBO(0, 255, 0, .9),
      900: Color.fromRGBO(0, 255, 0, 1),
    };
    MaterialColor colorCustom = MaterialColor(0xFF7BD19B, color);

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 Pro dimensions
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          color: Colors.white,
          debugShowCheckedModeBanner: false,
          title: 'Turf and Park',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case UserSignupStep1.id:
                return PageTransition(
                  child: const UserSignupStep1(),
                  type: PageTransitionType.scale,
                  curve: Curves.ease,
                  alignment: Alignment.center,
                  duration: const Duration(milliseconds: 300),
                  settings: settings,
                );
              case TurfList.id:
                return PageTransition(
                  child: const TurfList(),
                  type: PageTransitionType.scale,
                  curve: Curves.ease,
                  alignment: Alignment.center,
                  duration: const Duration(milliseconds: 300),
                  settings: settings,
                );
              case LoginUser.id:
                return PageTransition(
                  child: const LoginUser(),
                  type: PageTransitionType.scale,
                  curve: Curves.bounceIn,
                  alignment: Alignment.center,
                  duration: const Duration(milliseconds: 400),
                  settings: settings,
                );
              default:
                return null;
            }
          },
          theme: ThemeData(
            useMaterial3: true,
            primarySwatch: colorCustom,
          ),
          home: screenLoaded
              ? Material(
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 38.w), // Using .w for width
                        child: Image.asset("assets/logo.png"),
                      ),
                      SizedBox(height: 70.h), // Using .h for height
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ],
                  ),
                )
              : (userIsLoggedIn
                  ? (userType == "owner" ? OwnerTurfList() : TurfList())
                  : PreLoginUser()),
        );
      },
      child: Container(), // Empty container as child
    );
  }
}
