import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:turfandpark/auth/owner_signup_upload.dart';
import '../helpers/widgets.dart';
// import 'package:dotted_border/dotted_border.dart';
// import '../helpers/display_image.dart';
import '../helpers/helper_functions.dart';

// import 'pre_login_owner.dart';
class OwnerSignup extends StatefulWidget {
  const OwnerSignup({Key? key}) : super(key: key);

  @override
  State<OwnerSignup> createState() => _OwnerSignupState();
}

class _OwnerSignupState extends State<OwnerSignup> {
  bool showPassword = true;
  bool isLoading = false;

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController mobileEditingController = TextEditingController();
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
    if (mobileEditingController.text.length != 10) {
      showSnackbar(context, "Please enter valid 10 digit Mobile no");
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

    // setState(() {
    //   isLoading = true;
    // });

    Map<String, String> data = {
      'mobile': mobileEditingController.text,
      'name': nameEditingController.text,
      'email': emailEditingController.text,
      'password': passwordEditingController.text
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OwnerSignupScreen(
          data: data,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade400,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Container(
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
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),

                    Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Basic Details",
                          style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.04,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    // InkWell(
                    //     onTap: () {
                    //       // navigateSecondPage(EditImagePage());
                    //     },
                    //     child: DisplayImage(
                    //       imagePath:
                    //           "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png",
                    //       onPressed: () {},
                    //     )),
                    SizedBox(
                      height: 10,
                    ),
                    // Container(

                    //   height: 150,
                    //   width: 150,
                    //   child: DottedBorder(
                    //   borderType: BorderType.RRect,
                    //   radius: Radius.circular(75),
                    //   dashPattern: [5, 5],
                    //   color: Colors.grey,
                    //   strokeWidth: 1,
                    //   child: Container(
                    //     alignment: Alignment.center,
                    //     child:Icon(Icons.person_sharp,size: 45,color:Colors.grey,)
                    //     // photo_camera_front_outlined
                    //   ),
                    // ),
                    // ),

                    SizedBox(
                      height: 20,
                    ),

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
                                    .bodyMedium!
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
                            TextFormField(
                              controller: emailEditingController,
                              cursorColor: Colors.green.shade400,
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: Theme.of(this.context)
                                    .textTheme
                                     .bodyMedium!
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
                            TextFormField(
                              keyboardType: TextInputType.phone,
                              controller: mobileEditingController,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(10),
                              ],
                              cursorColor: Colors.green.shade400,
                              decoration: InputDecoration(
                                hintText: "Phone Number",
                                hintStyle: Theme.of(this.context)
                                    .textTheme
                                     .bodyMedium!
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
                            TextFormField(
                              controller: passwordEditingController,
                              obscureText: showPassword,
                              cursorColor: Colors.green.shade400,
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: Theme.of(this.context)
                                    .textTheme
                                     .bodyMedium!
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
                              controller: cpasswordEditingController,
                              obscureText: true,
                              cursorColor: Colors.green.shade400,
                              decoration: InputDecoration(
                                hintText: "Confirm Password",
                                hintStyle: Theme.of(this.context)
                                    .textTheme
                                     .bodyMedium!
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
                              height: 40,
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: RaisedGradientButton(
                                  child: isLoading
                                      ? CircularProgressIndicator()
                                      : Text(
                                          'Signup',
                                          style: TextStyle(
                                              color: Colors.green.shade400,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                  gradient: LinearGradient(
                                    colors: <Color>[
                                      Colors.white,
                                      Colors.white,
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
      ),
    );
  }
}
