import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import '../helpers/helper_functions.dart';
import 'user_signup_step3.dart';
import '../helpers/widgets.dart';
import 'package:flutter/gestures.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

// import 'pre_login_owner.dart';
class UserSignupStep2 extends StatefulWidget {
  const UserSignupStep2(this.mobile_no);
  final String mobile_no;

  @override
  State<UserSignupStep2> createState() => _UserSignupStep2State();
}

class _UserSignupStep2State extends State<UserSignupStep2> {
  final TextEditingController phonecontroller = TextEditingController();
  TextEditingController textEditingController = TextEditingController();
  // ..text = "123456";

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false, isLoading = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: Duration(seconds: 2),
      ),
    );
  }

  validateOTP(context) async {
    // if(phonecontroller.text.length == 10){
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/user_verify_otp');
    var response = await http
        .post(url, body: {'mobile': widget.mobile_no, "otp": currentText});
    // 
    // 
    var body = jsonDecode(response.body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      showSnackbar(context, body['message']);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => UserSignupStep3(widget.mobile_no)));
      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserSignupStep2(this.phonecontroller.text.toString())));
    } else {
      showSnackbar(context, body['message']);
    }

    // 
    // }else{
    //   showSnackbar(context,"Please enter 10 digit valid mobile no");
    // }
  }

  resendOTP(context) async {
    // if(phonecontroller.text.length == 10){
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/user_resend_otp');
    var response = await http.post(url, body: {'mobile': widget.mobile_no});
    // 
    // 
    var body = jsonDecode(response.body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      showSnackbar(context, body['message']);
      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserSignupStep3(widget.mobile_no)));
      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserSignupStep2(this.phonecontroller.text.toString())));
    } else {
      showSnackbar(context, body['message']);
    }

    // 
    // }else{
    //   showSnackbar(context,"Please enter 10 digit valid mobile no");
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            color: Color(0xffF5F5F5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                Container(
                    child: Image.asset(
                  "assets/conifer-1109.png",
                  width: MediaQuery.of(context).size.width * 0.8,
                )),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "OTP Verification",
                      style: TextStyle(
                          fontSize: 26,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    )),
                SizedBox(
                  height: 25,
                ),
                Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter the 4 digit code Turf N Park just sent to " +
                          widget.mobile_no,
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500),
                    )),
                SizedBox(
                  height: 45,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: PinCodeTextField(
                    appContext: context,
                    pastedTextStyle: TextStyle(
                      color: Color(0xff6162F5),
                      fontWeight: FontWeight.bold,
                    ),
                    length: 4,
                    backgroundColor: Color(0xffF5F5F5),
                    // obscureText: true,
                    // obscuringCharacter: '*',
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    validator: (v) {
                      if (v!.length < 4) {
                        return "Please enter valid 4 digit OTP";
                      } else {
                        return null;
                      }
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50, activeColor: Color(0xff6162F5),
                      fieldWidth: 40, selectedColor: Color(0xff6162F5),
                      activeFillColor: Colors.white,
                      inactiveFillColor: Colors.white,
                      inactiveColor: Colors.grey,
                      selectedFillColor: Colors.white,
                      // selectedColor:Colors.green.shade300
                    ),
                    cursorColor: Color(0xff6162F5),
                    animationDuration: Duration(milliseconds: 300),
                    enableActiveFill: true,
                    errorAnimationController: errorController,
                    controller: textEditingController,
                    keyboardType: TextInputType.number,
                    boxShadows: [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                    onCompleted: (v) {
                      
                      
                    },
                    // onTap: () {
                    //   
                    // },
                    onChanged: (value) {
                      
                      setState(() {
                        currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      
                      //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                      //but you can show anything you want here, like your pop up saying wrong paste format or etc
                      return true;
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: RaisedGradientButton(
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'SUBMIT',
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
                        if (currentText.length == 4) {
                          validateOTP(context);
                          // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>UserSignupStep3()));
                        } else {
                          snackBar("Please fill OTP");
                        }
                      },
                      key: Key("test"),
                    )),
                SizedBox(
                  height: 50,
                ),
                Container(
                  alignment: Alignment.center,
                  child: RichText(
                      text: TextSpan(
                          text: "Didn't received the code ? ",
                          style: TextStyle(color: Colors.black, fontSize: 15),
                          children: <TextSpan>[
                        TextSpan(
                            text: ' Resend',
                            style: TextStyle(
                                color: Colors.blueAccent, fontSize: 16),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                resendOTP(context);
                                // navigate to desired screen
                              })
                      ])),
                ),
              ],
            ) /* add child content here */,
          ),
        ),
      ),
    );
  }
}
