class SearchRequest {
  final int requestNumber;
  final String bin;
  final String waste;
  final String pickupDest;
  final String dropoffDest;
  final bool received;
  final bool reported;


  const SearchRequest({
    required this.requestNumber,
    required this.bin,
    required this.waste,
    required this.pickupDest,
    required this.dropoffDest,
    required this.received,
    required this.reported,
  });

  factory SearchRequest.fromJson(Map<String, dynamic> json) => SearchRequest(
    requestNumber: json['requestNumber'],
    bin: json['bin'],
    waste: json['waste'],
    pickupDest: json['pickUpPoint'],
    dropoffDest: json['dropOffPoint'],
    received: json['received'],
    reported: json['reported'],
  );
}