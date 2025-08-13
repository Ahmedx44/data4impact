import 'package:data4impact/core/service/dialog_loading.dart';
import 'package:data4impact/core/widget/AfiyaButton.dart';
import 'package:data4impact/features/login/page/login_page.dart';
import 'package:data4impact/features/signup/cubit/signup_cubit.dart';
import 'package:data4impact/features/signup/cubit/signup_state.dart';
import 'package:data4impact/features/verify_email/page/verify_email_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_button/sign_in_button.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isPasswordValid = false;
  bool _doPasswordsMatch = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPassword);
    _confirmPasswordController.addListener(_checkPasswordMatch);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPassword);
    _confirmPasswordController.removeListener(_checkPasswordMatch);
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPassword() {
    final password = _passwordController.text;
    final hasMinLength = password.length >= 6;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    setState(() {
      _isPasswordValid = hasMinLength &&
          hasUppercase &&
          hasLowercase &&
          hasNumber &&
          hasSpecialChar;
    });

    // Also check if confirm password matches when password changes
    _checkPasswordMatch();
  }

  void _checkPasswordMatch() {
    setState(() {
      _doPasswordsMatch = _confirmPasswordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return BlocConsumer<SignupCubit, SignupState>(
      listener: (context, state) {
        if (state.isLoading) {
          DialogLoading.show(context);
        } else {
          DialogLoading.hide(context);
        }

        if (state.isSuccess) {
          Navigator.push(
            context,
            MaterialPageRoute<Widget>(
              builder: (_) => VerifyEmailPage(
                email: _emailController.text,
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.03),
                    _buildLogo(theme),
                    SizedBox(height: size.height * 0.02),
                    _buildHeaderText(),
                    SizedBox(height: size.height * 0.03),
                    _buildNameFields(theme),
                    SizedBox(height: size.height * 0.02),
                    _buildEmailField(theme),
                    SizedBox(height: size.height * 0.02),
                    _buildPhoneField(theme),
                    SizedBox(height: size.height * 0.02),
                    _buildPasswordField(theme, isPassword: true),
                    SizedBox(height: size.height * 0.01),
                    _buildPasswordRequirements(),
                    SizedBox(height: size.height * 0.01),
                    _buildPasswordField(theme, isPassword: false),
                    SizedBox(height: size.height * 0.03),
                    _buildSignupButton(theme),
                    SizedBox(height: size.height * 0.03),
                    _buildLoginLink(theme),
                    SizedBox(height: size.height * 0.03),
                    _buildOrDivider(),
                    SizedBox(height: size.height * 0.03),
                    _buildGoogleButton(),
                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;

    final hasMinLength = password.length >= 6;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password must contain:',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        _buildRequirementText('At least 6 characters', hasMinLength),
        _buildRequirementText('1 uppercase letter', hasUppercase),
        _buildRequirementText('1 lowercase letter', hasLowercase),
        _buildRequirementText('1 number', hasNumber),
        _buildRequirementText('1 special character', hasSpecialChar),
      ],
    );
  }

  Widget _buildRequirementText(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle,
          size: 12,
          color: isMet ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildLogo(ThemeData theme) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'D4I',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'Fill in your details to get started',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildNameFields(ThemeData theme) {
    return Column(
      children: [
        _buildTextField(
          controller: _firstNameController,
          label: 'First Name',
          icon: Icons.person_outline,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 13),
        _buildTextField(
          controller: _middleNameController,
          label: 'Middle Name',
          icon: Icons.person_outline,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Required' : null, // Added validation
        ),
        const SizedBox(height: 13),
        _buildTextField(
          controller: _lastNameController,
          label: 'Last Name',
          icon: Icons.person_outline,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return _buildTextField(
      controller: _emailController,
      label: 'Email Address',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Email is required';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
          return 'Enter valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(ThemeData theme) {
    return _buildTextField(
      controller: _phoneController,
      label: 'Phone Number (with country code)',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Required';
        if (!value!.startsWith('+')) {
          return 'Must start with + country code';
        }
        if (value.length < 8) {
          return 'Enter a valid phone number';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(ThemeData theme, {required bool isPassword}) {
    final isPasswordValid = isPassword ? _isPasswordValid : _doPasswordsMatch;
    final hasText = isPassword
        ? _passwordController.text.isNotEmpty
        : _confirmPasswordController.text.isNotEmpty;

    return _buildTextField(
      controller: isPassword ? _passwordController : _confirmPasswordController,
      label: isPassword ? 'Password' : 'Confirm Password',
      icon: Icons.lock_outline,
      obscureText:
          isPassword ? !_isPasswordVisible : !_isConfirmPasswordVisible,
      suffixIcon: IconButton(
        icon: Icon(
          isPassword
              ? _isPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off
              : _isConfirmPasswordVisible
                  ? Icons.visibility
                  : Icons.visibility_off,
          color: Colors.grey.shade600,
        ),
        onPressed: () {
          setState(() {
            if (isPassword) {
              _isPasswordVisible = !_isPasswordVisible;
            } else {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            }
          });
        },
      ),
      borderColor: hasText
          ? isPasswordValid
              ? Colors.green
              : Colors.red
          : null,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Required';
        if (isPassword && !_isPasswordValid) {
          return 'Password doesn\'t meet requirements';
        }
        if (!isPassword && !_doPasswordsMatch) {
          return 'Passwords don\'t match';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    Color? borderColor,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: borderColor ?? theme.colorScheme.primary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: borderColor ?? Colors.transparent,
              width: borderColor != null ? 2 : 0,
            ),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          suffixIcon: suffixIcon,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildSignupButton(ThemeData theme) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CustomButton(
        onTap: _handleSignup,
        width: double.infinity,
        height: 70,
        child: const Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleSignup() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<SignupCubit>().signup(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
            middleName: _middleNameController.text.trim(),
          );
    }
  }

  Widget _buildLoginLink(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? "),
        GestureDetector(
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          ),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('OR', style: TextStyle(color: Colors.grey.shade500)),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SignInButton(
      Buttons.google,
      text: "Continue with Google",
      onPressed: () {},
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
    );
  }
}
