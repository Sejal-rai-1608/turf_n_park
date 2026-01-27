import 'package:flutter/material.dart';

import 'auth/login_owner.dart';
import 'auth/owner_signup.dart';

class PreLoginOwner extends StatefulWidget {
  const PreLoginOwner({Key? key}) : super(key: key);

  @override
  State<PreLoginOwner> createState() => _PreLoginOwnerState();
}

class _PreLoginOwnerState extends State<PreLoginOwner> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              colorFilter: new ColorFilter.mode(
                  Colors.black.withOpacity(0.2), BlendMode.dstATop),
              // opacity: 0.7,
              image: AssetImage("assets/rope.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                // crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                      child: Text("User Login", style: TextStyle(fontSize: 14)),
                      style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(10)),
                          // foregroundColor:
                          //     MaterialStateProperty.all<Color>(Colors.white),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.white)))),
                      onPressed: () => {Navigator.of(context).pop()}),
                  SizedBox(
                    width: 20,
                  )
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "TURF N PARK",
                    style: TextStyle(
                        fontSize: 34,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Text(
                "Seller",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // Container(
              //   width: 260,
              //   // mainAxisAlignment: MainAxisAlignment.center,
              //   child:
              //     Text(
              //       "Bring your sporting life with you wherever you are",
              //
              //       style: TextStyle(
              //         fontSize: 16,
              //         color: Colors.white,
              //         fontWeight: FontWeight.w300
              //         ),
              //       )

              // ),
              SizedBox(
                height: 160,
              ),
              Container(
                  width: 260,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  child: Column(
                    children: [
                      ElevatedButton(
                          child: Text("Login",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          style: ButtonStyle(
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(10)),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white38),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(160, 40)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.white),
                              ))),
                          onPressed: () => {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => LoginOwner()))
                              }),
                      SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          child: Text("Sign up",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.green.shade400)),
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.all(10)),
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white),
                              minimumSize: MaterialStateProperty.all<Size>(
                                  Size(160, 40)),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18.0),
                                      side: BorderSide(color: Colors.white)))),
                          onPressed: () => {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => OwnerSignup()))
                              }),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ))
            ],
          ) /* add child content here */,
        ),
      ),
    );
  }
}
