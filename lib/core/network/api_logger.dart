import 'dart:convert';
import 'package:dio/dio.dart';

class ApiLogger extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logRequest(options);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logResponse(response);
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logError(err);
    super.onError(err, handler);
  }

  void _logRequest(RequestOptions options) {
    print('\n');
    print('╔════════════════════════════════════════════════════════════════');
    print('║ 📤 REQUEST');
    print('╠════════════════════════════════════════════════════════════════');
    print('║ 🌐 URL: ${options.baseUrl}${options.path}');
    print('║ 🔧 METHOD: ${options.method}');
    print('║ 📋 HEADERS: ${_prettyJson(options.headers)}');

    if (options.queryParameters.isNotEmpty) {
      print('║ 🔍 QUERY PARAMS: ${_prettyJson(options.queryParameters)}');
    }

    if (options.data != null) {
      print('║ 📦 BODY TYPE: ${options.data.runtimeType}');
      print('║ 📦 BODY: ${_prettyJson(options.data)}');
    }
    print('╚════════════════════════════════════════════════════════════════');
    print('\n');
  }

  void _logResponse(Response response) {
    print('\n');
    print('╔════════════════════════════════════════════════════════════════');
    print('║ 📥 RESPONSE');
    print('╠════════════════════════════════════════════════════════════════');
    print('║ ✅ STATUS: ${response.statusCode}');
    print(
      '║ 🌐 URL: ${response.requestOptions.baseUrl}${response.requestOptions.path}',
    );
    print('║ 📦 DATA: ${_prettyJson(response.data)}');
    print('╚════════════════════════════════════════════════════════════════');
    print('\n');
  }

  void _logError(DioException error) {
    print('\n');
    print('╔════════════════════════════════════════════════════════════════');
    print('║ ❌ ERROR');
    print('╠════════════════════════════════════════════════════════════════');
    print(
      '║ 🌐 URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}',
    );
    print('║ 🔧 METHOD: ${error.requestOptions.method}');
    print('║ 💥 TYPE: ${error.type}');
    print('║ ⚠️ STATUS: ${error.response?.statusCode}');
    print('║ 📦 RESPONSE: ${_prettyJson(error.response?.data)}');
    print('║ 📝 MESSAGE: ${error.message}');
    print('╚════════════════════════════════════════════════════════════════');
    print('\n');
  }

  String _prettyJson(dynamic data) {
    try {
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (e) {
      return data.toString();
    }
  }
}
