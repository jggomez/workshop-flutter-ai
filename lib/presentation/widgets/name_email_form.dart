import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Form component for inputting attendee's name and email.
/// Features instant feedback and custom styling.
class NameEmailForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final void Function(String)? onNameChanged;
  final void Function(String)? onEmailChanged;
  final bool enabled;

  const NameEmailForm({
    super.key,
    required this.nameController,
    required this.emailController,
    this.onNameChanged,
    this.onEmailChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: nameController,
          enabled: enabled,
          onChanged: onNameChanged,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Nombre completo',
            hintText: 'Ej. Valeria Gomez',
            prefixIcon:
                const Icon(Icons.person_outline, color: AppColors.dashCyan),
            filled: true,
            fillColor: AppColors.surfaceDark,
          ),
          validator: (value) {
            if (value == null || value.trim().length < 2) {
              return 'Ingresa al menos 2 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: emailController,
          enabled: enabled,
          onChanged: onEmailChanged,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Correo del asistente',
            hintText: 'Ej. valeria@flutter.latam',
            prefixIcon: const Icon(Icons.email_outlined,
                color: AppColors.caribbeanTeal),
            filled: true,
            fillColor: AppColors.surfaceDark,
          ),
          validator: (value) {
            if (value == null || !value.contains('@') || !value.contains('.')) {
              return 'Ingresa un correo electrónico válido';
            }
            return null;
          },
        ),
      ],
    );
  }
}
