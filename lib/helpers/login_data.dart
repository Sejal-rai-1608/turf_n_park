import 'package:shared_preferences/shared_preferences.dart';

class LoginData{

  static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  static String sharedPreferenceUserTokenKey = "USERTOKEN";
  static String sharedPreferenceUserNameKey = "USERNAMEKEY";
  static String sharedPreferenceUserEmailKey = "USEREMAILKEY"; 
  static String sharedPreferenceUserMobileKey = "USERMOBILEKEY";
  static String sharedPreferenceUserProfileImageKey = "USERPROFILEIMGKEY";
  static String sharedPreferenceUserTypeKey = "USERTYPE";

  /// saving data to sharedpreference
  static Future<bool> saveUserLoggedInSharedPreference(bool isUserLoggedIn) async{

    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }

  static Future<bool> saveTokenSharedPreference(String userName) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserTokenKey, userName);
  }
  static Future<bool> saveUserNamePreference(String uName) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserNameKey, uName);
  }
  static Future<bool> saveProfileImagePreference(String img) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserProfileImageKey, img);
  }

  static Future<bool> saveUserEmailSharedPreference(String userEmail) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserEmailKey, userEmail);
  }
  static Future<bool> saveUserMobileSharedPreference(String userMobile) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserMobileKey, userMobile);
  }
  static Future<bool> saveUserTypeSharedPreference(String userType) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setString(sharedPreferenceUserTypeKey, userType);
  }



  static Future<String?> getUserProfileImgSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(sharedPreferenceUserProfileImageKey);
  }
  static Future<bool?> getUserLoggedInSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return  preferences.getBool(sharedPreferenceUserLoggedInKey);
  }
  static Future<String?> getTokenSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return  preferences.getString(sharedPreferenceUserTokenKey);
  }


  static Future<String?> getUserNameSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return  preferences.getString(sharedPreferenceUserNameKey);
  }
  static Future<String?> getUserEmailSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return  preferences.getString(sharedPreferenceUserEmailKey);
  }

   static Future<String?> getUserMobileSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return  preferences.getString(sharedPreferenceUserMobileKey);
  }
  static Future<String?> getUserTypeSharedPreference() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return  preferences.getString(sharedPreferenceUserTypeKey);
  }




}