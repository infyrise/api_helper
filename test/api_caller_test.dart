import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:api_helper/api_helper.dart';
import 'package:api_helper/models/api_helper_path_item.dart';

// ----------------------
// 1️⃣ Mock Dio
// ----------------------
class MockDio extends Mock implements Dio {}

void main() {
  late ApiHelper apiHelper;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiHelper = ApiHelper.instance;

    apiHelper.init(
      baseUrl: "https://example.com",
      token: "GLOBAL_TOKEN",
      paths: [
        ApiHelperPathItem.get("getCategories", "/api/categories"),
        ApiHelperPathItem.post("addCategory", "/api/add_category"),
      ],
    );

    // Inject mock Dio
    apiHelper.overrideDio(mockDio);
  });

  group("ApiHelper Tests", () {
    test("Normal GET request with global token", () async {
      // Mock response
      when(mockDio.get("/api/categories",
          queryParameters: anyNamed("queryParameters"),
          options: anyNamed("options")))
          .thenAnswer((_) async => Response(
        data: [
          {"id": 1, "name": "Category 1"},
          {"id": 2, "name": "Category 2"}
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: "/api/categories"),
      ));

      final res = await apiHelper.get("getCategories");

      expect(res.isSuccess, true);
      expect(res.value.length, 2);
      expect(res.value[0]["name"], "Category 1");
    });

    test("POST request with JSON body", () async {
      final data = {"name": "New Category"};

      when(mockDio.post("/api/add_category",
          data: data, queryParameters: anyNamed("queryParameters"), options: anyNamed("options")))
          .thenAnswer((_) async => Response(
        data: {"status": "success"},
        statusCode: 201,
        requestOptions: RequestOptions(path: "/api/add_category"),
      ));

      final res = await apiHelper.post("addCategory", data: data);

      expect(res.isSuccess, true);
      expect(res.value["status"], "success");
    });

    test("Override token & base URL for single request", () async {
      final item = apiHelper.getPathItem("getCategories")
        ..setTokenOverride("OVERRIDE_TOKEN")
        ..setBaseUrlOverride("https://override.com");

      when(mockDio.get(
        "https://override.com/api/categories",
        queryParameters: anyNamed("queryParameters"),
        options: anyNamed("options"),
      )).thenAnswer((_) async => Response(
        data: {"override": true},
        statusCode: 200,
        requestOptions: RequestOptions(path: "https://override.com/api/categories"),
      ));

      final res = await apiHelper.request(item);

      expect(res.isSuccess, true);
      expect(res.value["override"], true);
    });

    test("Change global token dynamically", () async {
      apiHelper.setToken("NEW_GLOBAL_TOKEN");

      expect(apiHelper.currentToken, "NEW_GLOBAL_TOKEN");
    });
  });
}
