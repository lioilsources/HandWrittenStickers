import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:handwritten_stickers/main.dart';

void main() {
  testWidgets('App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const HandwrittenStickersApp());
    // The editor's app bar shows the app icon, not a title.
    expect(find.byKey(const ValueKey('app-icon')), findsOneWidget);
  });
}
