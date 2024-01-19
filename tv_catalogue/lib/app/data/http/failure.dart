part of 'http.dart';

class HttpFailure {
  HttpFailure({this.statuscode, this.exception});
  final int? statuscode;
  final Object? exception;
}

class NetworkException {}
