import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../util/color_resources.dart';
import '../controllers/signup_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Image.asset(
                  'assets/images/login_screen_image.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image_not_supported, size: 48),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 10,
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
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 18),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Sign Up',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                color: ColorResources.accentBrown,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: ColorResources.accentBrown,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            GestureDetector(
                              onTap: controller.goToLogin,
                              child: Text(
                                'Login',
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
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: controller.firstNameController,
                          validator: (value) =>
                              controller.validateName(value, 'First name'),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Enter First Name',
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
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.lastNameController,
                          validator: (value) =>
                              controller.validateName(value, 'Last name'),
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Enter Last Name',
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
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.emailController,
                          validator: controller.validateEmail,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: 'Enter email address',
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
                        const SizedBox(height: 10),
                        Obx(
                          () => TextFormField(
                            controller: controller.passwordController,
                            validator: controller.validatePassword,
                            obscureText: !controller.showPassword.value,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: 'Create Password',
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
                        const SizedBox(height: 10),
                        Obx(
                          () => TextFormField(
                            controller: controller.confirmPasswordController,
                            validator: controller.validateConfirmPassword,
                            obscureText: !controller.showConfirmPassword.value,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
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
                                  controller.showConfirmPassword.value
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  size: 20,
                                  color: Colors.black,
                                ),
                                onPressed: controller.toggleShowConfirmPassword,
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
                            Text(
                              'Forgot Password?',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: ColorResources.accentBrown,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: controller.signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ColorResources.primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Sign Up',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: ColorResources.accentBrown,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
