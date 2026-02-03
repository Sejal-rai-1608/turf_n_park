import 'dart:convert';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:http/http.dart' as http;
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
  bool isLoading = false;
  bool isLoadingPayment = false;
  Map parkingData = {};
  TextEditingController startDateController = TextEditingController();
  List slotList = [];
  var dropdownSelectedSlot = "1";
  int _currentCarouselIndex = 0;

  @override
  void initState() {
    super.initState();
    getParkingDetails(context);
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  List<String> listImages = [];

  getParkingDetails(context) async {
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
      for (var i = 1; i < 25; i++)
        slotList.add(
            {"id": i.toString(), "name": i.toString() + " " + list['label']});
      setState(() {
        parkingData = list;
      });
    } else {
      showSnackbar(context, body['message']);
      parkingData = {};
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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.green.shade600,
            colorScheme: ColorScheme.light(primary: Colors.green.shade600),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      startDateController.text = convertDateTimeToString(picked).toString();
    }
  }

  convertDateTimeToString(dateTime) {
    return "${dateTime.toLocal()}".split(' ')[0];
  }

  // --- PAYMENT METHODS (RAZORPAY) ---
  calculateAndPay() async {
    if (dropdownSelectedSlot.isEmpty || startDateController.text.isEmpty) {
      showSnackbar(context, "Please select booking period and start date");
      return;
    }

    setState(() => isLoadingPayment = true);

    try {
      var amt = parkingDetails['rent'].split(".")[0];
      var price = int.parse(dropdownSelectedSlot) * int.parse(amt);
      await initPayment(price);
    } catch (e) {
      showSnackbar(context, "Error calculating amount");
      setState(() => isLoadingPayment = false);
    }
  }

  initPayment(amount) async {
    try {
      var url = Uri.parse(Constants.base_url + 'Service/create_razorpay_token');
      var response = await http.post(url, body: {
        "userToken": Constants.token,
        "total_amount": amount.toString()
      }).timeout(Duration(seconds: 30));

      var body = jsonDecode(response.body);

      if (response.statusCode == 200) {
        var orderId = body['message'].toString();
        var key = body['key_id'].toString();
        payNow(key, orderId, amount);
      } else if (response.statusCode == 401) {
        showSnackbar(context, "Session expired");
        onLogout(context);
        setState(() => isLoadingPayment = false);
      } else {
        showSnackbar(context, body['message'] ?? "Payment setup failed");
        setState(() => isLoadingPayment = false);
      }
    } on http.ClientException catch (e) {
      showSnackbar(context, "Network error: ${e.message}");
      setState(() => isLoadingPayment = false);
    } catch (e) {
      showSnackbar(context, "Payment error: ${e.toString()}");
      setState(() => isLoadingPayment = false);
    }
  }

  payNow(String key, String orderId, int amount) {
    try {
      var options = {
        'key': key,
        'amount': (amount * 100).toStringAsFixed(0), // Convert to paise
        'name': 'Turf N Park',
        'description': 'Parking Booking',
        'order_id': orderId,
        'prefill': {
          'contact': Constants.mobile?.toString() ?? '',
          'email': Constants.email?.toString() ?? ''
        },
        'theme': {'color': '#4CAF50'}
      };

      _razorpay.open(options);
    } catch (e) {
      showSnackbar(context, "Cannot open payment: ${e.toString()}");
      setState(() => isLoadingPayment = false);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    validatePaymentAndProcessCart(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    showSnackbar(
        context, "Payment failed: ${response.message ?? 'Please try again'}");
    setState(() => isLoadingPayment = false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showSnackbar(context, "External wallet selected: ${response.walletName}");
    setState(() => isLoadingPayment = false);
  }

  validatePaymentAndProcessCart(PaymentSuccessResponse res) async {
    setState(() => isLoadingPayment = true);

    try {
      var amt = parkingDetails['rent'].split(".")[0];
      var totalAmount = int.parse(dropdownSelectedSlot) * int.parse(amt);

      var payload = {
        "userToken": Constants.token,
        "payment_id": res.paymentId.toString(),
        "order_id": res.orderId.toString(),
        "signature": res.signature.toString(),
        "start_date": startDateController.text,
        "end_date": startDateController.text,
        "payment_type": parkingDetails['payment_type'],
        "parking_id": parkingDetails['id'].toString(),
        "qty": dropdownSelectedSlot,
        "total_amount": totalAmount.toString()
      };

      var url = Uri.parse(Constants.base_url + 'Service/parking_booking');
      var response =
          await http.post(url, body: payload).timeout(Duration(seconds: 30));

      var body = jsonDecode(response.body);

      setState(() => isLoadingPayment = false);

      if (response.statusCode == 200) {
        showSnackbar(context, body['message'] ?? "Booking successful!");
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MyBookings()));
      } else if (response.statusCode == 401) {
        showSnackbar(context, "Session expired");
        onLogout(context);
      } else {
        showSnackbar(context, body['message'] ?? "Booking failed");
      }
    } on http.ClientException catch (e) {
      showSnackbar(context, "Network error: ${e.message}");
      setState(() => isLoadingPayment = false);
    } catch (e) {
      showSnackbar(context, "Error: ${e.toString()}");
      setState(() => isLoadingPayment = false);
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
            bottom: Radius.circular(25),
          ),
        ),
        leading: Container(
          margin: EdgeInsets.only(left: 10),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            child: IconButton(
              icon:
                  Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          "Parking Details",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Carousel Section
            Expanded(
              flex: 4,
              child: Stack(
                children: [
                  CarouselSlider(
                    options: CarouselOptions(
                      height: double.infinity,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 4),
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentCarouselIndex = index;
                        });
                      },
                    ),
                    items: listImages.map((i) {
                      return Builder(
                        builder: (BuildContext context) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: EdgeInsets.all(20),
                                    child: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                                blurRadius: 40,
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: ZoomOverlay(
                                              twoTouchOnly: true,
                                              child: Container(
                                                color: Colors.black,
                                                child: FancyShimmerImage(
                                                  imageUrl: i,
                                                  errorWidget: Icon(Icons.image,
                                                      size: 50,
                                                      color: Colors.white),
                                                  boxFit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: Container(
                                              padding: EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.5),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.close,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 20,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "Use two fingers to zoom",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              child: FancyShimmerImage(
                                imageUrl: i,
                                errorWidget: Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.local_parking_rounded,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                boxFit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                  Positioned(
                    bottom: 15,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: listImages.asMap().entries.map((entry) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentCarouselIndex == entry.key
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Content Section
            Expanded(
              flex: 6,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    parkingDetails['title'] ?? 'Parking Space',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade900,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 18,
                                        color: Colors.grey.shade600,
                                      ),
                                      SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          parkingDetails['address'] ?? '',
                                          style: TextStyle(
                                            color: Colors.grey.shade700,
                                            fontSize: 14,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade500,
                                    Colors.green.shade700,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.shade200,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    "₹${parkingDetails['rent']?.split(".")[0] ?? '0'}",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    parkingDetails['payment_type'] ??
                                        'per month',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        // Rating and Availability Card
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade100,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Rating
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.amber.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        color: Colors.amber.shade700,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "4.0",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amber.shade900,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            "Rating",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(width: 12),

                              // Availability
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.blue.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        color: Colors.blue.shade700,
                                        size: 18,
                                      ),
                                      SizedBox(width: 8),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Available",
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            Text(
                                              parkingDetails['start_date'] ??
                                                  '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue.shade900,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // Owner Card
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade100,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                "OWNER",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Container(
                                height: 24,
                                width: 1,
                                margin: EdgeInsets.symmetric(horizontal: 12),
                                color: Colors.grey.shade300,
                              ),
                              Expanded(
                                child: isLoading
                                    ? Shimmer.fromColors(
                                        baseColor: Colors.grey.shade200,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        parkingData['owner_name'] ??
                                            'Loading...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade900,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 20),

                        // Booking Section
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.calendar_month_rounded,
                                      color: Colors.green.shade700,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    "Booking Details",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade900,
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 10),

                              Text(
                                "Select Booking Period",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 8),
                              DropdownButtonFormField<dynamic>(
                                value: dropdownSelectedSlot,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: Colors.green.shade400,
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 16),
                                ),
                                icon: Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey.shade600),
                                iconSize: 20,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    dropdownSelectedSlot = newValue!;
                                  });
                                },
                                items: slotList
                                    .map<DropdownMenuItem<dynamic>>((item) {
                                  return DropdownMenuItem(
                                    value: item['id'],
                                    child: Text(
                                      item['name'],
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              SizedBox(height: 10),

                              Text(
                                "Start Date",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () {
                                  pickDate(context, startDateController, '');
                                },
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    controller: startDateController,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey.shade50,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: Colors.green.shade400,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 16),
                                      hintText: "Select start date",
                                      hintStyle: TextStyle(
                                          color: Colors.grey.shade500),
                                      suffixIcon: Icon(
                                        Icons.calendar_today_rounded,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              SizedBox(height: 15),

                              // Calculate Price Button
                              if (dropdownSelectedSlot.isNotEmpty &&
                                  startDateController.text.isNotEmpty)
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.green.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total Amount:",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                      Text(
                                        "₹${(int.parse(dropdownSelectedSlot) * int.parse(parkingDetails['rent'].split(".")[0])).toString()}",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              SizedBox(height: 20),

                              // Pay Button
                              isLoadingPayment
                                  ? Center(
                                      child: Column(
                                        children: [
                                          CircularProgressIndicator(
                                            color: Colors.green.shade600,
                                          ),
                                          SizedBox(height: 16),
                                          Text(
                                            "Processing Payment...",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: calculateAndPay,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        minimumSize: Size(double.infinity, 55),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        elevation: 5,
                                        shadowColor: Colors.green.shade200,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.payment_rounded,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "PAY WITH RAZORPAY",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                              SizedBox(height: 10),

                              // Payment Note
                              Container(
                                padding: EdgeInsets.all(12),
                                margin: EdgeInsets.only(top: 10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.blue.shade100),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.security_rounded,
                                      color: Colors.blue.shade700,
                                      size: 18,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "Secure payment via Razorpay. Your payment details are protected.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 30),
                      ],
                    ),
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
