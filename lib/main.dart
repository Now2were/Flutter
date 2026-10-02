import 'package:flutter/material.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Заметки',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5)),
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      ),
      home: const NotesScreen(),
    );
  }
}

class Note {
  const Note({required this.id, required this.text, required this.createdAt});

  final int id;
  final String text;
  final DateTime createdAt;
}

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _fieldFocusNode = FocusNode();
  final List<Note> _notes = [];

  int _nextId = 1;
  int? _editingId;

  @override
  void dispose() {
    _controller.dispose();
    _fieldFocusNode.dispose();
    super.dispose();
  }

  void _saveNote() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Введите текст заметки')));
      return;
    }

    setState(() {
      if (_editingId != null) {
        final index = _notes.indexWhere((n) => n.id == _editingId);
        if (index != -1) {
          final note = _notes[index];
          _notes[index] = Note(id: note.id, text: text, createdAt: note.createdAt);
        }
        _editingId = null;
      } else {
        _notes.insert(
          0,
          Note(id: _nextId++, text: text, createdAt: DateTime.now()),
        );
      }
    });

    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  void _startEditing(Note note) {
    _editingId = note.id;
    _controller.text = note.text;
    _controller.selection = TextSelection.collapsed(offset: note.text.length);
    FocusScope.of(context).requestFocus(_fieldFocusNode);
    setState(() {});
  }

  void _cancelEditing() {
    setState(() {
      _editingId = null;
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить заметку?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      if (_editingId == note.id) {
        _editingId = null;
      }
      _notes.removeWhere((n) => n.id == note.id);
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sticky_note_2_outlined),
            SizedBox(width: 10),
            Text('Заметки'),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildInputArea(),
          const Divider(height: 1),
          _buildListHeader(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_editingId != null) ...[
            Row(
              children: [
                const Icon(Icons.edit_outlined, size: 18),
                const SizedBox(width: 6),
                const Expanded(child: Text('Редактирование заметки')),
                TextButton(
                  onPressed: _cancelEditing,
                  child: const Text('Отмена'),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
          TextField(
            controller: _controller,
            focusNode: _fieldFocusNode,
            minLines: 1,
            maxLines: 4,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Что нужно записать?',
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: _saveNote,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Сохранить'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Text('Все заметки', style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_notes.length}',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_notes.isEmpty) {
      return const _EmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _notes.length,
      itemBuilder: (context, index) {
        final note = _notes[index];
        return _NoteCard(
          note: note,
          isEditing: note.id == _editingId,
          onEdit: () => _startEditing(note),
          onDelete: () => _deleteNote(note),
        );
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.isEditing,
    required this.onEdit,
    required this.onDelete,
  });

  final Note note;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final time = TimeOfDay.fromDateTime(note.createdAt);

    return Card(
      elevation: 0,
      color: isEditing ? colorScheme.primaryContainer : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isEditing ? colorScheme.primary : colorScheme.outlineVariant,
          width: isEditing ? 1.5 : 1,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.text, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  Text(
                    time.format(context),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onEdit,
              tooltip: 'Редактировать',
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Удалить',
              icon: const Icon(Icons.delete_outline),
              color: colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notes_outlined, size: 72, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            'Заметок пока нет',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Text(
            'Введите текст и нажмите «Сохранить»',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
