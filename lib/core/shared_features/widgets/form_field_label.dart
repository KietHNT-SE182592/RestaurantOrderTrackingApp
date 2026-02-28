import 'package:flutter/material.dart';

/// Label chuẩn hiển thị phía trên mỗi input field trong form.
///
/// Sử dụng:
/// ```dart
/// FormFieldLabel(text: 'Tài khoản', color: labelColor),
/// const SizedBox(height: 4),
/// AppTextField(...),
/// ```
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({
    super.key,
    required this.text,
    required this.color,
    this.isRequired = false,
  });

  final String text;
  final Color color;

  /// Nếu true, hiển thị dấu * màu đỏ bên cạnh label.
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          if (isRequired) ...[
            const SizedBox(width: 2),
            const Text(
              '*',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFEF4444),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
