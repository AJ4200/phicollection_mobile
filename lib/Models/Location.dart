class Location {
  String? _dtype;
  String? _locationId;
  String? _longitude;
  String? _latitude;
  double? _capacity;
  String? _supervisor;

  Location(
      {String? dtype,
        String? locationId,
        String? longitude,
        String? latitude,
        Null? capacity,
        String? supervisor}) {
    if (dtype != null) {
      this._dtype = dtype;
    }
    if (locationId != null) {
      this._locationId = locationId;
    }
    if (longitude != null) {
      this._longitude = longitude;
    }
    if (latitude != null) {
      this._latitude = latitude;
    }
    if (capacity != null) {
      this._capacity = capacity;
    }
    if (supervisor != null) {
      this._supervisor = supervisor;
    }
  }

  String? get dtype => _dtype;
  set dtype(String? dtype) => _dtype = dtype;
  String? get locationId => _locationId;
  set locationId(String? locationId) => _locationId = locationId;
  String? get longitude => _longitude;
  set longitude(String? longitude) => _longitude = longitude;
  String? get latitude => _latitude;
  set latitude(String? latitude) => _latitude = latitude;
  double? get capacity => _capacity;
  set capacity(double? capacity) => _capacity = capacity;
  String? get supervisor => _supervisor;
  set supervisor(String? supervisor) => _supervisor = supervisor;

  Location.fromJson(Map<String, dynamic> json) {
    _dtype = json['dtype'];
    _locationId = json['locationId'];
    _longitude = json['longitude'];
    _latitude = json['latitude'];
    _capacity = json['capacity'];
    _supervisor = json['supervisor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dtype'] = this._dtype;
    data['locationId'] = this._locationId;
    data['longitude'] = this._longitude;
    data['latitude'] = this._latitude;
    data['capacity'] = this._capacity;
    data['supervisor'] = this._supervisor;
    return data;
  }
}
