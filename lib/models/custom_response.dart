class Response<T> {
  late bool _isSuccess;
  String? _errorMessage;
  T? value;

  Response() {
    _isSuccess = true;
    _errorMessage = null;
    value = null;
  }

  Response.create(bool isSuccess, {String? errorMessage, T? value}) {
    _isSuccess = isSuccess;
    _errorMessage = errorMessage;
    value = value;
  }

  Response.fromResponse(Response response) {
    if (response.isSuccess)
      Response.success(response.value);
    else
      Response.error(response.errorMessage);
  }

  Response.success(this.value) {
    _isSuccess = true;
  }

  Response.error(this._errorMessage) {
    _isSuccess = false;
    value = null;
  }

  bool get isSuccess => _isSuccess;
  String get errorMessage => _errorMessage ?? "";
}
