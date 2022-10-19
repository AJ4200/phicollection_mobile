class Staff {
  final String dtype;
  final String staffId;
  final String idNumber;
  final String name;
  final String surname;
  final String email;
  final String password;
  final String telephone;
  final String? licenceNumber;
  final String? rating;

  const Staff(
      {required this.dtype,
      required this.staffId,
      required this.idNumber,
      required this.name,
      required this.surname,
      required this.email,
      required this.password,
      required this.telephone,
      required this.licenceNumber,
      required this.rating});

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      dtype: json['dtype'],
      staffId: json['staffId'],
      idNumber: json['idNumber'],
      name: json['name'],
      surname: json['surname'],
      email: json['email'],
      password: json['password'],
      telephone: json['telephone'],
      licenceNumber: json['licenceNumber'],
      rating: json['rating'],
    );
  }
}
