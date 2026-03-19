import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:driverapp/app/app.dart';

void main() {
  testWidgets('App renders smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Driver App'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsWidgets);
  });
}
