import 'dart:convert';

import 'package:disco/disco.dart';
import 'package:flutter/material.dart';
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:http/http.dart' as http;

import '../model/todo.dart';

final todoControllerProvider = Provider<TodoController>(
  (context) => TodoController(),
  dispose: (controller) => controller.todos.dispose(),
);

@immutable
class TodoController {
  TodoController({
    List<Todo> initialTodos = const [],
  }) : todos = ListSignal(initialTodos);

  static const _baseUrl = 'http://localhost:8080';
  final ListSignal<Todo> todos;

  Future<void> getTodos() async {
    final response = await http.get(Uri.parse('$_baseUrl/todos'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load todos (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as List<dynamic>;
    final todos = decoded
        .map((e) => Todo.fromJson(e as Map<String, dynamic>))
        .toList();
    this.todos.value = todos;
  }

  Future<void> toggleTodo(String id) async {
    final current = _findTodo(id);
    await _persistUpdate(current.copyWith(isCompleted: !current.isCompleted));
  }

  Future<void> addTodo(String title) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/todos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'isCompleted': false}),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to create todo (${response.statusCode})');
    }
    final created = Todo.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    todos.value = [...todos.value, created];
  }

  Future<void> deleteTodo(String id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/todos/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete todo (${response.statusCode})');
    }
    todos.value = todos.value.where((todo) => todo.id != id).toList();
  }

  Future<void> updateTodo(String id, {bool? isCompleted}) async {
    final current = _findTodo(id);
    await _persistUpdate(
      current.copyWith(
        isCompleted: isCompleted ?? current.isCompleted,
      ),
    );
  }

  Future<void> _persistUpdate(Todo updated) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/todos/${updated.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updated.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update todo (${response.statusCode})');
    }
    final refreshed = Todo.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
    _replaceTodo(refreshed);
  }

  Todo _findTodo(String id) => todos.value.firstWhere(
    (todo) => todo.id == id,
    orElse: () => throw StateError('Todo $id not found'),
  );

  void _replaceTodo(Todo updated) {
    todos.value = [
      for (final todo in todos.value)
        if (todo.id == updated.id) updated else todo,
    ];
  }
}
