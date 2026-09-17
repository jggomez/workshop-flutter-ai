import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cancun_dashbooth/presentation/widgets/name_email_form.dart';

void main() {
  group('NameEmailForm Widget Tests', () {
    late TextEditingController nameController;
    late TextEditingController emailController;

    setUp(() {
      nameController = TextEditingController();
      emailController = TextEditingController();
    });

    tearDown(() {
      nameController.dispose();
      emailController.dispose();
    });

    Widget createTestWidget({
      void Function(String)? onNameChanged,
      void Function(String)? onEmailChanged,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: NameEmailForm(
            nameController: nameController,
            emailController: emailController,
            onNameChanged: onNameChanged,
            onEmailChanged: onEmailChanged,
          ),
        ),
      );
    }

    testWidgets('renders name and email fields with correct labels and hints',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Nombre completo'), findsOneWidget);
      expect(find.text('Correo del asistente'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('triggers callbacks when text is entered', (tester) async {
      String? changedName;
      String? changedEmail;

      await tester.pumpWidget(createTestWidget(
        onNameChanged: (v) => changedName = v,
        onEmailChanged: (v) => changedEmail = v,
      ));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre completo'), 'Sofia');
      expect(changedName, equals('Sofia'));
      expect(nameController.text, equals('Sofia'));

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Correo del asistente'),
          'sofia@flutter.dev');
      expect(changedEmail, equals('sofia@flutter.dev'));
      expect(emailController.text, equals('sofia@flutter.dev'));
    });
  });
}
