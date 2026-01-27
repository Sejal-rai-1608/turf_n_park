import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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

class EditTurfScreen extends StatefulWidget {
  Map turfData;

  EditTurfScreen({Key? key, required this.turfData}) : super(key: key);

  @override
  State<EditTurfScreen> createState() => _EditTurfScreenState();
}

typedef OnPickImageCallback = void Function(
    double? maxWidth, double? maxHeight, int? quality);

class _EditTurfScreenState extends State<EditTurfScreen> {
  final formGlobalKey = GlobalKey<FormState>();
  final TextEditingController maxWidthController = TextEditingController();
  final TextEditingController maxHeightController = TextEditingController();
  final TextEditingController qualityController = TextEditingController();

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
  String initialSelectedCountry = '';
  String initialselectedCity = '';
  String initialselectedState = '';
  late CountryModel selectedCity;
  late CountryModel selectedState;
  List<String> initialSelectedGame = [];
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

  editTurf() async {
    setState(() {
      isLoading = true;
    });
    try {
      var dio = Dio();
      var url = Uri.parse(Constants.base_url + 'Owner/edit_turf');
      print(selectedCity.id);
      print(selectedState.id);
      print(selectedCountry.id);

      var request = http.MultipartRequest("POST", url);
      Map<String, String> data = {
        "userToken": Constants.token,
        "turf_id": widget.turfData["id"],
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
        "amenities[]": _amenitiesController.text,
      };
      //  "main_image": await MultipartFile.fromFile(_imageFileSingle!.path,
      //       filename: _imageFileSingle!.path.split('/').last).toString(),

      for (int i = 0; i < selectedGame.length; i++) {
        String id = playableGames
            .firstWhere((element) => element.gameName == selectedGame[i])
            .gameId;
        print(id);
        request.fields.addEntries([MapEntry('playable_games[$i]', id)]);
      }
      if (_imageFileSingle == null) {
        data["main_image"] = widget.turfData["main_image"];
      } else {
        var mainImage = await http.MultipartFile.fromPath(
            "main_image", _imageFileSingle!.path);
        request.files.add(mainImage);
      }
      if (_imageFileList == null) {
        int j;
        for (j = 0; j < widget.turfData["slider_images"].length; j++) {
          data["slider_images[$j]"] = widget.turfData["slider_images"];
        }
      } else {
        int j;
        for (j = 0; j < _imageFileList!.length; j++) {
          request.files.add(await http.MultipartFile.fromPath(
              'slider_images[]', _imageFileList![j].path));
        }
      }
      request.fields.addAll(data);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        Navigator.pop(context);
        setState(() {
          isLoading = false;
        });
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        print(responseString);
        showSnackbar(context,
            "Turf data saved in the system. Please wait until review process.");
      }
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
        print(widget.turfData["games"]);
        initialSelectedCountry = countryList
            .firstWhere((element) => element.id == widget.turfData["country"])
            .name;
        for (int i = 0; i < widget.turfData["games"].length; i++) {
          initialSelectedGame.add(widget.turfData["games"][i]['name']);
        }
      });
      selectedGame = initialSelectedGame;
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
        initialselectedState = stateList
            .firstWhere((element) => element.id == widget.turfData["state"])
            .name;
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
        initialselectedCity = cityList
            .firstWhere((element) => element.id == widget.turfData["city"])
            .name;
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
    _fullNameTextEditingController.text = widget.turfData["turf_name"];
    _TurfDescTextEditingController.text = widget.turfData["description"];
    _hourlyPriceNumberTextEditingController.text =
        widget.turfData["hourly_rent"];
    _startTimeController.text = widget.turfData["day_start_time"];
    _endTimeController.text = widget.turfData["day_end_time"];
    _addressController.text = widget.turfData["address"];
    _latController.text = widget.turfData["lat"];
    _longController.text = widget.turfData["long"];
    List<String> temp = [];
    for (var data in widget.turfData['amenities']) {
      temp.add(data["text"]);
    }
    _amenitiesController.text =
        temp.toString().replaceAll("[", "").replaceAll("]", "");
    selectedCountry = CountryModel(name: "", id: widget.turfData["country"]);
    selectedState = CountryModel(name: "", id: widget.turfData["state"]);
    selectedCity = CountryModel(name: "", id: widget.turfData["city"]);
    getPlayableGames();
    getCountry();
    getCity(widget.turfData["state"]);
    getState(widget.turfData["country"]);

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
          selectedItems: (List<dynamic> selectedList) {
            _countryController.text = selectedList.first;
            selectedCountry = countryList.firstWhere(
                (element) => element.name == _countryController.text);
            getState(selectedCountry.id);
          },
          submitButtonChild: Text(
            "Done",
            style: TextStyle(color: Colors.white),
          ),
          enableMultipleSelection: false,
          searchWidget: TextFormField(
            controller: _searchTextEditingController,
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: TextStyle(color: Colors.white),
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            style: TextStyle(color: Colors.white),
          )),
    ).showModal(context);
  }

  void onTextFieldTapState() {
    DropDownState(
      DropDown(
        data: stateListName,
        bottomSheetTitle: Text("Select State"),
        selectedItems: (List<dynamic> selectedList) {
          _stateController.text = selectedList.first;
          selectedState = stateList
              .firstWhere((element) => element.name == _stateController.text);

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
        selectedItems: (List<dynamic> selected) {
          _cityController.text = selected.first;
          selectedCity =
              cityList.firstWhere((element) => element.name == selected);
        },
        searchWidget: TextFormField(
          controller: _searchTextEditingController,
          decoration: InputDecoration(
            hintText: "Search",
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade400,
      body: Form(
        key: formGlobalKey,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 30.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 6.0,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        const Text(
                          "Edit Turf",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Turf Name"),
                          const SizedBox(
                            height: 5.0,
                          ),
                          TextFormField(
                            controller: _fullNameTextEditingController,
                            cursorColor: Colors.black,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.only(
                                  left: 8, bottom: 0, top: 0, right: 15),
                              hintText: "Enter Turf Name",
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
                        ])),
                // AppTextField(
                //   textEditingController: _fullNameTextEditingController,
                //   title: "Turf Name",
                //   hint: "Enter Turf Name",
                //   isCitySelected: false,
                // ),
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
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: AppTextField(
                        textEditingController: _startTimeController.text == null
                            ? TextEditingController(
                                text: widget.turfData["day_start_time"])
                            : _startTimeController,
                        title: "Opening Time",
                        hint: "Start Time",
                        isCitySelected: true,
                        cities: _listOfStartTime,
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      height: 100,
                      width: MediaQuery.of(context).size.width / 2.5,
                      child: AppTextField(
                        textEditingController: _endTimeController.text == null
                            ? TextEditingController(
                                text: widget.turfData["day_end_time"])
                            : _endTimeController,
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
                Text("Select Playable Game"),
                DropDownMultiSelect(
                    childBuilder: (List<String> value) {
                      return Align(
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 10),
                              child: Text(
                                value.length > 0
                                    ? value.reduce((a, b) => a + ' , ' + b)
                                    : initialSelectedGame
                                        .toString()
                                        .replaceAll('[', ' ')
                                        .replaceAll(']', ''),
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )),
                          alignment: Alignment.centerLeft);
                    },
                    decoration: InputDecoration(
                      suffixStyle: TextStyle(color: Colors.white),
                      counterStyle: TextStyle(color: Colors.white),
                      //   labelText: "Select Playable Games",
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
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
                    whenEmpty: ""),
                AppTextField(
                  textEditingController: _addressController.text == null
                      ? TextEditingController(text: widget.turfData["address"])
                      : _addressController,
                  title: "Address",
                  hint: "Enter Turf Address",
                  isCitySelected: false,
                ),
                AppTextField(
                  textEditingController: _latController.text == null
                      ? TextEditingController(text: widget.turfData["lat"])
                      : _latController,
                  isNumber: true,
                  title: "Latitude",
                  hint: "Enter Turf Latitude",
                  isCitySelected: false,
                ),
                AppTextField(
                  textEditingController: _longController.text == null
                      ? TextEditingController(text: widget.turfData["long"])
                      : _latController,
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
                // Text(
                //   "Previous Images",
                //   style: TextStyle(
                //     fontSize: 20.0,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                // Card(
                //   child: Column(
                //     children: [
                //       Container(
                //           height: 250,
                //           decoration: BoxDecoration(
                //             border: Border.all(
                //               color: Colors.black,
                //               width: 1.0,
                //             ),
                //             borderRadius: BorderRadius.circular(4.0),
                //           ),
                //           child: ClipRRect(
                //               borderRadius: BorderRadius.circular(3.0),
                //               child: Image.network(
                //                   widget.turfData["main_image"]))),
                //       Text("Main Image", style: TextStyle()),
                //     ],
                //   ),
                // ),
                // Card(
                //   child: Column(
                //     children: [
                //       Container(
                //         height: 250,
                //         decoration: BoxDecoration(
                //           border: Border.all(
                //             color: Colors.black,
                //             width: 1.0,
                //           ),
                //           borderRadius: BorderRadius.circular(4.0),
                //         ),
                //         child: Container(
                //           height: 200,
                //           child: ListView.builder(
                //             scrollDirection: Axis.horizontal,
                //             itemCount: widget.turfData['slider_images']
                //                 .toString()
                //                 .split(',')
                //                 .length,
                //             itemBuilder: (context, index) {
                //               return Padding(
                //                 padding: const EdgeInsets.all(8.0),
                //                 child: Container(
                //                   height: 200,
                //                   width: 200,
                //                   decoration: BoxDecoration(
                //                     borderRadius: BorderRadius.circular(10.0),
                //                   ),
                //                   child: ClipRRect(
                //                     borderRadius: BorderRadius.circular(10.0),
                //                     child: Image.network(
                //                       widget.turfData['mediapath'] +
                //                           widget.turfData['slider_images']
                //                               .toString()
                //                               .split(',')[index],
                //                       fit: BoxFit.cover,
                //                     ),
                //                   ),
                //                 ),
                //               );
                //             },
                //           ),
                //         ),
                //       ),
                //       Text("Slider Image", style: TextStyle()),
                //     ],
                //   ),
                // ),

                Text(
                  "Update Images",
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
                  elevation: 4.0,
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
                  elevation: 4.0,
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
                          _latController.text.isEmpty ||
                          _longController.text.isEmpty ||
                          _amenitiesController.text.isEmpty ||
                          _cityController.text.isEmpty ||
                          _TurfDescTextEditingController.text.isEmpty ||
                          _fullNameTextEditingController.text.isEmpty ||
                          _hourlyPriceNumberTextEditingController
                              .text.isEmpty) {
                        showSnackbar(context, "Please fill all fields");
                      } else if (selectedGame == null) {
                        showSnackbar(context, "Please select playable games");
                      } else if (selectedCountry == null) {
                        showSnackbar(context, "Please select Locations");
                      } else {
                        editTurf();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_outlined, color: Colors.white),
                        const SizedBox(
                          width: 10.0,
                        ),
                        isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Edit Turf",
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
        bottomSheetTitle: Text("widget.title"),
        selectedItems: (List<dynamic> selectedList) {
          if (widget.isCityData) {}
          widget.textEditingController.text = selectedList.first;
        },
        enableMultipleSelection: false,
        searchWidget: TextFormField(
          controller: _searchTextEditingController,
          onChanged: (value) {},
          decoration: InputDecoration(
            hintText: "Search",
            border: InputBorder.none,
          ),
        ),
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
          Text(widget.title),
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
