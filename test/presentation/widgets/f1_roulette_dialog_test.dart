import 'package:cancun_dashbooth/domain/entities/user_card.dart';
import 'package:cancun_dashbooth/presentation/widgets/f1_roulette_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sampleCards = [
    UserCard(
      id: '1',
      name: 'Max Verstappen',
      email: 'max@redbull.com',
      imageUri: 'https://example.com/max.png',
      createdAt: DateTime.now(),
    ),
    UserCard(
      id: '2',
      name: 'Lewis Hamilton',
      email: 'lewis@ferrari.com',
      imageUri: 'https://example.com/lewis.png',
      createdAt: DateTime.now(),
    ),
    UserCard(
      id: '3',
      name: 'Fernando Alonso',
      email: 'fernando@astonmartin.com',
      imageUri: 'https://example.com/fernando.png',
      createdAt: DateTime.now(),
    ),
    UserCard(
      id: '4',
      name: 'Lando Norris',
      email: 'lando@mclaren.com',
      imageUri: 'https://example.com/lando.png',
      createdAt: DateTime.now(),
    ),
  ];

  Widget buildTestWidget(List<UserCard> cards) {
    return MaterialApp(
      home: Scaffold(
        body: F1RouletteDialog(cards: cards),
      ),
    );
  }

  group('F1RouletteDialog Widget Tests', () {
    testWidgets(
        'auto-starts into spinning state with telemetry bar, timer and candidate reel',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(sampleCards));
      await tester.pump();

      expect(find.text('GRAN PREMIO CANCÚN 2026'), findsOneWidget);
      expect(find.textContaining('Ruleta Oficial de Premios'), findsOneWidget);
      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
      expect(find.byIcon(Icons.speed), findsOneWidget);
      expect(find.text('PILOTO EN RUEDA'), findsOneWidget);
    });

    testWidgets(
        'completes ~10-second spin and displays 3-tiered F1 podium (P1, P2, P3)',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(sampleCards));
      await tester.pump();

      // Fast-forward 10.5 seconds to complete the 10-second spin sequence
      for (int i = 0; i < 110; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      expect(find.textContaining('PODIO DEL GRAN PREMIO FLUTTERCONF'),
          findsOneWidget);
      expect(find.text('P1'), findsOneWidget);
      expect(find.text('P2'), findsOneWidget);
      expect(find.text('P3'), findsOneWidget);
      expect(find.text('¡CAMPEÓN!'), findsOneWidget);
      expect(find.text('2º LUGAR'), findsOneWidget);
      expect(find.text('3ER LUGAR'), findsOneWidget);
      expect(find.text('Girar de Nuevo 🔄'), findsOneWidget);

      // Tapping "Girar de Nuevo" restarts the spin
      final restartBtn = find.text('Girar de Nuevo 🔄');
      await tester.tap(restartBtn);
      await tester.pump();

      expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    });
  });
}
