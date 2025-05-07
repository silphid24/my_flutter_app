import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/presentation/router/app_router.dart';
import 'package:my_flutter_app/domain/repositories/auth_repository.dart';
import 'package:my_flutter_app/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:my_flutter_app/data/repositories/auth_repository_impl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _autoLogin = false;

  @override
  void initState() {
    super.initState();
    _loadAutoLoginSettings();
  }

  Future<void> _loadAutoLoginSettings() async {
    try {
      final authRepository = context.read<AuthRepository>();
      final isAutoLoginEnabled = await authRepository.isAutoLoginEnabled();
      setState(() {
        _autoLogin = isAutoLoginEnabled;
      });
    } catch (e) {
      debugPrint('Auto login settings load error: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    final l10n = AppLocalizations.of(context)!;

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${l10n.emailHint} and ${l10n.passwordHint} are required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Save auto login settings
    if (_autoLogin) {
      context.read<AuthRepository>().setAutoLogin(
            true,
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    }

    // Execute login
    context.read<AuthBloc>().add(
          EmailLoginRequested(
            _emailController.text.trim(),
            _passwordController.text,
          ),
        );
  }

  void _adminLogin() {
    setState(() {
      _isLoading = true;
    });

    try {
      // Create admin user object
      final adminUser = DummyUser(
        id: 'admin-id',
        email: 'admin@camino.com',
        displayName: 'Administrator',
        photoURL: null,
      );

      // Send login success event to AuthBloc
      context.read<AuthBloc>().add(LoggedIn(adminUser));

      // Save auto login settings (optional)
      if (_autoLogin) {
        context.read<AuthRepository>().setAutoLogin(
              true,
              email: 'admin@camino.com',
              password: 'admin123',
            );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Admin login error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _signInWithGoogle() {
    // Execute Google login
    context.read<AuthBloc>().add(GoogleLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          // No additional handling in BlocListener (already shown in button)
        } else if (state is Authenticated) {
          setState(() {
            _isLoading = false;
          });
          context.go(AppRoutes.home);
        } else if (state is AuthError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is Unauthenticated) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3366CC),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title
                  Text(
                    l10n.loginTitle,
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  // Welcome message
                  Text(
                    l10n.welcomeMessage,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  // Email input field
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: l10n.emailHint,
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3366CC)),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  // Password input field
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: l10n.passwordHint,
                      hintStyle: const TextStyle(color: Colors.grey),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF3366CC)),
                      ),
                    ),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 8),
                  // Auto login checkbox
                  Row(
                    children: [
                      Checkbox(
                        value: _autoLogin,
                        onChanged: (value) {
                          setState(() {
                            _autoLogin = value ?? false;
                          });
                          // Delete saved info when auto login is disabled
                          if (!(value ?? true)) {
                            context.read<AuthRepository>().setAutoLogin(false);
                          }
                        },
                      ),
                      Text(
                        l10n.autoLoginLabel,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Login button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3366CC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              l10n.loginButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Admin login button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : _adminLogin,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3366CC),
                        side: const BorderSide(color: Color(0xFF3366CC)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF3366CC),
                              ),
                            )
                          : Text(
                              l10n.adminLoginButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider(color: Colors.grey)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          l10n.orLabel,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ),
                      const Expanded(child: Divider(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Social login buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google login
                      _buildSocialLoginButton(
                        color: const Color(0xFFF2F2F2),
                        onPressed: _signInWithGoogle,
                        child: const Text(
                          'G',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Kakao login
                      _buildSocialLoginButton(
                        color: const Color(0xFFFFE600),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kakao login is not supported yet'),
                            ),
                          );
                        },
                        child: const Text(
                          'K',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Naver login
                      _buildSocialLoginButton(
                        color: const Color(0xFF00CC00),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Naver login is not supported yet'),
                            ),
                          );
                        },
                        child: const Text(
                          'N',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Sign up link
                  GestureDetector(
                    onTap: () {
                      context.go(AppRoutes.signup);
                    },
                    child: Text(
                      l10n.dontHaveAccount,
                      style: const TextStyle(
                          color: Color(0xFF3366CC), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButton({
    required Color color,
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(child: child),
      ),
    );
  }
}
