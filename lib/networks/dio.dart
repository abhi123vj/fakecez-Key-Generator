import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';


class DioHelper {
  Dio dio = Dio();
  DioHelper(String baseUrl) {
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = 10000;
    dio.options.receiveTimeout = 10000;
    dio.options.followRedirects = true;
    dio.options.headers = {
      // 'bearer': 'Bearer ${UserSession().accessToken}',
      HttpHeaders.acceptHeader: 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
      HttpHeaders.acceptLanguageHeader:'en-US;q=0.5',
      HttpHeaders.refererHeader:' https://link.paid4link.net/'
      ,HttpHeaders.userAgentHeader:' Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.134 Safari/537.36'

      //  HttpHeaders.authorizationHeader: 'Bearer ${UserSession().accessToken}'
    };
    dio.transformer = JsonTransformer();

    // auth interceptor
    _setupAuthInterceptor();
  }

  void _setupAuthInterceptor() {
    dio.interceptors.add(
      RetryInterceptor(
        dio: dio,
        logPrint: print, // specify log function (optional)
        retries: 3, // retry count (optional)
        retryDelays: const [
          // set delays between retries (optional)
          Duration(seconds: 1), // wait 1 sec before first retry
          Duration(seconds: 2), // wait 2 sec before second retry
          Duration(seconds: 3), // wait 3 sec before third retry
        ],
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) async {
      
        log(" url = ${options.uri} \nheaders = ${options.headers.toString()} \nbody =${options.data}");

        return handler.next(options);
      }, onResponse: (response, handler) async {
        log("Response is $response");
         return handler.next(response);
      }, onError: (DioError error, ErrorInterceptorHandler handler) {
        if (error.type == DioErrorType.response) {
          switch (error.response?.statusCode) {
            case 401:
              break;
            case 403:
              handler.resolve(Response(
                requestOptions: error.requestOptions,
                data: {
                  'success': false,
                  'message': error.response?.data['message'],
                  'errorMessage': "errormessage"
                },
                statusCode: error.response?.statusCode,
              ));
              // Forbidden
              break;
            case 404:
              break;
            case 500:
              // Server broken
              handler.resolve(Response(
                requestOptions: error.requestOptions,
                data: {
                  'success': false,
                  'message': error.message,
                  'errorMessage': "errormessage"
                },
                statusCode: error.response?.statusCode,
              ));
              break;
          }
        } else if (error.type == DioErrorType.other) {
          log("Error time ${error.type}");
          handler.resolve(Response(
            requestOptions: error.requestOptions,
            data: {
              'success': false,
              'message': 'Network Error ${error.type}',
              'errorMessage': error.message
            },
            statusCode: error.response?.statusCode,
          ));
        } else if (error.type == DioErrorType.connectTimeout) {
          log("Error connection ${error.type}");

          handler.resolve(Response(
            requestOptions: error.requestOptions,
            data: {
              'success': false,
              'message': 'Network Error ${error.type}',
              'errorMessage': error.message
            },
            statusCode: 500,
          ));
        } else {
          log("Error time 2 ${error.type}");
          handler.resolve(Response(
            requestOptions: error.requestOptions,
            data: {
              'success': false,
              'message': error.message,
              'errorMessage': "errormessage"
            },
            statusCode: error.response?.statusCode,
          ));
          return;
          // Show error message
        }
        //   handler.resolve(Response(
        //     requestOptions: error.requestOptions,
        //     data: {
        //       'success': error.response?.data["success"],
        //       'message': error.response?.data["message"],
        //       'errorMessage': error.message
        //     },
        //     statusCode: error.response?.statusCode,
        //   ));
      }),
    );
  }
}

class JsonTransformer extends DefaultTransformer {
  JsonTransformer() : super(jsonDecodeCallback: _parseJson);
}

Map<String, dynamic> _parseJsonDecode(String response) {
  return jsonDecode(response) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _parseJson(String text) {
  return compute(_parseJsonDecode, text);
}

final Dio dio = DioHelper(Config.baseUrl).dio;

extension ResponseHelper on Response {
  bool isSuccess() {
    return statusCode == 200;
  }
}