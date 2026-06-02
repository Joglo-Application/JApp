import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showPassword = false;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _usernameCtrl.text,
      _passwordCtrl.text,
    );

    if (mounted && success) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shellBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.x5,
              vertical: AppSpacing.x8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _LogoHeader(),
                const SizedBox(height: AppSpacing.x8),
                _LoginCard(
                  formKey: _formKey,
                  usernameCtrl: _usernameCtrl,
                  passwordCtrl: _passwordCtrl,
                  showPassword: _showPassword,
                  onTogglePassword: () =>
                      setState(() => _showPassword = !_showPassword),
                  onSubmit: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo/logo-icon.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.x4),
        Text(
          'RESTO POS',
          style: AppTypography.textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.formKey,
    required this.usernameCtrl,
    required this.passwordCtrl,
    required this.showPassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameCtrl;
  final TextEditingController passwordCtrl;
  final bool showPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.x8),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome Back',
              style: AppTypography.textTheme.headlineSmall?.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.x1),
            Text(
              'Sign in to your account',
              style: AppTypography.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.x8),
            AppTextField(
              controller: usernameCtrl,
              label: 'Username',
              prefixIcon: Icons.person_outline,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Enter your username' : null,
            ),
            const SizedBox(height: AppSpacing.x4),
            AppTextField(
              controller: passwordCtrl,
              label: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: !showPassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => onSubmit(),
              suffixIcon: IconButton(
                icon: Icon(
                  showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.onSurfaceVariant,
                ),
                onPressed: onTogglePassword,
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Enter your password' : null,
            ),
            const _ErrorText(),
            const SizedBox(height: AppSpacing.x6),
            _SubmitButton(onSubmit: onSubmit),
            const SizedBox(height: AppSpacing.x6),
            const _HintText(),
          ],
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText();

  @override
  Widget build(BuildContext context) {
    final error = context.watch<AuthProvider>().error;
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.x3),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: AppSpacing.x2),
          Expanded(
            child: Text(
              error,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.onSubmit});

  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return AppButton(
      label: 'Sign In',
      onPressed: onSubmit,
      isLoading: isLoading,
      icon: Icons.login,
      width: double.infinity,
    );
  }
}

class _HintText extends StatelessWidget {
  const _HintText();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x3,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 14,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.x2),
          Text(
            'Default: admin / admin123',
            style: AppTypography.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
