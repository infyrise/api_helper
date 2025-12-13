📦 ApiHelper (Dio Based API Manager)

A singleton-based, reusable API helper built on top of Dio, supporting:

✅ Global base URL & token

✅ Per-API override (base URL + token)

✅ GET / POST / PUT / DELETE / PATCH

✅ JSON, www-form-urlencoded, multipart/form-data

✅ Safe cloning (no data leak between APIs)

✅ Clean & scalable architecture

🚀 Features

One-time initialization

Dynamic bearer token update

Override base URL & token for only one API

Supports:

JSON body

www-form-urlencoded

multipart/form-data (file upload)

Centralized response handling

📁 Structure
lib/
├─ api_helper.dart
├─ models/
│   ├─ api_helper_path_item.dart
│   └─ api_helper_request_type.dart

🔧 Initialization (ONE TIME)
ApiHelper.instance.init(
baseUrl: "https://api.example.com",
token: "GLOBAL_TOKEN_123",
paths: [
ApiHelperPathItem.get("getUsers", "/users"),
ApiHelperPathItem.post("addUser", "/users/add"),
ApiHelperPathItem.post("uploadFile", "/upload"),
],
);


✔ This sets global base URL & token
✔ Can be used anywhere in app

📥 GET Request (Normal)
final res = await ApiHelper.instance.get("getUsers");

if (res.isSuccess) {
print(res.value);
} else {
print(res.errorMessage);
}


➡ Uses global base URL + global token

📤 POST JSON Data
final res = await ApiHelper.instance.post(
"addUser",
data: {
"name": "Bittu",
"email": "bittu@example.com",
},
contentType: Headers.jsonContentType,
);

📤 POST www-form-urlencoded
final res = await ApiHelper.instance.post(
"addUser",
data: {
"username": "demo_user",
"password": "123456",
},
contentType: Headers.formUrlEncodedContentType,
);

📤 POST multipart / Form-Data (File Upload)
final formData = FormData.fromMap({
"title": "Profile Pic",
"file": MultipartFile.fromBytes(
[1, 2, 3, 4],
filename: "image.png",
),
});

final res = await ApiHelper.instance.post(
"uploadFile",
data: formData,
contentType: Headers.multipartFormDataContentType,
);

🔐 Change Token Dynamically (Global)
ApiHelper.instance.setToken("NEW_GLOBAL_TOKEN");


➡ All APIs will now use the new token

🌐 Override Base URL & Token (ONLY ONE API)
final item = ApiHelper.instance.getPathItem("getUsers")
..setBaseUrlOverride("https://uat.example.com")
..setTokenOverride("UAT_ONLY_TOKEN");

final res = await ApiHelper.instance.request(item);


✔ Override applies only to this request
✔ Other APIs remain unchanged

🔁 Back to Normal Automatically
final res = await ApiHelper.instance.get("getUsers");


➡ Uses original global base URL & token again

🧠 Token Priority Order
Request Token (highest)
↓
Path Override Token
↓
Global Token (lowest)

🧠 Base URL Priority
Path Override Base URL
↓
Global Base URL

❌ Error Handling
if (!res.isSuccess) {
print(res.errorMessage);
}


Handled cases:

Network error

Timeout

4xx / 5xx status codes

Dio exceptions

✅ Best Practices

✔ Call init() only once
✔ Always use getPathItem() for overrides
✔ Never modify stored path directly
✔ Prefer override instead of new instance

🏁 Conclusion

This ApiHelper provides a clean, scalable, and production-ready way to manage APIs in Flutter with:

Minimal boilerplate

Maximum flexibility

Safe override mechanism

If you want, I can also provide:

📦 Flutter UI integration example

🔄 Token refresh interceptor

🧪 Unit tests

🧩 Repository-pattern wrapper