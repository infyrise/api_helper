2.0.1
🐛 Bug fixes & improvements

Fixed minor dartdoc warnings and formatting issues in comments.

Renamed example file to example/example.dart for pub.dev recognition.

Ensured all public API members have dartdoc comments (≥20% coverage).

Clarified ApiHelper method documentation for better readability.

Updated pubspec.yaml to include explicit platforms: section for proper scoring.
## 2.0.0

- Major refactor of `ApiHelper`:
    - Singleton instance with dynamic base URL and token support.
    - Per-request token and base URL override.
    - GET, POST, PUT, DELETE, PATCH support.
    - JSON and Form-data body handling.
    - Global token can be updated at runtime.
    - Path registration and cloneable path items.
    - Response resolver support for typed responses.
    - Shortcut methods for GET and POST requests.

## 1.0.6

- Initial version.
