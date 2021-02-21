// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_belajar_bloc/main.dart';

void main() {
  testWidgets('test this widget', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
  });
}
