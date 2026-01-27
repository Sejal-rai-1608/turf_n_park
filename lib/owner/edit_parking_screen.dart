import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:turfandpark/owner/add_turf_screen.dart';

import '../helpers/helper_functions.dart';

class EditParkingScreen extends StatefulWidget {
  EditParkingScreen({Key? key, required this.turfData, required this.update})
      : super(key: key);
  Map turfData;
  Function update;
  @override
  State<EditParkingScreen> createState() => _EditParkingScreenState();
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);

class _EditParkingScreenState extends State<EditParkingScreen> {
  final formGlobalKey = GlobalKey<FormState>();

  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  final List<SelectedListItem> _parkingTypeList = [
    SelectedListItem(isSelected: false, name: "2 wheeler"),
    SelectedListItem(isSelected: false, name: "4 wheeler"),
  ];
  final List<SelectedListItem> _listSelectType = [
    SelectedListItem(isSelected: false, name: "Monthly"),
    SelectedListItem(isSelected: false, name: "Yearly"),
    SelectedListItem(isSelected: false, name: "Quarterly"),
  ];
  List<String> selectedGame = [];
  dynamic _pickImageError;
  List<XFile>? _imageFileList;
  XFile? _imageFileSingle;
  final ImagePicker _picker = ImagePicker();

  set _imageFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  late CountryModel selectedCountry;
  late CountryModel selectedCity;
  late CountryModel selectedState;

  String initialSelectedCountry = '';
  String initialselectedCity = '';
  String initialselectedState = '';

  List<CountryModel> countryList = [];

  List<SelectedListItem> countryListName = [];
  List<CountryModel> stateList = [];
  List<SelectedListItem> stateListName = [];
  List<CountryModel> cityList = [];
  List<SelectedListItem> cityListName = [];

  String? _retrieveDataError;

  /// This is register text field controllers.
  final TextEditingController _title = TextEditingController();

  final TextEditingController _TurfDescTextEditingController =
      TextEditingController();
  final TextEditingController _hourlyPriceNumberTextEditingController =
      TextEditingController();
  final TextEditingController _parkingTypeController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  final TextEditingController _cityController = TextEditingController();

  final TextEditingController _countryController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _parkingSlotController = TextEditingController();
  final TextEditingController _parkingfloorController = TextEditingController();
  final TextEditingController _flatController = TextEditingController();

  Future<void> _displayPickImageDialog(
      BuildContext context, OnPickImageCallback onPick) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add optional parameters'),
            content: Column(
              children: <Widget>[
                TextField(
                  controller: maxWidthController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      hintText: 'Enter maxWidth if desired'),
                ),
                TextField(
                  controller: maxHeightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      hintText: 'Enter maxHeight if desired'),
                ),
                TextField(
                  controller: qualityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      hintText: 'Enter quality if desired'),
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                  child: const Text('PICK'),
                  onPressed: () {
                    final double? width = maxWidthController.text.isNotEmpty
                        ? double.parse(maxWidthController.text)
                        : null;
                    final double? height = maxHeightController.text.isNotEmpty
                        ? double.parse(maxHeightController.text)
                        : null;
                    final int? quality = qualityController.text.isNotEmpty
                        ? int.parse(qualityController.text)
                        : null;
                    onPick(width, height, quality);
                    Navigator.of(context).pop();
                  }),
            ],
          );
        });
  }

  Future<void> _onImageButtonPressed(ImageSource source,
      {BuildContext? context, bool isMultiImage = false}) async {
    if (isMultiImage) {
      try {
        final List<XFile>? pickedFileList = await _picker.pickMultiImage(
          maxHeight: 500,
          maxWidth: 400,
        );
        setState(() {
          _imageFileList = pickedFileList;
        });
      } catch (e) {
        setState(() {
          _pickImageError = e;
        });
      }
    } else {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
      );
      setState(() {
        _imageFileSingle = pickedFile;
      });
      Navigator.pop(context!);
    }
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  var list = [];
  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList == null) {
      list = widget.turfData['slider_images'].toString().split(',');
      return Semantics(
          child: ListView.builder(
        scrollDirection: Axis.vertical,
        physics: BouncingScrollPhysics(),
        key: UniqueKey(),
        itemBuilder: (BuildContext context, int index) {
          // Why network for web?
          // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
          return Semantics(
            label: 'image_picker_example_picked_image',
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                    "https://turfnpark.com/turf_images/${list[index]}")),
          );
        },
        itemCount: list.length,
      ));
    } else if (_imageFileList != null) {
      return Semantics(
          child: ListView.builder(
            scrollDirection: Axis.vertical,
            physics: BouncingScrollPhysics(),
            key: UniqueKey(),
            itemBuilder: (BuildContext context, int index) {
              // Why network for web?
              // See https://pub.dev/packages/image_picker#getting-ready-for-the-web-platform
              return Semantics(
                label: 'image_picker_example_picked_image',
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    File(
                      _imageFileList![index].path,
                    ),
                  ),
                ),
              );
            },
            itemCount: _imageFileList!.length,
          ),
          label: 'image_picker_example_picked_images');
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
      );
    } else {
      return const Text(
        'You have not yet picked an image.(Note:- You can pick multiple images)',
      );
    }
  }

  Widget _previewSingleImage() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }

    if (_imageFileSingle == null) {
      return Semantics(
        child: Image.network(widget.turfData['main_image']),
      );
    } else if (_imageFileSingle != null) {
      return Semantics(
        child: Image.file(File(_imageFileSingle!.path)),
      );
    } else if (_pickImageError != null) {
      return Text(
        'Pick image error: $_pickImageError',
      );
    } else {
      return const Text(
        'You have not yet picked an image.(Note:- You can Only pick Single images)',
      );
    }
  }

  bool isLoading = false;

  updateParking() async {
    final DateFormat formatter = DateFormat('yyyy/MM/dd');
    final String formatted = formatter.format(selectedDate);

    try {
      setState(() {
        isLoading = true;
      });
      var dio = Dio();
      var url = Uri.parse(Constants.base_url + 'Owner/update_parking');

      var request = http.MultipartRequest("POST", url);

      Map<String, String> data = {
        "userToken": Constants.token,
        "parking_id": widget.turfData["id"],
        "parking_for": parkingFor ? "society" : "anyone",
        "title": _title.text,
        "rent": _hourlyPriceNumberTextEditingController.text,
        "description": _TurfDescTextEditingController.text,
        "payment_type": _parkingTypeController.text,
        "start_date": formatted.toString(),
        "flat_no": _flatController.text,
        "parking_type": _parkingSlotController.text,
        "address2": _address2Controller.text,
        "address": _addressController.text,
        "parking_slot": _parkingSlotController.text,
        "parking_floor": _parkingfloorController.text,
        "city": selectedCity.id,
        "state": selectedState.id,
        "country": selectedCountry.id,
        "active": isAvailableSelectedBool ? "1" : "0",
      };
      //  "main_image": await MultipartFile.fromFile(_imageFileSingle!.path,
      //       filename: _imageFileSingle!.path.split('/').last).toString(),
      if (_imageFileSingle == null) {
        data["main_image"] = widget.turfData["main_image"];
      } else {
        var mainImage = await http.MultipartFile.fromPath(
            "main_image", _imageFileSingle!.path);
        request.files.add(mainImage);
      }

      request.fields.addAll(data);
      var response = await request.send();
      if (response.statusCode == 200) {
        widget.update();
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        showSnackbar(context, "Parking Updated");
      }
      //Get the response from the server
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      //   var response = await http.get(
      //     url,
      //   );
      //   // var response = await dio.postUri(
      //   //     Uri.parse(Constants.base_url + 'Owner/add_turf'),
      //   //     data: formDsata);
      //   if (response.statusCode == 200) {
      //     setState(() {
      //       isLoading = false;
      //     });

      //     //  showSnackbar(context, response.data["message"]);
      //   } else {
      //     //  showSnackbar(context, response.data["message"]);
      //     setState(() {
      //       isLoading = false;
      //     });
      //   }
      // } catch (e) {
      //   showSnackbar(context, e.toString());
      //
      //   setState(() {
      //     isLoading = false;
      //   });
      // }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  getCountry() async {
    var url = Uri.parse(Constants.base_url + 'Service/country_list');
    var response = await http.post(
      url,
    );
    var body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      var list = body['message'];
      setState(() {
        list.forEach((element) {
          countryList.add(CountryModel(
            id: element['id'],
            name: element['country_name'],
          ));
          countryListName.add(SelectedListItem(
              isSelected: false, name: element['country_name']));
        });
      });
      initialSelectedCountry = countryList
          .firstWhere((element) => element.id == widget.turfData["country"])
          .name;
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);
    }
  }

  getState(id) async {
    var url = Uri.parse(Constants.base_url + 'Service/state_list');
    var response = await http.post(
      url,
      body: {"country_id": id},
    );
    var body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      var list = body['message'];
      setState(() {
        list.forEach((element) {
          stateList.add(CountryModel(
            id: element['id'],
            name: element['name'],
          ));
          stateListName
              .add(SelectedListItem(isSelected: false, name: element['name']));
        });
      });
      initialselectedState = stateList
          .firstWhere((element) => element.id == widget.turfData["state"])
          .name;
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);
    }
  }

  getCity(id) async {
    var url = Uri.parse(Constants.base_url + 'Service/cities_list');
    var response = await http.post(
      url,
      body: {"state_id": id},
    );
    var body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      var list = body['message'];
      if (list == "No cities Found.") {
        showSnackbar(context, list);
      }
      setState(() {
        list.forEach((element) {
          cityList.add(CountryModel(
            id: element['id'],
            name: element['city_name'],
          ));
          cityListName.add(
              SelectedListItem(isSelected: false, name: element['city_name']));
        });
      });
      initialselectedCity = cityList
          .firstWhere((element) => element.id == widget.turfData["city"])
          .name;
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);
    }
  }

  @override
  void initState() {
    log(widget.turfData.toString());
    _title.text = widget.turfData["title"];
    _TurfDescTextEditingController.text = widget.turfData["description"];
    _hourlyPriceNumberTextEditingController.text =
        widget.turfData["rent"] ?? "";
    _address2Controller.text = widget.turfData["address2"];
    _addressController.text = widget.turfData["address"];
    _parkingSlotController.text = widget.turfData["parking_slot"];
    _parkingTypeController.text = widget.turfData["payment_type"];
    _typeController.text = widget.turfData["parking_type"] == "1"
        ? "Monthly"
        : widget.turfData["parking_type"] == "2"
            ? "Yearly"
            : "Quarterly";
    _parkingfloorController.text = widget.turfData["parking_floor"];
    _flatController.text = widget.turfData["flat_no"];
    selectedCountry = CountryModel(name: "", id: widget.turfData["country"]);
    selectedState = CountryModel(name: "", id: widget.turfData["state"]);
    selectedCity = CountryModel(name: "", id: widget.turfData["city"]);
    selectedDate = DateTime.parse(widget.turfData["created"]);
    getCountry();
    getCity(widget.turfData["state"]);
    getState(widget.turfData["country"]);
    if (widget.turfData["active"] != "0") {
      isAvailableSelected = [true, false];
    } else {
      isAvailableSelected = [false, true];
    }

    if (widget.turfData["parking_for"] != "anyone") {
      isParkingFor = [true, false];
    } else {
      isParkingFor = [false, true];
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _title.dispose();
    _TurfDescTextEditingController.dispose();
    _hourlyPriceNumberTextEditingController.dispose();
    _parkingTypeController.dispose();
    _typeController.dispose();

    _addressController.dispose();

    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
  }

  TextEditingController _searchTextEditingController = TextEditingController();

  void onTextFieldTap() {
    DropDownState(
      DropDown(
        data: countryListName,
        selectedItems: (List<SelectedListItem> selectedList) {
          _countryController.text = selectedList.first.name;
          selectedCountry =
              countryList.firstWhere((element) => element.name == selected);
          getState(selectedCountry.id);
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  void onTextFieldTapState() {
    DropDownState(
      DropDown(
        bottomSheetTitle: Text("Select State"),
        data: stateListName,
        selectedItems: (List<SelectedListItem> selectedList) {
          _stateController.text = selectedList.first.name;
          selectedState =
              stateList.firstWhere((element) => element.name == selected);

          getCity(selectedState.id);
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  void onTextFieldTapCity() {
    DropDownState(
      DropDown(
        bottomSheetTitle: Text("Select City"),
        data: cityListName,
        selectedItems: (List<SelectedListItem> selectedList) {
          _cityController.text = selectedList.first.name;
          selectedCity =
              cityList.firstWhere((element) => element.name == selected);
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  DateTime selectedDate = DateTime.parse("2022-04-05 14:44:08.302667");
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  List<String> selected = [];

  late List<bool> isAvailableSelected;
  late List<bool> isParkingFor;
  bool isAvailableSelectedBool = true;
  bool parkingFor = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Edit Parking",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        backgroundColor: Colors.green.shade500,
      ),
      backgroundColor: Color(0xFFF5F5F5),
      body: Form(
        key: formGlobalKey,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(
                //   height: 30.0,
                // ),
                // Container(
                //   decoration: BoxDecoration(
                //     color: Colors.green.shade600,
                //     borderRadius: BorderRadius.circular(10.0),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black38,
                //         blurRadius: 6.0,
                //         offset: Offset(2, 2),
                //       ),
                //     ],
                //   ),
                //   child: Padding(
                //     padding: const EdgeInsets.all(8.0),
                //     child: Row(
                //       children: [
                //         const Icon(
                //           Icons.edit_outlined,
                //           color: Colors.white,
                //         ),
                //         const Text(
                //           "Edit Parking",
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: 34.0,
                //             fontWeight: FontWeight.bold,
                //           ),
                //         ),
                //         Spacer(),
                //         IconButton(
                //           icon: Icon(
                //             Icons.close,
                //             color: Colors.white,
                //           ),
                //           onPressed: () {
                //             Navigator.of(context).pop();
                //           },
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                // const SizedBox(
                //   height: 15.0,
                // ),
                AppTextField(
                  textEditingController: _title.text == ""
                      ? TextEditingController(text: widget.turfData["title"])
                      : _title,
                  title: "Parking Name",
                  hint: "Enter Parking Name",
                  isCitySelected: false,
                ),
                AppTextField(
                  textEditingController:
                      _TurfDescTextEditingController.text == ""
                          ? TextEditingController(
                              text: widget.turfData["description"])
                          : _TurfDescTextEditingController,
                  title: "Parking Description",
                  hint: "Enter Parking Description",
                  isCitySelected: false,
                ),
                AppTextField(
                  isNumber: true,
                  textEditingController:
                      _hourlyPriceNumberTextEditingController,
                  title: "Rate Amount",
                  hint: "Enter Rate Amount",
                  isCitySelected: false,
                ),
                Text(
                  "Select Start Date",
                  style: TextStyle(),
                ),
                SizedBox(height: 10.0),
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Date:  ",
                                style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                selectedDate ==
                                        DateTime.parse(
                                            "2022-04-05 14:44:08.302667")
                                    ? "Select Date"
                                    : "${DateFormat('dd-MMM-yyyy').format(selectedDate)}",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    SizedBox(
                      height: 100,
                      width: MediaQuery.of(context).size.width / 2.3,
                      child: AppTextField(
                        textEditingController: _parkingTypeController,
                        title: "Parking Type",
                        hint: "Parking Type",
                        isCitySelected: true,
                        cities: _parkingTypeList,
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      height: 100,
                      width: MediaQuery.of(context).size.width / 2.3,
                      child: AppTextField(
                        textEditingController: _typeController,
                        title: "Select Type",
                        hint: "Select Type",
                        isCitySelected: true,
                        cities: _listSelectType,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Select Country"),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller: _countryController
                          ..text = initialSelectedCountry,
                        cursorColor: Colors.black,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          onTextFieldTap();
                        },
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.only(
                              left: 8, bottom: 0, top: 0, right: 15),
                          hintText: "Country",
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Select State"),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller: _stateController
                          ..text = initialselectedState,
                        cursorColor: Colors.black,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          onTextFieldTapState();
                        },
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.only(
                              left: 8, bottom: 0, top: 0, right: 15),
                          hintText: "State",
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Select City"),
                      const SizedBox(
                        height: 5.0,
                      ),
                      TextFormField(
                        controller: _cityController..text = initialselectedCity,
                        cursorColor: Colors.black,
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          onTextFieldTapCity();
                        },
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.only(
                              left: 8, bottom: 0, top: 0, right: 15),
                          hintText: "City",
                          hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w500),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 0,
                              style: BorderStyle.none,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                    ],
                  ),
                ),
                AppTextField(
                  textEditingController: _addressController != ""
                      ? TextEditingController(text: widget.turfData["address"])
                      : _addressController,
                  title: "Address",
                  hint: "Enter Parking Address",
                  isCitySelected: false,
                ),
                AppTextField(
                  textEditingController: _address2Controller != ""
                      ? TextEditingController(text: widget.turfData["address2"])
                      : _address2Controller,
                  title: "Address 2",
                  hint: "Enter Parking Address 2",
                  isCitySelected: false,
                ),
                AppTextField(
                  textEditingController: _flatController == ""
                      ? TextEditingController(text: widget.turfData["flat_no"])
                      : _flatController,
                  title: "Flat No",
                  hint: "Enter Flat No",
                  isCitySelected: false,
                ),
                AppTextField(
                  textEditingController: _parkingSlotController != ""
                      ? TextEditingController(
                          text: widget.turfData["parking_slot"])
                      : _parkingSlotController,
                  title: "Parking Slot",
                  isNumber: true,
                  hint: "Enter Parking Slot",
                  isCitySelected: false,
                ),
                AppTextField(
                  textEditingController: _parkingfloorController != ""
                      ? TextEditingController(
                          text: widget.turfData["parking_floor"])
                      : _parkingfloorController,
                  title: "Parking Floor",
                  isNumber: true,
                  hint: "Enter Parking Floor",
                  isCitySelected: false,
                ),
                Text("Parking For", style: TextStyle(color: Colors.black54)),
                SizedBox(
                  height: 10,
                ),
                ToggleButtons(
                  borderColor: Colors.black38,
                  fillColor: Colors.green.shade600,
                  borderWidth: 1,
                  selectedBorderColor: Colors.black38,
                  selectedColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
                      child: Text(
                        'Society',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
                      child: Text(
                        'Anyone',
                      ),
                    ),
                  ],
                  onPressed: (int index) {
                    parkingFor = index == 0 ? true : false;

                    setState(() {
                      for (int i = 0; i < isParkingFor.length; i++) {
                        isParkingFor[i] = i == index;
                      }
                    });
                  },
                  isSelected: isParkingFor,
                ),
                SizedBox(
                  height: 20,
                ),
                Text("Is Available"),
                SizedBox(
                  height: 10,
                ),
                ToggleButtons(
                  borderColor: Colors.black38,
                  fillColor: Colors.green.shade600,
                  borderWidth: 1,
                  selectedBorderColor: Colors.black38,
                  selectedColor: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
                      child: Text(
                        'Yes',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                      ),
                      child: Text(
                        'No',
                      ),
                    ),
                  ],
                  onPressed: (int index) {
                    isAvailableSelectedBool = index == 0 ? true : false;

                    setState(() {
                      for (int i = 0; i < isAvailableSelected.length; i++) {
                        isAvailableSelected[i] = i == index;
                      }
                    });
                  },
                  isSelected: isAvailableSelected,
                ),
                const SizedBox(
                  height: 12.0,
                ),
                Text(
                  "Upload Images",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 6.0,
                ),
                Text(
                    "Please upload all images in JPEG/JPG/PNG format with size 500 X 400 PX"),
                const SizedBox(
                  height: 10.0,
                ),
                Card(
                  elevation: 1.0,
                  color: Colors.greenAccent.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      _onImageButtonPressed(
                                                          ImageSource.camera,
                                                          context: context);
                                                    },
                                                    icon: Icon(
                                                      Icons.camera,
                                                      size: 30,
                                                    )),
                                                Text("Camera"),
                                              ],
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      _onImageButtonPressed(
                                                          ImageSource.gallery,
                                                          context: context);
                                                    },
                                                    icon: Icon(
                                                      Icons.photo_album,
                                                      size: 30,
                                                    )),
                                                Text("Gallery"),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            },
                            icon: Icon(Icons.image),
                            label: Text("Select Main Image")),
                        _previewSingleImage(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Card(
                  elevation: 1.0,
                  color: Colors.greenAccent.shade100,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        ElevatedButton.icon(
                            onPressed: () {
                              _onImageButtonPressed(ImageSource.gallery,
                                  context: context, isMultiImage: true);
                            },
                            icon: Icon(Icons.image),
                            label: Text("Select Slider Images")),
                        if (_imageFileList == null)
                          Text("Total number of Images ${list.length}"),
                        SizedBox(
                            height: _imageFileList == null ? 500 : 500,
                            child: _previewImages()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 60.0,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_addressController.text.isEmpty ||
                          _address2Controller.text.isEmpty ||
                          _flatController.text.isEmpty ||
                          _parkingSlotController.text.isEmpty ||
                          _parkingTypeController.text.isEmpty ||
                          _TurfDescTextEditingController.text.isEmpty ||
                          _title.text.isEmpty ||
                          _hourlyPriceNumberTextEditingController
                              .text.isEmpty) {
                        showSnackbar(context, "Please fill all fields");
                      } else
                        updateParking();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined, color: Colors.white),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Text(
                          "Edit Parking",
                          style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      backgroundColor: Colors.green.shade600,
                      elevation: 4,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 25.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTextField extends StatefulWidget {
  TextEditingController textEditingController = TextEditingController();
  final String title;
  final String hint;
  final String CityId;
  final String StateId;
  final bool isCityData;
  final bool isStateData;
  final bool isCitySelected;
  final bool isNumber;
  final List<SelectedListItem>? cities;
  AppTextField({
    required this.textEditingController,
    required this.title,
    this.isNumber = false,
    this.CityId = '',
    this.isCityData = false,
    this.isStateData = false,
    this.StateId = '',
    required this.hint,
    required this.isCitySelected,
    this.cities,
    Key? key,
  }) : super(key: key);

  @override
  _AppTextFieldState createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  TextEditingController _searchTextEditingController = TextEditingController();

  /// This is on text changed method which will display on city text field on changed.
  void onTextFieldTap() {
    DropDownState(
      DropDown(
        bottomSheetTitle: Text(widget.title),
        data: widget.cities ?? [],
        selectedItems: (List<SelectedListItem> selectedList) {
          if (widget.isCityData) {}
          widget.textEditingController.text = selectedList.first.name;
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title,
              style: TextStyle(
                color: Colors.black54,
              )),
          const SizedBox(
            height: 5.0,
          ),
          TextFormField(
            controller: widget.textEditingController,
            cursorColor: Colors.black,
            keyboardType:
                widget.isNumber ? TextInputType.number : TextInputType.text,
            onTap: widget.isCitySelected
                ? () {
                    FocusScope.of(context).unfocus();
                    onTextFieldTap();
                  }
                : null,
            style: TextStyle(
              color: Colors.black,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.only(left: 8, bottom: 0, top: 0, right: 15),
              hintText: widget.hint,
              hintStyle:
                  TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
              border: const OutlineInputBorder(
                borderSide: BorderSide(
                  width: 0,
                  style: BorderStyle.none,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 15.0,
          ),
        ],
      ),
    );
  }
}

/// This is common class for 'REGISTER' elevated button.
class _AppElevatedButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 60.0,
      child: ElevatedButton(
        onPressed: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_task_rounded, color: Colors.white),
            const SizedBox(
              width: 10.0,
            ),
            Text(
              "Add Turf",
              style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.green.shade600,
          elevation: 4,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
