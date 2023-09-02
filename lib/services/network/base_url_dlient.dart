import 'package:http/http.dart';

abstract class BaseUrlClient {
  final String host = "";
  final String apiKey = "";
  final Client client = Client();
}

class SpeciesClient extends BaseUrlClient {
  @override
  String get host => 'my-api.plantnet.org/';

  @override
  String get apiKey => '2b10NG7jZpQ6wvyF5QYLILVte';
}

class OtherClient extends BaseUrlClient {
  @override
  String get host => 'https://jsonplaceholder.typicode.com/';
}