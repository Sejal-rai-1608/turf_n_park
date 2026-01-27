import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_context/riverpod_context.dart';

import '../helpers/helper_functions.dart';

class OwnerSignupScreen extends StatefulWidget {
  Map<String, String> data;
  OwnerSignupScreen({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<OwnerSignupScreen> createState() => _OwnerSignupScreenState();
}

class _OwnerSignupScreenState extends State<OwnerSignupScreen> {
  bool isLoading = false;
  ImagePicker _imagePicker = ImagePicker();
  String imagePath = "images/img.jpg";

  final _aadharCardImageFileProvider = StateProvider<File>((ref) => File(""));
  final _panCardImageFileProvider = StateProvider<File>((ref) => File(""));
  final _shopCertificateFileProvider = StateProvider<File>((ref) => File(""));
  final _gst_certificateFileProvider = StateProvider<File>((ref) => File(""));

  final _profile_pictureFileProvider = StateProvider<File>((ref) => File(""));

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: Text(
          "Signup Process",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer(builder: (context, refData, _) {
        Future<void> completeSignUpProcess() async {
          try {
            var dio = Dio();
            setState(() {
              isLoading = true;
            });

            FormData formData = FormData.fromMap({
              'name': widget.data['name'],
              'password': widget.data['password'],
              'mobile': widget.data['mobile'],
              'email': widget.data['email'],
              "aadhar_card": await MultipartFile.fromFile(
                  context.read(_aadharCardImageFileProvider.state).state.path,
                  filename: context
                      .read(_aadharCardImageFileProvider.state)
                      .state
                      .path
                      .split('/')
                      .last),
              "pan_card": await MultipartFile.fromFile(
                  context.read(_panCardImageFileProvider.state).state.path,
                  filename: context
                      .read(_panCardImageFileProvider.state)
                      .state
                      .path
                      .split('/')
                      .last),
              "shop_license": await MultipartFile.fromFile(
                  context.read(_shopCertificateFileProvider.state).state.path,
                  filename: context
                      .read(_shopCertificateFileProvider.state)
                      .state
                      .path
                      .split('/')
                      .last),
              "gst_certificate": await MultipartFile.fromFile(
                  context.read(_gst_certificateFileProvider.state).state.path,
                  filename: context
                      .read(_gst_certificateFileProvider.state)
                      .state
                      .path
                      .split('/')
                      .last),
              "profile_picture": await MultipartFile.fromFile(
                  context.read(_profile_pictureFileProvider.state).state.path,
                  filename: context
                      .read(_profile_pictureFileProvider.state)
                      .state
                      .path
                      .split('/')
                      .last),
            });

            try {
              var response = await dio.postUri(
                  Uri.parse(Constants.base_url + 'Service/owner_sign_up'),
                  data: formData);

              if (response.statusCode == 200) {
                setState(() {
                  isLoading = false;
                });
                Fluttertoast.showToast(
                    msg: response.data["message"],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                // context.read(kycCompleteProviderClient.state).state = true;
                // openScreenReplace(context, AdvisorHome());
              } else {
                setState(() {
                  isLoading = false;
                });
                Fluttertoast.showToast(
                    msg: response.data,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
            } on DioError catch (e) {
              // The request was made and the server responded with a status code
              // that falls out of the range of 2xx and is also not 304.
              if (e.response != null) {
                setState(() {
                  isLoading = false;
                });
                Fluttertoast.showToast(
                    msg: e.response!.data!["message"],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
              } else {
                setState(() {
                  isLoading = false;
                });
                Fluttertoast.showToast(
                    msg: e.response!.data!["message"],
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0);
                // Something happened in setting up or sending the request that triggered an Error
              }
            }
          } catch (e) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(
                msg: "Error Occurred",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black,
                textColor: Colors.white,
                fontSize: 16.0);
          }

          // var res = MultipartRequest('POST', getClientCompleteKycProcess);
          // res.fields['userToken'] = "${CurrentUser.userToken}";
          // res.fields['email'] = widget.email;
          // res.fields['pan_no'] = widget.panNumber;
          // res.fields['bank_name'] = widget.bankName;
          // res.fields['account_no'] = widget.bankACNo;
          // res.fields['ifsc_code'] = widget.ifscCode;
          // res.fields['branch_name'] = widget.branchName;
          // var adhaarCard = await MultipartFile.fromPath('aadhar_card',
          //     refData.read(_aadharCardImageFileProvider.state).state.path);
          // var panCard = await MultipartFile.fromPath('pan_card',
          //     refData.read(_panCardImageFileProvider.state).state.path);
          // var photo = await MultipartFile.fromPath(
          //     'photo', refData.read(_photoImageFileProvider.state).state.path);
          // var cheque = await MultipartFile.fromPath('aadhar_card',
          //     refData.read(_chequeImageFileProvider.state).state.path);
          // res.files.addAll([adhaarCard, photo, panCard, cheque]);

          // var resdata = await res.send();
          // Fluttertoast.showToast(msg: "${resdata.reasonPhrase}");
        }

        Future<void> pickImage(
            ImageSource imageSource, StateProvider<File> fileName) async {
          var tempFile = await _imagePicker.pickImage(source: imageSource);
          if (tempFile != null) {
            imagePath = tempFile.path;

            context.read(fileName.state).state = File(tempFile.path);
          }
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              children: [
                SizedBox(
                  //  height: getAppSize(context)["width"]! * 0.6,
                  child: Image.asset(
                    "assets/bonbon-upload-files-to-cloud-storage-on-computer-1.png",
                  ),
                ),
                Text(
                  "Upload Documents",
                  style: TextStyle(
                    //     fontSize: getAppSize(context)["width"]! * 0.07,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade400,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                Text(
                    "Upload your aadhaar card, passbook, Pan Card and Passport size photo.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      // fontSize: getAppSize(context)["width"]! * 0.04,
                      color: Colors.green.shade400,
                    )),
                SizedBox(
                  height: 10,
                ),
                // SizedBox(
                //   height: getAppSize(context)["height"]! * 0.05,
                // ),
                // Container(
                //   height: 66,
                //   decoration: BoxDecoration(
                //       color: const Color(0xffB2C3FF),
                //       borderRadius: BorderRadius.circular(8)),
                //   width: double.infinity,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //     children: [
                //       Icon(
                //         Icons.upload_file,
                //         size: getAppSize(context)["width"]! * 0.09,
                //         color: ColorsApp.darkColor2,
                //       ),
                //       Text(
                //         "Add a file",
                //         style: GoogleFonts.roboto(
                //           fontWeight: FontWeight.bold,
                //           fontSize: getAppSize(context)["width"]! * 0.07,
                //           color: ColorsApp.darkColor2,
                //         ),
                //       )
                //     ],
                //   ),
                // ),

                ListTile(
                  leading: refData
                              .watch(_panCardImageFileProvider.state)
                              .state
                              .path ==
                          File("").path
                      ? Icon(
                          Icons.check_box_outline_blank,
                          color: Color.fromARGB(255, 255, 69, 69),
                        )
                      : Icon(
                          Icons.check_box,
                          color: Color.fromARGB(255, 69, 255, 165),
                        ),
                  title: ElevatedButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(refData
                                    .watch(_panCardImageFileProvider.state)
                                    .state
                                    .path ==
                                File("").path
                            ? Colors.redAccent
                            : Colors.greenAccent)),
                    onPressed: () {
                      pickImage(ImageSource.gallery, _panCardImageFileProvider);
                    },
                    child: Text(
                      "PAN Card",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      context.read(_panCardImageFileProvider.state).state =
                          File("");
                    },
                    child: Icon(
                      Icons.delete,
                      color: refData
                                  .watch(_panCardImageFileProvider.state)
                                  .state
                                  .path ==
                              File("").path
                          ? Colors.grey
                          : Colors.redAccent,
                    ),
                  ),
                ),
                ListTile(
                  leading: refData
                              .watch(_aadharCardImageFileProvider.state)
                              .state
                              .path ==
                          File("").path
                      ? Icon(
                          Icons.check_box_outline_blank,
                          color: Color.fromARGB(255, 255, 69, 69),
                        )
                      : Icon(
                          Icons.check_box,
                          color: Color.fromARGB(255, 69, 255, 165),
                        ),
                  title: ElevatedButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(refData
                                    .watch(_aadharCardImageFileProvider.state)
                                    .state
                                    .path ==
                                File("").path
                            ? Colors.redAccent
                            : Colors.greenAccent)),
                    onPressed: () {
                      pickImage(
                          ImageSource.gallery, _aadharCardImageFileProvider);
                    },
                    child: Text(
                      "Aadhar Card",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      context.read(_aadharCardImageFileProvider.state).state =
                          File("");
                    },
                    child: Icon(
                      Icons.delete,
                      color: refData
                                  .watch(_aadharCardImageFileProvider.state)
                                  .state
                                  .path ==
                              File("").path
                          ? Colors.grey
                          : Colors.redAccent,
                    ),
                  ),
                ),

                ListTile(
                  leading: refData
                              .watch(_shopCertificateFileProvider.state)
                              .state
                              .path ==
                          File("").path
                      ? Icon(
                          Icons.check_box_outline_blank,
                          color: Color.fromARGB(255, 255, 69, 69),
                        )
                      : Icon(
                          Icons.check_box,
                          color: Color.fromARGB(255, 69, 255, 165),
                        ),
                  title: ElevatedButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(refData
                                    .watch(_shopCertificateFileProvider.state)
                                    .state
                                    .path ==
                                File("").path
                            ? Colors.redAccent
                            : Colors.greenAccent)),
                    onPressed: () {
                      pickImage(
                          ImageSource.gallery, _shopCertificateFileProvider);
                    },
                    child: Text(
                      "Shop License",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      context.read(_shopCertificateFileProvider.state).state =
                          File("");
                    },
                    child: Icon(
                      Icons.delete,
                      color: refData
                                  .watch(_shopCertificateFileProvider.state)
                                  .state
                                  .path ==
                              File("").path
                          ? Colors.grey
                          : Colors.redAccent,
                    ),
                  ),
                ),
                ListTile(
                  leading: refData
                              .watch(_gst_certificateFileProvider.state)
                              .state
                              .path ==
                          File("").path
                      ? Icon(
                          Icons.check_box_outline_blank,
                          color: Color.fromARGB(255, 255, 69, 69),
                        )
                      : Icon(
                          Icons.check_box,
                          color: Color.fromARGB(255, 69, 255, 165),
                        ),
                  title: ElevatedButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(refData
                                    .watch(_gst_certificateFileProvider.state)
                                    .state
                                    .path ==
                                File("").path
                            ? Colors.redAccent
                            : Colors.greenAccent)),
                    onPressed: () {
                      pickImage(
                          ImageSource.gallery, _gst_certificateFileProvider);
                    },
                    child: Text(
                      "GST Certificate",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      context.read(_gst_certificateFileProvider.state).state =
                          File("");
                    },
                    child: Icon(
                      Icons.delete,
                      color: refData
                                  .watch(_gst_certificateFileProvider.state)
                                  .state
                                  .path ==
                              File("").path
                          ? Colors.grey
                          : Colors.redAccent,
                    ),
                  ),
                ),
                ListTile(
                  leading: refData
                              .watch(_profile_pictureFileProvider.state)
                              .state
                              .path ==
                          File("").path
                      ? Icon(
                          Icons.check_box_outline_blank,
                          color: Color.fromARGB(255, 255, 69, 69),
                        )
                      : Icon(
                          Icons.check_box,
                          color: Color.fromARGB(255, 69, 255, 165),
                        ),
                  title: ElevatedButton(
                    style: ButtonStyle(
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.all(refData
                                    .watch(_profile_pictureFileProvider.state)
                                    .state
                                    .path ==
                                File("").path
                            ? Colors.redAccent
                            : Colors.greenAccent)),
                    onPressed: () {
                      pickImage(
                          ImageSource.gallery, _profile_pictureFileProvider);
                    },
                    child: Text(
                      "Profile Picture",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  trailing: InkWell(
                    onTap: () {
                      context.read(_profile_pictureFileProvider.state).state =
                          File("");
                    },
                    child: Icon(
                      Icons.delete,
                      color: refData
                                  .watch(_profile_pictureFileProvider.state)
                                  .state
                                  .path ==
                              File("").path
                          ? Colors.grey
                          : Colors.redAccent,
                    ),
                  ),
                ),
                // SizedBox(
                //   height: getAppSize(context)["height"]! * 0.04,
                // ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    // ref.read(kycCompleteProviderClient.state).state = true;
                    if (context
                                .read(_panCardImageFileProvider.state)
                                .state
                                .path ==
                            File("").path ||
                        context
                                .read(_aadharCardImageFileProvider.state)
                                .state
                                .path ==
                            File("").path ||
                        context
                                .read(_shopCertificateFileProvider.state)
                                .state
                                .path ==
                            File("").path ||
                        context
                                .read(_profile_pictureFileProvider.state)
                                .state
                                .path ==
                            File("").path ||
                        context
                                .read(_gst_certificateFileProvider.state)
                                .state
                                .path ==
                            File("").path) {
                      Fluttertoast.showToast(
                          msg: "Please upload all the documents");
                    } else {
                      completeSignUpProcess();
                    }
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(isLoading
                        ? CircleBorder(
                            side: BorderSide(
                              color: Colors.green.withOpacity(0.5),
                              width: 2,
                            ),
                          )
                        : RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 10),
                    child: isLoading
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.white,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green.shade400),
                          )
                        : Text(
                            "Summit",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(
                  height: 70,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
