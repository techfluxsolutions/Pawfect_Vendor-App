class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException({String? message})
    : super(message: message ?? 'No internet connection');
}

class TimeoutException extends ApiException {
  TimeoutException({String? message})
    : super(message: message ?? 'Request timeout');
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
    : super(message: message ?? 'Unauthorized', statusCode: 401);
}

class NotFoundException extends ApiException {
  NotFoundException({String? message})
    : super(message: message ?? 'Not found', statusCode: 404);
}

class ServerException extends ApiException {
  ServerException({String? message})
    : super(message: message ?? 'Server error', statusCode: 500);
}

class BadRequestException extends ApiException {
  BadRequestException({String? message, dynamic data})
    : super(message: message ?? 'Bad request', statusCode: 400, data: data);
}
