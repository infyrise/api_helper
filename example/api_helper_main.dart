
import 'package:api_caller/api_helper.dart';
import 'package:api_caller/models/api_helper_path_item.dart';
import 'package:dio/dio.dart';

Future<void> main() async {
  // ======================================================
  // 1️⃣ INIT (ONE TIME ONLY)
  // ======================================================
  ApiHelper.instance.init(
    baseUrl: "https://api.example.com",
    token: "GLOBAL_TOKEN_123",
    paths: [
      ApiHelperPathItem.get("getUsers", "/users"),
      ApiHelperPathItem.post("addUser", "/users/add"),
      ApiHelperPathItem.post("uploadFile", "/upload"),
    ],
  );

  // ======================================================
  // 2️⃣ SIMPLE GET (uses global baseUrl + global token)
  // ======================================================
  final res1 = await ApiHelper.instance.get("getUsers");

  print("---- SIMPLE GET ----");
  print(res1.isSuccess ? res1.value : res1.errorMessage);

  // ======================================================
  // 3️⃣ POST JSON DATA
  // ======================================================
  final res2 = await ApiHelper.instance.post(
    "addUser",
    data: {
      "name": "Bittu",
      "email": "bittu@example.com",
    },
    contentType: Headers.jsonContentType,
  );

  print("---- POST JSON ----");
  print(res2.isSuccess ? res2.value : res2.errorMessage);

  // ======================================================
  // 4️⃣ POST www-form-urlencoded
  // ======================================================
  final res3 = await ApiHelper.instance.post(
    "addUser",
    data: {
      "username": "demo_user",
      "password": "123456",
    },
    contentType: Headers.formUrlEncodedContentType,
  );

  print("---- POST WWW-FORM ----");
  print(res3.isSuccess ? res3.value : res3.errorMessage);

  // ======================================================
  // 5️⃣ POST MULTIPART / FORM-DATA
  // ======================================================
  final formData = FormData.fromMap({
    "title": "Profile Pic",
    "file": MultipartFile.fromBytes(
      [1, 2, 3, 4],
      filename: "image.png",
    ),
  });

  final res4 = await ApiHelper.instance.post(
    "uploadFile",
    data: formData,
    contentType: Headers.multipartFormDataContentType,
  );

  print("---- POST FORM-DATA ----");
  print(res4.isSuccess ? res4.value : res4.errorMessage);

  // ======================================================
  // 6️⃣ OVERRIDE BASE URL + TOKEN (ONLY THIS API)
  // ======================================================
  final overrideItem = ApiHelper.instance.getPathItem("getUsers")
    ..setBaseUrlOverride("https://uat.example.com")
    ..setTokenOverride("UAT_ONLY_TOKEN");

  final res5 = await ApiHelper.instance.request(overrideItem);

  print("---- OVERRIDE API ----");
  print(res5.isSuccess ? res5.value : res5.errorMessage);

  // ======================================================
  // 7️⃣ BACK TO NORMAL (NO OVERRIDE)
  // ======================================================
  final res6 = await ApiHelper.instance.get("getUsers");

  print("---- NORMAL AGAIN ----");
  print(res6.isSuccess ? res6.value : res6.errorMessage);
}
