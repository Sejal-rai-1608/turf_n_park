import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:multiselect/multiselect.dart';

import '../helpers/helper_functions.dart';

class PlayableGameModel {
  String gameName;
  String gameId;
  PlayableGameModel({required this.gameName, required this.gameId});
}

class CountryModel {
  String name;
  String id;
  CountryModel({required this.name, required this.id});
}

class AddTurfScreen extends StatefulWidget {
  Function updateHome;
  AddTurfScreen({Key? key, required this.updateHome}) : super(key: key);

  @override
  State<AddTurfScreen> createState() => _AddTurfScreenState();
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);

class _AddTurfScreenState extends State<AddTurfScreen> {
  final formGlobalKey = GlobalKey<FormState>();

  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();
  var SelectedLocation = "";

  Location location = new Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;
  bool loadingLocation = false;

  List<String> selectedGame = [];
  dynamic _pickImageError;
  List<XFile>? _imageFileList;
  XFile? _imageFileSingle;
  final ImagePicker _picker = ImagePicker();

  final List<SelectedListItem> _listOfStartTime = [
    SelectedListItem(isSelected: false, name: "03:00:00"),
    SelectedListItem(isSelected: false, name: "04:00:00"),
    SelectedListItem(isSelected: false, name: "05:00:00"),
    SelectedListItem(isSelected: false, name: "06:00:00"),
    SelectedListItem(isSelected: false, name: "07:00:00"),
    SelectedListItem(isSelected: false, name: "08:00:00"),
    SelectedListItem(isSelected: false, name: "09:00:00"),
    SelectedListItem(isSelected: false, name: "10:00:00"),
    SelectedListItem(isSelected: false, name: "11:00:00"),
    SelectedListItem(isSelected: false, name: "12:00:00"),
    SelectedListItem(isSelected: false, name: "13:00:00"),
    SelectedListItem(isSelected: false, name: "14:00:00"),
    SelectedListItem(isSelected: false, name: "15:00:00"),
    SelectedListItem(isSelected: false, name: "16:00:00"),
    SelectedListItem(isSelected: false, name: "17:00:00"),
    SelectedListItem(isSelected: false, name: "18:00:00"),
    SelectedListItem(isSelected: false, name: "19:00:00"),
    SelectedListItem(isSelected: false, name: "20:00:00"),
    SelectedListItem(isSelected: false, name: "21:00:00"),
    SelectedListItem(isSelected: false, name: "22:00:00"),
    SelectedListItem(isSelected: false, name: "23:00:00"),
  ];
  final List<SelectedListItem> _listOfEndTime = [
    SelectedListItem(isSelected: false, name: "03:00:00"),
    SelectedListItem(isSelected: false, name: "04:00:00"),
    SelectedListItem(isSelected: false, name: "05:00:00"),
    SelectedListItem(isSelected: false, name: "06:00:00"),
    SelectedListItem(isSelected: false, name: "07:00:00"),
    SelectedListItem(isSelected: false, name: "08:00:00"),
    SelectedListItem(isSelected: false, name: "09:00:00"),
    SelectedListItem(isSelected: false, name: "10:00:00"),
    SelectedListItem(isSelected: false, name: "11:00:00"),
    SelectedListItem(isSelected: false, name: "12:00:00"),
    SelectedListItem(isSelected: false, name: "13:00:00"),
    SelectedListItem(isSelected: false, name: "14:00:00"),
    SelectedListItem(isSelected: false, name: "15:00:00"),
    SelectedListItem(isSelected: false, name: "16:00:00"),
    SelectedListItem(isSelected: false, name: "17:00:00"),
    SelectedListItem(isSelected: false, name: "18:00:00"),
    SelectedListItem(isSelected: false, name: "19:00:00"),
    SelectedListItem(isSelected: false, name: "20:00:00"),
    SelectedListItem(isSelected: false, name: "21:00:00"),
    SelectedListItem(isSelected: false, name: "22:00:00"),
    SelectedListItem(isSelected: false, name: "23:00:00"),
  ];
  set _imageFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  late CountryModel selectedCountry;
  late CountryModel selectedCity;
  late CountryModel selectedState;

  List<CountryModel> countryList = [];

  List<SelectedListItem> countryListName = [];
  List<CountryModel> stateList = [];
  List<SelectedListItem> stateListName = [];
  List<CountryModel> cityList = [];
  List<SelectedListItem> cityListName = [];
  List<PlayableGameModel> playableGames = [];
  String? _retrieveDataError;

  /// This is register text field controllers.
  final TextEditingController _fullNameTextEditingController =
      TextEditingController();

  final TextEditingController _TurfDescTextEditingController =
      TextEditingController();
  final TextEditingController _hourlyPriceNumberTextEditingController =
      TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  final TextEditingController _cityController = TextEditingController();

  final TextEditingController _countryController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();

  final TextEditingController _amenitiesController = TextEditingController();

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

  getCurrentLocation() async {
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
    _latController.text = Constants.lat;
    _longController.text = Constants.long;
    Constants.fullLocation = "Nearst to Me";
  }

  Text? _getRetrieveErrorWidget() {
    if (_retrieveDataError != null) {
      final Text result = Text(_retrieveDataError!);
      _retrieveDataError = null;
      return result;
    }
    return null;
  }

  Widget _previewImages() {
    final Text? retrieveError = _getRetrieveErrorWidget();
    if (retrieveError != null) {
      return retrieveError;
    }
    if (_imageFileList != null) {
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
    if (_imageFileSingle != null) {
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

  addTurf() async {
    try {
      setState(() {
        isLoading = true;
      });
      var dio = Dio();
      var url = Uri.parse(Constants.base_url + 'Owner/add_turf');

      var request = http.MultipartRequest("POST", url);

      Map<String, String> data = {
        "userToken": Constants.token,
        "turf_name": _fullNameTextEditingController.text,
        "description": _TurfDescTextEditingController.text,
        "hourly_rent": _hourlyPriceNumberTextEditingController.text,
        "day_start_time": _startTimeController.text,
        "day_end_time": _endTimeController.text,
        "lat": _latController.text,
        "long": _longController.text,
        "address": _addressController.text,
        "city": selectedCity.id,
        "state": selectedState.id,
        "country": selectedCountry.id,
      };
      //  "main_image": await MultipartFile.fromFile(_imageFileSingle!.path,
      //       filename: _imageFileSingle!.path.split('/').last).toString(),
      var temp = _amenitiesController.text.toString().split(',');
      for (int i = 0; i < temp.length; i++) {
        request.fields.addEntries([MapEntry('amenities[$i]', temp[i])]);
      }
      for (int i = 0; i < selectedGame.length; i++) {
        String id = playableGames
            .firstWhere((element) => element.gameName == selectedGame[i])
            .gameId;

        request.fields.addEntries([MapEntry('playable_games[$i]', id)]);
      }

      var mainImage = await http.MultipartFile.fromPath(
          "main_image", _imageFileSingle!.path);
      request.files.add(mainImage);
      int j;
      for (j = 0; j < _imageFileList!.length; j++) {
        var sliderImage = await http.MultipartFile.fromPath(
            "slider_images[]", _imageFileList![j].path);

        request.files.add(sliderImage);
      }

      request.fields.addAll(data);
      var response = await request.send();
      if (response.statusCode == 200) {
        widget.updateHome();
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        showSnackbar(context,
            "Turf Added under review. Please wait until review process.");
      }
      //Get the response from the server
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  getPlayableGames() async {
    var url = Uri.parse(Constants.base_url + 'Owner/playable_games');
    var response = await http.get(
      url,
    );
    var body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      var list = body['message'];
      setState(() {
        list.forEach((element) {
          playableGames.add(PlayableGameModel(
              gameName: element['name'], gameId: element['id']));
        });
      });
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);

      setState(() {});
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
    } else if (response.statusCode == 401) {
      showSnackbar(context, body['message']);
      onLogout(context);
    } else {
      showSnackbar(context, body['message']);
    }
  }

  @override
  void initState() {
    getPlayableGames();
    getCountry();

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _fullNameTextEditingController.dispose();
    _TurfDescTextEditingController.dispose();
    _hourlyPriceNumberTextEditingController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _latController.dispose();

    _longController.dispose();
    _addressController.dispose();
    _amenitiesController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
  }

  TextEditingController _searchTextEditingController = TextEditingController();

  void onTextFieldTap() {
    DropDownState(
      DropDown(
        data: countryListName,
        bottomSheetTitle: Text("Select Country"),
        selectedItems: (List<SelectedListItem> selectedList) {
          _countryController.text = selectedList.first.name;
          selectedCountry = countryList
              .firstWhere((element) => element.name == selectedList.first.name);

          getState(selectedCountry.id);
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  void onTextFieldTapState() {
    DropDownState(
      DropDown(
        data: stateListName,
        bottomSheetTitle: Text("Select State"),
        selectedItems: (List<SelectedListItem> selectedList) {
          _stateController.text = selectedList.first.name;
          selectedState = stateList
              .firstWhere((element) => element.name == selectedList.first.name);

          getCity(selectedState.id);
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  void onTextFieldTapCity() {
    DropDownState(
      DropDown(
        data: cityListName,
        bottomSheetTitle: Text("Select City"),
        selectedItems: (List<SelectedListItem> selected) {
          _cityController.text = selected.first.name;
          selectedCity = cityList
              .firstWhere((element) => element.name == selected.first.name);
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

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
        title: Text("Add Turf",
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
                //           Icons.add,
                //           color: Colors.white,
                //         ),
                //         const Text(
                //           "Add Turf",
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
                  textEditingController: _fullNameTextEditingController,
                  title: "Turf Name",
                  hint: "Enter Turf Name",
                  isCitySelected: false,
                ),
                AppTextField(
                  textEditingController: _TurfDescTextEditingController,
                  title: "Turf Description",
                  hint: "Enter Turf Description",
                  isCitySelected: false,
                ),
                AppTextField(
                  isNumber: true,
                  textEditingController:
                      _hourlyPriceNumberTextEditingController,
                  title: "Hourly Rate",
                  hint: "Enter Hourly Rate in Rupees",
                  isCitySelected: false,
                ),
                Row(
                  children: [
                    SizedBox(
                      height: 100,
                      width: MediaQuery.of(context).size.width / 2.3,
                      child: AppTextField(
                        textEditingController: _startTimeController,
                        title: "Opening Time",
                        hint: "Start Time",
                        isCitySelected: true,
                        cities: _listOfStartTime,
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      height: 100,
                      width: MediaQuery.of(context).size.width / 2.3,
                      child: AppTextField(
                        textEditingController: _endTimeController,
                        title: "Closing Time",
                        hint: "End Time",
                        isCitySelected: true,
                        cities: _listOfEndTime,
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
                        controller: _countryController,
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
                        controller: _stateController,
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
                        controller: _cityController,
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
                Text("Select Playable Games"),
                DropDownMultiSelect(
                    childBuilder: (List<String> value) {
                      return Align(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Text(
                                value.length > 0
                                    ? value.reduce((a, b) => a + ' , ' + b)
                                    : '',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              )),
                          alignment: Alignment.centerLeft);
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      suffixStyle: TextStyle(color: Colors.black),
                      counterStyle: TextStyle(color: Colors.black),

                      //  labelText: "Select Playable Games",
                      labelStyle: TextStyle(
                        color: Colors.black54,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black12,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onChanged: (List<String> x) {
                      setState(() {
                        selectedGame = x;
                      });
                    },
                    options: playableGames.map((e) => e.gameName).toList(),
                    selectedValues: selectedGame,
                    whenEmpty: "Select Playable Games"),
                AppTextField(
                  textEditingController: _addressController,
                  title: "Address",
                  hint: "Enter Turf Address",
                  isCitySelected: false,
                ),
                Center(
                  child: loadingLocation
                      ? CircularProgressIndicator(color: Colors.green.shade500)
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(
                                MediaQuery.of(context).size.width / 1.15, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            backgroundColor: Colors.green.shade600,
                          ),
                          onPressed: () {
                            getCurrentLocation();
                          },
                          icon: Icon(
                            Icons.location_on_outlined,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Get Current Location(Lat & Long)",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                AppTextField(
                  textEditingController: _latController,
                  title: "Latitude",
                  isNumber: true,
                  hint: "Enter Turf Latitude",
                  isCitySelected: false,
                ),
                AppTextField(
                  textEditingController: _longController,
                  title: "Longitude",
                  isNumber: true,
                  hint: "Enter Turf Longitude",
                  isCitySelected: false,
                ),
                AppTextField(
                  textEditingController: _amenitiesController,
                  title: "Amenities (Use , to enter multiple Amenities)",
                  hint: "Enter Amenities",
                  isCitySelected: false,
                ),
                Text(
                  "Upload Images",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 10.0,
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
                            label: Text("Main Image")),
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
                            label: Text("Slider Images")),
                        SizedBox(
                            height: _imageFileList == null ? 60 : 500,
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
                          _latController.text.isEmpty ||
                          _longController.text.isEmpty ||
                          _amenitiesController.text.isEmpty ||
                          _cityController.text.isEmpty ||
                          _TurfDescTextEditingController.text.isEmpty ||
                          _fullNameTextEditingController.text.isEmpty ||
                          _hourlyPriceNumberTextEditingController
                              .text.isEmpty) {
                        showSnackbar(context, "Please fill all fields");
                      } else if (_imageFileList == null ||
                          _imageFileSingle == null) {
                        showSnackbar(context, "Please upload images");
                      } else
                        addTurf();
                    },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : Row(
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
        data: widget.cities ?? [],
        bottomSheetTitle: Text(widget.title),
        selectedItems: (List<SelectedListItem> selectedList) {
          // showSnackBar(selectedList.toString());

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
            height: 4.0,
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
