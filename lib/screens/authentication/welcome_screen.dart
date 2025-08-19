import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/wel.png',
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(36, 14, 36, 64),
                child: FadeTransition(
                  opacity: _fadeIn,
                  child: SlideTransition(
                    position: _slideIn,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        _buildWelcomeMessage(),
                        const Spacer(),
                        _buildSignUpButton(context),
                        const SizedBox(height: 14),
                        _buildLoginButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA).withOpacity(0.7),
        borderRadius: BorderRadius.circular(46),
      ),
      child: Column(
        children: [
          Text(
            'Welcome to PlanIt',
            style: TextStyle(
              fontSize: 32,
              color: Colors.orange[400],
              fontFamily: 'poppins',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          const Text(
            'Have the event of your dreams without giving up on your dreams',
            style: TextStyle(fontSize: 24, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'All your event planning needs in one place',
            style: TextStyle(fontSize: 24, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/signup');
      },
      child: Container(
        width: 231,
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
        ),
        child: const Text(
          'Sign up',
          style: TextStyle(
              fontSize: 16,
              color: Color(0xFF18181B),
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/login');
      },
      child: Container(
        width: 231,
        padding: const EdgeInsets.symmetric(horizontal: 64, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFB923C).withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
        ),
        child: const Text('Login',
            style: TextStyle(
                fontSize: 16,
                color: Color(0xFF18181B),
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
      ),
    );
  }
}
