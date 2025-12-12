import 'dart:async';
import 'package:custom_response/custom_response.dart' as ResponseHelper;
import 'package:dio/dio.dart';

import 'models/api_helper_path_item.dart';
import 'models/api_helper_request_type.dart';

/// Main API helper class
class ApiHelper {
  final Uri baseUrl;
  final String token;
  final List<ApiHelperPathItem> paths;
  final ResponseHelper.Response Function(Map<String, dynamic>?)?
      responseResolver;

  late Dio dio; // removed final to allow mock injection

  /// Constructor with optional Dio for testing
  ApiHelper.setup(
    this.baseUrl,
    this.token,
    this.paths, {
    ResponseHelper.Response Function(Map<String, dynamic>?)?
        responseResolverFunc,
    int timeout = 30000,
    Dio? dioInstance, // optional Dio for testing
  }) : responseResolver = responseResolverFunc {
    dio = dioInstance ??
        Dio(
          BaseOptions(
            baseUrl: _getUriAsUrl(baseUrl),
            headers: {"Authorization": "Bearer $token"},
            connectTimeout: Duration(milliseconds: timeout),
            sendTimeout: Duration(milliseconds: timeout),
            receiveTimeout: Duration(milliseconds: timeout),
          ),
        );
  }

  /// Convert Uri to full URL string
  static String _getUriAsUrl(Uri uri) {
    final path = uri.path.startsWith('/') ? uri.path : '/${uri.path}';
    String url = "${uri.scheme}://${uri.host}";
    if (uri.hasPort) url += ":${uri.port}";
    return "$url$path";
  }

  // ==========================
  //        REQUESTS
  // ==========================
  Future<ResponseHelper.Response> _sendRequestByType(
      ApiHelperPathItem item) async {
    try {
      late Response response;

      switch (item.requestType) {
        case ApiHelperRequestType.get:
          response =
              await dio.get(item.path, queryParameters: item.queryParameters);
          break;
        case ApiHelperRequestType.post:
          response = await dio.post(item.path,
              data: item.data, queryParameters: item.queryParameters);
          break;
        case ApiHelperRequestType.put:
          response = await dio.put(item.path,
              data: item.data, queryParameters: item.queryParameters);
          break;
        case ApiHelperRequestType.delete:
          response = await dio.delete(item.path,
              data: item.data, queryParameters: item.queryParameters);
          break;
        case ApiHelperRequestType.patch:
          response = await dio.patch(item.path,
              data: item.data, queryParameters: item.queryParameters);
          break;
        case ApiHelperRequestType.head:
          response =
              await dio.head(item.path, queryParameters: item.queryParameters);
          break;
        case ApiHelperRequestType.options:
          response = await dio.options(
            item.path,
            queryParameters: item.queryParameters,
          );
          break;
        default:
          throw Exception("Unsupported request type: ${item.requestType}");
      }

      return _processResponse(response);
    } on DioException catch (e) {
      return _handleDioException(e);
    } catch (e) {
      return ResponseHelper.Response.error(e.toString());
    }
  }

  ResponseHelper.Response _processResponse(Response response) {
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      return ResponseHelper.Response.error(
        "Status Code: ${response.statusCode}\n${response.statusMessage}",
      );
    }
    return ResponseHelper.Response.success(response.data);
  }

  // ==========================
  //       ERROR HANDLING
  // ==========================
  ResponseHelper.Response _handleDioException(DioException e) {
    String error;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        error = "Connection timeout with API server";
        break;
      case DioExceptionType.sendTimeout:
        error = "Send timeout with API server";
        break;
      case DioExceptionType.receiveTimeout:
        error = "Receive timeout from API server";
        break;
      case DioExceptionType.badResponse:
        return ResponseHelper.Response.error(
          "Bad response: ${e.response?.statusCode}",
        );
      case DioExceptionType.cancel:
        error = "Request was cancelled";
        break;
      case DioExceptionType.unknown:
      default:
        error = "Connection failed: ${e.message}";
        break;
    }

    return ResponseHelper.Response.error(error);
  }

  // ==========================
  //        PUBLIC API
  // ==========================
  ApiHelperPathItem getPathItem(String key) {
    return paths.firstWhere(
      (e) => e.key == key,
      orElse: () => throw Exception("Path item not found: $key"),
    );
  }

  Future<ResponseHelper.Response> _send(ApiHelperPathItem item) async =>
      _sendRequestByType(item);

  Future<ResponseHelper.Response> request(ApiHelperPathItem item) async {
    try {
      var response = await _send(item);

      if (!response.isSuccess) return response;

      if (responseResolver != null) {
        response = responseResolver!(response.value);
      }

      return response;
    } catch (e) {
      return ResponseHelper.Response.error(e.toString());
    }
  }

  Future<ResponseHelper.Response<T>> requestWithDataResolver<T>(
    ApiHelperPathItem item, {
    T Function(dynamic)? dataResolver,
  }) async {
    var response = await request(item);

    if (!response.isSuccess)
      return ResponseHelper.Response.error(response.errorMessage);

    if (dataResolver != null) {
      try {
        return ResponseHelper.Response.success(dataResolver(response.value));
      } catch (e) {
        return ResponseHelper.Response.error("Data resolution failed: $e");
      }
    }

    return ResponseHelper.Response.success(response.value as T);
  }
}
