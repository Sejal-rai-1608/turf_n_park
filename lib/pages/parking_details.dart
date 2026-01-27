import 'dart:convert';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';

import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:paytm/paytm.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zoom_pinch_overlay/zoom_pinch_overlay.dart';

import '../helpers/helper_functions.dart';
import 'my_bookings.dart';
import 'parkingList.dart';

class ParkingDetails extends StatefulWidget {
  ParkingDetails(this.parkingDetails);
  var parkingDetails;
  @override
  State<ParkingDetails> createState() =>
      _ParkingDetailsState(this.parkingDetails);
}

class _ParkingDetailsState extends State<ParkingDetails> {
  _ParkingDetailsState(this.parkingDetails);
  var parkingDetails;
  Razorpay _razorpay = Razorpay();
  int selectedDayIndex = 0;
  bool isLoading = false;
  bool isLoadingPayment = false;
  Map parkingData = {};
  TextEditingController startDateController = TextEditingController();
  // var slotList = [];
  List slotList = [
    {"id": "1", "name": "1 Months"},
    {"id": "2", "name": "2 Months"},
    {"id": "3", "name": "3 Months"},
    {"id": "4", "name": "4 Months"},
  ];
  var dropdownSelectedSlot = "1";

  var mid;
  var orderId;
  var amount;
  var callBackUrl;
  var testing;
  var txnToken;
  var payment_response;

  @override
  void initState() {
    getParkingDetails(context);
    super.initState();
  }

  List<String> listImages = [];

  getParkingDetails(context) async {
    print("widget.parkingDetails");
    slotList = [];
    listImages = [];
    var temp = widget.parkingDetails['slider_images'].toString().split(',');
    listImages = temp;
    listImages.add(widget.parkingDetails['main_image']);
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/parking_details');
    var response =
        await http.post(url, body: {"parking_id": parkingDetails['id']});
    var body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      var list = body['message'];
      print(list.toString());
      for (var i = 1; i < 25; i++)
        slotList.add(
            {"id": i.toString(), "name": i.toString() + " " + list['label']});
      setState(() {
        parkingData = list;
      });
      //  if(parkingData["dates"].length > 0){
      //    if(parkingData["dates"][0] !=null && parkingData["dates"][0]["full_date"] !=null){
      //      getTurfSlots(context, parkingData["dates"][0]["full_date"]);
      //    }
      //  }
    } else {
      showSnackbar(context, body['message']);
      parkingData = {};
      setState(() {});
    }
    setState(() {
      isLoading = false;
    });
  }

  pickDate(context, controller, which) async {
    var dtarr = parkingDetails['start_date'].split("-");
    var year = int.parse(dtarr[0]);
    var month = int.parse(dtarr[1]);
    var day = int.parse(dtarr[2]);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(year, month, day),
      firstDate: DateTime(year, month, day),
      lastDate: DateTime(2300),
    );
    if (picked != null) {
      //
      startDateController.text = convertDateTimeToString(picked).toString();
      // setS
    }
  }

  convertDateTimeToString(dateTime) {
    return "${dateTime.toLocal()}".split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade500,
        elevation: 0,
        title: Text(
          "Parking Details",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          child: Stack(children: [
            Container(
              color: Color(0xffF2F2F2),
              // margin:EdgeInsets.symmetric(horizontal:10,vertical:10 ),
              // padding: EdgeInsets.symmetric(horizontal:10,vertical:10 ),
              height: MediaQuery.of(context).size.height * 0.27,
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
                                          errorWidget: Icon(Icons.person),
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
                              errorWidget: Icon(Icons.person),
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
            //         decoration: BoxDecoration(
            //             color: Colors.white, shape: BoxShape.circle),
            //         child: IconButton(
            //           icon: Icon(Icons.arrow_back_rounded, size: 25),
            //           onPressed: () {
            //             Navigator.of(context).pop();
            //           },
            //         ))),
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
                    color: Color.fromARGB(255, 254, 255, 254),
                  ),
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
                                Text(
                                  "Owner",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(children: [
                                  isLoading
                                      ? Container(
                                          child: Shimmer.fromColors(
                                            baseColor: Colors.grey.shade400,
                                            highlightColor:
                                                Colors.grey.shade600,
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
                                            highlightColor:
                                                Colors.grey.shade400,
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              100,
                                          height: 50,
                                          child: Text(
                                              "" +
                                                  parkingData['owner_name']
                                                      .toString(),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold)))
                                ]),
                                SizedBox(
                                  height: 15,
                                ),
                                Divider(),
                                SizedBox(height: 10),
                                Text(
                                  "Select Booking Period",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                SizedBox(height: 5),
                                DropdownButtonFormField<dynamic>(
                                    // value: dropdownSelectedSlot,
                                    // value: dropdownSelectedUserType,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                    icon: const Icon(Icons.arrow_drop_down),
                                    iconSize: 24,
                                    hint: Text(
                                      "Select Period",
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                    isExpanded: true,
                                    style: const TextStyle(color: Colors.black),
                                    //underline: SizedBox(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        dropdownSelectedSlot = newValue!;
                                      });
                                    },
                                    items: slotList
                                        .map<DropdownMenuItem<dynamic>>((item) {
                                      return DropdownMenuItem(
                                        value: item['id'],
                                        child: Text(item['name']),
                                      );
                                    }).toList()),
                                SizedBox(height: 25),
                                TextFormField(
                                  controller: startDateController,
                                  readOnly: true,
                                  onTap: () {
                                    pickDate(context, startDateController, '');
                                  },
                                  validator: (value) => value!.isEmpty
                                      ? 'Date cannot be blank'
                                      : null,
                                  decoration: new InputDecoration(
                                    labelText: "Start Date",
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (dropdownSelectedSlot.isNotEmpty &&
                                        startDateController.text.isNotEmpty) {
                                      parkingDetails['start_from'] =
                                          startDateController.text;
                                      parkingDetails['qty'] =
                                          dropdownSelectedSlot;
                                      calculateAndPay();
                                    } else {
                                      showSnackbar(context,
                                          "Please select booking period and start date propoerly.");
                                    }
                                  },
                                  child: isLoadingPayment
                                      ? Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      : Container(
                                          alignment: Alignment.center,
                                          child: Container(
                                              padding: EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(25)),
                                                  // border: Border.all(color:Colors.grey.shade700,width: 1.0),
                                                  color: Colors.green.shade400),
                                              alignment: Alignment.center,
                                              width: 200,
                                              height: 50,
                                              child: Text(
                                                "Pay and book",
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

  calculateAndPay() {
    setState(() {
      isLoadingPayment = true;
    });
    var amt = parkingDetails['rent'].split(".")[0];
    var price = int.parse(parkingDetails['qty']) * int.parse(amt);
    initPaymentPaytm(price);
  }

  initPaymentPaytm(amount) async {
    // setState(() {
    //   isLoading = true;
    // });
    var url = Uri.parse(Constants.base_url + 'Service/create_paytm_token');

    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "total_amount": amount.toString()
    });

    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var result = body['message'];

      mid = body['mid'];
      orderId = body['orderId'];
      amount = body['amount'];
      callBackUrl = body['callBackUrl'];
      testing = body['testing'];
      txnToken = result['body']['txnToken'];
      // payNowPaytm();
      //     var mid;
      // var orderId;
      // var amount;
      // var callBackUrl;
      // var testing;

      // var order_id = body['message'];
      // var key = body['key_id'];
      // payNow(key, order_id);
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);
      // cartData = [];
      // cart_total = 0;
      setState(() {});
    }
  }

  initPayment(amount) async {
    setState(() {
      isLoadingPayment = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/create_razorpay_token');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "total_amount": amount.toString()
    });
    var body = jsonDecode(response.body);

    setState(() {
      isLoadingPayment = false;
    });
    if (response.statusCode == 200) {
      var orderId = body['message'];
      var key = body['key_id'];
      payNow(key, orderId, amount);
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);

      setState(() {});
    }
  }

  // payNowPaytm() {
  //   var paytmResponse = Paytm.payWithPaytm(
  //       mId: mid,
  //       orderId: orderId.toString(),
  //       txnToken: txnToken,
  //       txnAmount: amount.toString(),
  //       callBackUrl: callBackUrl,
  //       staging: testing,
  //       appInvokeEnabled: false);

  //   paytmResponse.then((value) {
  //     setState(() {
  //       // loading = false;

  //       if (value['error']) {
  //         payment_response = value['errorMessage'];
  //       } else {
  //         if (value['response'] != null) {
  //           payment_response = value['response']['STATUS'];
  //         }
  //       }
  //       if (payment_response == "TXN_SUCCESS" ||
  //           payment_response == "PENDING") {
  //         validatePaytmPaymentAndProcessCart(value);
  //       } else {
  //         showSnackbar(
  //             context,
  //             "Your Payment Status is " +
  //                 payment_response +
  //                 " . Please try again.");
  //         Navigator.of(context).pop();
  //       }
  //       // payment_response += "\n" + value.toString();
  //       //
  //     });
  //   });
  // }

  payNow(key, orderId, amount) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    var options = {
      'key': key,
      'order_id': orderId,
      'amount': amount * 100,
      'name': 'Turf N Park',
      'description': 'Parking Booking',
      'prefill': {
        'contact': Constants.mobile.toString(),
        'email': Constants.email.toString()
      }
    };
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
    //
    validatePaymentAndProcessCart(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails

    showSnackbar(context, "Your payment is failed. Please try again");
    Navigator.of(context).pop();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected

    // showSnackbar(context, "EXTERNAL_WALLET: " + response.walletName!);
  }

  validatePaymentAndProcessCart(res) async {
    setState(() {
      isLoadingPayment = true;
    });
    var payload = {
      "userToken": Constants.token,
      "payment_id": res.paymentId.toString(),
      "order_id": res.orderId.toString(),
      "signature": res.signature.toString(),
      "start_date": startDateController.text,
      "end_date": startDateController.text,
      "payment_type": parkingDetails['payment_type'],
      "parking_id": parkingDetails['id'].toString(),
      "qty": parkingDetails['qty'].toString(),
    };

    var url = Uri.parse(Constants.base_url + 'Service/parking_booking');
    var response = await http.post(url, body: payload);
    var body = jsonDecode(response.body);

    setState(() {
      isLoadingPayment = false;
    });
    if (response.statusCode == 200) {
      showSnackbar(context, body['message']);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ParkingList()));
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);

      setState(() {});
    }
  }

  validatePaytmPaymentAndProcessCart(res) async {
    setState(() {
      isLoadingPayment = true;
    });
    var payload = {
      "userToken": Constants.token,
      // "payment_id": res.paymentId.toString(),
      // "order_id": res.orderId.toString(),
      // "signature": res.signature.toString(),
      "start_date": startDateController.text,
      "end_date": startDateController.text,
      "payment_type": parkingDetails['payment_type'],
      "parking_id": parkingDetails['id'].toString(),
      "qty": parkingDetails['qty'].toString(),
      "TXNID": res['response']['TXNID'].toString(),
      "ORDERID": res['response']['ORDERID'].toString(),
      "STATUS": res['response']['STATUS'].toString(),
      "CHECKSUMHASH": res['response']['CHECKSUMHASH'].toString(),
      "order_id": orderId,
      "paytm_response": res.toString()
    };

    var url = Uri.parse(Constants.base_url + 'Service/parking_booking_paytm');
    var response = await http.post(url, body: payload);

    var body = jsonDecode(response.body);

    setState(() {
      isLoadingPayment = false;
    });
    if (response.statusCode == 200) {
      showSnackbar(context, body['message']);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => MyBookings()));
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);

      setState(() {});
    }
  }
}
