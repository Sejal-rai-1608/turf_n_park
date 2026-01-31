import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import '../helpers/widgets.dart';
import 'helper_functions.dart';

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
  Location location = Location();
  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  bool loadingLocation = false;

  @override
  void initState() {
    super.initState();
    getCountries(context);
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
    Constants.fullLocation = "Nearest to Me";
    Navigator.of(context).pop(true);
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
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 18.sp,
            ),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          "Select Location",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Column(
            children: [
              // Current Location Button
              Container(
                margin: EdgeInsets.only(bottom: 30.h),
                child: Material(
                  borderRadius: BorderRadius.circular(15.r),
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade500,
                          Colors.green.shade600,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.shade200,
                          blurRadius: 15.r,
                          offset: Offset(0, 5.h),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15.r),
                      child: InkWell(
                        onTap: () {
                          getcurrentLocation();
                        },
                        borderRadius: BorderRadius.circular(15.r),
                        child: Container(
                          padding: EdgeInsets.all(20.r),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!loadingLocation)
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 26.sp,
                                ),
                              if (!loadingLocation) SizedBox(width: 12.w),
                              if (!loadingLocation)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Use Current Location",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        "Find turfs and parking near you",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (loadingLocation)
                                Container(
                                  width: 24.w,
                                  height: 24.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5.w,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1.w,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w),
                    child: Text(
                      "OR",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.shade300,
                      thickness: 1.w,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 10.h),

              // Manual Location Selection
              Text(
                "Select Location Manually",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
              //SizedBox(height: 5.h),
              Text(
                "Choose your country, state and city",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 10.h),

              // Country Dropdown
              _buildDropdownSection(
                title: "Country",
                hint: "Select Country",
                items: countries,
                valueKey: 'id',
                labelKey: 'country_name',
                onChanged: (newValue) {
                  setState(() {
                    dropdownSelectedCountry = newValue!;
                    getStates(context);
                    dropdownSelectedState = "";
                    dropdownSelectedCity = "";
                    cities = [];
                  });
                },
                selectedValue: dropdownSelectedCountry,
              ),

              SizedBox(height: 10.h),

              // State Dropdown
              _buildDropdownSection(
                title: "State",
                hint: "Select State",
                items: states,
                valueKey: 'id',
                labelKey: 'name',
                onChanged: (newValue) {
                  setState(() {
                    dropdownSelectedState = newValue!;
                    getCities(context);
                    dropdownSelectedCity = "";
                  });
                },
                selectedValue: dropdownSelectedState,
                enabled: dropdownSelectedCountry.isNotEmpty,
              ),

              SizedBox(height: 10.h),

              // City Dropdown
              _buildDropdownSection(
                title: "City",
                hint: "Select City",
                items: cities,
                valueKey: 'id',
                labelKey: 'city_name',
                onChanged: (newValue) {
                  setState(() {
                    dropdownSelectedCity = newValue!;
                  });
                },
                selectedValue: dropdownSelectedCity,
                enabled: dropdownSelectedState.isNotEmpty,
              ),

              SizedBox(height: 20.h),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (dropdownSelectedCountry.isNotEmpty &&
                        dropdownSelectedState.isNotEmpty &&
                        dropdownSelectedCity.isNotEmpty) {
                      Constants.country_id = dropdownSelectedCountry;
                      Constants.state_id = dropdownSelectedState;
                      Constants.city_id = dropdownSelectedCity;

                      // Find selected city name
                      String cityName = "";
                      for (var element in cities) {
                        if (element['id'] == dropdownSelectedCity) {
                          cityName = element['city_name'];
                          break;
                        }
                      }

                      Constants.fullLocation = cityName;
                      Navigator.of(context).pop(true);
                    } else {
                      showSnackbar(
                          context, "Please select all fields correctly.");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.w,
                      vertical: 18.h,
                    ),
                    elevation: 5,
                    shadowColor: Colors.green.shade300,
                  ),
                  child: Text(
                    'Apply Location',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSection({
    required String title,
    required String hint,
    required List items,
    required String valueKey,
    required String labelKey,
    required Function(dynamic) onChanged,
    required String selectedValue,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: enabled ? Colors.grey.shade200 : Colors.grey.shade100,
          width: 1.5.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(15.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color:
                        enabled ? Colors.green.shade500 : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        enabled ? Colors.grey.shade800 : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: enabled ? Colors.white : Colors.grey.shade50,
              ),
              child: DropdownButtonFormField<dynamic>(
                value: selectedValue.isNotEmpty ? selectedValue : null,
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                  size: 26.sp,
                ),
                iconSize: 24,
                hint: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color:
                        enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                  ),
                ),
                isExpanded: true,
                style: TextStyle(
                  color: enabled ? Colors.grey.shade800 : Colors.grey.shade400,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1.5.w,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1.5.w,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(
                      color: Colors.green.shade400,
                      width: 2.w,
                    ),
                  ),
                  filled: true,
                  fillColor: enabled ? Colors.white : Colors.grey.shade50,
                ),
                onChanged: enabled ? onChanged : null,
                items: items.map<DropdownMenuItem<dynamic>>((item) {
                  return DropdownMenuItem(
                    value: item[valueKey],
                    child: Text(
                      item[labelKey],
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 15.sp,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
