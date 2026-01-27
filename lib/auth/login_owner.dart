import 'dart:convert';
import 'dart:ui';

import 'package:animate_do/animate_do.dart';
import 'package:bouncing_widget/bouncing_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../helpers/helper_functions.dart';
import '../helpers/login_data.dart';
import '../owner/turf_list.dart';

// import 'pre_login_owner.dart';
class LoginOwner extends StatefulWidget {
  const LoginOwner({Key? key}) : super(key: key);

  @override
  State<LoginOwner> createState() => _LoginOwnerState();
}

class _LoginOwnerState extends State<LoginOwner> {
  final TextEditingController phonecontroller = TextEditingController();
  final TextEditingController passwordcontroller = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = true;
  validateAndLogin(context) async {
    if (phonecontroller.text.length == 10) {
      setState(() {
        isLoading = true;
      });
      var url = Uri.parse(Constants.base_url + 'Service/owner_sign_in');
      var response = await http.post(url, body: {
        'mobile': phonecontroller.text,
        'password': passwordcontroller.text
      });
     
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
        LoginData.saveUserTypeSharedPreference("owner");
        Constants.token = body['data']['token'];
        Constants.name = body['data']['name'];
        Constants.email = body['data']['email'];
        Constants.mobile = body['data']['mobile'];
        Constants.type = "owner";
        Constants.isLoggedIn = true;
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => OwnerTurfList()));
      } else {
        showSnackbar(context, body['message']);
      }

    
    } else {
      showSnackbar(context, "Please enter 10 digit valid mobile no");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      duration: Duration(milliseconds: 700),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Colors.black,
                image: DecorationImage(
                  alignment: Alignment.centerRight,
                  colorFilter: new ColorFilter.mode(
                      Colors.black.withOpacity(0.2), BlendMode.dstATop),
                  // opacity: 0.5,
                  image:
                      AssetImage('assets/darko-nesic-VZEnVM6c1lY-unsplash.jpg'),
                  fit: BoxFit.fitHeight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // SizedBox(height: 10,),
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
                  Spacer(),
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
                            child: Column(
                              children: [
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
                                  height: 10,
                                ),
                                Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Seller",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white70,
                                          fontWeight: FontWeight.w700),
                                    )),
                                SizedBox(
                                  height: 20,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  child: Form(
                                    child: Column(
                                      children: [
                                        TextFormField(
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
                                                    fontWeight:
                                                        FontWeight.normal),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 15),
                                            prefixIconConstraints:
                                                const BoxConstraints(
                                                    minWidth: 40,
                                                    maxHeight: 25),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.green.shade400),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white30),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        TextFormField(
                                          controller: passwordcontroller,
                                          obscureText: isPasswordVisible,
                                          decoration: InputDecoration(
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
                                            prefixIcon: Icon(
                                              Icons.lock,
                                              color: Colors.green.shade400,
                                              size: 17,
                                            ),
                                            hintText: "Password",
                                            hintStyle: Theme.of(this.context)
                                                .textTheme
                                                .titleSmall!
                                                .copyWith(
                                                    color: Colors.green.shade400
                                                        .withOpacity(0.5),
                                                    fontWeight:
                                                        FontWeight.normal),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 15),
                                            prefixIconConstraints:
                                                const BoxConstraints(
                                                    minWidth: 40,
                                                    maxHeight: 25),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.green.shade400),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                            enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.white30),
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
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          child: BouncingWidget(
                                            duration:
                                                Duration(milliseconds: 100),
                                            scaleFactor: 1,
                                            onPressed: () {
                                              validateAndLogin(context);
                                            },
                                            child: Container(
                                              height: 50,
                                              width: 240,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        100.0),
                                                color: Colors.green.shade500,
                                              ),
                                              child: Center(
                                                child: isLoading
                                                    ? CircularProgressIndicator()
                                                    : Text(
                                                        'Login',
                                                        style: TextStyle(
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                      ],
                                    ),
                                  ),
                                )
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
