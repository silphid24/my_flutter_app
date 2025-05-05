import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_flutter_app/config/routes.dart';
import 'package:my_flutter_app/domain/repositories/auth_repository.dart';
import 'package:my_flutter_app/presentation/bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Firebase 로그인 실행
      context.read<AuthBloc>().add(
        EmailLoginRequested(
          _emailController.text.trim(),
          _passwordController.text,
        ),
      );
    }
  }

  void _signInWithGoogle() {
    // Show platform limitation message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('알림'),
          content: const Text('Google 로그인은 웹 플랫폼에서만 지원됩니다. 다른 로그인 방법을 이용해주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );

    // Still attempt to trigger the login flow for testing UI
    context.read<AuthBloc>().add(GoogleLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          // BlocListener에서는 별도 처리 없음 (이미 버튼 상태로 로딩 표시)
        } else if (state is Authenticated) {
          setState(() {
            _isLoading = false; // 인증 상태에서 로딩 상태 해제
          });
          Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        } else if (state is AuthError) {
          setState(() {
            _isLoading = false; // 에러 상태에서 로딩 상태 해제
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is Unauthenticated) {
          setState(() {
            _isLoading = false; // 미인증 상태에서 로딩 상태 해제
          });
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // 앱 로고 및 제목
                Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.hiking,
                        size: 80,
                        color: Color(0xFF1E88E5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Camino de Santiago',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your Pilgrim Companion',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // 로그인 폼
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Login',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      const SizedBox(height: 24),

                      // 이메일 입력 필드
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 비밀번호 입력 필드
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 8),

                      // 비밀번호 찾기 링크
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // 비밀번호 찾기 화면으로 이동
                          },
                          child: const Text('Forgot Password?'),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 로그인 버튼
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Login'),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 소셜 로그인 옵션
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or login with',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 24),

                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final bool isGoogleLoading = state is AuthLoading;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Google 로그인 버튼
                              _socialLoginButton(
                                icon: Icons.g_mobiledata,
                                label: 'Google',
                                isLoading: isGoogleLoading,
                                onPressed:
                                    isGoogleLoading ? null : _signInWithGoogle,
                              ),

                              // Apple 로그인 버튼
                              _socialLoginButton(
                                icon: Icons.apple,
                                label: 'Apple',
                                onPressed: () {
                                  // Apple 로그인 로직
                                },
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // 회원 가입 링크
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRoutes.signup);
                            },
                            child: const Text(
                              'Sign Up',
                              style: TextStyle(
                                color: Color(0xFF1E88E5),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialLoginButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    bool isLoading = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon:
          isLoading
              ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: const BorderSide(color: Colors.grey),
      ),
    );
  }
}
