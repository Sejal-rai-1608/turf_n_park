import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:turfandpark/helpers/helper_functions.dart';

class CountProviderCart extends GetxController {
  var count = 0.obs;

  getCartCount(context) async {
    count.value = 0;
    List cartData;
    var url = Uri.parse(Constants.base_url + 'Service/my_cart_list');
    var response = await http.post(url, body: {"userToken": Constants.token});

    var body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      var list = body['message'];

      cartData = list;

      cartData.forEach((element) {
        //
        count.value = count.value + 1;
      });

      return count.value;
    } else if (response.statusCode == 401) {
      count(0);
      return count.value;
    } else {
      count(0);
      return count.value;
    }
  }
}
