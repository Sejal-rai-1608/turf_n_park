import 'dart:convert';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/helper_functions.dart';

class BookingDetails extends StatefulWidget {
  BookingDetails(this.bookingDetails);
  var bookingDetails;
  @override
  State<BookingDetails> createState() =>
      _BookingDetailsState(this.bookingDetails);
}

class _BookingDetailsState extends State<BookingDetails> {
  _BookingDetailsState(this.bookingDetails);
  var bookingDetails;
  bool isCancel = false;
  String invoiceString = '';
  int selectedDayIndex = 0;
  bool isLoading = false;
  Map bookingData = {};
  // var slotList = [];
  List slotList = [
    // {"id":"1","name":"1 Months"},
    // {"id":"2","name":"2 Months"},
    // {"id":"3","name":"3 Months"},
    // {"id":"4","name":"4 Months"},
  ];
  var dropdownSelectedSlot = "";

  @override
  void initState() {
    super.initState();
    getBookingDetails(context);
  }

  Future<void> _launchUrl() async {
    final Uri _url = Uri.parse(
        'https://turfnpark.com/turf-admin/Invoice/viewinvoice?invoice=$invoiceString');
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }

  getBookingDetails(context) async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/booking_details');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "booking_id": bookingDetails['id']
    });
    var body = jsonDecode(response.body);
    print(body);
    if (response.statusCode == 200) {
      isCancel = body['can_cancel'] == "true" ? true : false;
      var list = body['message'];
      invoiceString = body['encoded_string'].toString();

      setState(() {
        bookingData = list;
      });
    } else {
      showSnackbar(context, body['message'].toString());
      bookingData = {};
      setState(() {});
    }
    setState(() {
      isLoading = false;
    });
  }

  requestCancellation(context) async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/request_cancellation');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "booking_id": bookingDetails['id']
    });
    var body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      showSnackbar(context, body['message']);
      //  var list = body['message'];
      Navigator.of(context).pop(true);
    } else {
      showSnackbar(context, body['message']);
      bookingData = {};
      setState(() {});
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            if (bookingDetails['image'] != null)
              Container(
                // margin:EdgeInsets.symmetric(horizontal:10,vertical:10 ),
                // padding: EdgeInsets.symmetric(horizontal:10,vertical:10 ),
                height: 200, width: double.infinity,
                child: FancyShimmerImage(
                  imageUrl: bookingDetails['image'],
                  boxFit: BoxFit.cover,
                ),
                // width: MediaQuery.of(context).size.width*0.85,
                // decoration: BoxDecoration(
                //   image: DecorationImage(
                //     image: NetworkImage(bookingDetails['image']),
                //     fit: BoxFit.cover,
                //   )
                // )
              ),
            Positioned(
                top: 10,
                left: 10,
                child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_rounded, size: 22),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ))),
            Positioned(
              top: 180,
              height: MediaQuery.of(context).size.height - 180,
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
                    child: Column(
                        // mainAxisAlignment:MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // crossAxisAlignment: ,
                              children: [
                                Text("#" + bookingDetails['booking_no'],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600)),
                              ]),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // crossAxisAlignment: ,
                              children: [
                                if (bookingDetails['title'] != null)
                                  Text(bookingDetails['title'],
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                              ]),
                          SizedBox(
                            height: 15,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              // crossAxisAlignment: ,
                              children: [
                                Text(
                                    "Amount Paid : " + bookingDetails['amount'],
                                    style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700)),
                              ]),
                          SizedBox(
                            height: 5,
                          ),
                          Divider(),
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
                                : Column(
                                    children: [
                                      if (bookingDetails["owner_details"] !=
                                          null)
                                        Container(
                                            padding: EdgeInsets.only(left: 20),
                                            alignment: Alignment.centerLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                100,
                                            height: 30,
                                            child: Text(
                                                "" +
                                                    bookingData["owner_details"]
                                                            ['name']
                                                        .toString(),
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Colors.red.shade400))),
                                      if (bookingDetails["owner_details"] !=
                                          null)
                                        Container(
                                            padding: EdgeInsets.only(left: 20),
                                            alignment: Alignment.centerLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                100,
                                            height: 20,
                                            child: Text(
                                                "" +
                                                    bookingData["owner_details"]
                                                            ['mobile']
                                                        .toString(),
                                                style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)))
                                    ],
                                  )
                          ]),
                          if (isLoading)
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
                          SizedBox(
                            height: 10,
                          ),
                          if (!isLoading && isCancel == true)
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Cancel Booking"),
                                        content: Text(
                                            "Are you sure you want to cancel this booking?"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("No")),
                                          TextButton(
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all<
                                                            Color>(
                                                        Colors.red.shade400),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                requestCancellation(context);
                                              },
                                              child: Text(
                                                "Yes",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ],
                                      );
                                    });
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  margin: EdgeInsets.only(bottom: 25, top: 10),
                                  width:
                                      MediaQuery.of(context).size.width * 0.88,
                                  child: Container(
                                      alignment: Alignment.center,
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      padding: EdgeInsets.all(15),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.red.shade400),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8))),
                                      child: Text(
                                        "Request Cancellation",
                                        style: TextStyle(
                                            color: Colors.red.shade400,
                                            fontWeight: FontWeight.bold),
                                      ))),
                            ),
                          if (bookingData["details"] != null)
                            if (!isLoading && bookingData['details'].length > 0)
                              for (var j = 0;
                                  j < bookingData['details'].length;
                                  j++)
                                GestureDetector(
                                  // onTap: (){
                                  //   if(bookingData['details'][j]['is_booked']){
                                  //     showSnackbar(context,"This Slot is Already Booked.");
                                  //   }else  if(bookingData['details'][j]['is_in_my_cart']){
                                  //     showSnackbar(context,"This Slot is Already in your cart.");
                                  //   }else {
                                  //     addToCart(context,turfDetails["dates"][selectedDayIndex]['full_date'],bookingData['details'][j]['start'],bookingData['details'][j]['end'],bookingData['details'][j]['rent'],j);
                                  //   }
                                  // },
                                  child: Container(
                                      height: 50,
                                      margin: EdgeInsets.all(4),
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                        border: Border.all(
                                            color: Colors.red.shade400,
                                            width: 1.0),
                                        color: Colors.grey.shade100,
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            bookingData['details'][j]
                                                ['date_show'],
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            bookingData['details'][j]['label'],
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          // Container(
                                          //   padding:EdgeInsets.all(6),
                                          //   decoration: BoxDecoration(
                                          //     borderRadius: BorderRadius.all(Radius.circular(8)),
                                          //     border: Border.all(color:Colors.white,width: 1.0) ,
                                          //     // color: Colors.grey.shade100,
                                          //   ),
                                          //   child:bookingData['details'][j]['is_booked'] == true ? Text("Booked.",style: TextStyle(color:Colors.red.shade400),) : Text("Rs."+bookingData['details'][j]['rent'].toString(),style: TextStyle(color:bookingData['details'][j]['is_in_my_cart'] == true ? Colors.white:Colors.red.shade400),)
                                          // ),
                                        ],
                                      )),
                                ),
                          if (bookingData["details"] != null)
                            ElevatedButton(
                              onPressed: () {
                                _launchUrl();
                              },
                              child: Text("View Invoice"),
                            ),
                          SizedBox(
                            height: 20,
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

  calculateAndPay() {}
}
