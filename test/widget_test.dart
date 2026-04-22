import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snapbid/main.dart';

void main() {
  testWidgets('SnapBid app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SnapBidApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
