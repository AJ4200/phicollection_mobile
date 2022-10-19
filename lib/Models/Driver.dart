class Driver {
  String? _staffId;
  String? _name;
  String? _surname;
  String? _email;
  String? _telephone;
  String? _rating;

  Driver(
      {String? staffId,
        String? name,
        String? surname,
        String? email,
        String? telephone,
        String? rating}) {
    if (staffId != null) {
      this._staffId = staffId;
    }
    if (name != null) {
      this._name = name;
    }
    if (surname != null) {
      this._surname = surname;
    }
    if (email != null) {
      this._email = email;
    }
    if (telephone != null) {
      this._telephone = telephone;
    }
    if (rating != null) {
      this._rating = rating;
    }
  }

  String? get staffId => _staffId;
  set staffId(String? staffId) => _staffId = staffId;
  String? get name => _name;
  set name(String? name) => _name = name;
  String? get surname => _surname;
  set surname(String? surname) => _surname = surname;
  String? get email => _email;
  set email(String? email) => _email = email;
  String? get telephone => _telephone;
  set telephone(String? telephone) => _telephone = telephone;
  String? get rating => _rating;
  set rating(String? rating) => _rating = rating;

  Driver.fromJson(Map<String, dynamic> json) {
    _staffId = json['staffId'];
    _name = json['name'];
    _surname = json['surname'];
    _email = json['email'];
    _telephone = json['telephone'];
    _rating = json['rating'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['staffId'] = this._staffId;
    data['name'] = this._name;
    data['surname'] = this._surname;
    data['email'] = this._email;
    data['telephone'] = this._telephone;
    data['rating'] = this._rating;
    return data;
  }
}
