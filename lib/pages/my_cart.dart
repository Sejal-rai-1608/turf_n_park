import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:turfandpark/helpers/utils.dart';
import 'package:turfandpark/pages/turfList.dart';

import '../helpers/helper_functions.dart';
import 'checkout_cart.dart';

// import 'pre_login_owner.dart';
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
    print(body.toString());
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
      //
      ttl = ttl + double.parse(element['price']);
    });

    cart_total = ttl;
    assert(cart_total is int);
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
    print(body.toString());
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
                          child: Text("My Cart",
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
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Obx(() => Text(
                          "Total Items in Cart : " + c.count.toString(),
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 16,
                          ),
                        )),
                  ),
                ),
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
                            for (var i = 0; i < 4; i++)
                              Container(
                                child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade400,
                                  highlightColor: Colors.grey.shade600,
                                  enabled: true,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                      color: Colors.white,
                                    ),
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                    height: 200,
                                    margin: EdgeInsets.all(10),
                                  ),
                                ),
                              ),
                          if (!isLoading)
                            for (var i = 0; i < cartData.length; i++)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //  Container(width:40,child: Icon(Icons.label_important_outline,color: Colors.blue,)),
                                  Container(
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          // boxShadow: [
                                          //   BoxShadow(
                                          //     color: Colors.grey.shade400,
                                          //     blurRadius:
                                          //         4.0, // soften the shadow
                                          //     spreadRadius:
                                          //         1.0, //extend the shadow
                                          //     offset: Offset(
                                          //       2.0, // Move to right 10  horizontally
                                          //       2.0, // Move to bottom 10 Vertically
                                          //     ),
                                          //   )
                                          // ],
                                          color: Colors.grey.shade200),
                                      width: MediaQuery.of(context).size.width *
                                          0.85,
                                      margin:
                                          EdgeInsets.symmetric(vertical: 10),
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Row(
                                            // mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 65,
                                                height: 65,
                                                decoration: BoxDecoration(
                                                    color: Colors.grey,
                                                    image: DecorationImage(
                                                      image: NetworkImage(
                                                          cartData[i]
                                                              ['main_image']),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    // borderRadius: BorderRadius.all(Radius.circular(17)),
                                                    shape: BoxShape.circle),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.85 -
                                                            98,
                                                    child: Text(
                                                        cartData[i]
                                                            ['turf_name'],
                                                        overflow:
                                                            TextOverflow.clip,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16)),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                      .size
                                                                      .width *
                                                                  0.85 -
                                                              98,
                                                      child: Text(
                                                          cartData[i]
                                                              ['address'],
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Colors
                                                                  .grey))),
                                                ],
                                              )
                                            ],
                                          ),
                                          // SizedBox(height: 10,),
                                          Container(
                                              child: Text(
                                            "Date : " + cartData[i]['date'],
                                          )),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                              child: Text(
                                            "Times : " +
                                                cartData[i]['timeslot'],
                                          )),
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.85,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  // width: MediaQuery.of(context).size.width-85,
                                                  child: Text(
                                                      "Price : Rs." +
                                                          cartData[i]['price'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 15)),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                      Icons.delete_outline),
                                                  onPressed: () {
                                                    deleteFromCart(context,
                                                        cartData[i]['cart_id']);
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          )
                                        ],
                                      ))
                                ],
                              ),
                          SizedBox(
                            height: 20,
                          ),
                          cart_total > 0
                              ? Container(
                                  padding: EdgeInsets.all(10),
                                  height: 70,
                                  width:
                                      MediaQuery.of(context).size.width * 0.85,
                                  decoration: BoxDecoration(
                                      color: Colors.green.shade400,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(14))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                            "Rs. " + (cart_total).toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CheckoutCart()));
                                          },
                                          child: Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1,
                                                      color: Colors.white),
                                                  borderRadius:
                                                      BorderRadius.circular(5)),
                                              child: Text("Pay Now",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold))))
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    SizedBox(
                                      height: 70,
                                    ),
                                    Image.asset(
                                        "assets/conifer-volleyball-1.png"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                        alignment: Alignment.center,
                                        child: Text("Cart is Empty",
                                            style: TextStyle(
                                                fontSize: 28,
                                                color: Colors.grey.shade800,
                                                fontWeight: FontWeight.bold))),
                                  ],
                                ),
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
