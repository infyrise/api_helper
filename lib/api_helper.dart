import 'package:dio/dio.dart';

import 'models/api_helper_path_item.dart';
import 'models/api_helper_request_type.dart';
import 'package:api_caller/models/custom_response.dart' as response_helper;

class ApiHelper {
  ApiHelper._();
  static final ApiHelper instance = ApiHelper._();

  late Dio _dio;
  late String _baseUrl;
  String? _token;

  final Map<String, ApiHelperPathItem> _paths = {};

  response_helper.Response Function(dynamic)? responseResolver;

  // ==========================
  // INIT
  // ==========================
  void init({
    required String baseUrl,
    String? token,
    List<ApiHelperPathItem>? paths,
    response_helper.Response Function(dynamic)? resolver,
    int timeout = 30000,
  }) {
    _baseUrl = baseUrl;
    _token = token;
    responseResolver = resolver;

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: Duration(milliseconds: timeout),
        sendTimeout: Duration(milliseconds: timeout),
        receiveTimeout: Duration(milliseconds: timeout),
      ),
    );

    _applyToken();

    if (paths != null) {
      for (final p in paths) {
        _paths[p.key] = p;
      }
    }
  }

  // ==========================
  // TOKEN & BASE URL MANAGEMENT
  // ==========================
  /// Get current token
  String? get currentToken => _token;

  /// Set global token
  void setToken(String? token) {
    _token = token;
    _applyToken();
  }

  /// Set global base URL
  void setBaseUrl(String url) {
    _baseUrl = url;
    _dio.options.baseUrl = _baseUrl;
  }

  /// Inject custom Dio (useful for mocking)
  void overrideDio(Dio dio) {
    _dio = dio;
  }

  void _applyToken() {
    if (_token != null && _token!.isNotEmpty) {
      _dio.options.headers["Authorization"] = "Bearer $_token";
    } else {
      _dio.options.headers.remove("Authorization");
    }
  }

  // ==========================
  // PATH MANAGEMENT
  // ==========================
  void addPath(ApiHelperPathItem item) {
    _paths[item.key] = item;
  }

  ApiHelperPathItem getPathItem(String key) {
    final item = _paths[key];
    if (item == null) throw Exception("Path not found: $key");
    return item.clone(); // important: return a clone for overrides
  }

  // ==========================
  // CORE REQUEST
  // ==========================
  Future<response_helper.Response> request(
    ApiHelperPathItem item, {
    String? token,
    String? contentType,
  }) async {
    try {
      final finalToken = token ?? item.tokenOverride ?? _token;

      final headers = <String, dynamic>{};
      if (finalToken != null && finalToken.isNotEmpty) {
        headers["Authorization"] = "Bearer $finalToken";
      }
      if (contentType != null) {
        headers["Content-Type"] = contentType;
      }

      final options = headers.isNotEmpty ? Options(headers: headers) : null;

      final url = item.baseUrlOverride != null
          ? "${item.baseUrlOverride}${item.path}"
          : item.path;

      late Response response;

      switch (item.requestType) {
        case ApiHelperRequestType.get:
          response = await _dio.get(url,
              queryParameters: item.queryParameters, options: options);
          break;
        case ApiHelperRequestType.post:
          response = await _dio.post(url,
              data: item.data,
              queryParameters: item.queryParameters,
              options: options);
          break;
        case ApiHelperRequestType.put:
          response = await _dio.put(url,
              data: item.data,
              queryParameters: item.queryParameters,
              options: options);
          break;
        case ApiHelperRequestType.delete:
          response = await _dio.delete(url,
              data: item.data,
              queryParameters: item.queryParameters,
              options: options);
          break;
        case ApiHelperRequestType.patch:
          response = await _dio.patch(url,
              data: item.data,
              queryParameters: item.queryParameters,
              options: options);
          break;
        case ApiHelperRequestType.head:
          // TODO: Handle this case.
          break;
      }

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        return response_helper.Response.error(
          "Status Code: ${response.statusCode}",
        );
      }

      return responseResolver != null
          ? responseResolver!(response.data)
          : response_helper.Response.success(response.data);
    } on DioException catch (e) {
      return response_helper.Response.error(e.message ?? "Dio error");
    } catch (e) {
      return response_helper.Response.error(e.toString());
    }
  }

  // ==========================
  // SHORTCUT METHODS
  // ==========================
  Future<response_helper.Response> get(
    String key, {
    Map<String, dynamic>? query,
    String? token,
  }) {
    final item = getPathItem(key);
    if (query != null) item.setQueryParameters(query);
    return request(item, token: token);
  }

  Future<response_helper.Response> post(
    String key, {
    dynamic data,
    String? token,
    String? contentType,
  }) {
    final item = getPathItem(key);
    if (data != null) item.setData(data);
    return request(item, token: token, contentType: contentType);
  }
}
