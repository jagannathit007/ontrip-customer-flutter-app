// import 'dart:developer';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import '../core/constants.dart';
// import '../core/app_session.dart';
// import '../helper/app_toast.dart';
// import '../services/storage_service.dart';
// import 'api_response.dart';
// import 'network_config.dart';

// enum ApiType { get, post, put, patch, delete }

// class ApiManager {
//   static final instance = ApiManager._apiManager();

//   factory ApiManager() => instance;
//   final Dio _dio = Dio();
//   final String baseUrl = AppNetworkConstants.apiBaseURL;

//   ApiManager._apiManager() {
//     _dio.options.baseUrl = baseUrl;
//     _dio.options.headers = {
//       'Accept': 'application/json',
//       'content-type': 'application/json',
//     };
//     _dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           if (kDebugMode) {
//             log("AuthToken ::: ${await getStorage(AppSession.token)}");
//             log("Endpoint URL ::: ${options.uri}");
//             log("Request SEND BODY ::: ${options.data}");
//           }
//           dynamic authToken = await getStorage(AppSession.token);
//           if (authToken != null && authToken != '') {
//             log("Admin Token");
//             options.headers["Authorization"] = "Bearer $authToken";
//           }
//           handler.next(options);
//         },
//         onResponse: (response, handler) {
//           if (kDebugMode) {
//             log("Method: ${response.requestOptions.method}");
//             if (response.requestOptions.responseType == ResponseType.bytes) {
//               log(
//                 "Server Response: Binary data (${response.data.length} bytes)",
//               );
//             } else {
//               log("Server Response: ${response.data}");
//             }
//           }
//           handler.next(response);
//         },
//         onError: (error, handler) {
//           if (kDebugMode) {
//             log("API Error: ${error.toString()}");
//           }
//           handler.next(error);
//         },
//       ),
//     );
//   }

//   Future<ApiResponse> call({
//     required String endPoint,
//     dynamic body,
//     ApiType type = ApiType.post,
//     ResponseType responseType = ResponseType.json,
//     Map<String, String>? customHeaders,
//   }) async {
//     // ApiResponse apiData = ApiResponse(
//     //   status: 0,
//     //   message: Constant.instance.initialErrorMdg,
//     //   data: null,
//     // );
//     try {
//       if (customHeaders != null) {
//         _dio.options.headers.addAll(customHeaders);
//       }
//       Response response;
//       final options = Options(responseType: responseType);
//       switch (type) {
//         case ApiType.post:
//           response = await _dio.post(endPoint, data: body, options: options);
//           break;
//         case ApiType.put:
//           response = await _dio.put(endPoint, data: body, options: options);
//           break;
//         case ApiType.patch:
//           response = await _dio.patch(endPoint, data: body, options: options);
//           break;
//         case ApiType.delete:
//           response = await _dio.delete(endPoint, data: body, options: options);
//           break;
//         default:
//           response = await _dio.get(endPoint, options: options);
//           break;
//       }
//       ApiResponse apiData = _checkStatus(
//         response,
//         endPoint,
//         body,
//         responseType,
//       );
//       return apiData;

//       // APIResponse(status: err.response?.statusCode ?? 500, message: err.message);
//     } on DioException catch (e) {
//       if (e.type == DioExceptionType.connectionError) {
//         onSocketException(e);
//       } else {
//         onException(e);
//       }
//       return ApiResponse(
//         status: 0,
//         message: e.message ?? e.toString(),
//         data: null,
//       );
//     } catch (e) {
//       final exception = e is Exception ? e : Exception(e.toString());
//       onException(exception);
//       return ApiResponse(status: 0, message: exception.toString(), data: null);
//     }
//   }

//   // ApiResponse _checkStatus(Response response, String apiName, dynamic req, ResponseType responseType) {
//   //   if (response.statusCode == 200 || response.statusCode == 201) {

//   //     if (responseType == ResponseType.bytes) {
//   //       return ApiResponse(status: response.statusCode ?? 200, message: 'Success', data: response.data);
//   //     } else {
//   //       return ApiResponse.fromJson(response.data);
//   //     }
//   //   } else {
//   //     return ApiResponse(
//   //       status: response.statusCode ?? 0,
//   //       message: response.data is Map ? response.data['message'] ?? 'Request failed' : 'Request failed',
//   //       data: response.data is Map ? response.data['data'] : null,
//   //     );
//   //   }
//   // }

//   ApiResponse _checkStatus(
//     Response response,
//     String apiName,
//     dynamic req,
//     ResponseType responseType,
//   ) {
//     final statusCode = response.statusCode ?? 0;

//     // Handle binary response
//     if (responseType == ResponseType.bytes &&
//         (statusCode == 200 || statusCode == 201)) {
//       return ApiResponse(
//         status: statusCode,
//         message: 'Success',
//         data: response.data,
//       );
//     }

//     // Parse JSON safely
//     final data = response.data;

//     bool isSuccess = false;
//     String message = "Request failed";

//     if (data is Map) {
//       isSuccess = data['success'] == true;
//       message = data['message'] ?? message;
//     }

//     return ApiResponse(
//       status: isSuccess ? 1 : 0, // ✅ IMPORTANT CHANGE
//       message: message,
//       data: data is Map ? data['data'] : null,
//     );
//   }

//   void onSocketException(DioException e) =>
//       log("API : SocketException - ${e.toString()}");

//   void onException(Exception e) => log("API : Exception - ${e.toString()}");
// }
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../app_export.dart' hide FormData, Response;

enum ApiType { get, post, put, delete, patch }

class ApiManager {
  static Dio dio = Dio();

  static void _initializeDio() {
    dio.options
      ..baseUrl = AppNetworkConstants.apiBaseURL
      ..connectTimeout = const Duration(milliseconds: 20000)
      ..receiveTimeout = const Duration(milliseconds: 20000)
      ..validateStatus = (int? status) {
        return status! > 0;
      }
      ..headers = {'Accept': 'application/json', 'content-type': 'application/json'};
  }

  static Future<bool> isNetworkConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return false;
    } else {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    }
  }

  static Future<APIResponse> call({required String endPoint, dynamic body, ApiType? type}) async {
    _initializeDio();
    bool isInternet = await isNetworkConnection();
    if (isInternet) {
      try {
        String token = await getStorage(AppSession.token) ?? "";
        if (token.isNotEmpty) {
          dio.options.headers["Authorization"] = "Bearer $token";
          dio.options.headers["token"] = token;
        }

        if (body is FormData) {
          dio.options.headers.remove("content-type");
          if (kDebugMode) print("ApiManager: Detected FormData, removed content-type header.");
        } else {
          dio.options.headers["content-type"] = "application/json";
        }

        final safeBody = body ?? {};
        final apiType = type ?? ApiType.post; // Default to POST if no type specified
        if (kDebugMode) {
          print("Api Name :${AppNetworkConstants.apiBaseURL}$endPoint");
          print("AuthToken :${dio.options.headers["Authorization"]}");
          print("Request ($endPoint) :$safeBody");
        }
        Response? response;
        switch (apiType) {
          case ApiType.post:
            response = await dio.post(endPoint, data: safeBody);
            break;
          case ApiType.delete:
            response = await dio.delete(endPoint, data: safeBody);
            break;
          case ApiType.put:
            response = await dio.put(endPoint, data: safeBody);
            break;
          case ApiType.patch:
            response = await dio.patch(endPoint, data: safeBody);
            break;
          case ApiType.get:
            response = await dio.get(endPoint, queryParameters: safeBody is Map && safeBody.isNotEmpty ? Map<String, dynamic>.from(safeBody) : null);
            break;
        }
        log("Response...${response!.data}");
        return _formatOutput(response, null);
      } on DioException catch (err) {
        if (err.type == DioExceptionType.badResponse) {
          if (err.response?.statusCode == 401) {
            bool isGuest = await getStorage('isGuest') ?? false;
            if (!isGuest) {
              await clearStorage();
              Get.offNamedUntil(RouteNames.splash, (Route<dynamic> route) => false);
              Get.put(SplashCtrl(), permanent: true).onReady();
            }
            errorToast("Session expired. Please login again.");
          } else {
            errorToast(err.message ?? "Server error");
          }
          return APIResponse(status: 0, message: err.message);
        } else if (err.type == DioExceptionType.receiveTimeout || err.type == DioExceptionType.connectionTimeout) {
          errorToast("Server is busy...!");
          return APIResponse(status: 0, message: "Timeout");
        } else {
          errorToast("Unable to process your request right now, Please try again later.!");
          return APIResponse(status: 0, message: "Internal error");
        }
      } catch (err) {
        return _formatOutput(null, err.toString());
      }
    } else {
      return _formatOutput(null, "Please make sure the internet is connected!");
    }
  }

  static APIResponse _formatOutput(Response? response, String? message) {
    if (response == null) {
      return APIResponse.fromJson({"message": message, "data": 0, "status": 0});
    } else {
      if (response.data is Map) {
        final responseData = Map<String, dynamic>.from(response.data);

        // Ensure consistent status pattern: 1 for success, 0 for failure
        if (responseData.containsKey('success') && responseData['success'] == true) {
          responseData['status'] = 1;
        } else if (responseData.containsKey('status') && (responseData['status'] == 200 || responseData['status'] == 201)) {
          responseData['status'] = 1;
        } else if (!responseData.containsKey('status')) {
          responseData['status'] = 1; // Default to success if no status field and no error
        }

        return APIResponse.fromJson(responseData);
      } else {
        // Handle non-json responses (like HTML error pages) - treat as failure
        return APIResponse.fromJson({"message": response.statusMessage ?? response.data?.toString() ?? message, "data": null, "status": 0});
      }
    }
  }

  _errorThrow(DioException err) async {
    if (err.response != null) {
      dynamic userData = await getStorage(AppSession.userData);
      String userName = "";
      if (userData != null && userData is Map) {
        userName = userData["name"] ?? "";
      }
      var errorShow = {"Api": err.response!.realUri, "Status": err.response!.statusCode, "UserName": userName, "StatusMessage": err.response!.statusMessage};
      throw Exception(errorShow);
    }
  }
}
