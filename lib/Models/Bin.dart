class Bin {
  int? _binId;
  String? _qrcode;
  int? _waste;

  Bin({int? binId, String? qrcode, int? waste}) {
    if (binId != null) {
      this._binId = binId;
    }
    if (qrcode != null) {
      this._qrcode = qrcode;
    }
    if (waste != null) {
      this._waste = waste;
    }
  }

  int? get binId => _binId;
  set binId(int? binId) => _binId = binId;
  String? get qrcode => _qrcode;
  set qrcode(String? qrcode) => _qrcode = qrcode;
  int? get waste => _waste;
  set waste(int? waste) => _waste = waste;

  Bin.fromJson(Map<String, dynamic> json) {
    _binId = json['binId'];
    _qrcode = json['qrcode'];
    _waste = json['waste'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['binId'] = this._binId;
    data['qrcode'] = this._qrcode;
    data['waste'] = this._waste;
    return data;
  }
}
