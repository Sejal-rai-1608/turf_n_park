import 'dart:convert';

import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:turfandpark/pages/my_cart.dart';
import 'package:turfandpark/pages/turfList.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

import '../helpers/helper_functions.dart';

class TurfDetails extends StatefulWidget {
  Map turfData;
  VoidCallback update;

  TurfDetails(
    this.turfData,
    this.update,
  );

  @override
  State<TurfDetails> createState() => _TurfDetailsState(this.turfData);
}

class _TurfDetailsState extends State<TurfDetails> {
  _TurfDetailsState(this.turfData);
  int selectedDayIndex = 0;
  Map turfData;
  Map turfDetails = {};
  List slotList = [
    // {"time":"7 AM - 8 AM","price":1000},
    // {"time":"8 AM - 9 AM","price":1000},
    // {"time":"9 AM - 10 AM","price":1000},
    // {"time":"10 AM - 11 AM","price":1000},
  ];
  bool isLoading = false;
  bool isLoadingSlot = false;

  @override
  void initState() {
    super.initState();
    getTurfDetails(context);
    c.getCartCount(context);
  }

  List<String> listImages = [];
  getTurfDetails(context) async {
    listImages = [];
    var temp = widget.turfData['slider_images'].toString().split(',');
    listImages = temp;
    listImages.add(widget.turfData['main_image']);
    if (mounted)
      setState(() {
        isLoading = true;
      });
    var url = Uri.parse(Constants.base_url + 'Service/turf_details');
    var response = await http.post(url, body: {"turf_id": turfData['id']});
    var body = jsonDecode(response.body);
    //
    if (mounted)
      setState(() {
        isLoading = false;
      });
    if (response.statusCode == 200) {
      var list = body['message'];
      if (mounted)
        setState(() {
          turfDetails = list;
        });
      if (turfDetails["dates"].length > 0) {
        if (turfDetails["dates"][0] != null &&
            turfDetails["dates"][0]["full_date"] != null) {
          getTurfSlots(context, turfDetails["dates"][0]["full_date"]);
        }
      }
    } else {
      showSnackbar(context, body['message']);
      turfDetails = {};
      setState(() {});
    }
  }

  getTurfSlots(context, date) async {
    setState(() {
      isLoadingSlot = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/get_turf_slots');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "turf_id": turfData['id'],
      "date": date
    });
    var body = jsonDecode(response.body);

    if (mounted)
      setState(() {
        isLoadingSlot = false;
      });
    if (response.statusCode == 200) {
      var list = body['message'];
      if (mounted)
        setState(() {
          slotList = list;
        });
    } else {
      showSnackbar(context, body['message']);
      slotList = [];
      setState(() {});
    }
  }

  addToCart(context, date, start, end, price, j) async {
    setState(() {
      isLoadingSlot = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/add_to_cart');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "turf_id": turfData['id'],
      "date": date,
      "start_time": start,
      "end_time": end,
      "price": price
    });
    var body = jsonDecode(response.body);
    //
    setState(() {
      isLoadingSlot = false;
    });
    if (response.statusCode == 200) {
      showSnackbar(context, body['message']);
      slotList[j]['is_in_my_cart'] = true;
      c.getCartCount(context);
      widget.update();

      //  var list = body['message'];
      setState(() {
        // slotList= list;
      });
    } else {
      showSnackbar(context, body['message']);
      // slotList=[];
      // setState(() {

      // });
    }
  }

  updateTurfList() {
    getTurfSlots(context, turfDetails["dates"][selectedDayIndex]["full_date"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade500,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                  onPressed: () => {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MyCart(
                                  update: updateTurfList,
                                )))
                      },
                  icon: Icon(Icons.shopping_cart_rounded, color: Colors.white)),
              Positioned(
                right: 5,
                child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Obx(
                        () => Text(
                          c.count.toString(),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ],
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          turfData['turf_name'],
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Color(0xffe5e5e5),
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            Container(
              color: Color.fromARGB(255, 243, 243, 243),
              // marginColor.fromARGB(255, 240, 240, 240)tric(horizontal:10,vertical:10 ),
              // padding: EdgeInsets.symmetric(horizontal:10,vertical:10 ),
              height: MediaQuery.of(context).size.height * 0.25,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                          errorWidget: Image.asset(
                                            "assets/logo.png",
                                            fit: BoxFit.contain,
                                          ),
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
                              errorWidget: Image.asset(
                                "assets/logo.png",
                                fit: BoxFit.contain,
                              ),
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
            // Positioned(
            //     top: 10,
            //     left: 10,
            //     child: Container(
            //         height: 32,
            //         decoration: BoxDecoration(
            //             color: Colors.white, shape: BoxShape.circle),
            //         child: IconButton(
            //           icon: Icon(Icons.arrow_back_ios_new, size: 18),
            //           onPressed: () {
            //             Navigator.of(context).pop();
            //           },
            //         ))),
            // Positioned(
            //   top: 10,
            //   right: 10,
            //   child: Stack(
            //     children: [
            //       IconButton(
            //           onPressed: () => {
            //                 Navigator.of(context).push(MaterialPageRoute(
            //                     builder: (context) => MyCart(
            //                           update: updateTurfList,
            //                         )))
            //               },
            //           icon: Icon(Icons.shopping_cart_rounded)),
            //       Positioned(
            //         right: 5,
            //         child: Container(
            //             decoration: BoxDecoration(
            //               shape: BoxShape.circle,
            //               color: Colors.red,
            //             ),
            //             child: Padding(
            //               padding: const EdgeInsets.all(5.0),
            //               child: Obx(
            //                 () => Text(
            //                   c.count.toString(),
            //                   style: TextStyle(
            //                     color: Colors.white,
            //                   ),
            //                 ),
            //               ),
            //             )),
            //       ),
            //     ],
            //   ),
            // ),
            Positioned(
              top: 210,
              height: MediaQuery.of(context).size.height - 230,
              child: Container(
                  padding: EdgeInsets.all(20),
                  // alignment: Alignment.bottomCenter,
                  height: MediaQuery.of(context).size.width - 180,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)),
                      color: Colors.white),
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                        // mainAxisAlignment:MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              // crossAxisAlignment: ,
                              children: [
                                Container(
                                  alignment: Alignment.centerLeft,
                                  // crossAxisAlignment: ,
                                  child: Text(turfData['turf_name'],
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                ),
                                Spacer(),
                                Text(
                                    "Rs." +
                                        (int.parse(turfData['hourly_rent']))
                                            .toString(),
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black)),
                              ]),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            turfData['address'],
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // crossAxisAlignment: ,
                              children: [
                                Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(15)),
                                      border: Border.all(
                                          color: Colors.grey.shade700,
                                          width: 1.0),
                                      // color: Colors.white
                                    ),
                                    alignment: Alignment.center,
                                    width: 100,
                                    child: turfData['rating'] == null
                                        ? Text("No Ratings.")
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            // crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                  int.parse(turfData['rating']
                                                              .toString()) >=
                                                          1
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 17,
                                                  color: int.parse(turfData[
                                                                  'rating']
                                                              .toString()) >=
                                                          1
                                                      ? Colors.yellow
                                                      : Colors.grey),
                                              Icon(
                                                  int.parse(turfData['rating']
                                                              .toString()) >=
                                                          2
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 17,
                                                  color: int.parse(turfData[
                                                                  'rating']
                                                              .toString()) >=
                                                          2
                                                      ? Colors.yellow
                                                      : Colors.grey),
                                              Icon(
                                                  int.parse(turfData['rating']
                                                              .toString()) >=
                                                          3
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 17,
                                                  color: int.parse(turfData[
                                                                  'rating']
                                                              .toString()) >=
                                                          3
                                                      ? Colors.yellow
                                                      : Colors.grey),
                                              Icon(
                                                  int.parse(turfData['rating']
                                                              .toString()) >=
                                                          4
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 17,
                                                  color: int.parse(turfData[
                                                                  'rating']
                                                              .toString()) >=
                                                          4
                                                      ? Colors.yellow
                                                      : Colors.grey),
                                              Icon(
                                                  int.parse(turfData['rating']
                                                              .toString()) >=
                                                          5
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  size: 17,
                                                  color: int.parse(turfData[
                                                                  'rating']
                                                              .toString()) >=
                                                          5
                                                      ? Colors.yellow
                                                      : Colors.grey),
                                            ],
                                          )),
                                GestureDetector(
                                  onTap: () {
                                    if (turfDetails['amenities'] != null &&
                                        turfDetails['amenities'].length > 0)
                                      showModalBottomSheet(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(18.0))),
                                        backgroundColor: Colors.white,
                                        context: context,
                                        // isScrollControlled: false,
                                        builder: (context) {
                                          return SingleChildScrollView(
                                            child: Wrap(
                                              children: [
                                                if (turfDetails['amenities'] !=
                                                    null)
                                                  for (var i = 0;
                                                      i <
                                                          turfDetails[
                                                                  'amenities']
                                                              .length;
                                                      i++)
                                                    ListTile(
                                                      leading: Icon(Icons
                                                          .arrow_forward_ios),
                                                      title: Text(turfDetails[
                                                              'amenities'][i]
                                                          ['text']),
                                                    ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                  },
                                  child: Container(
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15)),
                                          // border: Border.all(color:Colors.grey.shade700,width: 1.0),
                                          color: Colors.blue.shade800),
                                      alignment: Alignment.center,
                                      width: 100,
                                      child: Text(
                                        "Amenities",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ),
                              ]),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            "Owner",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(children: [
                            isLoading
                                ? Container(
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey.shade400,
                                      highlightColor: Colors.grey.shade600,
                                      enabled: true,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          color: Colors.white,
                                        ),
                                        // width: MediaQuery.of(context).size.width*0.90,
                                        height: 50,
                                        width: 50,
                                      ),
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        // border: Border.all(color:Colors.grey.shade700,width: 1.0),
                                        color: Colors.grey,
                                        image: DecorationImage(
                                          image: AssetImage(
                                              "assets/user-image.png"),
                                          fit: BoxFit.cover,
                                        )),
                                    alignment: Alignment.center,
                                    width: 50,
                                    height: 50,
                                  ),
                            isLoading
                                ? Container(
                                    padding: EdgeInsets.all(5),
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey.shade200,
                                      highlightColor: Colors.grey.shade400,
                                      enabled: true,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(2)),
                                          color: Colors.white,
                                        ),
                                        // width: MediaQuery.of(context).size.width*0.90,
                                        height: 20,
                                        width: 200,
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.only(left: 20),
                                    alignment: Alignment.centerLeft,
                                    width:
                                        MediaQuery.of(context).size.width - 100,
                                    height: 50,
                                    child: Text(turfDetails['turf_owner_name'],
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)))
                          ]),
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                              padding: EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                    color: Colors.grey.shade700, width: 1.0),
                                color: Colors.white,
                              ),
                              child: Text(
                                "Click on the time slot to add it to the cart. Cart Item will be valid for 15 Minutes only.",
                                style: TextStyle(
                                    fontWeight: FontWeight.w300, fontSize: 14),
                              )),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Availability",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                              height: 80,
                              width: MediaQuery.of(context).size.width * 0.90,
                              child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      if (isLoading)
                                        for (var i = 0; i <= 6; i++)
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            child: Shimmer.fromColors(
                                              baseColor: Colors.grey.shade200,
                                              highlightColor:
                                                  Colors.grey.shade400,
                                              enabled: true,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  color: Colors.white,
                                                ),
                                                // width: MediaQuery.of(context).size.width*0.90,
                                                height: 75,
                                                width: 50,
                                              ),
                                            ),
                                          ),
                                      if (!isLoading)
                                        for (var i = 0;
                                            i < turfDetails['dates'].length;
                                            i++)
                                          GestureDetector(
                                            onTap: () {
                                              selectedDayIndex = i;
                                              getTurfSlots(
                                                  context,
                                                  turfDetails['dates'][i]
                                                      ['full_date']);
                                              // setState(() {

                                              // });
                                            },
                                            child: Container(
                                                width: 50,
                                                margin: EdgeInsets.all(4),
                                                padding: EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  // border: Border.all(color:Colors.grey.shade300,width: 1.0),
                                                  color: selectedDayIndex == i
                                                      ? Colors.red.shade400
                                                      : Colors.grey.shade100,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                        turfDetails['dates'][i]
                                                            ['month'],
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            color: selectedDayIndex ==
                                                                    i
                                                                ? Colors.white
                                                                : Colors
                                                                    .black)),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      turfDetails['dates'][i]
                                                          ['date'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18,
                                                          color:
                                                              selectedDayIndex ==
                                                                      i
                                                                  ? Colors.white
                                                                  : Colors.red
                                                                      .shade400),
                                                    ),
                                                  ],
                                                )),
                                          ),
                                    ],
                                  ))),
                          if (isLoading || isLoadingSlot)
                            for (var j = 0; j < slotList.length; j++)
                              Container(
                                padding: EdgeInsets.all(5),
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade200,
                                  highlightColor: Colors.grey.shade400,
                                  enabled: true,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      color: Colors.white,
                                    ),
                                    // width: MediaQuery.of(context).size.width*0.90,
                                    height: 50,
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                  ),
                                ),
                              ),
                          if (!isLoadingSlot)
                            for (var j = 0; j < slotList.length; j++)
                              GestureDetector(
                                onTap: () {
                                  if (slotList[j]['is_booked']) {
                                    showSnackbar(context,
                                        "This Slot is Already Booked.");
                                  } else if (slotList[j]['is_in_my_cart']) {
                                    showSnackbar(context,
                                        "This Slot is Already in your cart.");
                                  } else {
                                    addToCart(
                                        context,
                                        turfDetails["dates"][selectedDayIndex]
                                            ['full_date'],
                                        slotList[j]['start'],
                                        slotList[j]['end'],
                                        slotList[j]['rent'],
                                        j);
                                  }
                                },
                                child: Container(
                                    height: 60,
                                    margin: EdgeInsets.all(4),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                      border: slotList[j]['is_booked'] == true
                                          ? Border.all(
                                              color: Colors.red.shade400,
                                              width: 1.0)
                                          : (slotList[j]['is_in_my_cart'] ==
                                                  true
                                              ? Border.all(
                                                  color: Colors.grey.shade400,
                                                  width: 1.0)
                                              : Border.all(
                                                  color: Colors.grey.shade100,
                                                  width: 1.0)),
                                      color:
                                          slotList[j]['is_in_my_cart'] == true
                                              ? Colors.green.shade400
                                              : Colors.grey.shade100,
                                    ),
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          slotList[j]['label'],
                                          style: TextStyle(
                                              color: slotList[j]
                                                          ['is_in_my_cart'] ==
                                                      true
                                                  ? Colors.white
                                                  : Colors.black),
                                        ),
                                        Container(
                                            padding: EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              border: slotList[j]
                                                          ['is_in_my_cart'] ==
                                                      true
                                                  ? Border.all(
                                                      color: Colors.white,
                                                      width: 1.0)
                                                  : Border.all(
                                                      color:
                                                          Colors.red.shade400,
                                                      width: 1.0),
                                              // color: Colors.grey.shade100,
                                            ),
                                            child:
                                                slotList[j]['is_booked'] == true
                                                    ? Text(
                                                        "Booked.",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .red.shade400),
                                                      )
                                                    : Text(
                                                        "Rs." +
                                                            slotList[j]['rent']
                                                                .toString(),
                                                        style: TextStyle(
                                                            color: slotList[j][
                                                                        'is_in_my_cart'] ==
                                                                    true
                                                                ? Colors.white
                                                                : Colors.red
                                                                    .shade400),
                                                      )),
                                      ],
                                    )),
                              ),
                          SizedBox(
                            height: 20,
                          )
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
