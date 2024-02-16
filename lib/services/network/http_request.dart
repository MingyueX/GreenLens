import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:GreenLens/services/network/base_url_dlient.dart';

enum HttpMethod {
  get('GET'),
  post('POST'),
  put('PUT'),
  delete('DELETE');

  const HttpMethod(this.value);

  final String value;
}

enum StatusCode {
  // For more on status codes:
  // https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
  ok(200),
  permanentRedirect(301),
  temporaryRedirect(302),
  notFound(404),
  gone(410),
  internalServerError(500),
  serviceUnavailable(503);

  const StatusCode(this.value);

  final int value;
}

enum RequestType {
  species,
  other;
}

class HttpRequest {
  final HttpMethod method;
  final RequestType type;
  final List<String> pathSegments;
  final Map<String, dynamic> params;
  Map<String, String> header;
  late final BaseUrlClient baseUrlClient;
  late final Uri url;

  HttpRequest(
      {required this.method,
        required this.type,
        required this.pathSegments,
        this.params = const {},
        this.header = const {}}) {
    //select client
    if (type == RequestType.species) {
      baseUrlClient = SpeciesClient();
    } else {
      baseUrlClient = OtherClient();
    }

    final apikey =
    baseUrlClient.apiKey.isEmpty ? {} : {'api_key': baseUrlClient.apiKey};

    //build url
    url = Uri.https(baseUrlClient.host, pathSegments.join('/'),
        {...params, ...apikey}.isEmpty ? null : {...params, ...apikey});
  }

  Future<dynamic> send() async {
    final request = http.Request(method.value, url)..headers.addAll(header);
    final response = await http.Response.fromStream(
        await baseUrlClient.client.send(request));
    baseUrlClient.client.close();
    if (response.statusCode == StatusCode.ok.value) {
      return jsonDecode(response.body);
    } else {
      throw Exception();
    }
  }

  @override
  String toString() => ('${method.value} $url');
}