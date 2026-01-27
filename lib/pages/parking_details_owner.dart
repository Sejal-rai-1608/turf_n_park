import 'dart:convert';

import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

import '../helpers/helper_functions.dart';

class ParkingDetailsOwner extends StatefulWidget {
  ParkingDetailsOwner(this.parkingDetails, this.updateHome);
  var parkingDetails;
  Function updateHome;
  @override
  State<ParkingDetailsOwner> createState() =>
      _ParkingDetailsOwnerState(this.parkingDetails);
}

class _ParkingDetailsOwnerState extends State<ParkingDetailsOwner> {
  _ParkingDetailsOwnerState(this.parkingDetails);
  var parkingDetails;

  int selectedDayIndex = 0;
  bool isLoading = false;
  bool isLoadingPayment = false;
  Map parkingData = {};
  TextEditingController startDateController = TextEditingController();
  // var slotList = [];
  List slotList = [
    // {"id":"1","name":"1 Months"},
    // {"id":"2","name":"2 Months"},
    // {"id":"3","name":"3 Months"},
    // {"id":"4","name":"4 Months"},
  ];
  var dropdownSelectedSlot = "";

  var mid;
  var orderId;
  var amount;
  var callBackUrl;
  var testing;
  var txnToken;
  var payment_response;
  List<String> listImages = [];
  @override
  void initState() {
    super.initState();

    listImages = [];
    var temp = widget.parkingDetails['slider_images'].toString().split(',');
    for (var i = 0; i < temp.length; i++) {
      listImages.add("https://turfnpark.com/turf_images/${temp[i]}");
    }
    listImages.add(widget.parkingDetails['main_image']);
  }

  convertDateTimeToString(dateTime) {
    return "${dateTime.toLocal()}".split(' ')[0];
  }

  getParkingDelete(parkingID) async {
    setState(() {
      isLoading = true;
    });

    var url = Uri.parse(Constants.base_url + "Owner/delete_parking");
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "parking_id": parkingID,
    });
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      widget.updateHome();
      showSnackbar(context, body['message']);
      Navigator.pop(context);
      Navigator.pop(context);
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);

      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            Material(
              child: Container(
                // margin:EdgeInsets.symmetric(horizontal:10,vertical:10 ),
                // padding: EdgeInsets.symmetric(horizontal:10,vertical:10 ),
                height: MediaQuery.of(context).size.height * 0.4,
                width: double.infinity,
                child: CarouselSlider(
                    options: CarouselOptions(
                      scrollPhysics: NeverScrollableScrollPhysics(),
                      autoPlay: true,
                    ),
                    items: listImages.map((i) {
                      return Builder(builder: (BuildContext context) {
                        return InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ZoomOverlay(
                                        twoTouchOnly: true,
                                        child: Container(
                                          color: Colors.white,
                                          child: FancyShimmerImage(
                                            //  height: 40.h,
                                            imageUrl: i,
                                            boxFit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          "  Use Two Fingers to zoom the image.  ",
                                          style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text("Close"))
                                    ],
                                  );
                                });
                          },
                          child: ZoomOverlay(
                            twoTouchOnly: true,
                            child: Container(
                              color: Colors.white,
                              child: FancyShimmerImage(
                                height: 200,
                                imageUrl: i,
                                boxFit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      });
                    }).toList()),

                // width: MediaQuery.of(context).size.width*0.85,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: NetworkImage(turfData['main_image']),
                //     fit: BoxFit.cover,
                //   ),
                // ),
              ),
            ),
            Positioned(
                top: 10,
                left: 10,
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_rounded, size: 25),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ))),
            Positioned(
              top: 180,
              height: MediaQuery.of(context).size.height - 180,
              child: Container(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                  // alignment: Alignment.bottomCenter,
                  height: MediaQuery.of(context).size.width - 180,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      color: Colors.white),
                  child: SingleChildScrollView(
                    child: isLoadingPayment
                        ? Container(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade400,
                              highlightColor: Colors.grey.shade600,
                              enabled: true,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  color: Colors.white,
                                ),
                                // width: MediaQuery.of(context).size.width*0.90,
                                height: 200,
                                width: MediaQuery.of(context).size.width * 0.9,
                              ),
                            ),
                          )
                        : Column(
                            // mainAxisAlignment:MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    // crossAxisAlignment: ,
                                    children: [
                                      Text(parkingDetails['title'],
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black)),
                                    ]),
                                SizedBox(
                                  height: 15,
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    // crossAxisAlignment: ,
                                    children: [
                                      Text(
                                          "${parkingDetails['rent']}" +
                                              " " +
                                              parkingDetails['payment_type'],
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black)),
                                    ]),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  parkingDetails['address'],
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    // crossAxisAlignment: ,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(15)),
                                            border: Border.all(
                                                color: Colors.grey.shade700,
                                                width: 1.0),
                                            // color: Colors.white
                                          ),
                                          alignment: Alignment.center,
                                          width: 100,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            // crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(Icons.star,
                                                  size: 17,
                                                  color: Colors.yellow),
                                              Icon(Icons.star,
                                                  size: 17,
                                                  color: Colors.yellow),
                                              Icon(Icons.star,
                                                  size: 17,
                                                  color: Colors.yellow),
                                              Icon(Icons.star,
                                                  size: 17,
                                                  color: Colors.yellow),
                                              Icon(Icons.star_border,
                                                  size: 17,
                                                  color: Colors.grey.shade700),
                                            ],
                                          )),
                                      Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15)),
                                              // border: Border.all(color:Colors.grey.shade700,width: 1.0),
                                              color: Colors.blue.shade800),
                                          alignment: Alignment.center,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              150,
                                          child: Text(
                                            "Available After " +
                                                parkingDetails['start_date'],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ]),
                                SizedBox(
                                  height: 15,
                                ),
                                Divider(),
                                SizedBox(height: 10),
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                              title: Text("Are you sure?"),
                                              content: Text(
                                                  "Do you want to Delete parking?"),
                                              actions: [
                                                ElevatedButton(
                                                  child: Text("Yes"),
                                                  onPressed: () {
                                                    getParkingDelete(
                                                        parkingDetails['id']);
                                                  },
                                                ),
                                                ElevatedButton(
                                                  child: Text("No"),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                )
                                              ],
                                            ));
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    child: Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(25)),
                                            // border: Border.all(color:Colors.grey.shade700,width: 1.0),
                                            color: Colors.green.shade400),
                                        alignment: Alignment.center,
                                        width: 200,
                                        height: 50,
                                        child: Text(
                                          "Delete Parking",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        )),
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ]),
                  )),
            ),
            //   Positioned(
            //     top:180,
            //     child:Container(
            //       padding: EdgeInsets.all(15),
            //       width:MediaQuery.of(context).size.width,
            //       height: 30,
            //         decoration: BoxDecoration(
            //             borderRadius: BorderRadius.only(topLeft:Radius.circular(20),topRight:Radius.circular(20)),
            //             color: Colors.white
            //           ),
            //     )
            //   ),
          ]),
        ),
      ),
    );
  }
// Widget create
}
