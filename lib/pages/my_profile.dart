import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:turfandpark/helpers/login_data.dart';
import 'package:turfandpark/owner/turf_list.dart';
import 'package:turfandpark/pages/turfList.dart';

// import 'package:dotted_border/dotted_border.dart';
// import '../helpers/display_image.dart';
import '../helpers/helper_functions.dart';
import '../helpers/widgets.dart';

// import 'pre_login_owner.dart';
class MyProfile extends StatefulWidget {
  final usertype;
  MyProfile(this.usertype);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  bool showPassword = true;
  bool showNewPassword = true;
  bool isLoading = false;
  bool isLoadingName = false;
  bool isLoadingEmail = false;
  TextEditingController nameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController mobileEditingController = TextEditingController();
  TextEditingController newpasswordEditingController = TextEditingController();
  TextEditingController oldpasswordEditingController = TextEditingController();

  @override
  initState() {
    super.initState();
    emailEditingController.text = Constants.email;
    mobileEditingController.text = Constants.mobile;
    nameEditingController.text = Constants.name;
  }

  pushmeBack() {
    widget.usertype == "owner"
        ? Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => OwnerTurfList()))
        : Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => TurfList()));
  }

  validateAndSubmit(context) async {
    if (newpasswordEditingController.text.length <= 1) {
      showSnackbar(context, "Please enter new password");
      return false;
    }
    if (oldpasswordEditingController.text.length <= 1) {
      showSnackbar(context, "Please enter old password");
      return false;
    }

    setState(() {
      isLoading = true;
    });

    var url = widget.usertype == 'owner'
        ? Uri.parse(Constants.base_url + 'Service/owner_change_password')
        : Uri.parse(Constants.base_url + 'Service/user_change_password');
    var response = await http.post(url, body: {
      'old_password': oldpasswordEditingController.text,
      'new_password': newpasswordEditingController.text,
      'userToken': Constants.token,
    });
    //

    var body = jsonDecode(response.body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      showSnackbar(context, body['message']);
      // Navigator.of(context).pop();
      pushmeBack();
      // Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (context) => LoginUser()));
      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserSignupStep2(this.phonecontroller.text.toString())));
    } else {
      showSnackbar(context, body['message']);
    }
  }

  validateAndSubmitName(context) async {
    if (nameEditingController.text.length <= 2) {
      showSnackbar(context, "Please enter your name");
      return false;
    }

    setState(() {
      isLoadingName = true;
    });

    var url = widget.usertype == 'owner'
        ? Uri.parse(Constants.base_url + 'Service/owner_edit_profile')
        : Uri.parse(Constants.base_url + 'Service/user_edit_profile');
    var response = await http.post(url, body: {
      'name': nameEditingController.text,
      'userToken': Constants.token
    });
    //

    var body = jsonDecode(response.body);
    setState(() {
      isLoadingName = false;
    });
    if (response.statusCode == 200) {
      Constants.name = nameEditingController.text;
      LoginData.saveUserNamePreference(nameEditingController.text);
      showSnackbar(context, body['message']);

      // Navigator.of(context).pop();
      pushmeBack();
      // Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (context) => LoginUser()));
      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserSignupStep2(this.phonecontroller.text.toString())));
    } else {
      showSnackbar(context, body['message']);
    }
  }

  validateAndSubmitEmailAndMobile(context) async {
    if (emailEditingController.text.length == 0 ||
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(emailEditingController.text)) {
      showSnackbar(context, "Please enter valid Email");
      return false;
    }
    if (mobileEditingController.text.length != 10) {
      showSnackbar(context, "Please enter valid 10 digit Mobile no");
      return false;
    }

    setState(() {
      isLoadingEmail = true;
    });
    String _flag = '';

    if (emailEditingController.text != Constants.email &&
        mobileEditingController.text != Constants.mobile) {
      _flag = 'both';
    } else if (mobileEditingController.text != Constants.mobile) {
      _flag = 'mobile';
    } else {
      _flag = 'email';
    }

    var url = Uri.parse(Constants.base_url + 'Owner/update_mobile_email');
    var response = await http.post(url, body: {
      "flag": _flag,
      "email": emailEditingController.text,
      "mobile": mobileEditingController.text,
      'userToken': Constants.token
    });
    //

    var body = jsonDecode(response.body);
    setState(() {
      isLoadingEmail = false;
    });
    if (response.statusCode == 200) {
      LoginData.saveUserEmailSharedPreference(emailEditingController.text);
      LoginData.saveUserMobileSharedPreference(mobileEditingController.text);
      Constants.email = emailEditingController.text;
      Constants.mobile = mobileEditingController.text;
      showSnackbar(context, body['message']);

      // Navigator.of(context).pop();
      pushmeBack();
      // Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (context) => LoginUser()));
      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserSignupStep2(this.phonecontroller.text.toString())));
    } else {
      showSnackbar(context, body['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
          ),
          onPressed: () {
            pushmeBack();
            // Navigator.of(context).pop();
          },
        ),
        title: Text(
          "My Profile",
          style: TextStyle(
              fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Color.fromARGB(255, 238, 238, 238),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: nameEditingController,
                            cursorColor: Colors.green.shade400,
                            decoration: InputDecoration(
                              hintText: "Name",
                              disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.green.shade400, width: 5),
                              ),
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
                                borderSide:
                                    BorderSide(color: Colors.green.shade400),
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
                          Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: RaisedGradientButton(
                                child: isLoadingName
                                    ? CircularProgressIndicator()
                                    : Text(
                                        'Update Username',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    Colors.green.shade500,
                                    Colors.green.shade600,
                                  ],
                                ),
                                onPressed: () {
                                  validateAndSubmitName(context);
                                },
                                key: Key("test"),
                              )),
                          SizedBox(
                            height: 10,
                          ),
                          if (widget.usertype == "owner")
                            Divider(
                              color: Colors.white,
                            ),
                          SizedBox(
                            height: 10,
                          ),
                          if (widget.usertype == "owner")
                            Column(children: [
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Change Email/Mobile",
                                    style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  )),
                              SizedBox(
                                height: 25,
                              ),
                              TextFormField(
                                controller: emailEditingController,
                                cursorColor: Colors.green.shade400,
                                decoration: InputDecoration(
                                  hintText: "email",
                                  disabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.green.shade400, width: 5),
                                  ),
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
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: mobileEditingController,
                                cursorColor: Colors.green.shade400,
                                decoration: InputDecoration(
                                  hintText: "phone",
                                  disabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.green.shade400, width: 5),
                                  ),
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
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  child: RaisedGradientButton(
                                    child: isLoadingEmail
                                        ? CircularProgressIndicator()
                                        : Text(
                                            'Update Email / Mobile',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                    gradient: LinearGradient(
                                      colors: <Color>[
                                        Colors.green.shade500,
                                        Colors.green.shade600,
                                      ],
                                    ),
                                    onPressed: () {
                                      validateAndSubmitEmailAndMobile(context);
                                    },
                                    key: Key("test"),
                                  )),
                            ]),
                          Divider(
                            color: Colors.black12,
                          ),
                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Change Password",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              )),
                          SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            controller: oldpasswordEditingController,
                            obscureText: showPassword,
                            cursorColor: Colors.green.shade400,
                            decoration: InputDecoration(
                              hintText: "Old Password",
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
                                borderSide:
                                    BorderSide(color: Colors.green.shade400),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white30),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              suffixIcon: IconButton(
                                icon: showPassword
                                    ? Icon(
                                        Icons.visibility,
                                        color: Colors.green.shade400,
                                      )
                                    : Icon(
                                        Icons.visibility_off,
                                        color: Colors.grey,
                                      ),
                                onPressed: () {
                                  setState(() {
                                    this.showPassword = !this.showPassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: newpasswordEditingController,
                            obscureText: showNewPassword,
                            cursorColor: Colors.green.shade400,
                            decoration: InputDecoration(
                                hintText: "New Password",
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
                                  borderSide:
                                      BorderSide(color: Colors.green.shade400),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white30),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                suffixIcon: IconButton(
                                  icon: showNewPassword
                                      ? Icon(
                                          Icons.visibility,
                                          color: Colors.green.shade400,
                                        )
                                      : Icon(
                                          Icons.visibility_off,
                                          color: Colors.grey,
                                        ),
                                  onPressed: () {
                                    setState(() {
                                      this.showNewPassword =
                                          !this.showNewPassword;
                                    });
                                  },
                                )),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: RaisedGradientButton(
                                child: isLoading
                                    ? CircularProgressIndicator()
                                    : Text(
                                        'Change Password',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                        ),
                                      ),
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    Colors.green.shade500,
                                    Colors.green.shade600,
                                  ],
                                ),
                                onPressed: () {
                                  validateAndSubmit(context);
                                },
                                key: Key("test"),
                              )),
                          SizedBox(
                            height: 25,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
