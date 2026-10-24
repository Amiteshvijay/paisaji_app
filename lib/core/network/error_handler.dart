import 'package:dio/dio.dart';

String getFriendlyErrorMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.connectionError:
        return 'Unable to connect to the server. Please check if the backend is running.';
      case DioExceptionType.badResponse:
        final response = error.response;
        if (response != null && response.data is Map) {
          final data = response.data as Map;
          if (data.containsKey('error') && data['error'] is Map) {
            return data['error']['message'] ?? 'An error occurred. Please try again.';
          }
          if (data.containsKey('message')) {
            return data['message'];
          }
        }
        if (response?.statusCode == 401) {
          return 'Your session has expired. Please sign in again.';
        }
        if (response?.statusCode == 403) {
          return 'Access forbidden. Please check your account status.';
        }
        if (response?.statusCode == 404) {
          return 'The requested information could not be found.';
        }
        if (response?.statusCode == 500) {
          return 'Internal server error. Please try again later.';
        }
        return 'Server error (${response?.statusCode ?? 'unknown'}). Please try again.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.unknown:
      default:
        final errStr = error.error?.toString() ?? error.message ?? '';
        if (errStr.contains('Connection closed') || errStr.contains('Connection reset')) {
          return 'Connection closed by server. Please check backend server status.';
        }
        return 'Network connection error. Please check your internet.';
    }
  }
  final cleanMsg = error.toString().replaceAll('Exception: ', '');
  if (cleanMsg.contains('DioException') || cleanMsg.contains('HttpException')) {
    return 'Unable to connect to server. Please try again.';
  }
  return cleanMsg;
}
