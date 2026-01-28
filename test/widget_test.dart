import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:alarm_new/app/app.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const AlarmNewApp());
    await tester.pumpAndSettle();

    // Verify we see the Alarm tab title on first load
    expect(find.text('Alarm'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
