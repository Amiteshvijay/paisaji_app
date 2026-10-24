import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:zeokash/core/storage/secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  // Production AWS Backend API URL (Fully standalone, no adb reverse required)
  const String baseUrl = 'https://api.paisaji.com/api/v1/';

  final dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  final storageService = ref.read(secureStorageProvider);

  // Single refresh lock to prevent race conditions when multiple API calls 401 simultaneously
  Future<String?>? refreshFuture;

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await storageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException e, handler) async {
      if (e.response?.statusCode == 401 && !e.requestOptions.path.contains('auth/login') && !e.requestOptions.path.contains('auth/refresh')) {
        final refreshToken = await storageService.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          try {
            String? newAccess;

            if (refreshFuture != null) {
              // Wait for existing refresh operation
              newAccess = await refreshFuture;
            } else {
              refreshFuture = () async {
                final refreshDio = Dio(BaseOptions(
                  baseUrl: baseUrl,
                  connectTimeout: const Duration(seconds: 30),
                  receiveTimeout: const Duration(seconds: 30),
                ));
                
                final response = await refreshDio.post('auth/refresh/', data: {
                  'refresh': refreshToken,
                });

                if (response.statusCode == 200 && response.data['success'] == true) {
                  final data = response.data['data'];
                  final access = data['access']?.toString();
                  final rotatedRefresh = data['refresh']?.toString() ?? refreshToken;

                  if (access != null) {
                    await storageService.saveTokens(
                      accessToken: access,
                      refreshToken: rotatedRefresh,
                    );
                    return access;
                  }
                }
                return null;
              }();

              try {
                newAccess = await refreshFuture;
              } finally {
                refreshFuture = null;
              }
            }

            if (newAccess != null) {
              e.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
              final retryResponse = await dio.fetch(e.requestOptions);
              return handler.resolve(retryResponse);
            }
          } on DioException catch (refreshError) {
            // ONLY delete tokens if the server explicitly rejected the refresh token with 401/400
            final statusCode = refreshError.response?.statusCode;
            if (statusCode == 401 || statusCode == 400) {
              await storageService.deleteTokens();
            }
            // If temporary network failure / timeout -> DO NOT DELETE TOKENS!
          } catch (_) {
            // Non-http error -> preserve session
          }
        }
      }
      return handler.next(e);
    },
  ));

  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
    ));
  }

  return dio;
});
