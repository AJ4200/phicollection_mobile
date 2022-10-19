class Landfill {
  String? _locationId;
  String? _longitude;
  String? _latitude;
  double? _capacity;

  Landfill(
      {String? locationId,
        String? longitude,
        String? latitude,
        double? capacity}) {
    if (locationId != null) {
      _locationId = locationId;
    }
    if (longitude != null) {
      _longitude = longitude;
    }
    if (latitude != null) {
      _latitude = latitude;
    }
    if (capacity != null) {
      _capacity = capacity;
    }
  }

  String? get locationId => _locationId;
  set locationId(String? locationId) => _locationId = locationId;
  String? get longitude => _longitude;
  set longitude(String? longitude) => _longitude = longitude;
  String? get latitude => _latitude;
  set latitude(String? latitude) => _latitude = latitude;
  double? get capacity => _capacity;
  set capacity(double? capacity) => _capacity = capacity;

  Landfill.fromJson(Map<String, dynamic> json) {
    _locationId = json['locationId'];
    _longitude = json['longitude'];
    _latitude = json['latitude'];
    _capacity = json['capacity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['locationId'] = _locationId;
    data['longitude'] = _longitude;
    data['latitude'] = _latitude;
    data['capacity'] = _capacity;
    return data;
  }
}
