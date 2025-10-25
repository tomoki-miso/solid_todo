import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_solidart/flutter_solidart.dart';

import 'pages/counter.dart';
import 'pages/todos.dart';

final routes = <String, WidgetBuilder>{
  'カウンター': (_) => CounterPage(),
  'ToDo リスト': (_) => const TodoListPage(),
};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Solid Demo',
    home: const MainPage(),
    routes: routes,
  );
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final route in routes.keys)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _NavButton(route: route),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.route});

  final String route;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        onPressed: () async {
          await Navigator.of(context).pushNamed(route);
        },
        child: Text(
          route,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
