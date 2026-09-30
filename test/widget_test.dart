// Test sederhana: memastikan biodata tampil di layar.

import 'package:flutter_test/flutter_test.dart';

import 'package:first_app/main.dart';

void main() {
  testWidgets('Biodata tampil di layar', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('JIFRAN AL SHIRAF'), findsWidgets);
    expect(find.text('NPM 2408007010046'), findsOneWidget);
    expect(find.text('BANDA ACEH'), findsOneWidget);
  });
}
