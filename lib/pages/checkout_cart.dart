import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:paytm/paytm.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:turfandpark/pages/my_bookings.dart';

import '../helpers/helper_functions.dart';
import 'turfList.dart';

// import 'pre_login_owner.dart';
class CheckoutCart extends StatefulWidget {
  const CheckoutCart({Key? key}) : super(key: key);

  @override
  State<CheckoutCart> createState() => _CheckoutCartState();
}

class _CheckoutCartState extends State<CheckoutCart> {
  var cartData = [];
  double cart_total = 0;

  Razorpay _razorpay = Razorpay();
  bool isLoading = false;
  bool error = false;

  var mid;
  var orderId;
  var amount;
  var callBackUrl;
  var testing;
  var txnToken;
  var payment_response;

  // get txnToken => null;

  @override
  void initState() {
    super.initState();
    gatCartData(context);
  }

  gatCartData(context) async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/my_cart_list');
    var response = await http.post(url, body: {"userToken": Constants.token});
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var list = body['message'];
      setState(() {
        cartData = list;
      });
      calculateCartTotal();
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);
      cartData = [];
      cart_total = 0;
      setState(() {});
    }
  }

  calculateCartTotal() async {
    double ttl = 0;
    cartData.forEach((element) {
      //
      ttl = ttl + double.parse(element['price']);
    });

    cart_total = ttl;
    // assert(cart_total is int);
    if (cart_total > 0)
      // initPayment();
      initPaymentPaytm();
    else
      setState(() {
        error = true;
      });
  }

  initPayment() async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/create_razorpay_token');
    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "total_amount": cart_total.toString()
    });
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var orderId = body['message'];
      var key = body['key_id'];
      payNow(key, orderId);
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);
      cartData = [];
      cart_total = 0;
      setState(() {});
    }
  }

  initPaymentPaytm() async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/create_paytm_token');

    var response = await http.post(url, body: {
      "userToken": Constants.token,
      "total_amount": cart_total.toString()
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
      cartData = [];
      cart_total = 0;
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
  //                 payment_response.toString() +
  //                 " . Please try again.");
  //         Navigator.of(context).pop();
  //       }
  //       // payment_response += "\n" + value.toString();
  //       //
  //     });
  //   });
  // }

  payNow(key, orderId) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    var options = {
      'key': key,
      'order_id': orderId,
      'amount': cart_total * 100,
      'name': 'Turf N Park',
      'description': 'Turf Booking',
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
    showSnackbar(context, "Your payment is failed. Please try again");
    Navigator.of(context).pop();

    // showSnackbar(context, "EXTERNAL_WALLET: " + response.walletName!);
  }

  validatePaymentAndProcessCart(res) async {
    setState(() {
      isLoading = true;
    });
    var payload = {
      "userToken": Constants.token,
      "payment_id": res.paymentId.toString(),
      "order_id": res.orderId.toString(),
      "signature": res.signature.toString()
    };

    var url = Uri.parse(
        Constants.base_url + 'Service/validate_payment_and_process_cart');
    var response = await http.post(url, body: payload);
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      showSnackbar(context, body['message']);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => TurfList()));
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);
      cartData = [];
      cart_total = 0;
      setState(() {});
    }
  }

  validatePaytmPaymentAndProcessCart(res) async {
    setState(() {
      isLoading = true;
    });
    var payload = {
      "userToken": Constants.token,
      "TXNID": res['response']['TXNID'].toString(),
      "ORDERID": res['response']['ORDERID'].toString(),
      "STATUS": res['response']['STATUS'].toString(),
      "CHECKSUMHASH": res['response']['CHECKSUMHASH'].toString(),
      "order_id": orderId,
      "paytm_response": res.toString()
      // "order_id": res.orderId.toString(),
      // "signature": res.signature.toString()
    };

    var url = Uri.parse(
        Constants.base_url + 'Service/validate_payment_and_process_cart_paytm');
    var response = await http.post(url, body: payload);

    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
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
      cartData = [];
      cart_total = 0;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            // padding:EdgeInsets.symmetric(horizontal:10),
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // SizedBox(height: 10,),
                Row(
                    // alignment: Alignment.topRight,
                    // crossAxisAlignment:CrossAxisAlignment.,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          padding: EdgeInsets.only(left: 15, top: 10),
                          child: Text("Checkout",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24))),
                      Container(
                        padding: EdgeInsets.only(right: 20, top: 10),
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(17))
                              // shape:BoxShape.circle
                              ),
                          child: IconButton(
                            icon: Icon(Icons.close),
                            iconSize: 18,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // SizedBox(width: 20,),
                    ]),
                SizedBox(
                  height: 30,
                ),
                SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Form(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (isLoading)
                            for (var i = 0; i < 1; i++)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                      "assets/mirage-payment-processed-1.png"),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Text(
                                      "Please wait... \nYour payment is processing",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 22)),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  // Container(
                                  //   child: Shimmer.fromColors(
                                  //     baseColor: Colors.grey.shade400,
                                  //     highlightColor: Colors.grey.shade600,
                                  //     enabled: true,
                                  //     child: Container(
                                  //       decoration: BoxDecoration(
                                  //         borderRadius: BorderRadius.all(
                                  //             Radius.circular(20)),
                                  //         color: Colors.white,
                                  //       ),
                                  //       width:
                                  //           MediaQuery.of(context).size.width *
                                  //               0.90,
                                  //       height: 200,
                                  //       margin: EdgeInsets.all(10),
                                  //     ),
                                  //   ),
                                  // ),
                                ],
                              ),
                          if (cart_total == 0 && !isLoading)
                            Container(
                                alignment: Alignment.center,
                                child: Text("No Data in the cart",
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.bold))),
                          if (error)
                            Container(
                                alignment: Alignment.center,
                                child: Text("Something Went Wrong.",
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ) /* add child content here */,
          ),
        ),
      ),
    );
  }
}
