import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

void main() {
  runApp(const PremodaApp());
}

class PremodaApp extends StatelessWidget {
  const PremodaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Premoda',
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Premoda_BG.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            
            // Dark overlay
            Container(
              height: screenHeight,
              width: screenWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            
            // PREMODA title at top
            Positioned(
              top: screenHeight * 0.08,
              left: 0,
              right: 0,
              child: Text(
                'PREMODA',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 8,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Sign up form container - adaptive to keyboard
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: screenWidth * 0.84,
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4), // Lighter container
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // SIGN UP title
                    Text(
                      'SIGN UP',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.025),
                    
                    // Name field
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Name',
                      icon: Icons.person_outline,
                      screenWidth: screenWidth,
                    ),
                    
                    SizedBox(height: screenHeight * 0.015),
                    
                    // Email field
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      screenWidth: screenWidth,
                    ),
                    
                    SizedBox(height: screenHeight * 0.015),
                    
                    // Password field
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      screenWidth: screenWidth,
                    ),
                    
                    SizedBox(height: screenHeight * 0.015),
                    
                    // Confirm Password field
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hintText: 'Confirm Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscureConfirmPassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      screenWidth: screenWidth,
                    ),
                    
                    SizedBox(height: screenHeight * 0.01),
                    
                    // Terms and Privacy text
                    Text(
                      'By signing up you agree to our Terms and conditions and Privacy Policy',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.025,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: screenHeight * 0.025),
                    
                    // Sign up button
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.055,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to home screen after successful sign up
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A574), // Brown color from screenshot
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Sign up',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                    
                    // OR divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                    
                    // Continue with Facebook button
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.045,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement Facebook login
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2), // Facebook blue
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.facebook, size: 18),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Continue with Facebook',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.032,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.01),
                    
                    // Continue with Google button
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.045,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement Google login
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipOval(
                              child: Container(
                                width: 18,
                                height: 18,
                                color: Colors.white,
                                child: Image.asset(
                                  'assets/images/Google__G__logo.svg.png',
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to gradient if image not found
                                    return Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red,
                                            Colors.yellow,
                                            Colors.green,
                                            Colors.blue,
                                          ],
                                          stops: [0.25, 0.5, 0.75, 1.0],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'G',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Continue with Google',
                                style: GoogleFonts.poppins(
                                  fontSize: screenWidth * 0.032,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
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
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required double screenWidth,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: GoogleFonts.poppins(
          fontSize: screenWidth * 0.035,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: screenWidth * 0.035,
            color: Colors.grey.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey.withValues(alpha: 0.7),
            size: 18,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.withValues(alpha: 0.7),
                    size: 18,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
  
  Widget _buildBackgroundItems(double screenWidth, double screenHeight) {
    return Stack(
      children: [
        // Same background items as welcome screen
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: screenWidth * 0.4,
            height: screenHeight * 0.2,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A574),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: screenHeight * 0.08,
          right: screenWidth * 0.05,
          child: Transform.rotate(
            angle: 0.1,
            child: Container(
              width: screenWidth * 0.25,
              height: screenHeight * 0.12,
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6D3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: screenHeight * 0.15,
          right: -screenWidth * 0.05,
          child: Container(
            width: screenWidth * 0.35,
            height: screenHeight * 0.25,
            decoration: const BoxDecoration(
              color: Color(0xFF5C9EAD),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Stack(
              children: [
                ...List.generate(8, (index) => Positioned(
                  bottom: 0,
                  left: (index * 8.0) + 10,
                  child: Container(
                    width: 3,
                    height: 25,
                    color: const Color(0xFF4A8291),
                  ),
                )),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: screenHeight * 0.1,
          left: screenWidth * 0.05,
          child: Container(
            width: screenWidth * 0.3,
            height: screenHeight * 0.08,
            decoration: BoxDecoration(
              color: const Color(0xFFB8956A),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: screenHeight * 0.42,
          left: screenWidth * 0.25,
          right: screenWidth * 0.25,
          child: Container(
            height: screenHeight * 0.2,
            decoration: BoxDecoration(
              color: const Color(0xFFE8A87C),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Premoda_BG.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            
            // Dark overlay
            Container(
              height: screenHeight,
              width: screenWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            
            // PREMODA title at top
            Positioned(
              top: screenHeight * 0.08,
              left: 0,
              right: 0,
              child: Text(
                'PREMODA',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 8,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Log in form container - adaptive to keyboard
            Center(
              child: SingleChildScrollView(
                child: Container(
                  width: screenWidth * 0.84,
                  margin: EdgeInsets.symmetric(vertical: screenHeight * 0.05),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4), // Lighter container
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    // LOG IN title
                    Text(
                      'LOG IN',
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.06,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.025),
                    
                    // Email field
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      screenWidth: screenWidth,
                    ),
                    
                    SizedBox(height: screenHeight * 0.015),
                    
                    // Password field
                    _buildTextField(
                      controller: _passwordController,
                      hintText: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      screenWidth: screenWidth,
                    ),
                    
                    SizedBox(height: screenHeight * 0.015),
                    
                    // Forgot Password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement forgot password
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Forgot password functionality coming soon!'),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.03,
                            color: Colors.white.withValues(alpha: 0.8),
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.025),
                    
                    // Log in button
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.055,
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to home screen after successful login
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4A574), // Brown color from screenshot
                          foregroundColor: Colors.white,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Text(
                          'Log in',
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                    
                    // OR divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'or',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: screenWidth * 0.035,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                    
                    // Continue with Facebook button
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.045,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement Facebook login
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1877F2), // Facebook blue
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.facebook, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'Continue with Facebook',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.032,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.01),
                    
                    // Continue with Google button
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.045,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement Google login
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Google logo with proper asset image
                            ClipOval(
                              child: Container(
                                width: 18,
                                height: 18,
                                color: Colors.white,
                                child: Image.asset(
                                  'assets/images/Google__G__logo.svg.png',
                                  width: 16,
                                  height: 16,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to gradient if image not found
                                    return Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.red,
                                            Colors.yellow,
                                            Colors.green,
                                            Colors.blue,
                                          ],
                                          stops: [0.25, 0.5, 0.75, 1.0],
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'G',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Continue with Google',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.032,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.025),
                    
                    // Don't have an account? Sign up link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.032,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpScreen()),
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.032,
                                color: const Color(0xFFD4A574),
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFFD4A574),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required double screenWidth,
    TextInputType? keyboardType,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: GoogleFonts.poppins(
          fontSize: screenWidth * 0.035,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(
            fontSize: screenWidth * 0.035,
            color: Colors.grey.withValues(alpha: 0.7),
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey.withValues(alpha: 0.7),
            size: 18,
          ),
          suffixIcon: isPassword
              ? IconButton(
                  onPressed: onToggleVisibility,
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.withValues(alpha: 0.7),
                    size: 18,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
  
  Widget _buildBackgroundItems(double screenWidth, double screenHeight) {
    return Stack(
      children: [
        // Same background items as welcome screen
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: screenWidth * 0.4,
            height: screenHeight * 0.2,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A574),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: screenHeight * 0.08,
          right: screenWidth * 0.05,
          child: Transform.rotate(
            angle: 0.1,
            child: Container(
              width: screenWidth * 0.25,
              height: screenHeight * 0.12,
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6D3),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: screenHeight * 0.15,
          right: -screenWidth * 0.05,
          child: Container(
            width: screenWidth * 0.35,
            height: screenHeight * 0.25,
            decoration: const BoxDecoration(
              color: Color(0xFF5C9EAD),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Stack(
              children: [
                ...List.generate(8, (index) => Positioned(
                  bottom: 0,
                  left: (index * 8.0) + 10,
                  child: Container(
                    width: 3,
                    height: 25,
                    color: const Color(0xFF4A8291),
                  ),
                )),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: screenHeight * 0.1,
          left: screenWidth * 0.05,
          child: Container(
            width: screenWidth * 0.3,
            height: screenHeight * 0.08,
            decoration: BoxDecoration(
              color: const Color(0xFFB8956A),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: screenHeight * 0.42,
          left: screenWidth * 0.25,
          right: screenWidth * 0.25,
          child: Container(
            height: screenHeight * 0.2,
            decoration: BoxDecoration(
              color: const Color(0xFFE8A87C),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Container(
        height: screenHeight,
        width: screenWidth,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Premoda_BG.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            
            // Main content overlay
            Container(
              height: screenHeight,
              width: screenWidth,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
            
            // PREMODA title centered on screen
            Center(
              child: Text(
                'PREMODA',
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 3.0,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 8,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // Buttons at the bottom
            Positioned(
              left: screenWidth * 0.08,
              right: screenWidth * 0.08,
              bottom: screenHeight * 0.08,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Get Started button
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.065,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        foregroundColor: Colors.black,
                        elevation: 8,
                        shadowColor: Colors.black.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Get Started',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: screenHeight * 0.015),
                  
                  // Log In button
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.065,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LogInScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.7),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Log In',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBackgroundItems(double screenWidth, double screenHeight) {
    return Stack(
      children: [
        // Top left - Woven basket and scarf (like in screenshot)
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: screenWidth * 0.4,
            height: screenHeight * 0.2,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A574), // Basket brown
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
          ),
        ),
        
        // Top right - Cream colored box/package
        Positioned(
          top: screenHeight * 0.08,
          right: screenWidth * 0.05,
          child: Transform.rotate(
            angle: 0.1,
            child: Container(
              width: screenWidth * 0.25,
              height: screenHeight * 0.12,
              decoration: BoxDecoration(
                color: const Color(0xFFF5E6D3), // Cream/ivory
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(3, 3),
                  ),
                ],
              ),
            ),
          ),
        ),
        
        // Center - Teal fringe scarf/shawl
        Positioned(
          top: screenHeight * 0.15,
          right: -screenWidth * 0.05,
          child: Container(
            width: screenWidth * 0.35,
            height: screenHeight * 0.25,
            decoration: const BoxDecoration(
              color: Color(0xFF5C9EAD), // Teal like in screenshot
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: Stack(
              children: [
                // Simulate fringe pattern
                ...List.generate(8, (index) => Positioned(
                  bottom: 0,
                  left: (index * 8.0) + 10,
                  child: Container(
                    width: 3,
                    height: 25,
                    color: const Color(0xFF4A8291),
                  ),
                )),
              ],
            ),
          ),
        ),
        
        // Bottom left - Brown shoes/sandals
        Positioned(
          bottom: screenHeight * 0.1,
          left: screenWidth * 0.05,
          child: Container(
            width: screenWidth * 0.3,
            height: screenHeight * 0.08,
            decoration: BoxDecoration(
              color: const Color(0xFFB8956A), // Brown leather
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(2, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Shoe sole patterns
                Container(
                  width: 35,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B7355),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  width: 35,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B7355),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Center-bottom - Orange/coral handbag like in screenshot
        Positioned(
          bottom: screenHeight * 0.42,
          left: screenWidth * 0.25,
          right: screenWidth * 0.25,
          child: Container(
            height: screenHeight * 0.2,
            decoration: BoxDecoration(
              color: const Color(0xFFE8A87C), // Coral/salmon color from screenshot
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Handbag handle
                Container(
                  width: 40,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4956A),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Handbag body details
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4956A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFB8845A),
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
