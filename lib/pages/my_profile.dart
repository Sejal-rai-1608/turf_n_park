import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Add this
import 'package:http/http.dart' as http;
import 'package:turfandpark/helpers/login_data.dart';
import 'package:turfandpark/owner/turf_list.dart';
import 'package:turfandpark/pages/turfList.dart';
import '../helpers/helper_functions.dart';
import '../helpers/widgets.dart';

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

    var body = jsonDecode(response.body);
    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      showSnackbar(context, body['message']);
      pushmeBack();
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

    var body = jsonDecode(response.body);
    setState(() {
      isLoadingName = false;
    });
    if (response.statusCode == 200) {
      Constants.name = nameEditingController.text;
      LoginData.saveUserNamePreference(nameEditingController.text);
      showSnackbar(context, body['message']);
      pushmeBack();
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
      pushmeBack();
    } else {
      showSnackbar(context, body['message']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20.r),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
          onPressed: () {
            pushmeBack();
          },
        ),
        title: Text(
          "My Profile",
          style: TextStyle(
            fontSize: 20.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.green.shade100,
                    width: 1.5.w,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.shade100,
                        border: Border.all(
                          color: Colors.green.shade300,
                          width: 2.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade100,
                            blurRadius: 10.r,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40.sp,
                        color: Colors.green.shade600,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Constants.name.isNotEmpty
                                ? Constants.name
                                : "Your Name",
                            style: TextStyle(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            Constants.email.isNotEmpty
                                ? Constants.email
                                : "Email not set",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            Constants.mobile.isNotEmpty
                                ? "Mobile: ${Constants.mobile}"
                                : "Mobile not set",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25.h),

              // Update Name Section
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.green.shade200,
                    width: 1.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade100,
                      blurRadius: 15.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          color: Colors.green.shade700,
                          size: 22.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "Update Your Name",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15.h),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade100,
                            blurRadius: 5.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: nameEditingController,
                        cursorColor: Colors.green.shade600,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade800,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter your name",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15.sp,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Colors.green.shade600,
                            size: 22.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5.w,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.green.shade600,
                              width: 2.w,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5.w,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          validateAndSubmitName(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.w,
                            vertical: 16.h,
                          ),
                          elevation: 4,
                          shadowColor: Colors.green.shade300,
                        ),
                        child: isLoadingName
                            ? Container(
                                height: 24.h,
                                width: 24.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5.w,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Update Name',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Update Email & Mobile Section (Only for owner)
              if (widget.usertype == "owner")
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.blue.shade100,
                      width: 1.5.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.shade50,
                        blurRadius: 15.r,
                        offset: Offset(0, 5.h),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            color: Colors.blue.shade700,
                            size: 22.sp,
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            "Update Email & Mobile",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // Email Field
                      Container(
                        margin: EdgeInsets.only(bottom: 15.h),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 5.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: emailEditingController,
                          cursorColor: Colors.blue.shade600,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade800,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter your email",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15.sp,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.blue.shade600,
                              size: 22.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5.w,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.blue.shade600,
                                width: 2.w,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Mobile Field
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade100,
                              blurRadius: 5.r,
                              offset: Offset(0, 2.h),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: mobileEditingController,
                          cursorColor: Colors.blue.shade600,
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade800,
                          ),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: "Enter your mobile number",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 15.sp,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 16.h,
                            ),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: Colors.blue.shade600,
                              size: 22.sp,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1.5.w,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Colors.blue.shade600,
                                width: 2.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            validateAndSubmitEmailAndMobile(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 30.w,
                              vertical: 16.h,
                            ),
                            elevation: 4,
                            shadowColor: Colors.blue.shade300,
                          ),
                          child: isLoadingEmail
                              ? Container(
                                  height: 24.h,
                                  width: 24.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5.w,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Update Email & Mobile',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

              if (widget.usertype == "owner") SizedBox(height: 20.h),

              // Change Password Section
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: Colors.lightGreen.shade100,
                    width: 1.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.lightGreen.shade50,
                      blurRadius: 15.r,
                      offset: Offset(0, 5.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lock_outline,
                          color: Colors.green.shade900,
                          size: 22.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "Change Password",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),

                    // Old Password Field
                    Container(
                      margin: EdgeInsets.only(bottom: 15.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade100,
                            blurRadius: 5.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: oldpasswordEditingController,
                        obscureText: showPassword,
                        cursorColor: Colors.lightGreen.shade700,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade100,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter old password",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15.sp,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Colors.lightGreen.shade700,
                            size: 22.sp,
                          ),
                          suffixIcon: IconButton(
                            icon: showPassword
                                ? Icon(
                                    Icons.visibility,
                                    color: Colors.grey.shade500,
                                    size: 22.sp,
                                  )
                                : Icon(
                                    Icons.visibility_off,
                                    color: Colors.grey.shade500,
                                    size: 22.sp,
                                  ),
                            onPressed: () {
                              setState(() {
                                showPassword = !showPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5.w,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.lightGreen.shade700,
                              width: 2.w,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // New Password Field
                    Container(
                      margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade100,
                            blurRadius: 5.r,
                            offset: Offset(0, 2.h),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        controller: newpasswordEditingController,
                        obscureText: showNewPassword,
                        cursorColor: Colors.lightGreen.shade700,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade800,
                        ),
                        decoration: InputDecoration(
                          hintText: "Enter new password",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 15.sp,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_reset,
                            color: Colors.lightGreen.shade700,
                            size: 22.sp,
                          ),
                          suffixIcon: IconButton(
                            icon: showNewPassword
                                ? Icon(
                                    Icons.visibility,
                                    color: Colors.grey.shade500,
                                    size: 22.sp,
                                  )
                                : Icon(
                                    Icons.visibility_off,
                                    color: Colors.grey.shade500,
                                    size: 22.sp,
                                  ),
                            onPressed: () {
                              setState(() {
                                showNewPassword = !showNewPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5.w,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.amber.shade700,
                              width: 2.w,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          validateAndSubmit(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightGreen.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 30.w,
                            vertical: 16.h,
                          ),
                          elevation: 4,
                          shadowColor: Colors.lightGreen.shade300,
                        ),
                        child: isLoading
                            ? Container(
                                height: 24.h,
                                width: 24.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5.w,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
