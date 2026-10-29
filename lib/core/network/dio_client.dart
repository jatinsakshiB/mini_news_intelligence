import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';

class DioClient {
  final Dio dio;

  DioClient({Dio? customDio})
    : dio =
          customDio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 15),
              headers: {
                'Accept': 'application/json',
                'X-Api-Key': ApiConstants.apiKey,
              },
            ),
          ) {
    if (customDio == null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Also add apiKey to queryParameters as a fallback for NewsAPI
            final queryParams = Map<String, dynamic>.from(
              options.queryParameters,
            );
            if (!queryParams.containsKey('apiKey')) {
              queryParams['apiKey'] = ApiConstants.apiKey;
            }
            options.queryParameters = queryParams;
            if (kDebugMode) {
              debugPrint('🌐 [DIO] ${options.method} ${options.uri}');
            }
            return handler.next(options);
          },
          onError: (DioException e, handler) {
            if (kDebugMode) {
              debugPrint(
                '❌ [DIO] Error: ${e.type} - ${e.response?.statusCode}',
              );
            }
            return handler.next(e);
          },
        ),
      );
    }
  }

  static Failure mapDioErrorToFailure(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkFailure(
            message:
                'Connection timed out. Please check your internet connection.',
          );

        case DioExceptionType.connectionError:
          return const NetworkFailure(
            message:
                'No internet connection detected. Please verify your connection.',
          );

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 429) {
            return const RateLimitFailure();
          } else if (statusCode == 401 || statusCode == 403) {
            return const ServerFailure(
              message: 'Authentication error reaching news service.',
            );
          } else if (statusCode != null && statusCode >= 500) {
            return const ServerFailure(
              message:
                  'The news server is temporarily unavailable. Please retry in a moment.',
            );
          } else {
            return const GeneralFailure(
              message: 'Unable to retrieve news at this time.',
            );
          }

        case DioExceptionType.cancel:
          return const GeneralFailure(message: 'Request was cancelled.');

        default:
          if (error.error is SocketException) {
            return const NetworkFailure(
              message:
                  'No internet connection. Please verify your Wi-Fi or mobile data.',
            );
          }
          return const GeneralFailure(
            message: 'Unable to load news feed. Please try again.',
          );
      }
    } else if (error is SocketException) {
      return const NetworkFailure(
        message: 'No internet connection. Please verify your network.',
      );
    }

    return const GeneralFailure(
      message: 'Something went wrong. Please try again.',
    );
  }
}
