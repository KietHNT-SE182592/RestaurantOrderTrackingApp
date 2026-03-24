import 'dart:async';

enum ApiMessageType { success, error }

class ApiMessageEvent {
  final String message;
  final ApiMessageType type;

  const ApiMessageEvent({required this.message, required this.type});
}

class ApiMessageService {
  final StreamController<ApiMessageEvent> _controller =
      StreamController<ApiMessageEvent>.broadcast();

  String? _lastMessage;
  ApiMessageType? _lastType;
  DateTime? _lastAt;

  Stream<ApiMessageEvent> get stream => _controller.stream;

  void showSuccess(String message) {
    _emit(ApiMessageType.success, message);
  }

  void showError(String message) {
    _emit(ApiMessageType.error, message);
  }

  void _emit(ApiMessageType type, String message) {
    final normalized = message.trim();
    if (normalized.isEmpty) return;

    final now = DateTime.now();
    final isDuplicate =
        _lastMessage == normalized &&
        _lastType == type &&
        _lastAt != null &&
        now.difference(_lastAt!) < const Duration(milliseconds: 900);

    if (isDuplicate) return;

    _lastMessage = normalized;
    _lastType = type;
    _lastAt = now;

    _controller.add(ApiMessageEvent(message: normalized, type: type));
  }
}
