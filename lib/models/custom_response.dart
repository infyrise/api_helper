class Response<T> {
  final bool _isSuccess;
  final String? _errorMessage;
  final T? value;

  /// Default constructor: success response with null value
  Response()
      : _isSuccess = true,
        _errorMessage = null,
        value = null;

  /// Custom response with explicit success flag, optional error message and value
  Response.create(this._isSuccess, {String? errorMessage, this.value})
      : _errorMessage = errorMessage;

  /// Create a response from another Response instance
  Response.fromResponse(Response<T> response)
      : _isSuccess = response.isSuccess,
        _errorMessage = response._errorMessage,
        value = response.value;

  /// Success response with a value
  Response.success(this.value)
      : _isSuccess = true,
        _errorMessage = null;

  /// Error response with message
  Response.error(String errorMessage)
      : _isSuccess = false,
        _errorMessage = errorMessage,
        value = null;

  /// Whether the response is successful
  bool get isSuccess => _isSuccess;

  /// Returns the error message, or empty string if none
  String get errorMessage => _errorMessage ?? "";
}
