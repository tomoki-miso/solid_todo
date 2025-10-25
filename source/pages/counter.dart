import 'package:flutter/material.dart';
import 'package:solid_annotations/solid_annotations.dart';

class CounterPage extends StatelessWidget {
  CounterPage({super.key});

  @SolidState()
  int counter = 0;

  @SolidState()
  int get doubleCounter => counter * 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Counter is $counter'),
            const SizedBox(height: 16),
            Text('doubleCounter: $doubleCounter'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counter++;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
