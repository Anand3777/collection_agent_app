import 'package:flutter_test/flutter_test.dart';
import 'package:collection_agent_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CollectionAgentApp());
    expect(find.text('Collection Agent Dashboard'), findsOneWidget);
  });
}
