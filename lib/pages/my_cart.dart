import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Add this
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:turfandpark/helpers/utils.dart';
import 'package:turfandpark/pages/turfList.dart';
import '../helpers/helper_functions.dart';
import 'checkout_cart.dart';

class MyCart extends StatefulWidget {
  final update;
  const MyCart({Key? key, this.update}) : super(key: key);

  @override
  State<MyCart> createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> {
  var cartData = [];
  double cart_total = 0;
  bool isLoading = false;
  bool isLoadingSlot = false;

  @override
  void initState() {
    super.initState();
    gatCartData(context);
    c.getCartCount(context);
  }

  gatCartData(context) async {
    CountProviderCart c = Get.put(CountProviderCart());
    c.getCartCount(context);
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

  calculateCartTotal() {
    double ttl = 0;
    cartData.forEach((element) {
      ttl = ttl + double.parse(element['price']);
    });
    cart_total = ttl;
    setState(() {});
  }

  deleteFromCart(context, id) async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/delete_from_cart');
    var response = await http
        .post(url, body: {"userToken": Constants.token, "cart_id": id});
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      showSnackbar(context, body['message']);
      setState(() {
        widget.update();
      });
      gatCartData(context);
    } else {
      showSnackbar(context, body['message']);
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
            bottom: Radius.circular(20.r),
          ),
        ),
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 18.sp,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "My Cart",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Obx(() => Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    c.count.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              // Total Items Info Card
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.blue.shade100,
                    width: 1.5.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 10.r,
                      offset: Offset(0, 4.h),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_cart_rounded,
                      color: Colors.blue.shade700,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                                "Total Items in Cart: ${c.count.toString()}",
                                style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                          if (cart_total > 0)
                            Text(
                              "Total Amount: Rs.${cart_total.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: Colors.green.shade800,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Cart Items List
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        if (isLoading)
                          for (var i = 0; i < 4; i++)
                            Container(
                              margin: EdgeInsets.only(bottom: 15.h),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade200,
                                highlightColor: Colors.grey.shade100,
                                enabled: true,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    color: Colors.white,
                                  ),
                                  width: double.infinity,
                                  height: 180.h,
                                ),
                              ),
                            ),
                        if (!isLoading && cartData.isEmpty)
                          Container(
                            margin: EdgeInsets.only(top: 50.h),
                            child: Column(
                              children: [
                                Container(
                                  height: 200.h,
                                  child: Image.asset(
                                    "assets/conifer-volleyball-1.png",
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  "Your Cart is Empty",
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  "Add some turf slots to get started!",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 30.h),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade600,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 30.w,
                                      vertical: 14.h,
                                    ),
                                    elevation: 4,
                                  ),
                                  child: Text(
                                    "Browse Turfs",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (!isLoading)
                          for (var i = 0; i < cartData.length; i++)
                            Container(
                              margin: EdgeInsets.only(bottom: 15.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: Colors.grey.shade200,
                                  width: 1.5.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade100,
                                    blurRadius: 15.r,
                                    offset: Offset(0, 5.h),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Turf Image and Info
                                  Container(
                                    padding: EdgeInsets.all(16.r),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Turf Image
                                        Container(
                                          width: 80.w,
                                          height: 80.h,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15.r),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  cartData[i]['main_image']),
                                              fit: BoxFit.cover,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                                blurRadius: 8.r,
                                                offset: Offset(0, 4.h),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 15.w),
                                        // Turf Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                cartData[i]['turf_name'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade900,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 6.h),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 14.sp,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Expanded(
                                                    child: Text(
                                                      cartData[i]['address'] ??
                                                          '',
                                                      style: TextStyle(
                                                        fontSize: 13.sp,
                                                        color: Colors
                                                            .grey.shade700,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Divider
                                  Container(
                                    height: 1.h,
                                    color: Colors.grey.shade200,
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 16.w),
                                  ),

                                  // Booking Details
                                  Container(
                                    padding: EdgeInsets.all(16.r),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16.sp,
                                              color: Colors.green.shade700,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              "Date:",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              cartData[i]['date'] ?? '',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.h),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 16.sp,
                                              color: Colors.green.shade700,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              "Time Slot:",
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              cartData[i]['timeslot'] ?? '',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16.w,
                                                vertical: 8.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                border: Border.all(
                                                  color: Colors.green.shade200,
                                                ),
                                              ),
                                              child: Text(
                                                "Rs. ${cartData[i]['price'] ?? ''}",
                                                style: TextStyle(
                                                  fontSize: 15.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green.shade800,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                deleteFromCart(context,
                                                    cartData[i]['cart_id']);
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(10.r),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r),
                                                  border: Border.all(
                                                    color: Colors.red.shade200,
                                                  ),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.delete_outline,
                                                      size: 18.sp,
                                                      color:
                                                          Colors.red.shade600,
                                                    ),
                                                    SizedBox(width: 6.w),
                                                    Text(
                                                      "Remove",
                                                      style: TextStyle(
                                                        fontSize: 13.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color:
                                                            Colors.red.shade600,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      ],
                    ),
                  ),
                ),
              ),

              // Checkout Section (Only if cart has items)
              if (cart_total > 0 && !isLoading)
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color: Colors.grey.shade200,
                        width: 1.5.w,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20.r,
                        offset: Offset(0, -5.h),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            "Rs. ${cart_total.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => CheckoutCart(),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade600,
                                Colors.green.shade800,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade300,
                                blurRadius: 15.r,
                                offset: Offset(0, 5.h),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.payment,
                                color: Colors.white,
                                size: 22.sp,
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                "Proceed to Checkout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
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
