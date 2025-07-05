import 'package:connect/core/common/custom_button.dart';
import 'package:connect/core/common/custom_text_field.dart';
import 'package:connect/core/utils/ui_utils.dart';
import 'package:connect/data/repositories/auth_repository.dart';
import 'package:connect/data/services/service_locator.dart';
import 'package:connect/logic/cubits/auth/auth_cubit.dart';
import 'package:connect/logic/cubits/auth/auth_state.dart';
import 'package:connect/presentation/screens/auth/login_screen.dart';
import 'package:connect/presentation/screens/home_screen.dart';
import 'package:connect/router/app_router.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  bool _isPasswrodVisible = false;

  final _nameFocus = FocusNode();
  final _usernameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    _nameFocus.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your name";
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your username";
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your email";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return "Enter a valid email address (e.g., example@email.com)";
    }
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your phone number";
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return "Enter a valid phone number (10 digits)";
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
  }

  Future<void> handleSignUp() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await getIt<AuthCubit>().signUp(
          fullName: nameController.text,
          email: emailController.text,
          password: passwordController.text,
          phoneNumber: phoneController.text,
          username: usernameController.text,
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } else {
      print("form validation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      bloc: getIt<AuthCubit>(),
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          getIt<AppRouter>().pushAndRemoveUntil(HomeScreen());
        } else if (state.status == AuthStatus.error && state.error != null) {
          UiUtils.showSnackBar(context, message: state.error!);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create Account",
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Please fill in the details to continue",
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.grey),
                    ),
                    SizedBox(height: 30),
                    CustomTextField(
                      controller: nameController,
                      focusNode: _nameFocus,
                      validator: _validateName,
                      hintText: "Name",
                      prefixIcon: Icon(Icons.person),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: usernameController,
                      focusNode: _usernameFocus,
                      validator: _validateUsername,
                      hintText: "Username",
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: emailController,
                      focusNode: _emailFocus,
                      validator: _validateEmail,
                      hintText: "Email Address",
                      prefixIcon: Icon(Icons.email),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: phoneController,
                      focusNode: _phoneFocus,
                      validator: _validatePhone,
                      hintText: "Phone Number",
                      prefixIcon: Icon(Icons.phone),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      controller: passwordController,
                      focusNode: _passwordFocus,
                      validator: _validatePassword,
                      hintText: "Password",
                      obscureText: !_isPasswrodVisible,
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _isPasswrodVisible = !_isPasswrodVisible;
                          });
                        },
                        icon: _isPasswrodVisible
                            ? Icon(Icons.visibility)
                            : Icon(Icons.visibility_off),
                      ),
                    ),
                    SizedBox(height: 30),
                    CustomButton(
                      onPressed: handleSignUp,
                      child: state.status == AuthStatus.loading
                          ? CircularProgressIndicator(color: Colors.white,)
                          : Text(
                              "Sign Up",
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(color: Colors.grey.shade600),
                          children: [
                            TextSpan(
                              text: "Login",
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.pop(context);
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
