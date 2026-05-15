import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/app_routes.dart';
import '../../../util/app_constant.dart';
import '../../../data/api/api_manager.dart';
import '../../../data/api/api_exceptions.dart';
import '../../../data/storage/storage_service.dart';
import '../../../common/controllers/user_controller.dart';
import 'auth_response.dart';

class LoginController extends GetxController {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final rememberMe = false.obs;
  final showPassword = false.obs;
  final storageService = StorageService();

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(email)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if ((value ?? '').isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    try {
      final resp = await ApiManager.instance.post(
        AppConstant.authSignIn,
        data: {'email': email, 'password': password},
      );
      if (resp.statusCode == 200) {
        final auth = parseAuthResponse(resp.data);
        await storageService.saveToken(auth.token);

        final user = auth.user;
        if (user != null) {
          await storageService.saveUserData(user);
          try {
            final userController = Get.find<UserController>();
            await userController.updateUserData(user);
          } catch (_) {}
        }

        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.snackbar(
          'Login failed',
          resp.data?['message']?.toString() ?? 'Unknown error',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Login failed',
        authErrorMessage(e),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> forgotPassword() async {
    final email = await _askForResetEmail();
    if (email == null) return;

    try {
      await ApiManager.instance.post(
        AppConstant.authForgotPassword,
        data: {'email': email},
      );

      Get.snackbar(
        'OTP sent',
        'Check your registered email for the OTP code.',
        snackPosition: SnackPosition.TOP,
      );

      await Future<void>.delayed(const Duration(milliseconds: 250));
      final code = await _askForOtp();
      if (code == null) return;

      final verifyResp = await ApiManager.instance.post(
        AppConstant.authVerifyOtp,
        data: {'email': email, 'code': code},
      );

      final resetToken = verifyResp.data['data']?['resetToken']?.toString();
      if (resetToken == null || resetToken.isEmpty) {
        Get.snackbar(
          'Reset failed',
          'Missing password reset token',
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final newPassword = await _askForNewPassword();
      if (newPassword == null) return;

      await ApiManager.instance.post(
        AppConstant.authResetPassword,
        data: {'resetToken': resetToken, 'password': newPassword},
      );

      passwordController.clear();
      Get.snackbar(
        'Password updated',
        'You can now login with your new password.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Reset failed',
        _errorMessage(e),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void loginWithGoogle() {
    // Google login logic
  }

  void goToSignUp() {
    Get.toNamed(AppRoutes.signup);
  }

  Future<String?> _askForResetEmail() async {
    return Get.dialog<String>(
      _ResetEmailDialog(
        initialEmail: GetUtils.isEmail(emailController.text.trim())
            ? emailController.text.trim()
            : '',
        validateEmail: validateEmail,
      ),
    );
  }

  Future<String?> _askForOtp() async {
    return Get.dialog<String>(const _OtpDialog());
  }

  Future<String?> _askForNewPassword() async {
    return Get.dialog<String>(const _NewPasswordDialog());
  }

  String _errorMessage(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class _ResetEmailDialog extends StatefulWidget {
  const _ResetEmailDialog({
    required this.initialEmail,
    required this.validateEmail,
  });

  final String initialEmail;
  final String? Function(String?) validateEmail;

  @override
  State<_ResetEmailDialog> createState() => _ResetEmailDialogState();
}

class _ResetEmailDialogState extends State<_ResetEmailDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Get.back<String>(result: _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Forgot password'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          validator: widget.validateEmail,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            labelText: 'Registered email',
            hintText: 'Enter your email',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<void>(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Send OTP'),
        ),
      ],
    );
  }
}

class _OtpDialog extends StatefulWidget {
  const _OtpDialog();

  @override
  State<_OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<_OtpDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Get.back<String>(result: _controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify OTP'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          validator: (value) {
            final code = value?.trim() ?? '';
            if (code.isEmpty) return 'OTP is required';
            if (code.length != 6) return 'Enter the 6 digit OTP';
            return null;
          },
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _submit(),
          decoration: const InputDecoration(
            labelText: 'OTP code',
            hintText: 'Enter 6 digit code',
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<void>(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Verify'),
        ),
      ],
    );
  }
}

class _NewPasswordDialog extends StatefulWidget {
  const _NewPasswordDialog();

  @override
  State<_NewPasswordDialog> createState() => _NewPasswordDialogState();
}

class _NewPasswordDialogState extends State<_NewPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Get.back<String>(result: _password.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create new password'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _password,
              obscureText: !_showPassword,
              validator: (value) {
                if ((value ?? '').isEmpty) return 'Password is required';
                if ((value ?? '').length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'New password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _confirmPassword,
              obscureText: !_showConfirmPassword,
              validator: (value) {
                if ((value ?? '').isEmpty) return 'Confirm your password';
                if (value != _password.text) return 'Passwords do not match';
                return null;
              },
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Confirm password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () => setState(
                    () => _showConfirmPassword = !_showConfirmPassword,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back<void>(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Reset'),
        ),
      ],
    );
  }
}
