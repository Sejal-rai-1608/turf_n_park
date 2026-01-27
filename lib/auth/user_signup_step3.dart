import 'dart:convert';

import 'package:flutter/material.dart';
import '../helpers/widgets.dart';
import '../helpers/helper_functions.dart';
import 'package:http/http.dart' as http;

import 'login_user.dart';

// import 'pre_login_owner.dart';
class UserSignupStep3 extends StatefulWidget {
  // const UserSignupStep3({ Key? key }) : super(key: key);
  const UserSignupStep3(this.mobile_no);
  final String mobile_no;

  @override
  State<UserSignupStep3> createState() => _UserSignupStep3State();
}

class _UserSignupStep3State extends State<UserSignupStep3> {
  bool showPassword = true;
  bool isLoading = false;

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();
  TextEditingController cpasswordEditingController = TextEditingController();
  validateAndSubmit(context) async {
    if (nameEditingController.text.length <= 2) {
      showSnackbar(context, "Please enter your name");
      return false;
    }

    if (emailEditingController.text.length == 0 ||
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(emailEditingController.text)) {
      showSnackbar(context, "Please enter valid Email");
      return false;
    }

    if (passwordEditingController.text.length <= 1) {
      showSnackbar(context, "Please enter password");
      return false;
    }

    if (cpasswordEditingController.text != passwordEditingController.text) {
      showSnackbar(context, "Password And Confirm password should be same.");
      return false;
    }

    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/user_sign_up_step2');
    var response = await http.post(url, body: {
      'mobile': widget.mobile_no,
      'name': nameEditingController.text,
      'email': emailEditingController.text,
      'password': passwordEditingController.text
    });
    //
    //
    var body = jsonDecode(response.body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      showSnackbar(context, body['message']);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginUser()));
      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserSignupStep2(this.phonecontroller.text.toString())));
    } else {
      showSnackbar(context, body['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: Color(0xffF5F5F5),
            child: Column(
              children: [
                // SizedBox(height: 10,),
                Container(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/conifer-190.png",
                      width: MediaQuery.of(context).size.width * 0.8,
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Sign up",
                        style: TextStyle(
                            fontSize: 38,
                            color: Color(0xFF4242B6),
                            fontWeight: FontWeight.bold),
                      )),
                ),
                SizedBox(
                  height: 20,
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameEditingController,
                          cursorColor: Color(0xff6162F5),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.person,
                              color: Color(0xff6162F5),
                              size: 17,
                            ),
                            hintText: "Username",
                            hintStyle: Theme.of(this.context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Color(0xff6162F5).withOpacity(0.5),
                                    fontWeight: FontWeight.normal),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            prefixIconConstraints: const BoxConstraints(
                                minWidth: 40, maxHeight: 25),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff6162F5)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: emailEditingController,
                          cursorColor: Color(0xff6162F5),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: Color(0xff6162F5),
                              size: 17,
                            ),
                            hintText: "Email",
                            hintStyle: Theme.of(this.context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Color(0xff6162F5).withOpacity(0.5),
                                    fontWeight: FontWeight.normal),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            prefixIconConstraints: const BoxConstraints(
                                minWidth: 40, maxHeight: 25),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff6162F5)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: passwordEditingController,
                          obscureText: showPassword,
                          cursorColor: Color(0xff6162F5),
                          decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: showPassword
                                  ? Icon(Icons.visibility)
                                  : Icon(Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  this.showPassword = !this.showPassword;
                                });
                              },
                            ),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Color(0xff6162F5),
                              size: 17,
                            ),
                            hintText: "Password",
                            hintStyle: Theme.of(this.context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Color(0xff6162F5).withOpacity(0.5),
                                    fontWeight: FontWeight.normal),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            prefixIconConstraints: const BoxConstraints(
                                minWidth: 40, maxHeight: 25),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff6162F5)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          controller: cpasswordEditingController,
                          obscureText: true,
                          decoration: InputDecoration(
                            // hintText: "Mobile No.",
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Color(0xff6162F5),
                              size: 17,
                            ),
                            hintText: "Confirm Password",
                            hintStyle: Theme.of(this.context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Color(0xff6162F5).withOpacity(0.5),
                                    fontWeight: FontWeight.normal),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 15),
                            prefixIconConstraints: const BoxConstraints(
                                minWidth: 40, maxHeight: 25),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff6162F5)),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white30),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: RaisedGradientButton(
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white)
                                  : Text(
                                      'Signup',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color(0xff6162F5),
                                  Color(0xff6162F5),
                                ],
                              ),
                              onPressed: () {
                                validateAndSubmit(context);
                              },
                              key: Key("test"),
                            ))
                      ],
                    ),
                  ),
                )
              ],
            ) /* add child content here */,
          ),
        ),
      ),
    );
  }
}
