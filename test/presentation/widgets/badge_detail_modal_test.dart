import 'package:cancun_dashbooth/domain/entities/user_card.dart';
import 'package:cancun_dashbooth/presentation/widgets/badge_detail_modal.dart';
import 'package:cancun_dashbooth/presentation/widgets/official_badge_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleCard = UserCard(
    id: 'test-1',
    name: 'Carolina Gómez',
    email: 'carolina@flutterconf.latam',
    imageUri: 'https://example.com/badge_carolina.png',
    createdAt: DateTime.now(),
  );

  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: BadgeDetailModal(card: sampleCard),
      ),
    );
  }

  group('BadgeDetailModal Widget Tests', () {
    testWidgets(
        'renders attendee badge card and download/Instagram share action buttons',
        (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pump();

      // Badge Card
      expect(find.byType(OfficialBadgeCard), findsOneWidget);
      expect(find.text('Carolina Gómez'), findsOneWidget);
      expect(find.text('carolina@flutterconf.latam'), findsOneWidget);

      // Download Action
      expect(find.text('Descargar Credencial HD (PNG)'), findsOneWidget);

      // Instagram Share Action
      expect(find.text('Compartir en Instagram 📸'), findsOneWidget);

      // Close Action
      expect(find.text('Cerrar'), findsOneWidget);
    });
  });
}
