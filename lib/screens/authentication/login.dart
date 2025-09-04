import 'package:flutter/material.dart';
import 'package:planit_mt/providers/user_provider.dart';
import 'package:planit_mt/providers/vendor_provider.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/firestore_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      _showError('Please enter username/phone and password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final vendorProvider = context.read<VendorProvider>();
      final userProvider = context.read<UserProvider>();
      final firestoreService = FirestoreService();

      // 1. Find user's email and role from Firestore
      final userInfo = await firestoreService.findUserEmailAndRole(identifier);

      // ================== התיקון כאן ==================
      // We now perform a more robust check to ensure both email and role exist and are valid strings.
      if (userInfo == null ||
          userInfo['email'] is! String ||
          userInfo['role'] is! String) {
        _showError(
            "User not found or data is corrupted. Please check your details or sign up.");
        return;
      }
      // ===============================================

      final email = userInfo['email'] as String;
      final role = userInfo['role'] as String;

      // 2. Perform sign-in with Firebase Auth
      final error = await authProvider.signIn(email: email, password: password);

      if (!mounted) return;
      if (error != null) {
        _showError(error);
        return;
      }

      // This should not be null after a successful sign-in
      final uid = authProvider.firebaseUser?.uid;
      if (uid == null) {
        _showError("Authentication failed, could not get user ID.");
        return;
      }

      // 3. Load the full user/vendor/admin model and navigate to the correct home screen
      switch (role) {
        case 'admin':
          // For admin, we can just navigate. The AdminProvider loads its own data.
          Navigator.pushReplacementNamed(context, '/adminHome');
          break;
        case 'vendor':
          final vendorModel = await firestoreService.getVendor(uid);
          if (!mounted) return;
          if (vendorModel != null) {
            vendorProvider.setVendor(vendorModel);
            Navigator.pushReplacementNamed(context, '/vendorHome');
          } else {
            _showError("Could not load vendor profile.");
          }
          break;
        default: // 'user'
          final userModel = await firestoreService.getUser(uid);
          if (!mounted) return;
          if (userModel != null) {
            userProvider.setUser(userModel);
            Navigator.pushReplacementNamed(context, '/userHome');
          } else {
            _showError("Could not load user profile.");
          }
      }
    } catch (e) {
      if (mounted) {
        _showError("An unexpected error occurred: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Function to show the password reset dialog
  Future<void> _showForgotPasswordDialog() async {
    // Check if the current identifier is an email and use it as the initial value
    final initialEmail = _identifierController.text.trim().contains('@')
        ? _identifierController.text.trim()
        : '';
    final emailController = TextEditingController(text: initialEmail);

    // This is safe because the dialog is built within the same context
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email address',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();
                if (email.isEmpty) {
                  // You can add an error inside the dialog if needed
                  return;
                }

                // Capture context-dependent objects BEFORE the async gap.
                final authProvider = context.read<AuthProvider>();
                final navigator = Navigator.of(dialogContext);
                final messenger = ScaffoldMessenger.of(context);

                final result = await authProvider.resetPassword(email: email);

                // Now it's safe to use the captured objects after the await.
                if (!mounted) return;

                navigator.pop();

                if (result == null) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent to your email.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  // _showError already has a mounted check, so this is safe.
                  _showError(result);
                }
              },
              child: const Text('Send Reset Link'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // The UI remains unchanged
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/back1.png', fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  const Text("WELCOME BACK",
                      style: TextStyle(
                          fontSize: 24,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400)),
                  const SizedBox(height: 5),
                  const Text("Log In to your Account",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _identifierController,
                    decoration: const InputDecoration(
                      labelText: 'Username or Phone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: const Text(
                            'CONTINUE',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text('Forgot Password?'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: const Text("Don't have an account? Sign Up"),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
