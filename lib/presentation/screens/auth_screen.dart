import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _submit() async {
    if (_isLogin) {
      await _signIn();
    } else {
      await _signUp();
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showMessage('Please fill all fields', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'User not found';
          break;
        case 'wrong-password':
          message = 'Wrong password';
          break;
        case 'invalid-email':
          message = 'Invalid email';
          break;
        default:
          message = 'Login failed';
      }
      _showMessage(message, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUp() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showMessage('Please fill all fields', Colors.orange);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showMessage('Passwords do not match', Colors.red);
      return;
    }

    if (_passwordController.text.length < 6) {
      _showMessage('Password must be at least 6 characters', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        _showMessage('Account created successfully!', Colors.green);
        setState(() {
          _isLogin = true;
          _emailController.clear();
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email already in use';
          break;
        case 'weak-password':
          message = 'Password too weak';
          break;
        case 'invalid-email':
          message = 'Invalid email';
          break;
        default:
          message = 'Sign up failed';
      }
      _showMessage(message, Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 45,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 32),

              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              Text(
                _isLogin
                    ? 'Sign in to manage your finances'
                    : 'Sign up to start tracking your expenses',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLogin = true;
                          _clearFields();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _isLogin
                                  ? Colors.green.shade700
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _isLogin
                                ? Colors.green.shade700
                                : Colors.grey.shade400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isLogin = false;
                          _clearFields();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: !_isLogin
                                  ? Colors.green.shade700
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: !_isLogin
                                ? Colors.green.shade700
                                : Colors.grey.shade400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'name@example.com',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: Colors.grey.shade500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green.shade700,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: '••••••••',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade500,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey.shade500,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Colors.green.shade700,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),

              if (!_isLogin) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: '••••••••',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    labelStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: Colors.grey.shade500,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade500,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Colors.green.shade700,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ],

              if (_isLogin) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _showMessage(
                        'Reset password link sent to your email',
                        Colors.blue,
                      );
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                        _isLogin ? 'Login →' : 'Sign Up →',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}