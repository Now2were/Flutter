import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

final services = GetIt.instance;
const gymFitOrigin = 'https://api.gymfit-api.com';
const webApiPrefix = '/api/gymfit';

class ApiCredentials {
  String key = '';
}

class ApiKeyInterceptor extends Interceptor {
  ApiKeyInterceptor(this.credentials);
  final ApiCredentials credentials;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final uri = options.uri;
    final isLocalWebApi =
        kIsWeb &&
        const {'127.0.0.1', 'localhost'}.contains(uri.host) &&
        uri.origin == Uri.base.origin &&
        uri.path.startsWith('$webApiPrefix/');
    if ((uri.origin == gymFitOrigin || isLocalWebApi) &&
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
              baseUrl: kIsWeb ? Uri.base.origin : gymFitOrigin,
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
  String get gymFitId => field('id');
  String get id => gymFitId.isNotEmpty
      ? gymFitId
      : jsonEncode([name, field('muscle'), field('type')]);
  Map<String, dynamic> get favoriteData =>
      gymFitId.isEmpty ? data : {'id': gymFitId, 'name': name};
  List<String> get muscleGroups {
    final groups = data['primaryGroups'];
    return groups is List
        ? groups.whereType<String>().toList()
        : [field('muscle')];
  }

  String get instructions {
    final steps = data['instructions'];
    if (steps is! List) return field('instructions');
    return steps
        .whereType<Map<String, dynamic>>()
        .map((step) {
          final order = step['order'];
          final description = step['description'];
          return order is int ? '$order. $description' : '$description';
        })
        .join('\n\n');
  }

  String get equipment {
    final items = data['equipments'];
    if (items is List && items.isNotEmpty) {
      return items
          .map((item) => item is Map ? item['equipment'] : item)
          .whereType<String>()
          .join(', ');
    }
    return field('equipment');
  }
}

class ExerciseRepository {
  ExerciseRepository(this.dio);
  final Dio dio;
  String get _path => '${kIsWeb ? webApiPrefix : ''}/v2/exercises';

  Future<List<Exercise>> search({
    required String name,
    String? muscle,
    String? difficulty,
  }) async {
    final response = await dio.get<Map<String, dynamic>>(
      '$_path/search',
      queryParameters: {
        if (name.trim().isNotEmpty) 'query': name.trim(),
        'muscleGroup': ?muscle,
        'difficulty': ?difficulty,
      },
    );
    return (response.data!['results'] as List)
        .map((item) => Exercise(item as Map<String, dynamic>))
        .toList();
  }

  Future<Exercise> details(String id) async {
    final response = await dio.get<Map<String, dynamic>>(
      '$_path/${Uri.encodeComponent(id)}',
    );
    return Exercise(response.data!);
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
      if (next.remove(exercise.id) == null) {
        next[exercise.id] = Exercise(exercise.favoriteData);
      }
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
