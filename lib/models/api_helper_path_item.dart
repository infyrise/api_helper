import 'api_helper_request_type.dart';

class ApiHelperPathItem {
  final String key;
  final String path;
  final ApiHelperRequestType requestType;

  Map<String, dynamic> _query = {};
  dynamic _data;

  // 👇 PER API OVERRIDES
  String? baseUrlOverride;
  String? tokenOverride;

  ApiHelperPathItem.get(this.key, this.path)
      : requestType = ApiHelperRequestType.get;

  ApiHelperPathItem.post(this.key, this.path)
      : requestType = ApiHelperRequestType.post;

  ApiHelperPathItem.put(this.key, this.path)
      : requestType = ApiHelperRequestType.put;

  ApiHelperPathItem.delete(this.key, this.path)
      : requestType = ApiHelperRequestType.delete;

  ApiHelperPathItem.patch(this.key, this.path)
      : requestType = ApiHelperRequestType.patch;

  // ==========================
  // SETTERS
  // ==========================
  void setQueryParameters(Map<String, dynamic> query) => _query = query;
  void setData(dynamic data) => _data = data;

  void setBaseUrlOverride(String url) => baseUrlOverride = url;
  void setTokenOverride(String token) => tokenOverride = token;

  Map<String, dynamic> get queryParameters => _query;
  dynamic get data => _data;

  // ==========================
  // CLONE (VERY IMPORTANT)
  // ==========================
  ApiHelperPathItem clone() {
    final cloned = ApiHelperPathItem.get(key, path)
      .._query = Map.from(_query)
      .._data = _data
      ..baseUrlOverride = baseUrlOverride
      ..tokenOverride = tokenOverride;

    return cloned;
  }
}
