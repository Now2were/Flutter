import 'dart:io';

const _apiPrefix = '/api/gymfit';
final _exerciseRoute = RegExp(r'^/v2/exercises/[a-zA-Z0-9_-]+$');

Future<void> main() async {
  final web = Directory('build/web');
  if (!File('${web.path}/index.html').existsSync()) {
    stderr.writeln('Run flutter build web first.');
    exitCode = 1;
    return;
  }

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 10);
  stdout.writeln('Open http://127.0.0.1:${server.port} in your browser.');
  await for (final request in server) {
    _handle(request, web, client);
  }
}

Future<void> _handle(
  HttpRequest request,
  Directory web,
  HttpClient client,
) async {
  final response = request.response;
  try {
    if (!const {'127.0.0.1', 'localhost'}.contains(request.requestedUri.host)) {
      response.statusCode = HttpStatus.forbidden;
    } else if (request.method != 'GET') {
      response.statusCode = HttpStatus.methodNotAllowed;
    } else if (request.uri.path.startsWith('$_apiPrefix/')) {
      await _proxy(request, client);
    } else {
      await _serveFile(request, web);
    }
  } finally {
    await response.close();
  }
}

Future<void> _proxy(HttpRequest request, HttpClient client) async {
  final response = request.response;
  response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
  final path = request.uri.path.substring(_apiPrefix.length);
  if (!_exerciseRoute.hasMatch(path)) {
    response.statusCode = HttpStatus.notFound;
    return;
  }

  final key = request.headers.value('X-API-Key');
  if (key == null || key.isEmpty) {
    response.statusCode = HttpStatus.unauthorized;
    response.headers.contentType = ContentType.json;
    response.write('{"code":"missing_api_key"}');
    return;
  }
  try {
    final url = Uri.https(
      'api.gymfit-api.com',
      path,
      request.uri.queryParameters,
    );
    final upstream = await client.getUrl(url);
    upstream.followRedirects = false;
    upstream.headers.set('X-API-Key', key);
    final result = await upstream.close().timeout(const Duration(seconds: 15));
    final chunks = await result.toList().timeout(const Duration(seconds: 15));
    response.statusCode = result.statusCode;
    response.headers.contentType =
        result.headers.contentType ?? ContentType.json;
    for (final chunk in chunks) {
      response.add(chunk);
    }
  } catch (_) {
    response.statusCode = HttpStatus.badGateway;
  }
}

Future<void> _serveFile(HttpRequest request, Directory web) async {
  final response = request.response;
  final parts = request.uri.pathSegments;
  if (parts.any((part) => part == '..' || part.contains(RegExp(r'[/\\:]')))) {
    response.statusCode = HttpStatus.badRequest;
    return;
  }
  final name = request.uri.path == '/' ? 'index.html' : parts.join('/');
  final file = File('${web.path}/$name');
  if (!await file.exists()) {
    response.statusCode = HttpStatus.notFound;
    return;
  }
  const mediaTypes = {
    'html': 'text/html; charset=utf-8',
    'js': 'text/javascript',
    'json': 'application/json',
    'wasm': 'application/wasm',
    'png': 'image/png',
    'otf': 'font/otf',
    'ttf': 'font/ttf',
  };
  final mediaType = mediaTypes[name.split('.').last];
  if (mediaType != null) {
    response.headers.contentType = ContentType.parse(mediaType);
  }
  response.headers.set(HttpHeaders.cacheControlHeader, 'no-cache');
  await response.addStream(file.openRead());
}
