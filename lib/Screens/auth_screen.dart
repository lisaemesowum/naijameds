import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:naijameds/dashboard/dashboard_screeen.dart';

class AuthScreen extends StatefulWidget {
  final int? tabIndex;
  final Widget? nextScreen;

  const AuthScreen({
    super.key,
    this.tabIndex,
    this.nextScreen,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // =====================================================================================
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential;

      if (_isLogin) {
        // ================= LOGIN =================

        userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Reload user to get latest email verification status
        await userCredential.user?.reload();

        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          throw FirebaseAuthException(
            code: "user-not-found",
            message: "User not found.",
          );
        }

        if (!user.emailVerified) {
          // Uncomment if you want to resend verification every login attempt.
          // await user.sendEmailVerification();

          await FirebaseAuth.instance.signOut();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.orange,
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                content: const Row(
                  children: [
                    Icon(Icons.email_outlined, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Please verify your email before logging in. Check your inbox or spam folder.",
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return;
        }

        // Navigate only if verified
        if (mounted) {
          if (widget.nextScreen != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => widget.nextScreen!,
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardScreeen(
                  initialIndex: widget.tabIndex ?? 0,
                ),
              ),
            );
          }
        }
      } else {
        // ================= REGISTER =================

        userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = userCredential.user;

        if (user != null) {
          // Save user's name
          await user.updateDisplayName(
            _nameController.text.trim(),
          );

          // Send verification email
          await user.sendEmailVerification();

          // Refresh user info
          await user.reload();
        }

        // Sign out until email is verified
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              content: const Row(
                children: [
                  Icon(Icons.mark_email_read, color: Colors.white),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Account created successfully! Please verify your email before logging in. Check your inbox or spam folder.",
                    ),
                  ),
                ],
              ),
            ),
          );

          // Switch back to login mode
          setState(() {
            _isLogin = true;
          });
        }

        return;
      }
    } on FirebaseAuthException catch (e) {
      String message;

      switch (e.code) {
        case "user-not-found":
        case "wrong-password":
        case "invalid-credential":
          message = "Invalid email or password.";
          break;

        case "email-already-in-use":
          message = "An account with this email already exists.";
          break;

        case "weak-password":
          message = "Password is too weak.";
          break;

        case "invalid-email":
          message = "Please enter a valid email address.";
          break;

        case "too-many-requests":
          message = "Too many attempts. Please try again later.";
          break;

        default:
          message = e.message ?? "Authentication failed.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(message),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  // =========================================================================================


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                _isLogin ? "Welcome Back!" : "Create Account",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2A6074),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLogin
                    ? "Login to consult with our verified pharmacists."
                    : "Join NaijaMeds to get access to professional healthcare.",
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 40),
              if (!_isLogin) ...[
                _buildInputField(
                  controller: _nameController,
                  label: "Full Name",
                  hint: "Enter your full name",
                  icon: Icons.person_outline_rounded,
                  validator: (value) => value!.isEmpty ? "Please enter your name" : null,
                ),
                const SizedBox(height: 20),
              ],
              _buildInputField(
                controller: _emailController,
                label: "Email Address",
                hint: "example@mail.com",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => !value!.contains("@") ? "Enter a valid email" : null,
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _passwordController,
                label: "Password",
                hint: "••••••••",
                icon: Icons.lock_outline_rounded,
                isPassword: true,
                validator: (value) => value!.length < 6 ? "Password too short" : null,
              ),
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Color(0xFF4FB062), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4FB062),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    _isLogin ? "Login" : "Sign Up",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? "Don't have an account? " : "Already have an account? ",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(
                      _isLogin ? "Sign Up" : "Login",
                      style: const TextStyle(
                        color: Color(0xFF2A6074),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Or continue with", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade300)),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSocialBtn("assets/splash/Google__G__logo.svg.png", () {}),
                  _buildSocialBtn("assets/splash/apple_logo.png", () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2A6074)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF4FB062), size: 22),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialBtn(String asset, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 100,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.g_mobiledata, size: 40, color: Colors.grey),
        ),
      ),
    );
  }
}