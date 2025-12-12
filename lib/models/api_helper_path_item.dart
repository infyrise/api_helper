// api_helper_path_item.dart
import 'package:api_helper/models/api_helper_request_type.dart';

class ApiHelperPathItem {
  final String key;
  final String path;
  final ApiHelperRequestType requestType;

  Map<String, dynamic> _query = {};
  dynamic _data;

  ApiHelperPathItem.get(this.key, this.path) : requestType = ApiHelperRequestType.get;
  ApiHelperPathItem.post(this.key, this.path) : requestType = ApiHelperRequestType.post;
  ApiHelperPathItem.put(this.key, this.path) : requestType = ApiHelperRequestType.put;
  ApiHelperPathItem.delete(this.key, this.path) : requestType = ApiHelperRequestType.delete;
  ApiHelperPathItem.patch(this.key, this.path) : requestType = ApiHelperRequestType.patch;
  ApiHelperPathItem.head(this.key, this.path) : requestType = ApiHelperRequestType.head;
  ApiHelperPathItem.options(this.key, this.path) : requestType = ApiHelperRequestType.options;

  void addQueryParameter(String key, dynamic value) {
    _query[key] = value;
  }

  void setQueryParameters(Map<String, dynamic> query) {
    _query = query;
  }

  void setData(dynamic data) => _data = data;

  Map<String, dynamic> get queryParameters => _query;
  dynamic get data => _data;
}
