import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:exercise_finder/data.dart';
import 'package:exercise_finder/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseAdapter implements HttpClientAdapter {
  RequestOptions? request;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final exercise = {
      'id': 'push-up',
      'name': 'Push Up',
      'category': 'Strength',
      'primaryGroups': ['Chest'],
      'difficulty': 'Beginner',
      'equipment': 'Bodyweight',
    };
    return ResponseBody.fromString(
      jsonEncode(
        options.uri.path.endsWith('/push-up')
            ? {
                ...exercise,
                'instructions': [
                  {
                    'order': 1,
                    'description': 'Lower your chest and press back up.',
                  },
                ],
              }
            : {
                'results': [exercise],
              },
      ),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  testWidgets('search authenticates the request and favorites survive reload', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await configureServices();
    addTearDown(() => services.reset());
    services<ApiCredentials>().key = 'test-key';
    final adapter = ExerciseAdapter();
    services<Dio>().httpClientAdapter = adapter;

    await tester.pumpWidget(const ExerciseApp());
    await tester.enterText(find.byType(TextField), ' push ');
    await tester.tap(find.text('Любой').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Грудь').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Найти упражнения'));
    await tester.pumpAndSettle();

    expect(
      adapter.request?.uri.toString(),
      'https://api.gymfit-api.com/v2/exercises/search?query=push&muscleGroup=Chest',
    );
    expect(adapter.request?.headers['X-Api-Key'], 'test-key');
    await tester.scrollUntilVisible(
      find.text('Push Up'),
      180,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.text('Push Up')),
      alignment: 0.5,
    );
    await tester.tap(find.text('Push Up'));
    await tester.pumpAndSettle();
    expect(adapter.request?.uri.path, '/v2/exercises/push-up');
    expect(adapter.request?.headers['X-Api-Key'], 'test-key');
    expect(find.text('1. Lower your chest and press back up.'), findsOneWidget);
    await tester.tap(find.byTooltip('Добавить в избранное').last);
    await tester.pumpAndSettle();
    final restored = Favorites(services<SharedPreferences>());
    expect(restored.items.single.name, 'Push Up');
    expect(restored.items.single.data, {'id': 'push-up', 'name': 'Push Up'});
    restored.dispose();

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Избранное'));
    await tester.pumpAndSettle();
    expect(find.text('Push Up'), findsOneWidget);
    await tester.tap(find.byTooltip('Убрать из избранного'));
    await tester.pumpAndSettle();
    expect(find.text('Push Up'), findsNothing);
  });

  test('API key is not attached to other origins', () async {
    final adapter = ExerciseAdapter();
    final dio = Dio()..httpClientAdapter = adapter;
    addTearDown(dio.close);
    dio.interceptors.add(ApiKeyInterceptor(ApiCredentials()..key = 'test-key'));
    await dio.get<dynamic>('https://example.com/exercises');
    expect(adapter.request?.headers['X-Api-Key'], isNull);
  });
}
