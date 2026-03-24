import 'package:dio/dio.dart';

import '../errors/exceptions.dart';
import 'base_response.dart';

class BaseResponseDecoder {
  const BaseResponseDecoder._();

  static BaseResponse decode(
    dynamic payload, {
    required String invalidFormatMessage,
  }) {
    try {
      return BaseResponse.fromDynamic(payload);
    } on FormatException {
      throw ServerException(invalidFormatMessage);
    }
  }

  static BaseResponse requireSuccess(
    dynamic payload, {
    required String fallbackErrorMessage,
    required String invalidFormatMessage,
  }) {
    final response = decode(
      payload,
      invalidFormatMessage: invalidFormatMessage,
    );

    if (!response.succeeded) {
      throw ServerException(response.messageOr(fallbackErrorMessage));
    }

    return response;
  }

  static Map<String, dynamic> requireMapData(
    BaseResponse response, {
    required String fallbackErrorMessage,
  }) {
    final rawData = response.data;
    if (rawData is Map<String, dynamic>) {
      return rawData;
    }

    throw ServerException(fallbackErrorMessage);
  }

  static List<dynamic> requireListData(
    BaseResponse response, {
    required String fallbackErrorMessage,
  }) {
    final rawData = response.data;
    if (rawData is List<dynamic>) {
      return rawData;
    }

    throw ServerException(fallbackErrorMessage);
  }

  static String extractErrorMessage(
    DioException exception, {
    required String fallbackMessage,
  }) {
    final responsePayload = exception.response?.data;
    try {
      final baseResponse = BaseResponse.fromDynamic(responsePayload);
      return baseResponse.messageOr(fallbackMessage);
    } on FormatException {
      final statusMessage = exception.response?.statusMessage?.trim();
      if (statusMessage != null && statusMessage.isNotEmpty) {
        return statusMessage;
      }

      final dioMessage = exception.message?.trim();
      if (dioMessage != null && dioMessage.isNotEmpty) {
        return dioMessage;
      }

      return fallbackMessage;
    }
  }
}
