import 'package:flutter/material.dart';
import 'package:turfandpark/pre_login_user.dart';

// const String base_url = "https://turfnpark.googlehai.com/app_api/index.php/";
class Constants {
  // static String base_url = "https://turfnpark.googlehai.com/app_api/index.php/";
  static String base_url =
      "https://cosmicwebsolution.shop/turfnpark/app_api/index.php/";
  //"https://turfnpark.com/app_api/index.php/";
  static String name = "";
  static String email = "";
  static String mobile = "";
  static String token = "";
  static String type = "";
  static bool isLoggedIn = false;

  static String country_id = "";
  static String state_id = "";
  static String city_id = "";
  static String fullLocation = "";
  static String lat = "";
  static String long = "";
}

class HelperFunction {}

showSnackbar(context, message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),

      // action: SnackBarAction(
      //   label: 'Action',
      //   onPressed: () {
      //     // Code to execute.
      //   },
      // ),
    ),
  );
}

onLogout(context) {
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => PreLoginUser()));
}
