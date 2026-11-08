import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureServices();
  runApp(const ExerciseApp());
}

const muscles = {
  'abdominals': 'Пресс',
  'abductors': 'Отводящие мышцы бедра',
  'adductors': 'Приводящие мышцы бедра',
  'biceps': 'Бицепсы',
  'calves': 'Икры',
  'chest': 'Грудь',
  'forearms': 'Предплечья',
  'glutes': 'Ягодицы',
  'hamstrings': 'Задняя поверхность бедра',
  'lats': 'Широчайшие мышцы спины',
  'lower_back': 'Поясница',
  'middle_back': 'Средняя часть спины',
  'neck': 'Шея',
  'quadriceps': 'Квадрицепсы',
  'traps': 'Трапеции',
  'triceps': 'Трицепсы',
};
const levels = {
  'beginner': 'Начальный',
  'intermediate': 'Средний',
  'expert': 'Продвинутый',
};

class ExerciseApp extends StatelessWidget {
  const ExerciseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Атлас упражнений',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff00796b)),
    ),
    home: const Catalog(),
  );
}

class Catalog extends StatefulWidget {
  const Catalog({super.key});

  @override
  State<Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  final name = TextEditingController();
  final credentials = services<ApiCredentials>();
  final favorites = services<Favorites>();
  String? muscle, difficulty, error;
  List<Exercise>? results;
  bool busy = false;
  int tab = 0;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> editKey() async {
    final key = await showDialog<String>(
      context: context,
      builder: (_) => KeyDialog(initialKey: credentials.key),
    );
    if (!mounted || key == null) return;
    setState(() => credentials.key = key);
  }

  Future<void> search() async {
    if (busy) return;
    if (credentials.key.isEmpty) {
      await editKey();
      if (!mounted || credentials.key.isEmpty || busy) return;
    }
    setState(() {
      busy = true;
      error = null;
      results = null;
    });
    try {
      final found = await services<ExerciseRepository>().search(
        name: name.text,
        muscle: muscle,
        difficulty: difficulty,
      );
      if (mounted) setState(() => results = found);
    } on DioException catch (exception) {
      if (mounted) setState(() => error = networkMessage(exception));
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Не удалось прочитать ответ сервера.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  String networkMessage(DioException exception) {
    final response = exception.response;
    final data = response?.data;
    final reason = data is Map ? data['error'].toString().toLowerCase() : '';
    if (reason.contains('api key') || response?.statusCode == 401) {
      return 'Ключ API не принят. Проверьте его в настройках.';
    }
    return switch (response?.statusCode) {
      400 => 'Сервис отклонил запрос. Проверьте параметры поиска.',
      403 => 'API отказал в доступе. Проверьте ключ и права аккаунта.',
      429 => 'Достигнут лимит запросов. Попробуйте позже.',
      final int code => 'Ошибка сервиса (HTTP $code). Попробуйте позже.',
      null => 'Нет ответа от сервера. Проверьте подключение и повторите поиск.',
    };
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Атлас упражнений'),
      actions: [
        IconButton(
          onPressed: busy ? null : editKey,
          tooltip: 'Настроить ключ API',
          icon: const Icon(Icons.key),
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (index) => setState(() => tab = index),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.search), label: 'Поиск'),
        NavigationDestination(
          icon: Icon(Icons.bookmark_outline),
          label: 'Избранное',
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListenableBuilder(
            listenable: favorites,
            builder: (context, _) => ListView(
              key: PageStorageKey(tab),
              padding: const EdgeInsets.all(20),
              children: tab == 0
                  ? searchContent(context)
                  : [
                      Text(
                        'Избранное',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      if (favorites.items.isEmpty)
                        const Text(
                          'Сохраняйте упражнения из поиска, чтобы открыть их без сети.',
                        ),
                      ...favorites.items.map(exerciseTile),
                    ],
            ),
          ),
        ),
      ),
    ),
  );

  List<Widget> searchContent(BuildContext context) => [
    Text(
      'Найдите упражнение',
      style: Theme.of(context).textTheme.headlineSmall,
    ),
    const SizedBox(height: 8),
    const Text('Введите название на английском или выберите параметры.'),
    const SizedBox(height: 16),
    TextField(
      controller: name,
      enabled: !busy,
      onSubmitted: (_) => search(),
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Название',
        hintText: 'Например, push up',
        prefixIcon: Icon(Icons.fitness_center),
      ),
    ),
    const SizedBox(height: 12),
    filter(
      'Группа мышц',
      muscles,
      muscle,
      (value) => setState(() => muscle = value),
    ),
    const SizedBox(height: 12),
    filter(
      'Уровень сложности',
      levels,
      difficulty,
      (value) => setState(() => difficulty = value),
    ),
    const SizedBox(height: 16),
    FilledButton.icon(
      onPressed: busy ? null : search,
      icon: const Icon(Icons.search),
      label: const Text('Найти упражнения'),
    ),
    const SizedBox(height: 20),
    if (busy) ...[
      const LinearProgressIndicator(),
      const SizedBox(height: 8),
      const Text('Загружаем упражнения…'),
    ] else if (error != null)
      Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error))
    else if (results case final found?)
      if (found.isEmpty)
        const Text(
          'Ничего не найдено. Попробуйте изменить название или фильтры.',
        )
      else ...[
        Text(
          'Результаты: ${found.length}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...found.map(exerciseTile),
      ]
    else if (credentials.key.isEmpty)
      const Text('Для первого поиска понадобится ключ API Ninjas.'),
  ];

  Widget filter(
    String label,
    Map<String, String> options,
    String? current,
    ValueChanged<String?> change,
  ) => InputDecorator(
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: current ?? '',
        isExpanded: true,
        isDense: true,
        onChanged: busy ? null : (value) => change(value == '' ? null : value),
        items: [
          const DropdownMenuItem(value: '', child: Text('Любой')),
          for (final option in options.entries)
            DropdownMenuItem(value: option.key, child: Text(option.value)),
        ],
      ),
    ),
  );

  Widget exerciseTile(Exercise exercise) => Card(
    child: ListTile(
      leading: const Icon(Icons.fitness_center),
      title: Text(exercise.name),
      subtitle: Text(summary(exercise)),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              ExerciseDetails(exercise: exercise, favorites: favorites),
        ),
      ),
      trailing: FavoriteButton(exercise: exercise, favorites: favorites),
    ),
  );
}

String summary(Exercise exercise) {
  final muscle = exercise.field('muscle');
  final level = exercise.field('difficulty');
  return [
    muscles[muscle] ?? muscle,
    levels[level] ?? level,
  ].where((value) => value.isNotEmpty).join(' · ');
}

class KeyDialog extends StatefulWidget {
  const KeyDialog({super.key, required this.initialKey});
  final String initialKey;

  @override
  State<KeyDialog> createState() => _KeyDialogState();
}

class _KeyDialogState extends State<KeyDialog> {
  late final controller = TextEditingController(text: widget.initialKey);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void save() => Navigator.pop(context, controller.text.trim());

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Ключ API Ninjas'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Скопируйте ключ из аккаунта на api-ninjas.com. Введённый ключ действует до закрытия приложения.',
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          obscureText: true,
          autocorrect: false,
          enableSuggestions: false,
          decoration: const InputDecoration(labelText: 'X-Api-Key'),
          onSubmitted: (_) => save(),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Отмена'),
      ),
      FilledButton(onPressed: save, child: const Text('Применить')),
    ],
  );
}

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.exercise,
    required this.favorites,
  });
  final Exercise exercise;
  final Favorites favorites;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: favorites,
    builder: (context, _) {
      final saved = favorites.contains(exercise);
      return IconButton(
        tooltip: saved ? 'Убрать из избранного' : 'Добавить в избранное',
        icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
        onPressed: () async {
          try {
            await favorites.toggle(exercise);
          } catch (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Не удалось обновить избранное.')),
              );
            }
          }
        },
      );
    },
  );
}

class ExerciseDetails extends StatelessWidget {
  const ExerciseDetails({
    super.key,
    required this.exercise,
    required this.favorites,
  });
  final Exercise exercise;
  final Favorites favorites;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Упражнение'),
      actions: [FavoriteButton(exercise: exercise, favorites: favorites)],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                exercise.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(summary(exercise)),
              if (exercise.equipment.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Инвентарь',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(exercise.equipment),
              ],
              const SizedBox(height: 20),
              Text(
                'Техника выполнения',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SelectableText(
                exercise.field('instructions').isEmpty
                    ? 'Описание отсутствует.'
                    : exercise.field('instructions'),
              ),
              if (exercise.field('safety_info').isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Рекомендации по безопасности',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SelectableText(exercise.field('safety_info')),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
