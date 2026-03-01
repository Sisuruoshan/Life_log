import 'package:flutter/material.dart';
import 'package:life_log/core/widgets/custom_text_field.dart';
import 'package:life_log/features/auth/views/password_success_view.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _resetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PasswordSuccessView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reset Password 🔑',
                style: theme.textTheme.displayMedium?.copyWith(fontSize: 32),
              ),
              const SizedBox(height: 8),
              Text(
                'Create a new password for your account.',
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 48),
              
              CustomTextField(
                label: 'New Password',
                controller: _newPasswordController,
                isPassword: true,
                hint: 'Enter new password',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                isPassword: true,
                hint: 'Confirm new password',
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetPassword,
                  child: const Text('Reset Password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
