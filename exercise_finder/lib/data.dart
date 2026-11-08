import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

final services = GetIt.instance;

class ApiCredentials {
  String key = const String.fromEnvironment('API_NINJAS_KEY').trim();
}

class ApiKeyInterceptor extends Interceptor {
  ApiKeyInterceptor(this.credentials);
  final ApiCredentials credentials;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.uri.origin == 'https://api.api-ninjas.com' &&
        credentials.key.isNotEmpty) {
      options.headers['X-Api-Key'] = credentials.key;
    }
    handler.next(options);
  }
}

Future<void> configureServices() async {
  services.registerSingleton(ApiCredentials());
  services.registerSingleton(await SharedPreferences.getInstance());
  services.registerLazySingleton(
    () =>
        Dio(
            BaseOptions(
              baseUrl: 'https://api.api-ninjas.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              followRedirects: false,
            ),
          )
          ..interceptors.addAll([
            ApiKeyInterceptor(services<ApiCredentials>()),
            PrettyDioLogger(
              enabled: kDebugMode,
              requestHeader: false,
              responseHeader: false,
              responseBody: false,
              error: false,
            ),
          ]),
  );
  services.registerLazySingleton(() => ExerciseRepository(services<Dio>()));
  services.registerLazySingleton(
    () => Favorites(services<SharedPreferences>()),
  );
}

class Exercise {
  const Exercise(this.data);
  final Map<String, dynamic> data;

  String field(String name) => data[name] is String ? data[name] as String : '';
  String get name => field('name');
  String get id => jsonEncode([name, field('muscle'), field('type')]);
  String get equipment {
    final items = data['equipments'];
    return items is List
        ? items.whereType<String>().join(', ')
        : field('equipment');
  }
}

class ExerciseRepository {
  ExerciseRepository(this.dio);
  final Dio dio;

  Future<List<Exercise>> search({
    required String name,
    String? muscle,
    String? difficulty,
  }) async {
    final response = await dio.get<List<dynamic>>(
      '/v1/exercises',
      queryParameters: {
        if (name.trim().isNotEmpty) 'name': name.trim(),
        'muscle': ?muscle,
        'difficulty': ?difficulty,
      },
    );
    return response.data!
        .map((item) => Exercise(item as Map<String, dynamic>))
        .toList();
  }
}

class Favorites extends ChangeNotifier {
  Favorites(this.preferences) {
    for (final raw in preferences.getStringList('exercises') ?? <String>[]) {
      final exercise = Exercise(jsonDecode(raw) as Map<String, dynamic>);
      _items[exercise.id] = exercise;
    }
  }
  final SharedPreferences preferences;
  final _items = <String, Exercise>{};
  bool _saving = false;

  List<Exercise> get items => _items.values.toList();
  bool contains(Exercise exercise) => _items.containsKey(exercise.id);

  Future<void> toggle(Exercise exercise) async {
    if (_saving) return;
    _saving = true;
    try {
      final next = Map.of(_items);
      if (next.remove(exercise.id) == null) next[exercise.id] = exercise;
      final saved = await preferences.setStringList(
        'exercises',
        next.values.map((item) => jsonEncode(item.data)).toList(),
      );
      if (!saved) throw StateError('Could not save favorites');
      _items
        ..clear()
        ..addAll(next);
      notifyListeners();
    } finally {
      _saving = false;
    }
  }
}
