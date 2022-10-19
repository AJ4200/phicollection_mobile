class SupervisorRequest {
  final String supervisor;
  final int requests;

  const SupervisorRequest({
    required this.supervisor,
    required this.requests
  });

  factory SupervisorRequest.fromJson(Map<String, dynamic> json) => SupervisorRequest(
      supervisor: json['supervisor'],
      requests: json['requestsMade']
  );
}