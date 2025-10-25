import 'dart:async';

import 'package:disco/disco.dart';
import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';

import 'package:todo_solid/controller/todo_contoller.dart';
import 'package:todo_solid/model/todo.dart';

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      providers: [todoControllerProvider],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Todos'),
        ),
        body: const _TodoList(),
        floatingActionButton: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: AddTodoFAB(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class _TodoList extends StatefulWidget {
  const _TodoList();

  @override
  State<_TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<_TodoList> {
  late TodoController _todoController;
  bool _hasRequestedTodos = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _todoController = todoControllerProvider.of(context);
    if (!_hasRequestedTodos) {
      _hasRequestedTodos = true;
      unawaited(_todoController.getTodos());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context, child) {
        final todos = _todoController.todos.value;
        if (todos.isEmpty) {
          return const Center(child: Text('No todos found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(bottom: 240),
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            return _ListItem(
              todo: todo,
              onToggle: () async => _todoController.toggleTodo(todo.id),
              onDelete: () async => _todoController.deleteTodo(todo.id),
            );
          },
        );
      },
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onToggle,
            icon: todo.isCompleted
                ? const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 32,
                  )
                : const Icon(
                    Icons.circle,
                    color: Colors.grey,
                    size: 32,
                  ),
          ),
          Expanded(
            child: Text(
              todo.title,
              style: const TextStyle(fontSize: 20),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class AddTodoFAB extends StatefulWidget {
  const AddTodoFAB({super.key});

  @override
  State<AddTodoFAB> createState() => _AddTodoFABState();
}

class _AddTodoFABState extends State<AddTodoFAB> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      onPressed: () async {
        final todoController = todoControllerProvider.of(context);
        await showDialog<String>(
          context: context,
          builder: (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.grey),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 240,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Input New Todo!',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _titleController,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        final title = _titleController.text.trim();
                        if (title.isNotEmpty) {
                          await todoController.addTodo(title);
                          _titleController.clear();
                          if (context.mounted) {
                            Navigator.of(context).pop(title);
                          }
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        _titleController.clear();
      },
      child: const Text('Add Todo'),
    ),
  );
}
