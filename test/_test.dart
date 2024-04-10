/* By Abdullah As-Sadeed */

import 'package:flutter_test/flutter_test.dart';
import 'package:bitscoper_cyber_toolbox/main.dart';

void main() {
  /* Widget Test */
  testWidgets('MainApp Widget Test', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.byType(MainApp), findsOneWidget);
  });

  /* Unit Test */
  test('Toggle Theme Test', () {
    MainAppState mainAppState = MainAppState();

    expect(mainAppState.isDarkTheme, false);

    mainAppState.toggleTheme();

    expect(mainAppState.isDarkTheme, true);
  });
}
