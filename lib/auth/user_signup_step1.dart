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
import 'user_signup_step2.dart';

// import 'pre_login_owner.dart';
class UserSignupStep1 extends StatefulWidget {
  static const String id = 'UserSignupStep1_screen';
  const UserSignupStep1({Key? key}) : super(key: key);

  @override
  State<UserSignupStep1> createState() => _UserSignupStep1State();
}

class _UserSignupStep1State extends State<UserSignupStep1> {
  final TextEditingController phonecontroller = TextEditingController();
  bool isLoading = false;

  bool isLoading1 = false;
  bool isLoading2 = false;

  validateSignup(context) async {
    if (phonecontroller.text.length == 10) {
      setState(() {
        isLoading = true;
      });
      var url = Uri.parse(Constants.base_url + 'Service/user_sign_up');
      var response =
          await http.post(url, body: {'mobile': phonecontroller.text});
      //
      //
      var body = jsonDecode(response.body);
      setState(() {
        isLoading = false;
      });
      if (response.statusCode == 200) {
        showSnackbar(context, body['message']);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                UserSignupStep2(this.phonecontroller.text.toString())));
      } else {
        showSnackbar(context, body['message']);
      }

      //
    } else {
      showSnackbar(context, "Please enter 10 digit valid mobile no");
    }
  }

  signInWithGoogle(context) async {
    await Firebase.initializeApp();
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
    //
    //
    //
    //
    //
    setState(() {
      isLoading1 = true;
    });
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: FadeIn(
            duration: Duration(milliseconds: 700),
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  alignment: Alignment.topRight,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.2), BlendMode.dstATop),
                  // opacity: 0.5,
                  image: AssetImage(
                      'assets/miguel-bruna-lsSpxsTDy54-unsplash.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  // SizedBox(height: 10,),
                  Container(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Spacer(),
                  FadeInUp(
                    duration: Duration(milliseconds: 700),
                    child: Container(
                        padding: EdgeInsets.all(8),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: 38,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )),
                  ),

                  FadeInUp(
                    duration: Duration(milliseconds: 700),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.black38,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Column(
                              children: [
                                Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Enter your phone number to sign  up",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.white54,
                                          fontWeight: FontWeight.w500),
                                    )),
                                SizedBox(
                                  height: 16,
                                ),
                                TextFormField(
                                  controller: phonecontroller,
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
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 15),
                                    prefixIconConstraints: const BoxConstraints(
                                        minWidth: 40, maxHeight: 25),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.green.shade400),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white30),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                // Row(
                                //   mainAxisAlignment: MainAxisAlignment.start,
                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                //   children: [
                                //     Container(
                                //       child:Text("+91 "),
                                //     ),
                                //     TextFormField(
                                //       decoration: InputDecoration(
                                //         // hintText: "Mobile No.",
                                //         labelText: "Phone Number",
                                //         labelStyle: TextStyle(
                                //           color: Colors.grey
                                //         )
                                //       ),
                                //     )
                                //   ],
                                // ),
                                // InternationalPhoneNumberInput(
                                //   onInputChanged: (PhoneNumber number) {
                                //
                                //   },
                                //   onInputValidated: (bool value) {
                                //
                                //   },
                                //   selectorConfig: SelectorConfig(
                                //     selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                                //     trailingSpace: false,
                                //   ),
                                //   ignoreBlank: false,
                                //   autoValidateMode: AutovalidateMode.disabled,
                                //   selectorTextStyle: TextStyle(color: Colors.black),
                                //   // initialValue: number,
                                //   textFieldController: phonecontroller,
                                //   formatInput: false,
                                //   keyboardType:
                                //       TextInputType.numberWithOptions(signed: true, decimal: true),
                                //   // inputBorder: OutlineInputBorder(),
                                //   onSaved: (PhoneNumber number) {
                                //
                                //   },
                                // ),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20))),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.green.shade600)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: isLoading
                                              ? CircularProgressIndicator(
                                                  color: Colors.white,
                                                )
                                              : Text(
                                                  'Proceed',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                        ),
                                        onPressed: () {
                                          validateSignup(context);
                                          // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserSignupStep2(this.phonecontroller.text.toString())));
                                          //
                                        },
                                        key: Key("test"),
                                      ),
                                    )),
                                SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "OR",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.white54,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                // SizedBox(
                                //   height: 20,
                                // ),
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
                  Spacer(),
                ],
              ) /* add child content here */,
            ),
          ),
        ),
      ),
    );
  }
}
