import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import '../helpers/widgets.dart';
import 'helper_functions.dart';

// import 'pre_login_owner.dart';
class SelectLocation extends StatefulWidget {
  const SelectLocation({Key? key}) : super(key: key);

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  bool isLoading = false;

  var countries = [];
  var states = [];
  var cities = [];

  var dropdownSelectedCountry = "";
  var dropdownSelectedState = "";
  var dropdownSelectedCity = "";
  var SelectedLocation = "";

  Location location = new Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  bool loadingLocation = false;

  @override
  void initState() {
    super.initState();
    getCountries(context);
    // countries.add({"id": "1", "country_name": "India"});
    // countries.add({"id": "2", "country_name": "USA"});

    // states.add({"id": "1", "name": "Maharashtra"});
    // states.add({"id": "2", "name": "Rajasthan"});

    // cities.add({"id": "1", "city_name": "Pune"});
    // cities.add({"id": "2", "city_name": "Nashik"});
    // cities.add({"id": "3", "city_name": "Mumbai"});
    // cities.add({"id": "4", "city_name": "Jodhpur"});
  }

  getCountries(context) async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/country_list');
    var response = await http.post(url, body: {});
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var list = body['message'];
      setState(() {
        countries = list;
      });
    } else {
      showSnackbar(context, body['message']);
    }
  }

  getStates(context) async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/state_list');
    var response =
        await http.post(url, body: {"country_id": dropdownSelectedCountry});
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var list = body['message'];
      setState(() {
        states = list;
      });
    } else {
      showSnackbar(context, body['message']);
    }
  }

  getCities(context) async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.parse(Constants.base_url + 'Service/cities_list');
    var response =
        await http.post(url, body: {"state_id": dropdownSelectedState});
    var body = jsonDecode(response.body);

    setState(() {
      isLoading = false;
    });
    if (response.statusCode == 200) {
      var list = body['message'];
      cities = [];
      setState(() {
        cities = list;
      });
    } else {
      showSnackbar(context, body['message']);
    }
  }

  getcurrentLocation() async {
    setState(() {
      loadingLocation = true;
    });
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          loadingLocation = false;
        });
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          loadingLocation = false;
        });
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      loadingLocation = false;
    });
    Constants.lat = _locationData.latitude.toString();
    Constants.long = _locationData.longitude.toString();
    Constants.fullLocation = "Nearst to Me";
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      appBar: AppBar(
        backgroundColor: Colors.green.shade500,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Select Location",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // SizedBox(height: 10,),

            // Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     // alignment: Alignment.topRight,
            //     children: [
            //       Padding(
            //         padding: EdgeInsets.symmetric(horizontal: 20),
            //         child: Text(
            //           "Select Location",
            //           style: TextStyle(
            //               fontSize: 16, fontWeight: FontWeight.bold),
            //         ),
            //       ),
            //       Spacer(),
            //       isLoading
            //           ? Container(
            //               padding: EdgeInsets.only(left: 10, top: 10),
            //               child: CircularProgressIndicator(
            //                 color: Colors.green.shade500,
            //               ))
            //           : SizedBox(width: 10),
            //       Spacer(),
            //       IconButton(
            //         icon: Icon(Icons.close),
            //         onPressed: () {
            //           Navigator.of(context).pop();
            //         },
            //       )
            //     ]),
            // SizedBox(
            //   height: 10,
            // ),
            GestureDetector(
                onTap: () {
                  getcurrentLocation();
                },
                child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(25),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.green.shade400),
                        color: Colors.green.shade400,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!loadingLocation)
                          Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                            size: 25,
                          ),
                        if (!loadingLocation)
                          SizedBox(
                            width: 10,
                          ),
                        if (!loadingLocation)
                          Text(
                            "Nearest to my current location",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        if (loadingLocation)
                          CircularProgressIndicator(
                            color: Colors.white,
                          )
                      ],
                    ))),
            Container(
              alignment: Alignment.center,
              child: Text("OR"),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Country",
                        style: TextStyle(
                            fontSize: 14, color: Colors.green.shade600)),
                    DropdownButtonFormField<dynamic>(
                        // value: dropdownSelectedUserType,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        hint: Text(
                          "Select Country",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.black),
                        //underline: SizedBox(),
                        onChanged: (newValue) {
                          setState(() {
                            dropdownSelectedCountry = newValue!;

                            getStates(context);
                          });
                        },
                        items: countries.map<DropdownMenuItem<dynamic>>((item) {
                          return DropdownMenuItem(
                            value: item['id'],
                            child: Text(item['country_name']),
                          );
                        }).toList()),
                    SizedBox(height: 25),
                    Text("State",
                        style: TextStyle(
                            fontSize: 14, color: Colors.green.shade600)),
                    DropdownButtonFormField<dynamic>(
                        // value: dropdownSelectedState,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        hint: Text(
                          "Select State",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.black),
                        //underline: SizedBox(),
                        onChanged: (newValue) {
                          setState(() {
                            dropdownSelectedState = newValue!;

                            getCities(context);
                          });
                        },
                        items: states.map<DropdownMenuItem<dynamic>>((item) {
                          return DropdownMenuItem(
                            value: item['id'],
                            child: Text(item['name']),
                          );
                        }).toList()),
                    SizedBox(height: 25),
                    Text("City",
                        style: TextStyle(
                            fontSize: 14, color: Colors.green.shade600)),
                    DropdownButtonFormField<dynamic>(
                        // value: dropdownSelectedCity,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        hint: Text(
                          "Select City",
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.black),
                        //underline: SizedBox(),
                        onChanged: (newValue) {
                          setState(() {
                            dropdownSelectedCity = newValue!;
                          });
                        },
                        items: cities.map<DropdownMenuItem<dynamic>>((item) {
                          return DropdownMenuItem(
                            value: item['id'],
                            child: Text(item['city_name']),
                          );
                        }).toList()),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                        alignment: Alignment.center,
                        child: Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            // width: MediaQuery.of(context).size.width*0.6,
                            child: RaisedGradientButton(
                              child: Text(
                                'Submit',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Colors.green.shade500,
                                  Colors.green.shade600
                                ],
                              ),
                              onPressed: () {
                                if (dropdownSelectedCountry.length > 0 &&
                                    dropdownSelectedState.length > 0 &&
                                    dropdownSelectedCity.length > 0) {
                                  Constants.country_id =
                                      dropdownSelectedCountry.toString();
                                  Constants.state_id =
                                      dropdownSelectedState.toString();
                                  Constants.city_id =
                                      dropdownSelectedCity.toString();
                                  // states.forEach((element) {
                                  //   if(element['id'] == dropdownSelectedState){
                                  //     SelectedLocation = SelectedLocation+element['name']+"/";
                                  //   }
                                  // });
                                  cities.forEach((element) {
                                    if (element['id'] == dropdownSelectedCity) {
                                      SelectedLocation = SelectedLocation +
                                          element['city_name'];
                                    }
                                  });
                                  Constants.fullLocation =
                                      SelectedLocation.toString();
                                  Navigator.of(context).pop(true);
                                } else {
                                  showSnackbar(context,
                                      "Please Select all fields correctly.");
                                }
                                // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SelectType()));
                              },
                              key: Key("test"),
                            )))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
