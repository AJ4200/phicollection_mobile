class ControlStation {
  String? _locationId;
  String? _longitude;
  String? _latitude;

  ControlStation({String? locationId, String? longitude, String? latitude}) {
    if (locationId != null) {
      this._locationId = locationId;
    }
    if (longitude != null) {
      this._longitude = longitude;
    }
    if (latitude != null) {
      this._latitude = latitude;
    }
  }

  String? get locationId => _locationId;
  set locationId(String? locationId) => _locationId = locationId;
  String? get longitude => _longitude;
  set longitude(String? longitude) => _longitude = longitude;
  String? get latitude => _latitude;
  set latitude(String? latitude) => _latitude = latitude;

  ControlStation.fromJson(Map<String, dynamic> json) {
    _locationId = json['locationId'];
    _longitude = json['longitude'];
    _latitude = json['latitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['locationId'] = this._locationId;
    data['longitude'] = this._longitude;
    data['latitude'] = this._latitude;
    return data;
  }
}
