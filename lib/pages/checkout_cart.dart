import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:turfandpark/pages/my_bookings.dart';

import '../helpers/helper_functions.dart';

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
  bool showPaymentButton = false;

  @override
  void initState() {
    super.initState();
    gatCartData();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  gatCartData() async {
    setState(() {
      isLoading = true;
      error = false;
    });

    try {
      var url = Uri.parse(Constants.base_url + 'Service/my_cart_list');
      var response = await http.post(url,
          body: {"userToken": Constants.token}).timeout(Duration(seconds: 30));

      var body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        var list = body['message'];
        setState(() {
          cartData = list;
          showPaymentButton = list.isNotEmpty;
        });
        calculateCartTotal();
      } else if (response.statusCode == 401) {
        showSnackbar(context, "Session expired. Please login again.");
        onLogout(context);
      } else {
        showSnackbar(context, body['message'] ?? "Failed to load cart");
        setState(() {
          cartData = [];
          showPaymentButton = false;
        });
      }
    } on http.ClientException catch (e) {
      showSnackbar(context, "Network error: ${e.message}");
      setState(() => error = true);
    } catch (e) {
      showSnackbar(context, "Error loading cart");
      setState(() => error = true);
    } finally {
      setState(() => isLoading = false);
    }
  }

  calculateCartTotal() {
    double ttl = 0;
    cartData.forEach((element) {
      ttl = ttl + double.parse(element['price'] ?? '0');
    });
    setState(() => cart_total = ttl);
  }

  initPayment() async {
    if (cart_total <= 0) {
      showSnackbar(context, "Invalid amount");
      return;
    }

    setState(() => isLoading = true);

    try {
      var url = Uri.parse(Constants.base_url + 'Service/create_razorpay_token');
      var response = await http.post(url, body: {
        "userToken": Constants.token,
        "total_amount": cart_total.toStringAsFixed(2)
      }).timeout(Duration(seconds: 30));

      var body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        var orderId = body['message'].toString();
        var key = body['key_id'].toString();
        payNow(key, orderId);
      } else if (response.statusCode == 401) {
        showSnackbar(context, "Session expired");
        onLogout(context);
      } else {
        showSnackbar(context, body['message'] ?? "Payment setup failed");
        setState(() => isLoading = false);
      }
    } on http.ClientException catch (e) {
      showSnackbar(context, "Network error: ${e.message}");
      setState(() => isLoading = false);
    } on Exception catch (e) {
      showSnackbar(context, "Payment error: ${e.toString()}");
      setState(() => isLoading = false);
    }
  }

  payNow(String key, String orderId) {
    try {
      _razorpay.clear();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

      var options = {
        'key': key,
        'amount':
            (cart_total * 100).toStringAsFixed(0), // In paise, no decimals
        'name': 'Turf N Park',
        'description': 'Turf Booking',
        'order_id': orderId,
        'prefill': {
          'contact': Constants.mobile?.toString() ?? '',
          'email': Constants.email?.toString() ?? ''
        },
        'theme': {'color': '#4CAF50'}
      };

      _razorpay.open(options);
      setState(() => isLoading = false);
    } catch (e) {
      showSnackbar(context, "Cannot open payment: ${e.toString()}");
      setState(() => isLoading = false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    validatePaymentAndProcessCart(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showSnackbar(
        context, "Payment failed: ${response.message ?? 'Please try again'}");
    setState(() => isLoading = false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showSnackbar(context, "External wallet selected: ${response.walletName}");
    setState(() => isLoading = false);
  }

  validatePaymentAndProcessCart(PaymentSuccessResponse res) async {
    setState(() => isLoading = true);

    try {
      var payload = {
        "userToken": Constants.token,
        "payment_id": res.paymentId.toString(),
        "order_id": res.orderId.toString(),
        "signature": res.signature.toString()
      };

      var url = Uri.parse(
          Constants.base_url + 'Service/validate_payment_and_process_cart');
      var response =
          await http.post(url, body: payload).timeout(Duration(seconds: 30));

      var body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        showSnackbar(context, body['message'] ?? "Payment successful!");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MyBookings()));
      } else if (response.statusCode == 401) {
        showSnackbar(context, "Session expired");
        onLogout(context);
      } else {
        showSnackbar(context, body['message'] ?? "Payment validation failed");
        setState(() => isLoading = false);
      }
    } on http.ClientException catch (e) {
      showSnackbar(context, "Network error: ${e.message}");
      setState(() => isLoading = false);
    } catch (e) {
      showSnackbar(context, "Error: ${e.toString()}");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Checkout",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  if (cartData.isNotEmpty)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${cartData.length} item${cartData.length > 1 ? 's' : ''}",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Loading State
                      if (isLoading)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: Colors.green.shade600,
                                strokeWidth: 3,
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Processing...",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Error State
                      if (error && !isLoading)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 50),
                          child: Column(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 60,
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Something went wrong",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Please try again",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: gatCartData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text("Retry"),
                              ),
                            ],
                          ),
                        ),

                      // Cart Items
                      if (!isLoading && !error && cartData.isNotEmpty)
                        Column(
                          children: [
                            // Order Summary Card
                            Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.shopping_cart,
                                          color: Colors.green.shade700,
                                          size: 24,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "Order Summary",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),

                                    // Cart Items List
                                    for (var i = 0; i < cartData.length; i++)
                                      Container(
                                        margin: EdgeInsets.only(bottom: 12),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade50,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            // Item number
                                            Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "${i + 1}",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        Colors.green.shade800,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 12),

                                            // Turf details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    cartData[i]['turf_name'] ??
                                                        'Turf',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  SizedBox(height: 4),
                                                  Text(
                                                    "${cartData[i]['date']} • ${cartData[i]['timeslot']}",
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Price
                                            Text(
                                              "₹${cartData[i]['price']}",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Colors.green.shade700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Divider
                                    Divider(height: 30, thickness: 1),

                                    // Total Amount
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Total Amount",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            "₹${cart_total.toStringAsFixed(2)}",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 30),

                            // Payment Button
                            Container(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: initPayment,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 4,
                                  padding: EdgeInsets.symmetric(horizontal: 24),
                                ),
                                icon: Icon(Icons.payment, size: 24),
                                label: Text(
                                  "Pay ₹${cart_total.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 15),

                            // Security Note
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.blue.shade100),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.security,
                                    color: Colors.blue.shade700,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Secure payment via Razorpay. Your payment details are protected.",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      // Empty Cart State
                      if (!isLoading && !error && cartData.isEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 80),
                          child: Column(
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Colors.grey.shade300,
                              ),
                              SizedBox(height: 20),
                              Text(
                                "Your cart is empty",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Add turf bookings to proceed",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade600,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 14),
                                ),
                                child: Text("Browse Turfs"),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
