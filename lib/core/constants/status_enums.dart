enum TableStatus {
  available(0, 'Available', 'Trống'),
  occupied(1, 'Occupied', 'Đặt trước'),
  reserved(2, 'Reserved', 'Đang phục vụ'),
  unknown(-1, 'Unknown', 'Không xác định');

  const TableStatus(this.apiCode, this.apiName, this.viLabel);

  final int apiCode;
  final String apiName;
  final String viLabel;

  static TableStatus fromApi(dynamic raw) {
    if (raw == null) return TableStatus.unknown;
    if (raw is TableStatus) return raw;

    if (raw is num) {
      return _fromCode(raw.toInt());
    }

    final text = raw.toString().trim();
    if (text.isEmpty) return TableStatus.unknown;

    final parsedCode = int.tryParse(text);
    if (parsedCode != null) {
      return _fromCode(parsedCode);
    }

    return _fromName(text);
  }

  static TableStatus _fromCode(int code) {
    for (final value in TableStatus.values) {
      if (value.apiCode == code) return value;
    }
    return TableStatus.unknown;
  }

  static TableStatus _fromName(String name) {
    final normalized = name.toLowerCase();
    for (final value in TableStatus.values) {
      if (value.apiName.toLowerCase() == normalized) return value;
    }
    return TableStatus.unknown;
  }
}

enum OrderStatus {
  pending(0, 'Pending', 'Chờ xử lý'),
  confirmed(1, 'Confirmed', 'Đã xác nhận'),
  preparing(2, 'Preparing', 'Đang chuẩn bị'),
  delivering(3, 'Delivering', 'Đang giao'),
  paying(4, 'Paying', 'Đang thanh toán'),
  completed(5, 'Completed', 'Hoàn tất'),
  cancelled(6, 'Cancelled', 'Đã hủy'),
  unknown(-1, 'Unknown', 'Không xác định');

  const OrderStatus(this.apiCode, this.apiName, this.viLabel);

  final int apiCode;
  final String apiName;
  final String viLabel;

  static OrderStatus fromApi(dynamic raw) {
    if (raw == null) return OrderStatus.unknown;
    if (raw is OrderStatus) return raw;

    if (raw is num) {
      return _fromCode(raw.toInt());
    }

    final text = raw.toString().trim();
    if (text.isEmpty) return OrderStatus.unknown;

    final parsedCode = int.tryParse(text);
    if (parsedCode != null) {
      return _fromCode(parsedCode);
    }

    return _fromName(text);
  }

  static OrderStatus _fromCode(int code) {
    for (final value in OrderStatus.values) {
      if (value.apiCode == code) return value;
    }
    return OrderStatus.unknown;
  }

  static OrderStatus _fromName(String name) {
    final normalized = name.toLowerCase();
    for (final value in OrderStatus.values) {
      if (value.apiName.toLowerCase() == normalized) return value;
    }
    return OrderStatus.unknown;
  }
}

enum OrderItemStatus {
  pending(0, 'Pending', 'Chờ xác nhận'),
  confirmed(1, 'Confirmed', 'Đã xác nhận'),
  cooking(2, 'Cooking', 'Đang nấu'),
  ready(3, 'Ready', 'Sẵn sàng phục vụ'),
  delivering(4, 'Delivering', 'Đang mang ra'),
  served(5, 'Served', 'Đã phục vụ'),
  cancelled(6, 'Cancelled', 'Đã hủy'),
  unknown(-1, 'Unknown', 'Không xác định');

  const OrderItemStatus(this.apiCode, this.apiName, this.viLabel);

  final int apiCode;
  final String apiName;
  final String viLabel;

  static OrderItemStatus fromApi(dynamic raw) {
    if (raw == null) return OrderItemStatus.unknown;
    if (raw is OrderItemStatus) return raw;

    if (raw is num) {
      return _fromCode(raw.toInt());
    }

    final text = raw.toString().trim();
    if (text.isEmpty) return OrderItemStatus.unknown;

    final parsedCode = int.tryParse(text);
    if (parsedCode != null) {
      return _fromCode(parsedCode);
    }

    return _fromName(text);
  }

  static OrderItemStatus _fromCode(int code) {
    for (final value in OrderItemStatus.values) {
      if (value.apiCode == code) return value;
    }
    return OrderItemStatus.unknown;
  }

  static OrderItemStatus _fromName(String name) {
    final normalized = name.toLowerCase();
    for (final value in OrderItemStatus.values) {
      if (value.apiName.toLowerCase() == normalized) return value;
    }
    return OrderItemStatus.unknown;
  }
}