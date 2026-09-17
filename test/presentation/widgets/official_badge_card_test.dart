import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cancun_dashbooth/presentation/widgets/official_badge_card.dart';

void main() {
  group('OfficialBadgeCard Widget Tests', () {
    testWidgets('renders attendee name, email and official conference texts',
        (tester) async {
      final boundaryKey = GlobalKey();
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OfficialBadgeCard(
                repaintBoundaryKey: boundaryKey,
                attendeeName: 'Valeria Gomez',
                attendeeEmail: 'valeria@flutter.latam',
                badgeImageBytes: dummyBytes,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Valeria Gomez'), findsOneWidget);
      expect(find.text('valeria@flutter.latam'), findsOneWidget);
      expect(find.textContaining('FLUTTERCONF LATAM 2026'), findsOneWidget);
      expect(find.textContaining('Cancún'), findsOneWidget);
      expect(find.text('FLUTTER PIONEER'), findsOneWidget);
      expect(find.text('#flutterconflatam26'), findsOneWidget);
      expect(find.textContaining('Firebase AI • Gemini 3.1'), findsNothing);
      expect(find.byKey(boundaryKey), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsNothing);
    });

    testWidgets(
        'renders glowing AI vibe pill with Icons.auto_awesome when aiVibeTitle is provided',
        (tester) async {
      final boundaryKey = GlobalKey();
      final dummyBytes = Uint8List.fromList([1, 2, 3, 4]);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OfficialBadgeCard(
                repaintBoundaryKey: boundaryKey,
                attendeeName: 'Carlos Maya',
                attendeeEmail: 'carlos@flutter.latam',
                badgeImageBytes: dummyBytes,
                aiVibeTitle: 'Capitán de Widgets Caribeños',
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
      expect(find.textContaining('IA Vibe: Capitán de Widgets Caribeños'),
          findsOneWidget);
    });
  });
}
