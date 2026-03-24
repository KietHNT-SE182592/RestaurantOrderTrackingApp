import 'dart:async';

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../network/api_message_service.dart';

class ApiFeedbackListener extends StatefulWidget {
  final Widget child;
  final ApiMessageService messageService;

  const ApiFeedbackListener({
    super.key,
    required this.child,
    required this.messageService,
  });

  @override
  State<ApiFeedbackListener> createState() => _ApiFeedbackListenerState();
}

class _ApiFeedbackListenerState extends State<ApiFeedbackListener> {
  StreamSubscription<ApiMessageEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.messageService.stream.listen(_onEvent);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onEvent(ApiMessageEvent event) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) return;

      final isError = event.type == ApiMessageType.error;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(event.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? AppColors.destructive
              : AppColors.foregroundLight,
          duration: Duration(seconds: isError ? 4 : 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
