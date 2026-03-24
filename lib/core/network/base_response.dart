class BaseResponse {
  final bool succeeded;
  final String message;
  final List<String> errors;
  final dynamic data;
  final Map<String, dynamic>? meta;

  const BaseResponse({
    required this.succeeded,
    required this.message,
    required this.errors,
    required this.data,
    required this.meta,
  });

  factory BaseResponse.fromJson(Map<String, dynamic> json) {
    final rawErrors = json['errors'];

    return BaseResponse(
      succeeded: json['succeeded'] == true,
      message: (json['message'] as String? ?? '').trim(),
      errors: rawErrors is List
          ? rawErrors
                .map((item) => item?.toString().trim() ?? '')
                .where((item) => item.isNotEmpty)
                .toList()
          : const <String>[],
      data: json['data'],
      meta: json['meta'] is Map<String, dynamic>
          ? json['meta'] as Map<String, dynamic>
          : null,
    );
  }

  static BaseResponse fromDynamic(dynamic payload) {
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Payload is not a JSON object.');
    }

    if (!payload.containsKey('succeeded')) {
      throw const FormatException('Missing "succeeded" in base response.');
    }

    return BaseResponse.fromJson(payload);
  }

  String messageOr(String fallback) {
    if (message.isNotEmpty) return message;
    if (errors.isNotEmpty) return errors.first;
    return fallback;
  }
}
