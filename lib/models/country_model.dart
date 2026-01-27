class CountryModel{
  int id;
  String name;
  CountryModel({required this.id,required this.name});
  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return  CountryModel(
        id: json["id"],
        name: json["country_name"]);
  }
}

class StateModel{
  int id;
  String name;
  StateModel({required this.id,required this.name});
  factory StateModel.fromJson(Map<String, dynamic> json) {
    return new StateModel(
        id: json["id"],
        name: json["name"]);
  }
}

class CityModel{
  int id;
  String name;
  CityModel({required this.id,required this.name});
  factory CityModel.fromJson(Map<String, dynamic> json) {
    return new CityModel(
        id: json["id"],
        name: json["city_name"]);
  }
}