import 'package:data4impact/core/widget/custom_button.dart';
import 'package:data4impact/features/forget_password/cubit/forget_password_cubit.dart';
import 'package:data4impact/features/forget_password/cubit/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:data4impact/core/service/toast_service.dart';


class ForgetPasswordView extends StatefulWidget {
  const ForgetPasswordView({super.key});

  @override
  State<ForgetPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgetPasswordView> {
  final TextEditingController _emailController = TextEditingController();
  final List<TextEditingController> _otpControllers =
  List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (index) => FocusNode());
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  int _countdown = 120;
  bool _canResendOtp = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
    for (int i = 0; i < _otpFocusNodes.length; i++) {
      _otpFocusNodes[i].addListener(() {
        if (_otpFocusNodes[i].hasFocus) {
          _otpControllers[i].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _otpControllers[i].text.length,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
            _startCountdown();
          } else {
            _canResendOtp = true;
          }
        });
      }
    });
  }

  void _resendOtp() {
    if (_canResendOtp) {
      setState(() {
        _countdown = 120;
        _canResendOtp = false;
        _startCountdown();
      });
      context.read<ForgetPasswordCubit>().sendResetEmail(_emailController.text);
    }
  }

  String _formatCountdown() {
    final minutes = (_countdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (_countdown % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _handleOtpInput(String value, int index) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }

    if (index == 5 && value.isNotEmpty) {
      _handleContinue();
    }
  }

  void _handleContinue() {
    final cubit = context.read<ForgetPasswordCubit>();
    final state = cubit.state;

    if (state.currentStep == 0) {
      if (_emailController.text.isEmpty) {
        ToastService.showErrorToast(message: 'Please enter your email');
        return;
      }
      cubit.sendResetEmail(_emailController.text);
    } else if (state.currentStep == 1) {
      final otp = _otpControllers.map((c) => c.text).join();
      if (otp.length != 6) {
        ToastService.showErrorToast(message: 'Please enter the full OTP');
        return;
      }
      cubit.verifyOtp(otp);
    } else {
      if (_newPasswordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty) {
        ToastService.showErrorToast(message: 'Please enter both passwords');
        return;
      }
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ToastService.showErrorToast(message: 'Passwords do not match');
        return;
      }
      cubit.resetPassword(_newPasswordController.text);
    }
  }

  Color _getTextFieldFillColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.grey.shade800.withOpacity(0.4)
        : Colors.white;
  }

  Color _getTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white
        : Colors.grey.shade800;
  }

  Color _getSubtitleColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.white70
        : Colors.grey.shade600;
  }

  Color _getDividerColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.grey.shade600
        : Colors.grey.shade300;
  }

  Color _getOtpFieldColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade200;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final theme = Theme.of(context);
    final brightness = Theme.of(context).brightness;

    return BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: height * 0.05),
                  const Image(
                    image: AssetImage('assets/image/d4i.png'),
                    height: 130,
                    width: 130,
                  ),
                  SizedBox(height: height * 0.04),

                  Text(
                    state.currentStep == 0
                        ? 'Forgot Password'
                        : state.currentStep == 1
                        ? 'Verify OTP'
                        : 'Reset Password',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: _getTextColor(context),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.currentStep == 0
                        ? 'Enter your email to receive a reset link'
                        : state.currentStep == 1
                        ? 'We sent a code to your email'
                        : 'Create a new password for your account',
                    style: TextStyle(
                      fontSize: 16,
                      color: _getSubtitleColor(context),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (state.currentStep == 1) ...[
                    const SizedBox(height: 8),
                    Text(
                      state.email ?? _emailController.text,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),

                  // Step Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index <= state.currentStep
                                  ? theme.colorScheme.primary
                                  : _getDividerColor(context),
                            ),
                            child: Center(
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                  color: index <= state.currentStep
                                      ? Colors.white
                                      : _getSubtitleColor(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (index < 2)
                            Container(
                              width: 40,
                              height: 2,
                              color: index < state.currentStep
                                  ? theme.colorScheme.primary
                                  : _getDividerColor(context),
                            ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 40),

                  // Dynamic content based on current step
                  if (state.currentStep == 0) _buildEmailStep(theme),
                  if (state.currentStep == 1) _buildOtpStep(theme),
                  if (state.currentStep == 2) _buildPasswordStep(theme),

                  const SizedBox(height: 32),

                  // Continue/Reset Button
                  Container(
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
                      height: 60,
                      onTap: state.isLoading ? (){} : _handleContinue,
                      width: double.infinity,
                      child: state.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        state.currentStep == 2 ? 'Reset Password' : 'Continue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Back to Login
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      label: Text(
                        'Back to login',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailStep(ThemeData theme) {
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              brightness == Brightness.dark ? 0.2 : 0.04,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _emailController,
        style: TextStyle(
          color: _getTextColor(context),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: 'Email Address',
          labelStyle: TextStyle(
            color: _getSubtitleColor(context),
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: _getTextFieldFillColor(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _getDividerColor(context),
              width: 1,
            ),
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.email_outlined,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 16,
          ),
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget _buildOtpStep(ThemeData theme) {
    final brightness = Theme.of(context).brightness;

    return Column(
      children: [
        // 6-Digit OTP Input
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 48,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(context),
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: _getOtpFieldColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _getDividerColor(context),
                      width: 1,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) => _handleOtpInput(value, index),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Resend Code Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive code?",
              style: TextStyle(
                color: _getSubtitleColor(context),
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: _canResendOtp ? _resendOtp : null,
              child: Text(
                'Resend',
                style: TextStyle(
                  color: _canResendOtp
                      ? theme.colorScheme.primary
                      : _getSubtitleColor(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            if (!_canResendOtp) ...[
              const SizedBox(width: 8),
              Text(
                _formatCountdown(),
                style: TextStyle(
                  color: _getSubtitleColor(context),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordStep(ThemeData theme) {
    final brightness = Theme.of(context).brightness;

    return Column(
      children: [
        // New Password
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  brightness == Brightness.dark ? 0.2 : 0.04,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _newPasswordController,
            obscureText: !_isPasswordVisible,
            style: TextStyle(
              color: _getTextColor(context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: 'New Password',
              labelStyle: TextStyle(
                color: _getSubtitleColor(context),
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: _getTextFieldFillColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _getDividerColor(context),
                  width: 1,
                ),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _getSubtitleColor(context),
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Confirm Password
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  brightness == Brightness.dark ? 0.2 : 0.04,
                ),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _confirmPasswordController,
            obscureText: !_isConfirmPasswordVisible,
            style: TextStyle(
              color: _getTextColor(context),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: TextStyle(
                color: _getSubtitleColor(context),
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: _getTextFieldFillColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _getDividerColor(context),
                  width: 1,
                ),
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: _getSubtitleColor(context),
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 20,
                horizontal: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}