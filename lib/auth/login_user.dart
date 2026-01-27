import 'dart:convert';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper_functions.dart';
import '../helpers/login_data.dart';
import '../pages/selectType.dart';

// import 'pre_login_owner.dart';
class LoginUser extends StatefulWidget {
  static const String id = 'login_screen';
  const LoginUser({Key? key}) : super(key: key);

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  final TextEditingController phonecontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  bool isLoading = false;
  bool isLoading1 = false;
  bool isLoading2 = false;
  bool isPasswordVisible = true;
  @override
  initState() {
    super.initState();
    Firebase.initializeApp();
    GoogleSignIn().signOut();
  }

  validateAndLogin(context) async {
    if (phonecontroller.text.length == 10) {
      setState(() {
        isLoading = true;
      });
      var url = Uri.parse(Constants.base_url + 'Service/user_sign_in');
      var response = await http.post(
        url,   
        body: {
          'mobile': phonecontroller.text,
          'password': passwordcontroller.text
        },
      );
      var body = jsonDecode(response.body);
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        showSnackbar(context, body['message']);
        LoginData.saveUserLoggedInSharedPreference(true);
        LoginData.saveTokenSharedPreference(body['data']['token']);
        LoginData.saveUserNamePreference(body['data']['name']);
        LoginData.saveUserEmailSharedPreference(body['data']['email']);
        LoginData.saveUserMobileSharedPreference(body['data']['mobile']);
        LoginData.saveUserTypeSharedPreference('user');
        Constants.token = body['data']['token'];
        Constants.name = body['data']['name'];
        Constants.email = body['data']['email'];
        Constants.mobile = body['data']['mobile'];
        Constants.type = 'user';
        Constants.isLoggedIn = true;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SelectType()));
      } else {
        showSnackbar(context, body['message']);
      }

      //
    } else {
      showSnackbar(context, "Please enter 10 digit valid mobile no");
    }
  }

  signInWithGoogle(context) async {
    setState(() {
      isLoading1 = true;
    });

    // Trigger the authentication flow
    // await Firebase.initializeApp();
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    UserCredential data =
        await FirebaseAuth.instance.signInWithCredential(credential);
    

    validateSocialLogin(context, data.user?.displayName, data.user?.email,
        data.user?.uid, "google");
    // return data;
  }

  signInWithFacebook(context) async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(
            loginResult.accessToken?.token as String);

    // Once signed in, return the UserCredential
    var data;
    data = await FirebaseAuth.instance
        .signInWithCredential(facebookAuthCredential);
    //
    //
    setState(() {
      isLoading2 = true;
    });
    validateSocialLogin(context, data.user?.displayName, data.user?.email,
        data.user?.uid, "facebook");
    // return data;
  }

  validateSocialLogin(context, name, email, uid, provider) async {
    if (uid.length > 2) {
      // setState(() {
      //   isLoading = true;
      // });
      var url = Uri.parse(Constants.base_url + 'Service/user_sign_in_social');
      var response = await http.post(url, body: {
        'name': name.toString(),
        'email': email.toString(),
        'uid': uid.toString(),
        'provider': provider,
      });
      //
      //
      var body = jsonDecode(response.body);
      setState(() {
        isLoading1 = false;
        isLoading2 = false;
      });
      if (response.statusCode == 200) {
        showSnackbar(context, body['message']);
        LoginData.saveUserLoggedInSharedPreference(true);
        LoginData.saveTokenSharedPreference(body['data']['token']);
        LoginData.saveUserNamePreference(body['data']['name']);
        LoginData.saveUserEmailSharedPreference(body['data']['email']);
        LoginData.saveUserMobileSharedPreference(body['data']['mobile']);
        LoginData.saveUserTypeSharedPreference('user');
        Constants.token = body['data']['token'];
        Constants.name = body['data']['name'];
        Constants.email = body['data']['email'];
        Constants.mobile = body['data']['mobile'];
        Constants.type = 'user';
        Constants.isLoggedIn = true;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SelectType()));
      } else {
        showSnackbar(context, body['message']);
      }

      //
    } else {
      showSnackbar(context, "Please enter 10 digit valid mobile no");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: FadeIn(
          duration: Duration(milliseconds: 700),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.2), BlendMode.dstATop),
                  // opacity: 0.5,
                  image: AssetImage(
                      'assets/henrique-macedo-8RzMsxk3wgg-unsplash.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_outlined),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  // Spacer(),
                  // Container(
                  //     alignment: Alignment.center,
                  //     child: Image.asset(
                  //       "assets/user-login.jpg",
                  //       width: 280,
                  //     )),

                  SizedBox(
                    height: 20,
                  ),
                  FadeInUp(
                    duration: Duration(milliseconds: 600),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black38,
                        ),
                        clipBehavior: Clip.antiAlias,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                            child: Form(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Welcome to Turf N Park",
                                        style: TextStyle(
                                            fontSize: 26,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700),
                                      )),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  TextField(
                                    controller: phonecontroller,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(10)
                                    ],
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.call,
                                        color: Colors.green.shade400,
                                        size: 17,
                                      ),
                                      hintText: "Mobile No",
                                      hintStyle: Theme.of(this.context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              color: Colors.green.shade400
                                                  .withOpacity(0.5),
                                              fontWeight: FontWeight.normal),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 15),
                                      prefixIconConstraints:
                                          const BoxConstraints(
                                              minWidth: 40, maxHeight: 25),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.green.shade400),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white30),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  TextField(
                                    controller: passwordcontroller,
                                    obscureText: isPasswordVisible,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.green.shade400,
                                        size: 17,
                                      ),
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isPasswordVisible =
                                                !isPasswordVisible;
                                          });
                                        },
                                        child: Icon(
                                          isPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: Colors.green.shade400,
                                          size: 17,
                                        ),
                                      ),
                                      hintText: "Password",
                                      hintStyle: Theme.of(this.context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(
                                              color: Colors.green.shade400
                                                  .withOpacity(0.5),
                                              fontWeight: FontWeight.normal),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 15),
                                      prefixIconConstraints:
                                          const BoxConstraints(
                                              minWidth: 40, maxHeight: 25),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.green.shade400),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white30),
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 40,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: BouncingWidget(
                                      duration: Duration(milliseconds: 100),
                                      scaleFactor: 1,
                                      onPressed: () {
                                        validateAndLogin(context);
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 240,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          color: Colors.green.shade500,
                                        ),
                                        child: Center(
                                          child: isLoading
                                              ? CircularProgressIndicator(
                                                  color: Colors.white)
                                              : Text(
                                                  'Login',
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    child: BouncingWidget(
                                      duration: Duration(milliseconds: 100),
                                      scaleFactor: 1,
                                      onPressed: () {
                                        if(!isLoading1)
                                        var res = signInWithGoogle(context);
                                      },
                                      child: Container(
                                        height: 50,
                                        width: 350,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(100.0),
                                          color: Colors.grey[100],
                                        ),
                                        child: Center(
                                          child: isLoading1
                                              ? CircularProgressIndicator(
                                                  color: Colors.green[400])
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset(
                                                      'assets/google.png',
                                                      height: 25,
                                                      width: 25,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      'Login With Google',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  // Container(
                                  //   padding: EdgeInsets.all(10),
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(20),
                                  //   ),
                                  //   width:
                                  //       MediaQuery.of(context).size.width * 0.8,
                                  //   child: BouncingWidget(
                                  //     duration: Duration(milliseconds: 100),
                                  //     scaleFactor: 1,
                                  //     onPressed: () async {
                                  //       var res =
                                  //           await signInWithFacebook(context);
                                  //       //
                                  //       // var user;
                                  //       //
                                  //     },
                                  //     child: Container(
                                  //       height: 50,
                                  //       width: 350,
                                  //       decoration: BoxDecoration(
                                  //         borderRadius:
                                  //             BorderRadius.circular(100.0),
                                  //         color: Colors.blue.shade400,
                                  //       ),
                                  //       child: Center(
                                  //         child: isLoading2
                                  //             ? CircularProgressIndicator(
                                  //                 color: Colors.white)
                                  //             : Text(
                                  //                 'Login With Facebook',
                                  //                 style: TextStyle(
                                  //                   fontSize: 20.0,
                                  //                   fontWeight: FontWeight.bold,
                                  //                   color: Colors.white,
                                  //                 ),
                                  //               ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
