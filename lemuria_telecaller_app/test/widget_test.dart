import 'package:flutter_test/flutter_test.dart';
import 'package:lemuria_telecaller_app/main.dart';

void main() {
  testWidgets('Lemuria Telecaller smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LemuriaTelecallerApp());
    expect(find.text('LEMURIA'), findsOneWidget);
  });
}
