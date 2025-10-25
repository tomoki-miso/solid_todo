import 'dart:convert';
import 'dart:io';

const _defaultPort = 8080;

class TodoDto {
  const TodoDto({
    required this.id,
    required this.title,
    required this.isCompleted,
  });

  final String id;
  final String title;
  final bool isCompleted;

  TodoDto copyWith({String? title, bool? isCompleted}) => TodoDto(
    id: id,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
  };
}

final List<TodoDto> _todos = [
  const TodoDto(id: '0', title: 'Todo 1st', isCompleted: false),
  const TodoDto(id: '1', title: 'Todo 2', isCompleted: true),
  const TodoDto(id: '2', title: 'Todo 3', isCompleted: false),
];
int _idSeed = _todos.length;

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty
      ? int.tryParse(args.first) ?? _defaultPort
      : _defaultPort;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln(
    'Mock TODO API running at http://${server.address.host}:$port',
  );

  await for (final request in server) {
    try {
      await _handleRequest(request);
    } on Exception catch (error, stackTrace) {
      stderr
        ..writeln('Mock API error: $error')
        ..writeln(stackTrace.toString());
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'message': 'Internal Server Error'}));
      await request.response.close();
    }
  }
}

Future<void> _handleRequest(HttpRequest request) async {
  final segments = _todosPathSegments(request);

  if (segments.length == 1) {
    switch (request.method) {
      case 'GET':
        await _handleGetTodos(request);
        break;
      case 'POST':
        await _handleCreateTodo(request);
        break;
      default:
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'message': 'Method Not Allowed'}));
        await request.response.close();
        break;
    }
    return;
  }

  if (segments.length == 2) {
    final id = segments[1];
    switch (request.method) {
      case 'DELETE':
        await _handleDeleteTodo(request, id);
        return;
      case 'PATCH':
        await _handlePatchTodo(request, id);
        return;
      default:
        request.response
          ..statusCode = HttpStatus.methodNotAllowed
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'message': 'Method Not Allowed'}));
        await request.response.close();
        return;
    }
  }

  request.response
    ..statusCode = HttpStatus.notFound
    ..headers.contentType = ContentType.json
    ..write(jsonEncode({'message': 'Not Found'}));
  await request.response.close();
}

List<String> _todosPathSegments(HttpRequest request) {
  final segments = request.uri.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList(growable: false);
  if (segments.isEmpty || segments.first != 'todos') {
    return const [];
  }
  return segments;
}

Future<void> _handleGetTodos(HttpRequest request) async {
  final delayQuery = request.uri.queryParameters['delay'];
  final delayMs = int.tryParse(delayQuery ?? '');
  if (delayMs != null && delayMs > 0) {
    await Future<void>.delayed(Duration(milliseconds: delayMs));
  }

  final payload = _todos.map((todo) => todo.toJson()).toList();
  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(payload));
  await request.response.close();
}

Future<void> _handleCreateTodo(HttpRequest request) async {
  final body = await utf8.decoder.bind(request).join();
  if (body.isEmpty) {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'message': 'Body required'}));
    await request.response.close();
    return;
  }

  final Map<String, dynamic> json;
  try {
    json = jsonDecode(body) as Map<String, dynamic>;
  } on FormatException catch (_) {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'message': 'Invalid JSON'}));
    await request.response.close();
    return;
  }

  final title = (json['title'] as String?)?.trim();
  if (title == null || title.isEmpty) {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'message': 'title is required'}));
    await request.response.close();
    return;
  }

  final bool isCompleted;
  if (json['isCompleted'] is bool) {
    isCompleted = json['isCompleted'] as bool;
  } else {
    isCompleted = false;
  }
  final newTodo = TodoDto(
    id: (_idSeed++).toString(),
    title: title,
    isCompleted: isCompleted,
  );
  _todos.add(newTodo);

  request.response
    ..statusCode = HttpStatus.created
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(newTodo.toJson()));
  await request.response.close();
}

Future<void> _handlePatchTodo(HttpRequest request, String id) async {
  final index = _todos.indexWhere((todo) => todo.id == id);
  if (index == -1) {
    request.response
      ..statusCode = HttpStatus.notFound
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'message': 'Todo not found'}));
    await request.response.close();
    return;
  }

  final body = await utf8.decoder.bind(request).join();
  if (body.isEmpty) {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'message': 'Body required'}));
    await request.response.close();
    return;
  }

  final Map<String, dynamic> json;
  try {
    json = jsonDecode(body) as Map<String, dynamic>;
  } on FormatException {
    request.response
      ..statusCode = HttpStatus.badRequest
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'message': 'Invalid JSON'}));
    await request.response.close();
    return;
  }

  final existing = _todos[index];
  String title = existing.title;
  if (json.containsKey('title')) {
    final rawTitle = (json['title'] as String?)?.trim();
    if (rawTitle == null || rawTitle.isEmpty) {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'message': 'title cannot be empty'}));
      await request.response.close();
      return;
    }
    title = rawTitle;
  }

  bool? isCompleted;
  if (json.containsKey('isCompleted')) {
    final value = json['isCompleted'];
    if (value is bool) {
      isCompleted = value;
    } else {
      request.response
        ..statusCode = HttpStatus.badRequest
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'message': 'isCompleted must be a bool'}));
      await request.response.close();
      return;
    }
  }

  final updated = existing.copyWith(
    title: title,
    isCompleted: isCompleted,
  );
  _todos[index] = updated;

  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(updated.toJson()));
  await request.response.close();
}

Future<void> _handleDeleteTodo(HttpRequest request, String id) async {
  final index = _todos.indexWhere((todo) => todo.id == id);
  if (index == -1) {
    request.response
      ..statusCode = HttpStatus.notFound
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'message': 'Todo not found'}));
    await request.response.close();
    return;
  }

  final removed = _todos.removeAt(index);
  request.response
    ..statusCode = HttpStatus.ok
    ..headers.contentType = ContentType.json
    ..write(jsonEncode(removed.toJson()));
  await request.response.close();
}
