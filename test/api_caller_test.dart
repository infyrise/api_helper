import 'package:api_caller/api_helper.dart';
import 'package:api_caller/models/api_helper_path_item.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

// ----------------------
// 1️⃣ MOCK DIO
// ----------------------
class MockDio extends Mock implements Dio {
  @override
  late BaseOptions options = BaseOptions(); // Prevent null BaseOptions
}

void main() {
  late ApiHelper apiHelper;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiHelper = ApiHelper.instance;

    apiHelper.init(
      baseUrl: "https://srankbazaar.com",
      token: "GLOBAL_TOKEN_123",
      paths: [
        ApiHelperPathItem.get("getUsers", "/API/categories.php"),
        ApiHelperPathItem.post("addUser", "/users/add"),
        ApiHelperPathItem.post("uploadFile", "/upload"),
      ],
    );

    apiHelper.overrideDio(mockDio);
  });

  test("SIMPLE GET request", () async {
    when(mockDio.get(
      "/API/categories.php",
      queryParameters: anyNamed("queryParameters"),
      options: anyNamed("options"),
    )).thenAnswer((_) async => Response(
      data: [
        {"id": 1, "name": "User 1"},
        {"id": 2, "name": "User 2"}
      ],
      statusCode: 200,
      requestOptions: RequestOptions(path: "/API/categories.php"),
    ));

    final res = await apiHelper.get("getUsers");

    expect(res.isSuccess, true);
    expect(res.value.length, 2);
    expect(res.value[0]["name"], "User 1");
  });

  test("POST JSON data", () async {
    final data = {"name": "Bittu", "email": "bittu@example.com"};

    when(mockDio.post(
      "/users/add",
      data: data,
      queryParameters: anyNamed("queryParameters"),
      options: anyNamed("options"),
    )).thenAnswer((_) async => Response(
      data: {"status": "success"},
      statusCode: 201,
      requestOptions: RequestOptions(path: "/users/add"),
    ));

    final res = await apiHelper.post(
      "addUser",
      data: data,
      contentType: Headers.jsonContentType,
    );

    expect(res.isSuccess, true);
    expect(res.value["status"], "success");
  });

  test("POST www-form-urlencoded data", () async {
    final formData = {"username": "demo_user", "password": "123456"};

    when(mockDio.post(
      "/users/add",
      data: formData,
      queryParameters: anyNamed("queryParameters"),
      options: anyNamed("options"),
    )).thenAnswer((_) async => Response(
      data: {"status": "form success"},
      statusCode: 200,
      requestOptions: RequestOptions(path: "/users/add"),
    ));

    final res = await apiHelper.post(
      "addUser",
      data: formData,
      contentType: Headers.formUrlEncodedContentType,
    );

    expect(res.isSuccess, true);
    expect(res.value["status"], "form success");
  });

  test("POST multipart/form-data", () async {
    final formData = FormData.fromMap({
      "title": "Profile Pic",
      "file": MultipartFile.fromBytes([1, 2, 3], filename: "image.png"),
    });

    when(mockDio.post(
      "/upload",
      data: formData,
      queryParameters: anyNamed("queryParameters"),
      options: anyNamed("options"),
    )).thenAnswer((_) async => Response(
      data: {"status": "upload success"},
      statusCode: 201,
      requestOptions: RequestOptions(path: "/upload"),
    ));

    final res = await apiHelper.post(
      "uploadFile",
      data: formData,
      contentType: Headers.multipartFormDataContentType,
    );

    expect(res.isSuccess, true);
    expect(res.value["status"], "upload success");
  });

  test("OVERRIDE BASE URL + TOKEN for single request", () async {
    final overrideItem = apiHelper.getPathItem("getUsers")
      ..setBaseUrlOverride("https://uat.example.com")
      ..setTokenOverride("UAT_ONLY_TOKEN");

    when(mockDio.get(
      "https://uat.example.com/API/categories.php",
      queryParameters: anyNamed("queryParameters"),
      options: anyNamed("options"),
    )).thenAnswer((_) async => Response(
      data: {"override": true},
      statusCode: 200,
      requestOptions: RequestOptions(
          path: "https://uat.example.com/API/categories.php"),
    ));

    final res = await apiHelper.request(overrideItem);

    expect(res.isSuccess, true);
    expect(res.value["override"], true);
  });

  test("BACK TO NORMAL GET request", () async {
    when(mockDio.get(
      "/API/categories.php",
      queryParameters: anyNamed("queryParameters"),
      options: anyNamed("options"),
    )).thenAnswer((_) async => Response(
      data: {"message": "Normal again"},
      statusCode: 200,
      requestOptions: RequestOptions(path: "/API/categories.php"),
    ));

    final res = await apiHelper.get("getUsers");

    expect(res.isSuccess, true);
    expect(res.value["message"], "Normal again");
  });
}
