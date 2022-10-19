class PendingRequest {
  final int requestNumber;
  final String bin;
  final String waste;
  final String requestedAt;
  final String status;

  const PendingRequest({
      required this.requestNumber,
      required this.bin,
      required this.waste,
      required this.requestedAt,
      required this.status,
  });

  factory PendingRequest.fromJson(Map<String, dynamic> json) => PendingRequest(
      requestNumber: json['requestNumber'],
      bin: json['bin'],
      waste: json['waste'],
      requestedAt: json['requestedAt'],
      status: json['status'],
    );
}