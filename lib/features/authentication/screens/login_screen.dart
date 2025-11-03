import 'package:flutter/material.dart';
import 'package:AutoAir/api/api_service.dart';
import 'package:AutoAir/utils/app_assets.dart';
import 'package:AutoAir/widgets/app_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiService = ApiService();

  bool _isPasswordObscured = true;
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      await _apiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/device_list', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Image.asset(AppAssets.logo, height: 80),
                    const SizedBox(height: 16),
                    Text(
                      'AutoAir',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      'Log in Account',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: isDarkMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      decoration: _buildInputDecoration('Email', isDarkMode),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _isPasswordObscured,
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      decoration: _buildInputDecoration('Password', isDarkMode).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordObscured
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordObscured = !_isPasswordObscured;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: _buildButtonStyle(isDarkMode),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text('Log in'),
                    ),
                    const SizedBox(height: 24),
                    _buildRememberMeRow(isDarkMode),
                    const SizedBox(height: 32),
                    _buildDividerWithText(isDarkMode),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: _buildButtonStyle(isDarkMode),
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil('/signup', (route) => false);
                      },
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, bool isDarkMode) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
      filled: true,
      fillColor: isDarkMode ? Colors.grey.shade900.withOpacity(0.5) : Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade400 : Colors.deepPurple),
      ),
    );
  }

  ButtonStyle _buildButtonStyle(bool isDarkMode) {
    return ElevatedButton.styleFrom(
      backgroundColor: isDarkMode ? Colors.grey.shade800.withOpacity(0.8) : Colors.white,
      foregroundColor: isDarkMode ? Colors.white : Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      elevation: isDarkMode ? 2 : 4,
      shadowColor: Colors.black.withOpacity(0.2),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildRememberMeRow(bool isDarkMode) {
    final textColor = isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
                side: BorderSide(color: textColor),
                activeColor: isDarkMode ? Colors.grey.shade700 : Colors.deepPurple.shade100,
                checkColor: isDarkMode ? Colors.white : Colors.deepPurple,
              ),
            ),
            const SizedBox(width: 8),
            Text('Remember me', style: TextStyle(color: textColor)),
          ],
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/forgot_password');
          },
          child: Text('Forgot Password', style: TextStyle(color: textColor)),
        ),
      ],
    );
  }

  Widget _buildDividerWithText(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Don't have an account?",
            style: TextStyle(color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
