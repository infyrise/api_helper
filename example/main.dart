import 'package:api_helper/models/api_helper_path_item.dart';
import 'package:dio/dio.dart';
import 'package:api_helper/api_helper.dart';
import 'package:custom_response/custom_response.dart' hide Response;
import 'package:mockito/mockito.dart';

// Mock class for Dio
class MockDio extends Mock implements Dio {}

void main() async {
  // Step 1: Create a mock Dio
  final mockDio = MockDio();

  // Step 2: Setup ApiHelper
  final api = ApiHelper.setup(
    Uri.parse("https://example.com"),
    "dummy_token",
    [],
  );

  // Replace internal dio with mock
  api.dio = mockDio;

  // Step 3: Mock GET response
  when(mockDio.get('/test', queryParameters: {})).thenAnswer(
        (_) async => Response(
      requestOptions: RequestOptions(path: '/test'),
      data: {"message": "success"},
      statusCode: 200,
    ),
  );

  // Step 4: Create ApiHelperPathItem
  final pathItem = ApiHelperPathItem.get('test', '/test');

  // Step 5: Call ApiHelper
  final response = await api.request(pathItem);

  // Step 6: Check result
  if (response.isSuccess) {
    print("GET Success: ${response.value}");
  } else {
    print("GET Error: ${response.errorMessage}");
  }

  // Step 7: Mock POST response
  when(mockDio.post('/submit', data: {"name": "John"}, queryParameters: {}))
      .thenAnswer(
        (_) async => Response(
      requestOptions: RequestOptions(path: '/submit'),
      data: {"status": "ok"},
      statusCode: 200,
    ),
  );

  // Step 8: POST request
  final postItem = ApiHelperPathItem.post('submit', '/submit');
  postItem.setData({"name": "John"});

  final postResponse = await api.request(postItem);

  if (postResponse.isSuccess) {
    print("POST Success: ${postResponse.value}");
  } else {
    print("POST Error: ${postResponse.errorMessage}");
  }

  // Step 9: Test typed response
  final typedResponse = await api.requestWithDataResolver<Map<String, dynamic>>(
    pathItem,
    dataResolver: (data) => Map<String, dynamic>.from(data),
  );

  print("Typed Response: ${typedResponse.value}");
}
