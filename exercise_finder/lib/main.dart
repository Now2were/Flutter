import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'appearance.dart';
import 'data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureServices();
  runApp(const ExerciseApp());
}

const muscles = {
  'Abs': 'Пресс',
  'Adductors': 'Приводящие мышцы бедра',
  'Biceps': 'Бицепсы',
  'Calves': 'Икры',
  'Chest': 'Грудь',
  'Forearms': 'Предплечья',
  'Glutes': 'Ягодицы',
  'Hamstrings': 'Задняя поверхность бедра',
  'Hip flexors': 'Сгибатели бедра',
  'Lats': 'Широчайшие мышцы спины',
  'Lower back': 'Поясница',
  'Neck': 'Шея',
  'Obliques': 'Косые мышцы живота',
  'Quadriceps': 'Квадрицепсы',
  'Rotator cuff': 'Вращательная манжета плеча',
  'Serratus': 'Зубчатые мышцы',
  'Shoulders': 'Плечи',
  'Tibialis': 'Передние мышцы голени',
  'Trapezius': 'Трапеции',
  'Triceps': 'Трицепсы',
  'Upper back': 'Верхняя часть спины',
};
const levels = {
  'Beginner': 'Начальный',
  'Intermediate': 'Средний',
  'Advanced': 'Продвинутый',
};

class ExerciseApp extends StatelessWidget {
  const ExerciseApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Атлас упражнений',
    theme: atlasTheme(),
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

  Future<void> openExercise(Exercise exercise) async {
    if (exercise.gymFitId.isNotEmpty && credentials.key.isEmpty) {
      await editKey();
      if (!mounted || credentials.key.isEmpty) return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ExerciseDetails(exercise: exercise, favorites: favorites),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Row(
        children: [
          AtlasMark(Icons.fitness_center, size: 34),
          SizedBox(width: 12),
          Flexible(child: Text('Атлас упражнений')),
        ],
      ),
      actions: [
        IconButton(
          onPressed: busy ? null : editKey,
          tooltip: 'Настроить ключ API',
          icon: Icon(
            Icons.key_outlined,
            color: credentials.key.isEmpty ? steel : volt,
          ),
        ),
        const SizedBox(width: 12),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (index) => setState(() => tab = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search),
          label: 'Поиск',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_outline),
          selectedIcon: Icon(Icons.bookmark),
          label: 'Избранное',
        ),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: ListenableBuilder(
            listenable: favorites,
            builder: (context, _) => ListView(
              key: PageStorageKey(tab),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
              children: tab == 0
                  ? searchContent(context)
                  : [
                      Text(
                        'Избранное',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      if (favorites.items.isEmpty)
                        const AtlasPanel(
                          child: Text(
                            'Сохраняйте упражнения из поиска, чтобы быстро вернуться к ним.',
                          ),
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
    LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        final hero = searchIntro(context, wide: wide);
        final form = searchForm(context);
        return wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: hero),
                  const SizedBox(width: 32),
                  Expanded(child: form),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [hero, const SizedBox(height: 24), form],
              );
      },
    ),
    const SizedBox(height: 24),
    if (busy) ...[
      const LinearProgressIndicator(),
      const SizedBox(height: 8),
      const Text('Загружаем упражнения…'),
    ] else if (error != null)
      AtlasPanel(
        child: Text(
          error!,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      )
    else if (results case final found?)
      if (found.isEmpty)
        const AtlasPanel(
          child: Text(
            'Ничего не найдено. Попробуйте изменить название или фильтры.',
          ),
        )
      else ...[
        Text(
          'Результаты: ${found.length}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...found.map(exerciseTile),
      ],
  ];

  Widget searchIntro(BuildContext context, {required bool wide}) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'КАТАЛОГ  /  GYMFIT API',
          style: text.labelMedium?.copyWith(
            color: volt,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.8,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Найдите упражнение',
          style: text.displaySmall?.copyWith(fontSize: wide ? 52 : 36),
        ),
        const SizedBox(height: 12),
        Text(
          'Подберите движение по группе мышц и сложности. Откройте карточку, чтобы посмотреть технику выполнения.',
          style: text.bodyLarge?.copyWith(color: steel),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final example in ['Squat', 'Bench press', 'Deadlift'])
              ActionChip(
                label: Text(example),
                backgroundColor: panel,
                side: const BorderSide(color: line),
                onPressed: busy
                    ? null
                    : () {
                        name.text = example;
                        search();
                      },
              ),
          ],
        ),
      ],
    );
  }

  Widget searchForm(BuildContext context) => AtlasPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Поиск по каталогу',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: name,
          maxLength: 100,
          enabled: !busy,
          onSubmitted: (_) => search(),
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            labelText: 'Название',
            hintText: 'Например, push up',
            counterText: '',
            prefixIcon: Icon(Icons.search),
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
        if (credentials.key.isEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Для первого поиска понадобится ключ GymFit API.',
            style: TextStyle(color: steel),
          ),
        ],
      ],
    ),
  );

  Widget filter(
    String label,
    Map<String, String> options,
    String? current,
    ValueChanged<String?> change,
  ) => InputDecorator(
    decoration: InputDecoration(labelText: label),
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

  Widget exerciseTile(Exercise exercise) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: const AtlasMark(Icons.fitness_center),
        title: Text(
          exercise.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: summary(exercise).isEmpty ? null : Text(summary(exercise)),
        onTap: () => openExercise(exercise),
        trailing: FavoriteButton(exercise: exercise, favorites: favorites),
      ),
    ),
  );
}

String summary(Exercise exercise) {
  final level = exercise.field('difficulty');
  final gymFitLevel = level == 'expert' ? 'Advanced' : level;
  final translatedLevel = levels.entries
      .where((entry) => entry.key.toLowerCase() == gymFitLevel.toLowerCase())
      .firstOrNull
      ?.value;
  return [
    ...exercise.muscleGroups.map((muscle) => muscles[muscle] ?? muscle),
    translatedLevel ?? level,
  ].where((value) => value.isNotEmpty).join(' · ');
}

String networkMessage(Object? exception) {
  if (exception is! DioException) return 'Не удалось прочитать ответ сервера.';
  return switch (exception.response?.statusCode) {
    400 => 'Сервис отклонил запрос. Проверьте параметры поиска.',
    401 => 'GymFit не принял ключ API. Проверьте его в настройках.',
    403 => 'GymFit отказал в доступе. Проверьте ключ и права аккаунта.',
    404 => 'Упражнение больше недоступно.',
    429 => 'Достигнут лимит запросов. Попробуйте позже.',
    final int code => 'Ошибка сервиса (HTTP $code). Попробуйте позже.',
    null => 'Нет ответа от сервера. Проверьте подключение и повторите запрос.',
  };
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
    scrollable: true,
    icon: const Center(child: AtlasMark(Icons.key_outlined)),
    title: const Text('Ключ GymFit API'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Скопируйте ключ из кабинета на gymfit-api.com. Ключ нужно вводить заново после перезапуска.',
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

class ExerciseDetails extends StatefulWidget {
  const ExerciseDetails({
    super.key,
    required this.exercise,
    required this.favorites,
  });
  final Exercise exercise;
  final Favorites favorites;

  @override
  State<ExerciseDetails> createState() => _ExerciseDetailsState();
}

class _ExerciseDetailsState extends State<ExerciseDetails> {
  late Future<Exercise> details = loadDetails();

  Future<Exercise> loadDetails() {
    final exercise = widget.exercise;
    if (exercise.gymFitId.isEmpty) return Future.value(exercise);
    return services<ExerciseRepository>().details(exercise.gymFitId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Упражнение'),
      actions: [
        FavoriteButton(exercise: widget.exercise, favorites: widget.favorites),
      ],
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: FutureBuilder<Exercise>(
            future: details,
            builder: (context, snapshot) => ListView(
              padding: const EdgeInsets.all(24),
              children: [
                AtlasPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AtlasMark(Icons.fitness_center),
                      const SizedBox(height: 14),
                      Text(
                        snapshot.data?.name ?? widget.exercise.name,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (summary(snapshot.data ?? widget.exercise)
                          .isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          summary(snapshot.data ?? widget.exercise),
                          style: const TextStyle(color: steel),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState != ConnectionState.done)
                  const LinearProgressIndicator()
                else if (snapshot.hasError) ...[
                  Text(networkMessage(snapshot.error)),
                  OutlinedButton(
                    onPressed: () => setState(() => details = loadDetails()),
                    child: const Text('Повторить'),
                  ),
                ] else if (snapshot.data case final exercise?) ...[
                  if (exercise.equipment.isNotEmpty) ...[
                    section(context, 'Инвентарь', exercise.equipment),
                    const SizedBox(height: 12),
                  ],
                  section(
                    context,
                    'Техника выполнения',
                    exercise.instructions.isEmpty
                        ? 'Описание отсутствует.'
                        : exercise.instructions,
                  ),
                  if (exercise.field('safety_info').isNotEmpty) ...[
                    const SizedBox(height: 12),
                    section(
                      context,
                      'Рекомендации по безопасности',
                      exercise.field('safety_info'),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget section(BuildContext context, String title, String content) =>
      AtlasPanel(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            SelectableText(
              content,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: steel, height: 1.5),
            ),
          ],
        ),
      );
}
