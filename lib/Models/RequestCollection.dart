class RequestCollection {
  final String status;

  const RequestCollection({
      required this.status,
  });

  factory RequestCollection.fromJson(Map<String, dynamic> json) => RequestCollection(
      status: json['status'],
    );
}