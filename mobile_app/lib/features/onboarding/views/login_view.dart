import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/color_resources.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
                child: Image.asset(
                  'assets/images/login_screen_image.png',
                  fit: BoxFit.contain,
                  width: 1000,
                  height: 1000,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image_not_supported, size: 48),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: ColorResources.accentBrown,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: controller.emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter Username/email',
                          fillColor: const Color(0xFFD9D9D9),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => TextField(
                          controller: controller.passwordController,
                          obscureText: !controller.showPassword.value,
                          decoration: InputDecoration(
                            hintText: 'Enter Password',
                            fillColor: const Color(0xFFD9D9D9),
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.showPassword.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 20,
                                color: Colors.black,
                              ),
                              onPressed: controller.toggleShowPassword,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Obx(
                            () => Row(
                              children: [
                                Transform.scale(
                                  scale: 0.9,
                                  child: Checkbox(
                                    value: controller.rememberMe.value,
                                    onChanged: (_) =>
                                        controller.toggleRememberMe(),
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    side: const BorderSide(
                                      color: Color(0xFFCFCFCF),
                                    ),
                                    activeColor: ColorResources.primaryGreen,
                                  ),
                                ),
                                Text(
                                  'Remember me',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: ColorResources.accentBrown,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: controller.forgotPassword,
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: EdgeInsets.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Forgot Password?',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: ColorResources.accentBrown,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: controller.login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ColorResources.primaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: ColorResources.accentBrown,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'or continue with',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ColorResources.textGrey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: controller.loginWithGoogle,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF353535)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/google_icon.png',
                                height: 18,
                                width: 18,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.g_mobiledata,
                                    size: 22,
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Google',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Don’t have an account? ",
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: ColorResources.accentBrown,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            GestureDetector(
                              onTap: controller.goToSignUp,
                              child: Text(
                                'Sign Up',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: ColorResources.primaryGreen,
                                      fontWeight: FontWeight.w700,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
